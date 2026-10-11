select game_id, season, game_type, week, gameday::date as gameday, weekday, gametime,
    away_team, away_score, home_team, home_score, result, total, overtime, location,
    away_rest, home_rest, away_moneyline, home_moneyline, spread_line, total_line,
    div_game, roof, surface, temp, wind, away_qb_id, home_qb_id, away_qb_name, home_qb_name,
    away_coach, home_coach, referee, stadium,
    (home_score is not null and away_score is not null) as is_final
from {{ source('raw', 'games') }}
where game_id is not null
