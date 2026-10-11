-- league-wide weekly trends: scoring, pace, pass rate, efficiency, home field
with g as (
    select season, week, count(*) as games, avg(total) as avg_total_points,
           avg((home_score > away_score)::int) as home_win_pct,
           avg(abs(home_score - away_score)) as avg_margin,
           avg((overtime = 1)::int) as overtime_rate
    from {{ ref('stg_games') }}
    where is_final and game_type = 'REG'
    group by all
),
p as (
    select season, week, count(*) as plays, avg(is_pass) as pass_rate, avg(epa) as epa_play,
           avg(success) as success_rate, avg(case when is_pass = 1 then epa end) as epa_pass,
           avg(case when is_rush = 1 then epa end) as epa_rush,
           sum(sack) * 1.0 / nullif(sum(qb_dropback), 0) as sack_rate,
           sum(interception) * 1.0 / nullif(sum(qb_dropback), 0) as int_rate
    from {{ ref('stg_pbp') }} where is_scrimmage and season_type = 'REG'
    group by all
)
select * from g join p using (season, week)
