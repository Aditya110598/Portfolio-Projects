


select * from IPL..BallbyBall; 
select * from IPL..Matches; 


--Number of matches in each season/Year


SELECT a.Yr, COUNT(distinct id) AS Number_of_matches
FROM (SELECT YEAR(date) AS Yr, id FROM IPL..Matches) as a
group by Yr;


--Player with most Player of Match award overall


select player_of_match, count(player_of_match) as MoM 
from IPL.dbo.Matches
group by player_of_match
order by MoM desc;


--Player with Most Player of match per Season


select * from
(select player_of_match, Yr, MoM, rank() over(partition by Yr order by MoM desc) as rnk from
(
select player_of_match, year(date) as Yr, count(player_of_match) as MoM from IPL.dbo.Matches
group by player_of_match, year(date)
)as a) as b
where rnk = 1;


--Teams with most number of wins till date


select winner, count(winner) as No_of_Wins
from IPL.dbo.Matches
group by winner
order by no_of_wins desc;


--Top 5 venues where most number of matches are played


select top 5 venue, count(venue) as No_of_matches
from IPL.dbo.Matches
group by venue
order by No_of_matches desc;


--Top 10 Batsman with most number of runs/ Highest run scorer in the history of Ipl


select top 10 batsman, sum(total_runs) as Runs_scored from IPL.dbo.BallbyBall
group by batsman
order by Runs_scored desc;


--Percent of total runs scored by each of the batsman


select sum(Runs_scored) from
(select batsman, sum(total_runs) as Runs_scored from IPL.dbo.BallbyBall group by batsman) as a;


select *, 
Runs_scored/sum(Runs_scored) over(order by Runs_scored rows between unbounded preceding and unbounded following) as percent_of_total_runs 
from 
(select batsman, sum(total_runs) as Runs_scored from IPL.dbo.BallbyBall group by batsman) as a;


--Top 10 batsman with Most number of 6s 


select top 10 batsman, count(batsman) as no_of_sixes from
(select * from IPL.dbo.BallbyBall where batsman_runs = 6) as a
group by batsman
order by no_of_sixes desc;


--Top 10 batsman with Most number of 4s 


select top 10 batsman, count(batsman) as no_of_fours from
(select * from IPL.dbo.BallbyBall where batsman_runs = 4) as a
group by batsman
order by no_of_fours desc;


--Top 10 Players with more than 3000 runs and having highest strike rate


select top 10 batsman, total_runs, total_balls_faced, strike_rate from
(select batsman, total_runs, total_balls_faced, (total_runs/total_balls_faced)*100 as strike_rate from
(select batsman, sum(batsman_runs) as total_runs, count(batsman) as total_balls_faced from IPL.dbo.BallbyBall
group by batsman) a) b
where total_runs >= 3000
order by strike_rate desc;


--Top 5 Bowlers with lowest economy rate having bowled atleast 50 overs


select top 5 bowler, Total_balls_bowled, Total_runs_conceded, 
(total_runs_conceded/Total_balls_bowled) as economy_rate from
(select bowler, count(bowler) as Total_balls_bowled, sum(total_runs) as Total_runs_conceded
from IPL.dbo.BallbyBall
group by bowler) a
where Total_balls_bowled > 300
order by economy_rate;


--Total number of matches played till date


select count(distinct id) from IPL.dbo.Matches;


--Total number of matches won by each team


select winner, count(winner) as no_of_wins 
from IPL.dbo.Matches 
group by winner
order by no_of_wins desc;