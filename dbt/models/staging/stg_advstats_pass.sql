select p.season, p.week, p.game_id, p.team, p.opponent, p.pfr_player_id, pl.gsis_id, p.pfr_player_name as player_name,
    p.passing_drops, p.passing_drop_pct, p.passing_bad_throws, p.passing_bad_throw_pct,
    p.times_sacked, p.times_blitzed, p.times_hurried, p.times_hit, p.times_pressured, p.times_pressured_pct
from {{ source('raw', 'advstats_week_pass') }} p
left join {{ ref('stg_players') }} pl on pl.pfr_id = p.pfr_player_id
