---
title: NFL Data Platform
hide_title: true
---

# 🏈 NFL Data Platform

Auto-refreshed twice a week from [nflverse](https://github.com/nflverse/nflverse-data) releases. Built with dbt + DuckDB/MotherDuck.

```sql latest
select max(season) as season,
  (select max(week) from nfl.league_trends where season = (select max(season) from nfl.league_trends)) as week
from nfl.league_trends
```

```sql kpis
select
  (select max(season) from nfl.league_trends) as season,
  (select max(week) from nfl.league_trends where season = (select max(season) from nfl.league_trends)) as week,
  (select count(*) from nfl.team_game_results where season = (select max(season) from nfl.league_trends) and game_type = 'REG') / 2 as games,
  (select avg(points_for) from nfl.team_game_results where season = (select max(season) from nfl.league_trends) and game_type = 'REG') as ppg,
  (select count(*) from nfl.player_streaks where season = (select max(season) from nfl.league_trends) and stat = 'passing_yards_200' and hit_every_game and games_played >= 3) as qb_200
```

<BigValue data={kpis} value=season fmt=id title="Season" />
<BigValue data={kpis} value=week fmt=id title="Latest week" />
<BigValue data={kpis} value=games fmt=num0 title="Games played" />
<BigValue data={kpis} value=ppg fmt=num1 title="Points per team per game" />
<BigValue data={kpis} value=qb_200 fmt=num0 title="QBs with 200+ pass yds every game" />

## Top teams by net EPA per play

```sql top_teams
select team, wins, losses, point_diff, net_epa_play
from nfl.team_season
where season = (select max(season) from nfl.league_trends) and net_epa_play is not null
order by net_epa_play desc limit 10
```

<BarChart data={top_teams} x=team y=net_epa_play swapXY=true sort=false yFmt=num3 title="Net EPA/play (top 10)" />

## Explore

| Page | What's inside |
|---|---|
| [Teams](/teams) | Standings, efficiency, betting results, strength of schedule |
| [League](/league) | Weekly scoring, pass rate and efficiency trends |
| [Quarterbacks](/quarterbacks) | EPA, CPOE, time to throw, QBR, pressure |
| [Players](/players) | Season leaders, receiving and rushing efficiency |
| [Streaks](/streaks) | Players hitting a threshold every game, team win/cover/over streaks |
| [Play-by-play](/play-by-play) | Tendencies, fourth downs, red zone and third down |
| [Injuries](/injuries) | Current report and team injury burden |
