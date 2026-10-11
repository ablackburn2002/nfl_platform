-- rushing efficiency by player and run direction from play-by-play
select season, rusher_player_id as player_id, any_value(rusher_player_name) as player_name,
    arg_max(posteam, week) as team,
    count(*) as carries, sum(yards_gained) as yards, avg(yards_gained) as ypc,
    avg(epa) as epa_per_carry, avg(success) as success_rate,
    sum(touchdown * (td_team = posteam)::int) as tds,
    avg((yards_gained >= 10)::int) as explosive_rate,
    avg(case when run_gap = 'guard' then yards_gained end) as ypc_guard,
    avg(case when run_gap = 'tackle' then yards_gained end) as ypc_tackle,
    avg(case when run_gap = 'end' then yards_gained end) as ypc_end
from {{ ref('stg_pbp') }}
where season_type = 'REG' and is_rush = 1 and rusher_player_id is not null
group by season, rusher_player_id
