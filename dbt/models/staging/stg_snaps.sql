select s.game_id, s.season, s.week, s.game_type, s.team, s.opponent, s.player as player_name,
    s.pfr_player_id, p.gsis_id, s.position,
    s.offense_snaps, s.offense_pct, s.defense_snaps, s.defense_pct, s.st_snaps, s.st_pct
from {{ source('raw', 'snap_counts') }} s
left join {{ ref('stg_players') }} p on p.pfr_id = s.pfr_player_id
where s.game_id is not null
