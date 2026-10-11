select dt, team, player_name, gsis_id, pos_grp, pos_abb, pos_slot, pos_rank
from {{ source('raw', 'depth_charts') }}
where gsis_id is not null
