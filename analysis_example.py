import duckdb

c = duckdb.connect("warehouse/nfl.duckdb", read_only=True)
print(c.execute("""
    select player_name, team, games_played, longest_streak, current_streak
    from marts.mart_player_streaks
    where stat = 'passing_yards_200' and hit_every_game and games_played >= 2
    order by games_played desc, player_name
""").fetchall())
print(c.execute("select * from marts.mart_season_leaders where stat='passing_yards' order by rnk limit 3").fetchall())
