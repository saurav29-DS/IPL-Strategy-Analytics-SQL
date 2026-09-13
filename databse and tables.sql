-- USE THIS FILE (not the old SQL tab).
-- IPL Strategy Analytics | MySQL 8 setup and CSV loading

DROP DATABASE IF EXISTS ipl_analytics;
CREATE DATABASE ipl_analytics CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ipl_analytics;

CREATE TABLE matches (
    match_id BIGINT PRIMARY KEY, season VARCHAR(20) NOT NULL, match_date DATE NOT NULL,
    venue VARCHAR(150), city VARCHAR(100), team1 VARCHAR(100) NOT NULL, team2 VARCHAR(100) NOT NULL,
    toss_winner VARCHAR(100), toss_decision ENUM('bat', 'field'), winner VARCHAR(100),
    win_by_runs INT, win_by_wickets INT, player_of_match VARCHAR(100), umpire1 VARCHAR(100),
    umpire2 VARCHAR(100), match_stage VARCHAR(50)
);

CREATE TABLE deliveries (
    delivery_id BIGINT AUTO_INCREMENT PRIMARY KEY, match_id BIGINT NOT NULL, inning TINYINT NOT NULL,
    over_number TINYINT NOT NULL, ball TINYINT NOT NULL, batting_team VARCHAR(100) NOT NULL,
    bowling_team VARCHAR(100) NOT NULL, batter VARCHAR(100) NOT NULL, bowler VARCHAR(100) NOT NULL,
    non_striker VARCHAR(100), runs_batter TINYINT NOT NULL, runs_extras TINYINT NOT NULL,
    extras_type VARCHAR(30), runs_total TINYINT NOT NULL, is_wicket BOOLEAN NOT NULL,
    player_out VARCHAR(100), wicket_kind VARCHAR(50), fielder VARCHAR(100),
    CONSTRAINT fk_deliveries_match FOREIGN KEY (match_id) REFERENCES matches(match_id)
);

CREATE TABLE player_season_stats (
    player VARCHAR(100) NOT NULL, season VARCHAR(20) NOT NULL, matches_played INT, runs INT,
    balls_faced INT, strike_rate DECIMAL(7,2), wickets INT, overs_bowled DECIMAL(6,1),
    economy DECIMAL(6,2), catches INT, run_outs INT, PRIMARY KEY (player, season)
);

CREATE TABLE venue_stats (
    venue VARCHAR(150) PRIMARY KEY, matches_played INT, avg_first_innings_score DECIMAL(7,2),
    avg_second_innings_score DECIMAL(7,2), highest_total INT, lowest_total INT,
    win_bat_first_pct DECIMAL(6,2), win_field_first_pct DECIMAL(6,2)
);

CREATE TABLE season_summary (
    season VARCHAR(20) NOT NULL, team VARCHAR(100) NOT NULL, matches_played INT, wins INT,
    losses INT, points INT, net_run_rate DECIMAL(6,3), final_position INT,
    PRIMARY KEY (season, team)
);

CREATE TABLE batter_vs_bowler (
    batter VARCHAR(100) NOT NULL, bowler VARCHAR(100) NOT NULL, balls_faced INT, runs_scored INT,
    dismissals INT, strike_rate DECIMAL(7,2), batting_average DECIMAL(8,2),
    PRIMARY KEY (batter, bowler)
);

LOAD DATA LOCAL INFILE 'C:/Users/princ/Desktop/ipl analytics/matches.csv'
INTO TABLE matches FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(match_id, season, @match_date, venue, city, team1, team2, toss_winner, toss_decision, winner, @win_by_runs, @win_by_wickets, player_of_match, umpire1, umpire2, match_stage)
SET match_date = STR_TO_DATE(@match_date, '%d-%m-%Y'), win_by_runs = NULLIF(@win_by_runs, ''), win_by_wickets = NULLIF(@win_by_wickets, '');

LOAD DATA LOCAL INFILE 'C:/Users/princ/Desktop/ipl analytics/deliveries.csv'
INTO TABLE deliveries FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(match_id, inning, over_number, ball, batting_team, bowling_team, batter, bowler, non_striker, runs_batter, runs_extras, extras_type, runs_total, @is_wicket, player_out, wicket_kind, fielder)
SET is_wicket = (@is_wicket = 'TRUE'), extras_type = NULLIF(extras_type, ''), player_out = NULLIF(player_out, ''), wicket_kind = NULLIF(wicket_kind, ''), fielder = NULLIF(fielder, '');

LOAD DATA LOCAL INFILE 'C:/Users/princ/Desktop/ipl analytics/player_season_stats.csv'
INTO TABLE player_season_stats FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(player, season, matches_played, runs, balls_faced, strike_rate, wickets, overs_bowled, @economy, catches, run_outs)
SET economy = NULLIF(@economy, '');

LOAD DATA LOCAL INFILE 'C:/Users/princ/Desktop/ipl analytics/venue_stats.csv'
INTO TABLE venue_stats FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Users/princ/Desktop/ipl analytics/season_summary.csv'
INTO TABLE season_summary FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Users/princ/Desktop/ipl analytics/batter_vs_bowler.csv'
INTO TABLE batter_vs_bowler FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(batter, bowler, balls_faced, runs_scored, dismissals, strike_rate, @batting_average)
SET batting_average = NULLIF(@batting_average, '');

CREATE INDEX idx_matches_season ON matches (season);
CREATE INDEX idx_matches_venue ON matches (venue);
CREATE INDEX idx_deliveries_match_inning ON deliveries (match_id, inning);
CREATE INDEX idx_deliveries_batter ON deliveries (batter);
CREATE INDEX idx_deliveries_bowler ON deliveries (bowler);

SELECT 'matches' AS table_name, COUNT(*) AS row_count FROM matches
UNION ALL SELECT 'deliveries', COUNT(*) FROM deliveries
UNION ALL SELECT 'player_season_stats', COUNT(*) FROM player_season_stats
UNION ALL SELECT 'venue_stats', COUNT(*) FROM venue_stats
UNION ALL SELECT 'season_summary', COUNT(*) FROM season_summary
UNION ALL SELECT 'batter_vs_bowler', COUNT(*) FROM batter_vs_bowler;
