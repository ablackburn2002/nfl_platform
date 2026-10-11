select season, week, season_type, 'passing' as ngs_type, player_gsis_id as gsis_id, player_display_name as player_name, team_abbr as team,
    attempts, avg_time_to_throw, aggressiveness, avg_intended_air_yards, avg_completed_air_yards,
    completion_percentage_above_expectation as cpoe, expected_completion_percentage, passer_rating
from {{ source('raw', 'ngs_passing') }}
union all by name
select season, week, season_type, 'receiving' as ngs_type, player_gsis_id as gsis_id, player_display_name as player_name, team_abbr as team,
    avg_separation, avg_cushion, avg_yac_above_expectation
from {{ source('raw', 'ngs_receiving') }}
union all by name
select season, week, season_type, 'rushing' as ngs_type, player_gsis_id as gsis_id, player_display_name as player_name, team_abbr as team,
    efficiency, rush_yards_over_expected_per_att
from {{ source('raw', 'ngs_rushing') }}
