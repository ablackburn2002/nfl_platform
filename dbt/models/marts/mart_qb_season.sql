-- quarterback season table from play-by-play, joined with Next Gen Stats season totals and ESPN QBR
with pbp as (
    select season, passer_player_id as gsis_id, any_value(passer_player_name) as player_name,
           arg_max(posteam, week) as team,
           count(distinct game_id) as games,
           count(*) as dropbacks,
           sum((play_type = 'pass' and sack = 0)::int) as attempts,
           sum(complete_pass) as completions,
           sum(sack) as sacks, sum(interception) as interceptions,
           sum(touchdown * (td_team = posteam)::int * is_pass::int) as pass_tds,
           avg(epa) as epa_dropback, sum(epa) as total_epa, avg(success) as success_rate,
           avg(cpoe) as cpoe, avg(air_yards) as avg_air_yards, avg(yards_after_catch) as avg_yac
    from {{ ref('stg_pbp') }}
    where season_type = 'REG' and qb_dropback = 1 and passer_player_id is not null and epa is not null
    group by all
),
ngs as (
    select season, gsis_id, avg_time_to_throw, aggressiveness, avg_intended_air_yards, cpoe as ngs_cpoe, passer_rating
    from {{ ref('stg_ngs') }}
    where ngs_type = 'passing' and week = 0 and season_type = 'REG'
),
qbr as (
    select season, gsis_id, avg(qbr_total) as avg_qbr from {{ ref('stg_qbr_week') }}
    where season_type = 'Regular' or season_type = 'REG' group by all
),
press as (
    select season, gsis_id, sum(times_pressured) as pressures, avg(times_pressured_pct) as pressure_pct,
           sum(times_blitzed) as blitzed, sum(passing_bad_throws) as bad_throws
    from {{ ref('stg_advstats_pass') }} group by all
)
select pbp.*, ngs.avg_time_to_throw, ngs.aggressiveness, ngs.avg_intended_air_yards, ngs.passer_rating,
    qbr.avg_qbr, press.pressures, press.pressure_pct, press.blitzed, press.bad_throws,
    case when pbp.dropbacks >= 100 then rank() over (partition by pbp.season, pbp.dropbacks >= 100 order by pbp.epa_dropback desc) end as epa_rank
from pbp
left join ngs using (season, gsis_id)
left join qbr using (season, gsis_id)
left join press using (season, gsis_id)
