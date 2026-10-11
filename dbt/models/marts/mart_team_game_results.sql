-- one row per team per game, from the team's perspective, incl. betting outcomes
with sides as (
    select game_id, season, week, game_type, gameday, home_team as team, away_team as opponent, true as is_home,
           home_score as points_for, away_score as points_against,
           -spread_line as team_spread,  -- spread_line is home-team-relative (positive = home favoured)
           total_line, home_moneyline as moneyline, roof, surface, temp, wind, home_qb_name as qb, home_coach as coach, total
    from {{ ref('stg_games') }} where is_final
    union all
    select game_id, season, week, game_type, gameday, away_team, home_team, false,
           away_score, home_score, spread_line, total_line, away_moneyline, roof, surface, temp, wind,
           away_qb_name, away_coach, total
    from {{ ref('stg_games') }} where is_final
)
select *,
    points_for - points_against as margin,
    case when points_for > points_against then 'W' when points_for < points_against then 'L' else 'T' end as result,
    -- spread_line convention: positive means home is favoured by that many points
    case when team_spread is null then null
         when points_for - points_against + team_spread > 0 then 'cover'
         when points_for - points_against + team_spread < 0 then 'no_cover' else 'push' end as ats_result,
    case when total_line is null then null
         when total > total_line then 'over' when total < total_line then 'under' else 'push' end as ou_result
from sides
