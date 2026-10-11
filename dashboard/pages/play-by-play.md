---
title: Play-by-play
---

```sql seasons
select distinct season from nfl.play_tendencies order by season desc
```

<Dropdown name=season data={seasons} value=season title="Season" />

## Pass rate by down and distance

```sql pr
select down, distance_bucket, sum(plays) as plays, sum(pass_rate * plays) / sum(plays) as pass_rate,
  sum(epa_play * plays) / sum(plays) as epa_play
from nfl.play_tendencies where season = ${inputs.season.value} group by down, distance_bucket order by down, distance_bucket
```

<DataTable data={pr}>
  <Column id=down /><Column id=distance_bucket /><Column id=plays />
  <Column id=pass_rate fmt=pct1 contentType=colorscale />
  <Column id=epa_play fmt=num3 />
</DataTable>

## Team pass rate over expected by game state

```sql proe
select team, score_state, sum(plays) as plays, sum(pass_rate_over_expected * plays) / sum(plays) as pass_rate_over_expected
from nfl.play_tendencies where season = ${inputs.season.value} group by team, score_state having sum(plays) > 20
```

<Heatmap data={proe} x=score_state y=team value=pass_rate_over_expected valueFmt=pct1 title="Pass rate over expected" />

## Fourth-down aggressiveness

```sql fd
select team, sum(fourth_downs) as fourth_downs, sum(went_for_it) as went_for_it,
  sum(went_for_it) * 1.0 / sum(fourth_downs) as go_rate,
  sum(conversions) * 1.0 / nullif(sum(went_for_it), 0) as conversion_rate
from nfl.fourth_down where season = ${inputs.season.value} group by team order by go_rate desc
```

<BarChart data={fd} x=team y=go_rate yFmt=pct0 sort=false swapXY=true chartAreaHeight=700 title="4th-down go-for-it rate by team" />

```sql fd_zone
select distance_bucket, field_zone, sum(fourth_downs) as fourth_downs, sum(went_for_it) * 1.0 / sum(fourth_downs) as go_rate
from nfl.fourth_down where season = ${inputs.season.value} group by all
```

<Heatmap data={fd_zone} x=distance_bucket y=field_zone value=go_rate valueFmt=pct0 title="Go-for-it rate by distance and field zone" />

## Red zone and third down

```sql sit
select team, rz_td_rate, rz_td_rate_allowed, third_down_rate, third_down_rate_allowed
from nfl.team_situational where season = ${inputs.season.value} order by rz_td_rate desc
```

<DataTable data={sit} rows=32>
  <Column id=team />
  <Column id=rz_td_rate fmt=pct1 title="RZ TD %" />
  <Column id=rz_td_rate_allowed fmt=pct1 title="RZ TD % allowed" />
  <Column id=third_down_rate fmt=pct1 title="3rd down %" />
  <Column id=third_down_rate_allowed fmt=pct1 title="3rd down % allowed" />
</DataTable>
