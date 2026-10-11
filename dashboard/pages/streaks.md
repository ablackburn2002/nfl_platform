---
title: Streaks
---

```sql seasons
select distinct season from nfl.player_streaks order by season desc
```

<Dropdown name=season data={seasons} value=season title="Season" />

```sql rules
select distinct stat from nfl.player_streaks order by stat
```

<Dropdown name=stat data={rules} value=stat title="Threshold" defaultValue="passing_yards_200" />

## Hit the threshold in every game played

```sql every
select player_name, position, team, games_played, longest_streak, current_streak
from nfl.player_streaks
where season = ${inputs.season.value} and stat = '${inputs.stat.value}' and hit_every_game and games_played >= 3
order by games_played desc, player_name
```

<BigValue data={every} value=player_name agg=count title="Players" />
<DataTable data={every} rows=50 />

## Longest active streaks

```sql active
select player_name, position, team, games_played, games_hit, current_streak, longest_streak
from nfl.player_streaks
where season = ${inputs.season.value} and stat = '${inputs.stat.value}' and current_streak > 0
order by current_streak desc limit 25
```

<DataTable data={active} />
