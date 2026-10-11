-- strength of schedule: average opponent quality over games already played
select g.season, g.team,
    avg(o.win_pct) as avg_opp_win_pct,
    avg(o.net_epa_play) as avg_opp_net_epa,
    avg(o.off_epa_play) as avg_opp_off_epa,
    avg(o.def_epa_play) as avg_opp_def_epa
from {{ ref('mart_team_game_results') }} g
join {{ ref('mart_team_season') }} o on o.season = g.season and o.team = g.opponent
where g.game_type = 'REG'
group by all
