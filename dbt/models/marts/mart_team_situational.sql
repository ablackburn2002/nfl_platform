-- red zone and third down efficiency, offense and defense
with rz_drives as (
    select season, game_id, drive, posteam as team, defteam,
           max((yardline_100 <= 20)::int) as reached_rz,
           max((touchdown = 1 and td_team = posteam)::int) as scored_td
    from {{ ref('stg_pbp') }}
    where season_type = 'REG' and posteam is not null and drive is not null and play_type in ('pass', 'run')
    group by all
),
rz as (
    select season, team, sum(reached_rz) as rz_trips, sum(reached_rz * scored_td) as rz_tds from rz_drives group by all
),
rz_def as (
    select season, defteam as team, sum(reached_rz) as rz_trips_faced, sum(reached_rz * scored_td) as rz_tds_allowed
    from rz_drives group by all
),
third as (
    select season, posteam as team, sum(third_down_converted + third_down_failed) as third_downs,
           sum(third_down_converted) as third_conv
    from {{ ref('stg_pbp') }} where season_type = 'REG' and posteam is not null group by all
),
third_def as (
    select season, defteam as team, sum(third_down_converted + third_down_failed) as third_faced,
           sum(third_down_converted) as third_allowed
    from {{ ref('stg_pbp') }} where season_type = 'REG' and defteam is not null group by all
)
select rz.season, rz.team, rz.rz_trips, rz.rz_tds, rz.rz_tds * 1.0 / nullif(rz.rz_trips, 0) as rz_td_rate,
    rz_def.rz_trips_faced, rz_def.rz_tds_allowed, rz_def.rz_tds_allowed * 1.0 / nullif(rz_def.rz_trips_faced, 0) as rz_td_rate_allowed,
    third.third_downs, third.third_conv, third.third_conv * 1.0 / nullif(third.third_downs, 0) as third_down_rate,
    third_def.third_faced, third_def.third_allowed, third_def.third_allowed * 1.0 / nullif(third_def.third_faced, 0) as third_down_rate_allowed
from rz
left join rz_def using (season, team)
left join third using (season, team)
left join third_def using (season, team)
