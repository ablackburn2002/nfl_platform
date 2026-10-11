-- player x game log combining box score, snap share, and injury report status
select s.*,
    sn.offense_snaps, sn.offense_pct, sn.defense_snaps, sn.defense_pct, sn.st_snaps,
    i.report_status as injury_status, i.report_primary_injury as injury,
    i.practice_status
from {{ ref('stg_player_week') }} s
left join {{ ref('stg_snaps') }} sn on sn.game_id = s.game_id and sn.gsis_id = s.player_id
left join {{ ref('stg_injuries') }} i on i.season = s.season and i.week = s.week and i.gsis_id = s.player_id
