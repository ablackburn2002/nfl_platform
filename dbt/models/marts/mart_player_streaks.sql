{# add rows here to track new thresholds #}
{% set rules = [
    ('passing_yards_200', 'passing_yards', 200),
    ('passing_tds_2', 'passing_tds', 2),
    ('rushing_yards_100', 'rushing_yards', 100),
    ('receiving_yards_100', 'receiving_yards', 100),
    ('receptions_5', 'receptions', 5),
] %}

with games as (
    {% for stat, col, thr in rules %}
    select '{{ stat }}' as stat, {{ thr }} as threshold,
           player_id, player_name, position, team, season, week,
           {{ col }} as value, ({{ col }} >= {{ thr }}) as hit
    from {{ ref('stg_player_week') }}
    -- only games where the player actually recorded the relevant usage
    where {{ col }} is not null
      and {% if col == 'passing_yards' or col == 'passing_tds' %}attempts > 0
          {% elif col == 'rushing_yards' %}carries > 0
          {% else %}targets > 0{% endif %}
    {% if not loop.last %}union all{% endif %}
    {% endfor %}
),
islands as (
    select *,
        row_number() over (partition by stat, player_id, season order by week)
      - row_number() over (partition by stat, player_id, season, hit order by week) as grp
    from games
),
runs as (
    select stat, threshold, player_id, season, grp,
           count(*) as run_len, max(week) as run_end_week
    from islands where hit
    group by all
),
summary as (
    select stat, player_id, season,
           max(run_len) as longest_streak,
           max(case when run_end_week = (select max(week) from games g2
                 where g2.stat = runs.stat and g2.player_id = runs.player_id and g2.season = runs.season)
               then run_len end) as current_streak
    from runs group by all
)
select
    g.stat, g.threshold, g.player_id, any_value(g.player_name) as player_name,
    any_value(g.position) as position, arg_max(g.team, g.week) as team, g.season,
    count(*) as games_played,
    sum(hit::int) as games_hit,
    coalesce(max(s.longest_streak), 0) as longest_streak,
    coalesce(max(s.current_streak), 0) as current_streak,
    sum(hit::int) = count(*) as hit_every_game
from games g
left join summary s using (stat, player_id, season)
group by g.stat, g.threshold, g.player_id, g.season
