-- regular-season team table: record, points, ATS/O-U, efficiency, ranks
with rec as (
    select season, team,
        count(*) as games,
        sum((result = 'W')::int) as wins, sum((result = 'L')::int) as losses, sum((result = 'T')::int) as ties,
        sum(points_for) as points_for, sum(points_against) as points_against,
        sum(margin) as point_diff,
        sum((ats_result = 'cover')::int) as ats_wins, sum((ats_result = 'no_cover')::int) as ats_losses,
        sum((ou_result = 'over')::int) as overs, sum((ou_result = 'under')::int) as unders
    from {{ ref('mart_team_game_results') }}
    where game_type = 'REG'
    group by all
),
eff as (
    select season, team, avg(off_epa_play) as off_epa_play, avg(def_epa_play) as def_epa_play,
           avg(net_epa_play) as net_epa_play, avg(off_success_rate) as off_success_rate, avg(pass_rate) as pass_rate,
           avg(explosive_rate) as explosive_rate
    from {{ ref('mart_team_game_efficiency') }}
    group by all
)
select r.*, (r.wins + 0.5 * r.ties) / nullif(r.games, 0) as win_pct,
    t.team_conf, t.team_division, t.team_name, t.team_logo_espn,
    e.off_epa_play, e.def_epa_play, e.net_epa_play, e.off_success_rate, e.pass_rate, e.explosive_rate,
    rank() over (partition by r.season order by e.off_epa_play desc) as off_epa_rank,
    rank() over (partition by r.season order by e.def_epa_play asc) as def_epa_rank,
    rank() over (partition by r.season order by e.net_epa_play desc) as net_epa_rank,
    rank() over (partition by r.season, t.team_division order by (r.wins + 0.5 * r.ties) desc, r.point_diff desc) as division_rank
from rec r
left join eff e using (season, team)
left join {{ ref('stg_teams') }} t on t.team_abbr = r.team
