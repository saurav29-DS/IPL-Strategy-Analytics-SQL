use ipl_analytics;
-- 1. Dataset overview: demonstrate the scale and coverage of the analysis.
select 
count(*) as total_matches,
min(match_date) as first_match_date,
max(match_date) as last_match_date,
count(distinct season)as seasons_covered,
count(distinct venue)as venues_covered
from matches;

-- 2. Toss-decision impact: does the toss winner benefit from batting or fielding?
select
toss_decision,
count(*)as matches_after_winning_toss,
round(100.0*sum(toss_winner=winner)/count(*),2) as win_pct_after_toss
from matches
where toss_decision is not null
and winner is not null
group by toss_decision
order by win_pct_after_toss desc;

-- 3. Best venues for chasing. A positive chase advantage means fielding first
-- was more successful than batting first at that venue.
SELECT
    venue,
    matches_played,
    win_field_first_pct,
    win_bat_first_pct,
    ROUND(win_field_first_pct - win_bat_first_pct, 2) AS chase_advantage_pct,
    CASE
        WHEN win_field_first_pct > win_bat_first_pct
            THEN 'Favors chasing'
        WHEN win_field_first_pct < win_bat_first_pct
            THEN 'Favors defending'
        ELSE 'Balanced'
    END AS venue_strategy
FROM venue_stats
WHERE matches_played >= 20
ORDER BY chase_advantage_pct DESC, matches_played DESC;

-- 4.Season dominance: rank top 3 team within each season by wins, then NRR.
With ranked_teams as(
select 
season,
team,
matches_played,
wins,
losses,
points,
net_run_rate,
final_position,
rank() over(partition by season 
		    order by wins desc,net_run_rate desc)as season_win_rank
from season_summary
)
select*from ranked_teams
where season_win_rank<=3
order by season,season_win_rank;   

-- 5.Most player of the awards by player:
-- awards received on winning side vs losing side.
with player_team as (
select distinct match_id,batter as player,
batting_team as team
from deliveries
union
select distinct match_id, bowler as player,
bowling_team as team
from deliveries
)
select
m.player_of_match as player,
count(*) as total_player_of_match_awards,
sum(case when pt.team=m.winner then 1 else 0 end) as awards_on_winning_side,
sum(case when pt.team<>m.winner then 1 else 0 end)as awrads_on_losing_side
from matches m 
join player_team pt
on m.match_id=pt.match_id
and m.player_of_match=pt.player
where m.player_of_match is not null
group by m.player_of_match
order by total_player_of_match_awards desc
limit 15;

-- 6. Death-over batting: players with the best combination of output and intent. 
with death_batting as(
select
batter,
sum(runs_batter)as death_runs,
sum(case when extras_type = 'wides' then 0 else 1 end) as legal_balls_faced,
sum(runs_batter in(4,6)) as boundaries,
count(distinct match_id)as matches_batted
from deliveries
where over_number between 16 and 19
group by batter
)
select
batter,
death_runs,
legal_balls_faced,
boundaries,
round(100.0*death_runs/nullif(legal_balls_faced,0),2) as death_strike_rate,
matches_batted
from death_batting
where legal_balls_faced>=100
order by death_strike_rate desc,death_runs desc 
limit 15;

-- 7. Death-over bowling: economical bowlers under end-of-innigs pressure.
with death_bowling as (
select
bowler,
sum(runs_batter + case when extras_type in ('byes','legbyes')
    then 0 else runs_extras end) as runs_conceded,
sum(case when extras_type in ('wide','noballs')
    then 0 else 1 end)as legal_balls,
sum(is_wicket)as wickets
from deliveries
where over_number between 16 and 19
group by bowler
)
select
bowler,
runs_conceded,
legal_balls,
wickets,
round(6.0*runs_conceded/nullif(legal_balls,0),2)
      as death_economy
from death_bowling
where legal_balls>=120
order by death_economy,wickets desc
limit 15;

-- 8. Batter-versus-bowler matchups: high volume battles where the batter dominates. 
select
batter,
bowler,
balls_faced,
runs_scored,
dismissals,
strike_rate,
batting_average
from batter_vs_bowler
where balls_faced>=50
      and dismissals<=2
order by strike_rate desc, runs_scored desc
limit 15;

-- 9. Batter-versus-bowler matchups:high-volume battles where the bowler dominates. 
select
    batter,
    bowler,
    balls_faced,
    runs_scored,
    dismissals,
    strike_rate,
    batting_average
FROM batter_vs_bowler
WHERE balls_faced >= 50
ORDER BY dismissals DESC
LIMIT 15;

-- 10. All-round season impact:idetify players contributing with both bat and ball. 
with all_rounders as (
select
player,
season,
matches_played,
runs,
strike_rate,
wickets,
economy,
rank()over(partition by season order by runs desc)as batting_rank,
rank()over(partition by season order by wickets desc,
		   economy asc) as bowling_rank
from player_season_stats
where runs>=150 and wickets>=8
)
select 
player,
season,
matches_played,
runs,
strike_rate,
wickets,
economy,
batting_rank,
bowling_rank
from all_rounders
order by season,(batting_rank+bowling_rank),
runs desc;           

-- 11. IPL Final Winning Strategy:
-- Did champions win by defending a total or chasing one?

WITH final_matches AS (
    SELECT
        match_id,
        season,
        winner,
        win_by_runs,
        win_by_wickets
    FROM matches
    WHERE TRIM(REPLACE(match_stage, CHAR(13), '')) = 'Final'
),

first_innings AS (
    SELECT DISTINCT
        match_id,
        batting_team AS first_innings_team
    FROM deliveries
    WHERE inning = 1
)

SELECT
    f.season,
    f.winner AS champion,

    CASE
        WHEN f.winner = i.first_innings_team
            THEN 'Defended Total'
        ELSE 'Chased Target'
    END AS winning_strategy,

    CASE
        WHEN f.win_by_runs IS NOT NULL
            THEN CONCAT(f.win_by_runs, ' runs')
        ELSE CONCAT(f.win_by_wickets, ' wickets')
    END AS winning_margin

FROM final_matches f
JOIN first_innings i
    ON f.match_id = i.match_id

ORDER BY f.season;
