---
title: Injuries
---

## Current injury report

```sql cur
select team, player_name, position, report_status, report_primary_injury, practice_status, fantasy_ppg, avg_offense_snap_pct
from nfl.injury_current
where report_status in ('Out', 'Doubtful', 'Questionable')
order by case report_status when 'Out' then 1 when 'Doubtful' then 2 else 3 end, fantasy_ppg desc nulls last
```

<DataTable data={cur} rows=40 search=true groupBy=report_status />

## Team injury burden

```sql burden
select team, sum(out_or_doubtful) as out_or_doubtful, sum(questionable) as questionable
from nfl.injury_burden
where (season, week) = (select season, max(week) from nfl.injury_burden where season = (select max(season) from nfl.injury_burden) group by season)
group by team order by out_or_doubtful desc
```

<BarChart data={burden} x=team y={['out_or_doubtful','questionable']} type=stacked />

## Injury load over the season

```sql trend
select week, team, sum(out_or_doubtful) as out_or_doubtful from nfl.injury_burden
where season = (select max(season) from nfl.injury_burden) group by all order by week
```

<LineChart data={trend} x=week y=out_or_doubtful series=team />
