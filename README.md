# IPL Strategy Analytics with MySQL

## Overview

An end-to-end SQL data analytics project using IPL match, ball-by-ball, venue, player, and batter-versus-bowler data. The goal is to uncover the match strategies and player performances most associated with IPL success.

## Business questions answered

1. Does choosing to bat or field after winning the toss affect win percentage?
2. Which venues favour chasing a target?
3. Which teams dominated each IPL season?
4. Which players received the most Player of the Match awards on winning and losing sides?
5. Who are the most effective death-over batters and bowlers?
6. Which batter-versus-bowler matchups are most one-sided?
7. Which players delivered the strongest all-round seasons?
8. How did IPL champions win their finals: defending a total or chasing a target?

## Dataset

| File | Description |
|---|---|
| `matches.csv` | Match dates, teams, tosses, winners, venues, awards, and match stage |
| `deliveries.csv` | Ball-by-ball scoring, wickets, batters, bowlers, and extras |
| `player_season_stats.csv` | Batting, bowling, and fielding statistics by player and season |
| `venue_stats.csv` | Venue scoring patterns and batting/fielding-first win rates |
| `season_summary.csv` | Team league-stage performance by season |
| `batter_vs_bowler.csv` | Head-to-head batter and bowler statistics |

## Tools and SQL concepts

- MySQL 8 and MySQL Workbench
- Database and table design
- CSV loading with `LOAD DATA LOCAL INFILE`
- CTEs (`WITH`), `INNER JOIN`, and `UNION`
- Conditional aggregation with `CASE WHEN`
- Window functions with `RANK()`
- Aggregate functions: `COUNT`, `SUM`, `ROUND`, and `AVG`
- Data cleaning with `NULLIF`, `TRIM`, and `REPLACE`

## Key findings

- Teams that chose to **field after winning the toss** won **53.70%** of matches, compared with **44.26%** for teams choosing to bat.
- Sawai Mansingh Stadium showed the largest chasing advantage among venues with at least 20 matches: fielding-first teams won **68.09%** of games, versus **31.91%** for batting-first teams.
- **AB de Villiers** received the most Player of the Match awards (**25**); **24** of them came while playing for the winning side.
- AB de Villiers also led the displayed death-over batting results with **1,421 runs** at a **232.57** strike rate.
- Sunil Narine scored **133 runs from 57 balls** against Ravichandran Ashwin at a strike rate of **233.33**, illustrating how head-to-head data reveals one-sided matchups.
- Final-winning strategy varied by season: IPL champions have succeeded through both **defending totals** and **chasing targets**.

## Project files

| File | Purpose |
|---|---|
| `databse and tables.sql` | Creates the `ipl_analytics` database, tables, indexes, and loads the CSV files |
| `portfolio ipl_analytics by saurav kumar.sql` | Contains the 11 SQL analysis queries used in this project |
| `result screenshot/` | Query-result screenshots used to document findings |

## How to run

1. Download or clone this repository.
2. Open MySQL Workbench and enable `LOCAL INFILE` for your connection.
3. Run `databse and tables.sql` to create and populate the `ipl_analytics` database.
4. Run queries from `portfolio ipl_analytics by saurav kumar.sql` one at a time.
5. Compare your results with the screenshots in `result screenshot/`.

## Author

**Saurav Kumar**  
Data Analytics Portfolio Project
