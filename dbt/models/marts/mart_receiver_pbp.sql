-- receiving usage and efficiency by player from play-by-play targets
select season, receiver_player_id as player_id, any_value(receiver_player_name) as player_name,
    arg_max(posteam, week) as team,
    count(*) as targets, sum(complete_pass) as receptions,
    sum(case when complete_pass = 1 then yards_gained else 0 end) as receiving_yards,
    avg(air_yards) as avg_depth_of_target, sum(air_yards) as air_yards,
    avg(case when complete_pass = 1 then yards_after_catch end) as avg_yac,
    avg(epa) as epa_per_target, avg(success) as success_rate,
    sum(complete_pass) * 1.0 / count(*) as catch_rate,
    sum(touchdown * (td_team = posteam)::int) as tds
from {{ ref('stg_pbp') }}
where season_type = 'REG' and is_pass = 1 and receiver_player_id is not null and sack = 0
group by season, receiver_player_id
