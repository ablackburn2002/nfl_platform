-- offensive tendencies by team / down / distance / game state
select season, posteam as team, down,
    case when ydstogo <= 2 then '1-2' when ydstogo <= 6 then '3-6' when ydstogo <= 10 then '7-10' else '11+' end as distance_bucket,
    case when score_differential >= 9 then 'leading_big' when score_differential > 0 then 'leading'
         when score_differential = 0 then 'tied' when score_differential > -9 then 'trailing'
         else 'trailing_big' end as score_state,
    count(*) as plays, avg(is_pass) as pass_rate, avg(xpass) as expected_pass_rate,
    avg(is_pass) - avg(xpass) as pass_rate_over_expected,
    avg(epa) as epa_play, avg(success) as success_rate, avg(yards_gained) as yards_play,
    avg(shotgun) as shotgun_rate, avg(no_huddle) as no_huddle_rate
from {{ ref('stg_pbp') }}
where is_scrimmage and season_type = 'REG' and down is not null
group by all
