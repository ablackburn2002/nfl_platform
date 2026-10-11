select team_abbr, team_name, team_nick, team_conf, team_division, team_color, team_color2, team_logo_espn
from {{ source('raw', 'teams') }}
where team_abbr is not null
