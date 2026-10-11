-- current and longest team streaks (win / ATS cover / over), gaps-and-islands
{% set kinds = [("win", "result = 'W'"), ("cover", "ats_result = 'cover'"), ("over", "ou_result = 'over'")] %}
with flagged as (
    {% for k, cond in kinds %}
    select '{{ k }}' as streak_type, season, team, week, ({{ cond }}) as hit
    from {{ ref('mart_team_game_results') }} where game_type = 'REG'
    {{ 'union all' if not loop.last }}
    {% endfor %}
),
islands as (
    select *, row_number() over (partition by streak_type, season, team order by week)
            - row_number() over (partition by streak_type, season, team, hit order by week) as grp
    from flagged
),
runs as (
    select streak_type, season, team, count(*) as run_len, max(week) as end_week
    from islands where hit group by streak_type, season, team, grp
),
last_week as (
    select streak_type, season, team, max(week) as last_week from flagged group by all
)
select l.streak_type, l.season, l.team,
    coalesce(max(r.run_len), 0) as longest_streak,
    coalesce(max(case when r.end_week = l.last_week then r.run_len end), 0) as current_streak
from last_week l
left join runs r using (streak_type, season, team)
group by all
