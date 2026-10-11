select gsis_id, display_name as player_name, position, position_group, pfr_id, espn_id::varchar as espn_id,
    birth_date, college_name, rookie_season, last_season, latest_team, status, draft_year, draft_round,
    draft_pick, headshot
from {{ source('raw', 'players') }}
where gsis_id is not null
qualify row_number() over (partition by gsis_id order by last_season desc nulls last) = 1
