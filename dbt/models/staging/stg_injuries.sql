select season, week, game_type, team, gsis_id, full_name as player_name, position,
    report_primary_injury, report_secondary_injury, report_status,
    practice_primary_injury, practice_secondary_injury, practice_status
from {{ source('raw', 'injuries') }}
where gsis_id is not null
qualify row_number() over (partition by season, week, gsis_id order by report_status nulls last) = 1
