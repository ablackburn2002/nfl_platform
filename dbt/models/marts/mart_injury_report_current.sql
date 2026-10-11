-- latest injury report (most recent season/week available) with player context
with latest as (
    select season, week from {{ ref('stg_injuries') }} order by season desc, week desc limit 1
)
select i.season, i.week, i.team, i.player_name, i.position, i.report_status, i.report_primary_injury,
    i.report_secondary_injury, i.practice_status, i.practice_primary_injury,
    p.headshot,
    ps.fantasy_ppg, ps.avg_offense_snap_pct
from {{ ref('stg_injuries') }} i
join latest l using (season, week)
left join {{ ref('stg_players') }} p on p.gsis_id = i.gsis_id
left join {{ ref('mart_player_season') }} ps on ps.player_id = i.gsis_id and ps.season = i.season
where i.report_status is not null or i.practice_status is not null
