select q.season, q.season_type, q.game_id, coalesce(q.week_num, q.game_week) as week, q.team_abb as team,
    q.player_id as espn_id, q.name_display as player_name, p.gsis_id,
    q.qbr_total, q.qbr_raw, q.pts_added, q.qb_plays, q.epa_total, q.qualified
from {{ source('raw', 'qbr_week') }} q
left join {{ ref('stg_players') }} p on p.espn_id = q.player_id::varchar
