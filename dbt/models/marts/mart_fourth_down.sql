-- fourth-down decisions: go / punt / kick by distance and field position
select season, posteam as team,
    case when ydstogo <= 2 then '1-2' when ydstogo <= 5 then '3-5' else '6+' end as distance_bucket,
    case when yardline_100 > 60 then 'own_territory' when yardline_100 > 40 then 'midfield'
         when yardline_100 > 20 then 'fg_range' else 'red_zone' end as field_zone,
    count(*) as fourth_downs,
    sum((play_type in ('pass', 'run'))::int) as went_for_it,
    sum((play_type = 'punt')::int) as punts,
    sum((play_type = 'field_goal')::int) as field_goals,
    avg((play_type in ('pass', 'run'))::int) as go_rate,
    sum(fourth_down_converted) as conversions,
    sum(fourth_down_converted) * 1.0 / nullif(sum(fourth_down_converted + fourth_down_failed), 0) as conversion_rate,
    avg(case when play_type in ('pass', 'run') then wpa end) as avg_wpa_when_going
from {{ ref('stg_pbp') }}
where down = 4 and season_type = 'REG' and play_type in ('pass', 'run', 'punt', 'field_goal') and posteam is not null
group by all
