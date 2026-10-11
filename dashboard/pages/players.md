---
title: Players
---

```sql seasons
select distinct season from nfl.player_season order by season desc
```

<Dropdown name=season data={seasons} value=season title="Season" />

## Season leaders

```sql stats
select distinct stat from nfl.season_leaders order by stat
```

<Dropdown name=stat data={stats} value=stat title="Stat" defaultValue="receiving_yards" />

```sql leaders
select rnk, player_name, position, team, games, total
from nfl.season_leaders
where season = ${inputs.season.value} and stat = '${inputs.stat.value}'
order by rnk
```

<DataTable data={leaders} rows=25 />

## Fantasy (PPR) by position

```sql fantasy
select player_name, position, team, games, fantasy_points_ppr, fantasy_ppg, fantasy_pos_rank, avg_offense_snap_pct
from nfl.player_season
where season = ${inputs.season.value} and position in ('QB','RB','WR','TE') and fantasy_pos_rank <= 15
order by position, fantasy_pos_rank
```

<DataTable data={fantasy} rows=60 groupBy=position />

## Receiver efficiency (play-by-play)

```sql rec_eff
select player_name, team, targets, receptions, catch_rate, avg_depth_of_target, avg_yac, epa_per_target, tds
from nfl.receiver_pbp where season = ${inputs.season.value} and targets >= 20 order by epa_per_target desc
```

<DataTable data={rec_eff} rows=25 search=true />
<ScatterPlot data={rec_eff} x=avg_depth_of_target y=epa_per_target series=player_name />

## Rushing efficiency (play-by-play)

```sql rush_eff
select player_name, team, carries, yards, ypc, epa_per_carry, success_rate, explosive_rate, tds
from nfl.rusher_pbp where season = ${inputs.season.value} and carries >= 20 order by epa_per_carry desc
```

<DataTable data={rush_eff} rows=25 search=true />
