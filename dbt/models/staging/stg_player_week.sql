-- one row per player per regular-season game; weekly stats are already de-duplicated upstream
select
    player_id, player_display_name as player_name, position, position_group, team, opponent_team,
    season, week, season_type, game_id,
    completions, attempts, passing_yards, passing_tds, passing_interceptions, sacks_suffered,
    passing_air_yards, passing_epa, passing_cpoe,
    carries, rushing_yards, rushing_tds, rushing_epa, rushing_first_downs,
    receptions, targets, receiving_yards, receiving_tds, receiving_air_yards,
    receiving_yards_after_catch, receiving_epa, target_share, air_yards_share, wopr,
    def_tackles_solo, def_tackle_assists, def_sacks, def_qb_hits, def_interceptions,
    def_pass_defended, def_tackles_for_loss, def_fumbles_forced, def_tds,
    fg_made, fg_att, pat_made, pat_att,
    fantasy_points, fantasy_points_ppr
from {{ source('raw', 'stats_player_week') }}
where season_type = 'REG' and player_id is not null
