---
title: NFL Data Platform
---

Data refreshed from [nflverse](https://github.com/nflverse/nflverse-data) releases. Pick a page:

- [Teams](/teams): standings, efficiency, betting results, strength of schedule
- [League](/league): weekly scoring, pass rate and efficiency trends
- [Quarterbacks](/quarterbacks): EPA, CPOE, time to throw, QBR, pressure
- [Players](/players): season leaders, receiving and rushing efficiency
- [Streaks](/streaks): players hitting a threshold every game, team win/cover/over streaks
- [Play-by-play](/play-by-play): tendencies, fourth downs, red zone and third down
- [Injuries](/injuries): current report and team injury burden

```sql latest
select max(season) as season, (select max(week) from nfl.league_trends where season = (select max(season) from nfl.league_trends)) as week
from nfl.league_trends
```

Latest data: season <Value data={latest} column=season fmt=id/> through week <Value data={latest} column=week fmt=id/>.
