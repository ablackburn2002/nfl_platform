-- player season totals, per-game averages, usage, and rank within position
select season, player_id, any_value(player_name) as player_name, any_value(position) as position,
    arg_max(team, week) as team, count(*) as games,
    sum(passing_yards) as passing_yards, sum(passing_tds) as passing_tds, sum(passing_interceptions) as interceptions,
    sum(rushing_yards) as rushing_yards, sum(rushing_tds) as rushing_tds, sum(carries) as carries,
    sum(receptions) as receptions, sum(targets) as targets, sum(receiving_yards) as receiving_yards,
    sum(receiving_tds) as receiving_tds,
    sum(def_sacks) as sacks, sum(def_interceptions) as def_interceptions,
    sum(def_tackles_solo + def_tackle_assists) as tackles, sum(def_pass_defended) as pass_defended,
    sum(passing_epa) as passing_epa, sum(rushing_epa) as rushing_epa, sum(receiving_epa) as receiving_epa,
    avg(target_share) as avg_target_share, avg(air_yards_share) as avg_air_yards_share, avg(wopr) as avg_wopr,
    avg(offense_pct) as avg_offense_snap_pct,
    sum(fantasy_points_ppr) as fantasy_points_ppr, avg(fantasy_points_ppr) as fantasy_ppg,
    sum((injury_status in ('Out', 'Doubtful'))::int) as weeks_listed_out_or_doubtful,
    rank() over (partition by season, any_value(position) order by sum(fantasy_points_ppr) desc) as fantasy_pos_rank
from {{ ref('mart_player_game_log') }}
group by season, player_id
