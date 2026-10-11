# nfl_platform

Free, laptop-independent pipeline: nflverse-data releases -> DuckDB/MotherDuck -> dbt marts.

## Local (dev)
```
uv sync
uv run python -m pipeline.cli --seasons 2026          # loads warehouse/nfl.duckdb
cd dbt; uv run dbt build --profiles-dir .
uv run python ../analysis_example.py
```
Change detection uses each release's `timestamp.json` (no GitHub API quota); missing assets (e.g. `pbp_participation_2026`) are skipped.
Season data is replaced per asset, so stat corrections overwrite cleanly. Add history with `--seasons 1999-2025`.

## Cloud (free)
1. Create a public GitHub repo from this folder and a free MotherDuck account; create database `nfl`.
2. Add repo secret `MOTHERDUCK_TOKEN`.
3. `.github/workflows/refresh.yml` runs Wed ~07:00 and Sat ~07:00 AEDT (Sep-Feb), monthly off-season, or manually (Actions > refresh > Run workflow, with `seasons` for backfills).
4. Query in the MotherDuck UI, or locally: `duckdb md:nfl`.

## Models
- `marts.mart_player_streaks`: threshold streaks (edit rules in the model), incl. `hit_every_game`
- `marts.mart_season_leaders`: top 25 per stat per season

## Built
- Loader with retries, transactional loads, bad-file rejection and an error log (`ops.load_errors`).
- dbt staging + 19 marts (team, player, league, play-by-play, injuries, depth charts).
- Evidence dashboard in `dashboard/` (deployed to GitHub Pages by `refresh.yml`).
- Scheduled refresh: Wed and Sat ~07:00 AEDT in-season, monthly off-season; manual run via Actions > Run workflow.

## Backfill history
Run the workflow manually with `seasons=1999-2025` once the 2026 run succeeds.

## Still to do
Notebooks, extra marts (FTN, officials, draft/contracts), PR CI workflow.
