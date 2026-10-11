"""nflpipe: load nflverse-data release parquet files into DuckDB / MotherDuck."""
import os
import time
from pathlib import Path

import duckdb
import requests
import typer
import yaml

ROOT = Path(__file__).resolve().parent.parent
REPO = "nflverse/nflverse-data"
API = f"https://api.github.com/repos/{REPO}"
app = typer.Typer(add_completion=False)


def gh_headers():
    h = {"Accept": "application/vnd.github+json"}
    tok = os.environ.get("GITHUB_TOKEN")
    if tok:
        h["Authorization"] = f"Bearer {tok}"
    return h


def get_with_retry(url, **kw):
    for attempt in range(4):
        try:
            r = requests.get(url, timeout=120, **kw)
            if r.status_code == 404:
                return r
            r.raise_for_status()
            return r
        except requests.RequestException:
            if attempt == 3:
                raise
            time.sleep(2 ** attempt * 2)


def release_stamp(tag):
    """Upstream last_updated from the release's timestamp.json (no API quota needed)."""
    r = get_with_retry(f"https://github.com/{REPO}/releases/download/{tag}/timestamp.json")
    return r.json().get("last_updated") if r.status_code == 200 else None


def connect(target):
    if target == "prod":
        boot = duckdb.connect("md:")
        boot.execute("create database if not exists nfl_platform")
        boot.close()
        con = duckdb.connect("md:nfl_platform")
    else:
        (ROOT / "warehouse").mkdir(exist_ok=True)
        con = duckdb.connect(str(ROOT / "warehouse" / "nfl.duckdb"))
    for s in ("raw", "ops"):
        con.execute(f"create schema if not exists {s}")
    con.execute(
        "create table if not exists ops.load_log (tbl varchar, asset varchar, "
        "asset_updated_at varchar, row_count bigint, loaded_at timestamp, primary key (tbl, asset))"
    )
    con.execute(
        "create table if not exists ops.load_errors (tbl varchar, asset varchar, error varchar, logged_at timestamp)"
    )
    return con


def parse_seasons(spec):
    if "-" in spec:
        a, b = spec.split("-")
        return list(range(int(a), int(b) + 1))
    return [int(x) for x in spec.split(",")]


@app.command()
def refresh(
    target: str = typer.Option("dev", help="dev=local duckdb file, prod=MotherDuck (needs MOTHERDUCK_TOKEN)"),
    seasons: str = typer.Option("2026", help="e.g. 2026 or 2024,2025 or 1999-2025"),
    datasets: str = typer.Option("all", help="comma list of table names, or all"),
    full_refresh: bool = typer.Option(False, help="ignore load log and reload everything"),
):
    cfg = yaml.safe_load((ROOT / "pipeline" / "datasets.yaml").read_text())["datasets"]
    wanted = None if datasets == "all" else set(datasets.split(","))
    season_list = parse_seasons(seasons)
    cache = ROOT / "data" / "raw"
    con = connect(target)
    asset_cache = {}
    summary = []
    errors = [0]
    for d in cfg:
        if wanted and d["table"] not in wanted:
            continue
        try:
            if d["tag"] not in asset_cache:
                asset_cache[d["tag"]] = release_stamp(d["tag"])
        except Exception as e:  # one dataset failing must not stop the others
            record_error(con, d["table"], d["tag"], e, summary, errors)
            continue
        upd = asset_cache[d["tag"]]
        units = season_list if d["partition"] == "season" else [None]
        for season in units:
            for pat in d["files"]:
                base = pat.format(season=season) if season else pat
                name = f"{base}.parquet"
                try:
                    status = process_asset(con, d, season, name, upd, cache, full_refresh)
                    summary.append((d["table"], name, status))
                except Exception as e:
                    record_error(con, d["table"], name, e, summary, errors)

    for t, a, s in summary:
        typer.echo(f"{t:<22} {a:<40} {s}")
    if errors[0]:
        typer.echo(f"{errors[0]} dataset(s) failed; see ops.load_errors", err=True)
        raise typer.Exit(1)


def record_error(con, tbl, asset, exc, summary, errors):
    msg = f"{type(exc).__name__}: {exc}"[:500]
    summary.append((tbl, asset, f"ERROR {msg}"))
    errors[0] += 1
    try:
        con.execute("insert into ops.load_errors values (?,?,?,now())", [tbl, asset, msg])
    except Exception:
        pass


def process_asset(con, d, season, name, upd, cache, full_refresh):
    row = con.execute(
        "select asset_updated_at, row_count from ops.load_log where tbl=? and asset=?", [d["table"], name]
    ).fetchone()
    if upd and row and row[0] == upd and not full_refresh:
        return "unchanged"
    dest = cache / d["tag"] / name
    dest.parent.mkdir(parents=True, exist_ok=True)
    resp = get_with_retry(f"https://github.com/{REPO}/releases/download/{d['tag']}/{name}")
    if resp.status_code == 404:
        return "missing upstream, skipped"
    dest.write_bytes(resp.content)
    try:
        p = str(dest).replace("\\", "/")
        n = con.execute("select count(*) from read_parquet(?)", [p]).fetchone()[0]  # fails on corrupt files
        if n == 0:
            raise ValueError("empty file; keeping existing data")
        if row and row[1] and n < 0.5 * row[1] and not full_refresh:
            raise ValueError(f"suspicious shrink {row[1]} -> {n} rows; keeping existing data")
        con.execute("begin")
        try:
            load_parquet(con, d, dest, season, name)
            con.execute("insert or replace into ops.load_log values (?,?,?,?,now())", [d["table"], name, upd, n])
            con.execute("commit")
        except Exception:
            con.execute("rollback")
            raise
    finally:
        dest.unlink(missing_ok=True)
    return f"loaded {n} rows"


def load_parquet(con, d, path, season, name):
    tbl = f"raw.{d['table']}"
    p = str(path).replace("\\", "/")
    src = (
        f"select *, {season if season else 'null'}::integer as _season, "
        f"'{name}' as _source_asset, now() as _loaded_at from read_parquet('{p}')"
    )
    exists = con.execute(
        "select count(*) from information_schema.tables where table_schema='raw' and table_name=?", [d["table"]]
    ).fetchone()[0]
    if not exists or d["partition"] == "full":
        con.execute(f"create or replace table {tbl} as {src}")
    else:
        # reconcile new upstream columns, then replace this season's rows
        con.execute(f"create temp table _stage as {src}")
        cols = {r[0] for r in con.execute(f"describe {tbl}").fetchall()}
        for c, t in [(r[0], r[1]) for r in con.execute("describe _stage").fetchall()]:
            if c not in cols:
                con.execute(f'alter table {tbl} add column "{c}" {t}')
        con.execute(f"delete from {tbl} where _source_asset = ?", [name])
        con.execute(f"insert into {tbl} by name select * from _stage")
        con.execute("drop table _stage")
    return con.execute("select count(*) from read_parquet(?)", [p]).fetchone()[0]


if __name__ == "__main__":
    app()
