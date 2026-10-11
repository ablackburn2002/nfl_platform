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

## Not yet built
More staging/core/marts (injuries, snaps, NGS, team efficiency), Evidence dashboard, CI workflow.
