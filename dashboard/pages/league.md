---
title: League trends
---

```sql seasons
select distinct season from nfl.league_trends order by season desc
```

<Dropdown name=season data={seasons} value=season title="Season" />

```sql trends
select * from nfl.league_trends where season = ${inputs.season.value} order by week
```

## Scoring and results

<LineChart data={trends} x=week y=avg_total_points title="Average total points per game" />
<LineChart data={trends} x=week y=home_win_pct yFmt=pct0 title="Home win %" />

## Style of play

<LineChart data={trends} x=week y=pass_rate yFmt=pct1 title="Pass rate" />
<LineChart data={trends} x={'week'} y={['epa_pass','epa_rush']} title="EPA per play: pass vs rush" />
<LineChart data={trends} x=week y={['sack_rate','int_rate']} yFmt=pct1 title="Sack and interception rate per dropback" />
