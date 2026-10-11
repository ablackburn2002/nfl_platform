select
    game_id, play_id, season, week, season_type, home_team, away_team, posteam, defteam, posteam_type,
    qtr, down, ydstogo, yardline_100, game_seconds_remaining, drive, play_type, yards_gained,
    epa, wp, wpa, success, "pass" as is_pass, rush as is_rush, qb_dropback, shotgun, no_huddle,
    air_yards, yards_after_catch, cpoe, xpass, pass_length, pass_location, run_location, run_gap,
    score_differential, touchdown, td_team, interception, fumble_lost, sack, penalty, first_down,
    third_down_converted, third_down_failed, fourth_down_converted, fourth_down_failed,
    complete_pass, two_point_attempt, special,
    passer_player_id, passer_player_name, rusher_player_id, rusher_player_name,
    receiver_player_id, receiver_player_name,
    -- standard analysis filter: real offensive snaps with an EPA value
    (play_type in ('pass', 'run') and epa is not null and posteam is not null) as is_scrimmage
from {{ source('raw', 'pbp') }}
where game_id is not null and play_id is not null
