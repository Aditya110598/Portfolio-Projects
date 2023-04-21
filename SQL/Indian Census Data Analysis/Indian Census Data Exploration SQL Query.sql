

select * from Census2011.dbo.Data1;

select * from Census2011.dbo.Data2;


-- number of rows in the dataset


select count(*) from Census2011..Data1;

select count(*) from Census2011..Data2;


-- Extracting dataset for Orissa and Kerala


select * from Census2011..Data1 where state in ('Orissa' ,'Kerala');


-- population of India


select sum(population) as Population 
from Census2011..Data2;


-- avg growth of India


select state,avg(growth)*100 as avg_growth 
from Census2011..Data1 
group by state
order by avg_growth desc;


-- avg sex ratio of India


select state, round(avg(sex_ratio),0) as avg_sex_ratio 
from Census2011..Data1 
group by state 
order by avg_sex_ratio desc;


-- average literacy rate of India
 

select state, round(avg(literacy),0) as avg_literacy_ratio 
from Census2011..Data1 
group by state having round(avg(literacy),0) > 60 
order by avg_literacy_ratio desc;


-- top 3 state showing highest growth ratio


select top 3 state, avg(growth)*100 as avg_growth 
from Census2011..Data1 
group by state 
order by avg_growth desc;


--bottom 3 state showing lowest sex ratio


select top 3 state,round(avg(sex_ratio),0) avg_sex_ratio 
from Census2011..Data1 
group by state 
order by avg_sex_ratio asc;


-- top and bottom 3 states in literacy state data to be shown in a single table using temporary table & Union Operator


drop table if exists #topstates;
create table #topstates
( state nvarchar(255),
  topstate float
)

insert into #topstates
select state, round(avg(literacy),0) as avg_literacy_ratio 
from Census2011..Data1 
group by state 
order by avg_literacy_ratio desc;

select top 3 * from #topstates order by #topstates.topstate desc;


drop table if exists #bottomstates;
create table #bottomstates
( state nvarchar(255),
  bottomstate float
)

insert into #bottomstates
select state,round(avg(literacy),0) avg_literacy_ratio 
from Census2011..Data1 
group by state 
order by avg_literacy_ratio desc;

select top 3 * from #bottomstates order by #bottomstates.bottomstate asc;


--Merging both the temporary table using union opertor


select * from (
select top 3 * from #topstates order by #topstates.topstate desc) a

union

select * from (
select top 3 * from #bottomstates order by #bottomstates.bottomstate asc) b;


-- states starting with letter a


select distinct state from Census2011..Data1 where lower(state) like 'a%' or lower(state) like 'b%';


select distinct state from Census2011..Data1 where lower(state) like 'a%' and lower(state) like '%m';


-- joining both table

-- total males and females per state
-- Males = Population / (Sex ratio + 1)
-- Females = (Population * Sex ratio) / (sex ratio + 1)


select d.state, sum(d.males) as total_males, sum(d.females) as total_females 
from
(select c.district, c.state as state, round(c.population / (c.sex_ratio + 1),0) as males, 
 round((c.population * c.sex_ratio) / (c.sex_ratio + 1),0) as females 
from
(select a.district, a.state, a.sex_ratio / 1000 as sex_ratio, b.population 
 from Census2011..Data1 as a 
 inner join Census2011..Data2 as b on a.district=b.district ) as c) as d
group by d.state;


-- total literate and Illiterate people in each state
-- Literate People = Literacy Ratio * Population
-- Illiterate people = (1 - Literacy ratio) * population


select d.state, sum(literate_people) as total_literate_people, sum(illiterate_people) as total_lliterate_people 
from 
(select c.district, c.state, round(c.literacy_ratio * c.population,0) as literate_people,
 round((1-c.literacy_ratio) * c.population,0) as illiterate_people 
from
(select a.district, a.state, a.literacy / 100 as literacy_ratio, b.population 
 from Census2011..Data1 a 
 inner join Census2011..Data2 b on a.district = b.district) as c) as d
group by d.state;


-- population in previous census
-- Previous census population = Current sensus Population / (1 + Growth) 


select sum(e.previous_census_population) as previous_census_population, sum(e.current_census_population) as current_census_population 
from(
select d.state, sum(d.previous_census_population) as previous_census_population, sum(d.current_census_population) as current_census_population 
from
(select c.district, c.state, round(c.population / (1+c.growth),0) as previous_census_population, c.population as current_census_population 
from
(select a.district, a.state, a.growth as growth, b.population 
 from Census2011..Data1 a 
 inner join Census2011..Data2 b on a.district=b.district) as c) as d
 group by d.state)as e;



-- Window function

-- Output top 3 districts from each state with highest literacy rate


select a.* from
(select state, District, literacy, rank() over(partition by state order by literacy desc) as rnk 
 from Census2011..Data1) as a
where a.rnk in (1,2,3) 
order by state;


-- Output top 3 districts from each state with highest Sex Ratio


select a.* from
(select state, District, Sex_Ratio, rank() over(partition by state order by Sex_Ratio desc) as rnk 
 from Census2011..Data1) as a
where a.rnk in (1,2,3) 
order by state;


-- Output top 3 districts from each state with highest growth rate


select a.* from
(select state, District, Growth * 100 as growth_percentage, rank() over(partition by state order by Growth desc) as rnk 
 from Census2011..Data1) as a
where a.rnk in (1,2,3) 
order by state;


-- Top 5 States in terms of population


select top 5 state, sum(population) as total_population 
from Census2011..Data2 
group by state 
order by total_population desc;