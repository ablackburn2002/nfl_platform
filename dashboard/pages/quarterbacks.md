---
title: Quarterbacks
---

```sql seasons
select distinct season from nfl.qb_season order by season desc
```

<Dropdown name=season data={seasons} value=season title="Season" />

```sql qbs
select player_name, team, games, dropbacks, epa_dropback, total_epa, success_rate, cpoe,
  avg_air_yards, avg_time_to_throw, aggressiveness, avg_qbr, pressure_pct, sacks, interceptions
from nfl.qb_season
where season = ${inputs.season.value} and dropbacks >= 100
order by epa_dropback desc
```

<DataTable data={qbs} rows=40 search=true wrapTitles=true compact=true>
  <Column id=player_name title="QB" />
  <Column id=team title="Team" />
  <Column id=dropbacks title="Dropbacks" />
  <Column id=epa_dropback fmt=num3 contentType=colorscale title="EPA/db" />
  <Column id=cpoe fmt=num1 title="CPOE" />
  <Column id=success_rate fmt=pct1 title="Success" />
  <Column id=avg_time_to_throw fmt=num2 title="TTT" />
  <Column id=aggressiveness fmt=num1 title="Aggr %" />
  <Column id=avg_qbr fmt=num1 title="QBR" />
  <Column id=pressure_pct fmt=num1 title="Press %" />
  <Column id=sacks title="Sacks" />
  <Column id=interceptions title="INT" />
</DataTable>

## EPA per dropback vs CPOE

<ScatterPlot data={qbs} x=cpoe y=epa_dropback tooltipTitle=player_name legend=false xAxisTitle="CPOE" yAxisTitle="EPA per dropback" />

## Time to throw vs aggressiveness

<ScatterPlot data={qbs} x=avg_time_to_throw y=aggressiveness tooltipTitle=player_name legend=false xAxisTitle="Avg time to throw (s)" yAxisTitle="Aggressiveness %" />
