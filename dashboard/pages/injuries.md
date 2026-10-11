---
title: Injuries
---

## Current injury report

```sql teams
select 'All' as team union all select distinct team from nfl.injury_current order by 1
```

<Dropdown name=team data={teams} value=team title="Team" defaultValue="All" />

```sql cur
select team, player_name, position, report_status, report_primary_injury, practice_status, fantasy_ppg, avg_offense_snap_pct
from nfl.injury_current
where report_status in ('Out', 'Doubtful', 'Questionable')
  and ('${inputs.team.value}' = 'All' or team = '${inputs.team.value}')
order by case report_status when 'Out' then 1 when 'Doubtful' then 2 else 3 end, fantasy_ppg desc nulls last
```

<DataTable data={cur} rows=25 search=true compact=true wrapTitles=true>
  <Column id=team title="Team" />
  <Column id=player_name title="Player" />
  <Column id=position title="Pos" />
  <Column id=report_status title="Status" />
  <Column id=report_primary_injury title="Injury" />
  <Column id=practice_status title="Practice" />
  <Column id=fantasy_ppg title="Fantasy PPG" fmt=num1 />
  <Column id=avg_offense_snap_pct title="Off snap %" fmt=pct0 />
</DataTable>

## Team injury burden

```sql burden
select team, sum(out_or_doubtful) as out_or_doubtful, sum(questionable) as questionable
from nfl.injury_burden
where season = (select max(season) from nfl.injury_burden)
  and week = (select max(week) from nfl.injury_burden where season = (select max(season) from nfl.injury_burden))
group by team order by out_or_doubtful desc
```

<BarChart data={burden} x=team y={['out_or_doubtful','questionable']} type=stacked sort=false swapXY=true chartAreaHeight=700 />

## Injury load over the season

```sql trend
select week, sum(out_or_doubtful) as out_or_doubtful from nfl.injury_burden
where season = (select max(season) from nfl.injury_burden)
  and ('${inputs.team.value}' = 'All' or team = '${inputs.team.value}')
group by week order by week
```

<LineChart data={trend} x=week y=out_or_doubtful title="Players out or doubtful (selected team, or league total)" />
