-- weekly injury burden per team and position group
select season, week, team, position,
    count(*) as listed,
    sum((report_status = 'Out')::int) as out,
    sum((report_status = 'Doubtful')::int) as doubtful,
    sum((report_status = 'Questionable')::int) as questionable,
    sum((report_status in ('Out', 'Doubtful'))::int) as out_or_doubtful
from {{ ref('stg_injuries') }}
where report_status is not null
group by all
