"""Copy the marts schema into a slim DuckDB file that the Evidence dashboard reads."""
import duckdb
import typer

from pipeline.cli import ROOT

app = typer.Typer(add_completion=False)


@app.command()
def export(target: str = "dev"):
    src = "md:nfl_platform" if target == "prod" else str(ROOT / "warehouse" / "nfl.duckdb")
    out = ROOT / "dashboard" / "sources" / "nfl" / "nfl.duckdb"
    out.unlink(missing_ok=True)
    con = duckdb.connect(str(out))
    con.execute(f"attach '{src}' as src (read_only)" if target != "prod" else f"attach '{src}' as src")
    con.execute("create schema marts")
    tables = [r[0] for r in con.execute(
        "select table_name from information_schema.tables where table_catalog='src' and table_schema='marts'"
    ).fetchall()]
    for t in tables:
        con.execute(f"create table marts.{t} as select * from src.marts.{t}")
    typer.echo(f"exported {len(tables)} tables to {out}")


if __name__ == "__main__":
    app()
