-- latest depth chart per team
with latest as (select team, max(dt) as dt from {{ ref('stg_depth_charts') }} group by team)
select d.team, d.pos_grp, d.pos_abb, d.pos_slot, d.pos_rank, d.player_name, d.gsis_id, d.dt
from {{ ref('stg_depth_charts') }} d
join latest l on l.team = d.team and l.dt = d.dt
