-- season-to-date leaders per stat (top 25)
{% set stats = ['passing_yards', 'passing_tds', 'rushing_yards', 'rushing_tds', 'receiving_yards', 'receiving_tds', 'receptions', 'fantasy_points_ppr'] %}
with totals as (
    select player_id, any_value(player_name) as player_name, any_value(position) as position,
           arg_max(team, week) as team, season, count(*) as games,
           {% for s in stats %}sum({{ s }}) as {{ s }}{{ ',' if not loop.last }}{% endfor %}
    from {{ ref('stg_player_week') }}
    group by player_id, season
),
long as (
    {% for s in stats %}
    select '{{ s }}' as stat, player_id, player_name, position, team, season, games, {{ s }} as total
    from totals
    {{ 'union all' if not loop.last }}
    {% endfor %}
)
select *, rank() over (partition by stat, season order by total desc) as rnk
from long
qualify rnk <= 25
