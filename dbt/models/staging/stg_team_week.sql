select season, week, team, opponent_team, game_id, season_type,
    completions, attempts, passing_yards, passing_tds, passing_interceptions, sacks_suffered, passing_epa,
    carries, rushing_yards, rushing_tds, rushing_epa, receiving_epa, penalties, penalty_yards,
    def_sacks, def_interceptions, def_qb_hits, def_tackles_for_loss, def_pass_defended, def_tds,
    fg_made, fg_att, fumbles_lost_total
from {{ source('raw', 'stats_team_week') }}
where game_id is not null
