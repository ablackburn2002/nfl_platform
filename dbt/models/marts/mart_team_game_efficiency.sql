-- team-game offensive and defensive efficiency from play-by-play, with rolling form
with off as (
    select game_id, season, week, posteam as team, defteam as opponent,
           count(*) as off_plays, avg(epa) as off_epa_play, avg(success) as off_success_rate,
           avg(is_pass) as pass_rate,
           avg(case when is_pass = 1 then epa end) as off_epa_pass,
           avg(case when is_rush = 1 then epa end) as off_epa_rush,
           sum(yards_gained) / count(*) as off_yards_play,
           sum(case when explosive then 1 else 0 end) * 1.0 / count(*) as explosive_rate
    from (select *, (is_pass = 1 and yards_gained >= 20) or (is_rush = 1 and yards_gained >= 10) as explosive
          from {{ ref('stg_pbp') }} where is_scrimmage and season_type = 'REG')
    group by all
),
def as (
    select game_id, defteam as team, avg(epa) as def_epa_play, avg(success) as def_success_rate_allowed,
           avg(case when is_pass = 1 then epa end) as def_epa_pass, avg(case when is_rush = 1 then epa end) as def_epa_rush
    from {{ ref('stg_pbp') }} where is_scrimmage and season_type = 'REG'
    group by all
),
joined as (
    select o.*, d.def_epa_play, d.def_success_rate_allowed, d.def_epa_pass, d.def_epa_rush,
           o.off_epa_play - d.def_epa_play as net_epa_play
    from off o join def d on d.game_id = o.game_id and d.team = o.team
)
select *,
    avg(off_epa_play) over (partition by season, team order by week rows between 3 preceding and current row) as off_epa_play_l4,
    avg(def_epa_play) over (partition by season, team order by week rows between 3 preceding and current row) as def_epa_play_l4,
    avg(net_epa_play) over (partition by season, team order by week rows between 3 preceding and current row) as net_epa_play_l4
from joined
