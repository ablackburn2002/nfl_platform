---
title: Teams
---

```sql seasons
select distinct season from nfl.team_season where net_epa_play is not null order by season desc
```

<Dropdown name=season data={seasons} value=season title="Season" />

## Standings and efficiency

```sql standings
select team, team_division as division, wins, losses, ties, points_for, points_against, point_diff,
  off_epa_play, def_epa_play, net_epa_play, off_success_rate, pass_rate, explosive_rate,
  ats_wins, ats_losses, overs, unders
from nfl.team_season
where season = ${inputs.season.value}
order by net_epa_play desc
```

<DataTable data={standings} rows=32 search=true>
  <Column id=team />
  <Column id=division />
  <Column id=wins />
  <Column id=losses />
  <Column id=point_diff />
  <Column id=off_epa_play fmt=num3 contentType=colorscale />
  <Column id=def_epa_play fmt=num3 contentType=colorscale colorScale=negative />
  <Column id=net_epa_play fmt=num3 contentType=colorscale />
  <Column id=off_success_rate fmt=pct1 />
  <Column id=pass_rate fmt=pct1 />
  <Column id=explosive_rate fmt=pct1 />
  <Column id=ats_wins title="ATS W" />
  <Column id=ats_losses title="ATS L" />
  <Column id=overs />
  <Column id=unders />
</DataTable>

## Offense vs defense

<ScatterPlot data={standings} x=off_epa_play y=def_epa_play series=team xAxisTitle="Offense EPA/play" yAxisTitle="Defense EPA/play allowed (lower is better)" yMin=-0.3 />

## Rolling form (4-game net EPA/play)

```sql form
select week, team, net_epa_play_l4 from nfl.team_game_efficiency where season = ${inputs.season.value} order by week
```

<LineChart data={form} x=week y=net_epa_play_l4 series=team />

## Strength of schedule

```sql sos
select team, avg_opp_win_pct, avg_opp_net_epa from nfl.team_sos where season = ${inputs.season.value} order by avg_opp_win_pct desc
```

<DataTable data={sos} rows=32>
  <Column id=team />
  <Column id=avg_opp_win_pct fmt=pct1 contentType=colorscale />
  <Column id=avg_opp_net_epa fmt=num3 />
</DataTable>

## Betting: results against the spread

```sql ats
select team, count(*) as games, sum((ats_result='cover')::int) as covers, sum((ats_result='no_cover')::int) as misses,
  avg(margin) as avg_margin
from nfl.team_game_results where season = ${inputs.season.value} and game_type = 'REG'
group by team order by covers desc
```

<BarChart data={ats} x=team y=covers swapXY=true />

## Team streaks

```sql streaks
select team, streak_type, current_streak, longest_streak from nfl.team_streaks
where season = ${inputs.season.value} and current_streak > 0 order by current_streak desc limit 20
```

<DataTable data={streaks} />
