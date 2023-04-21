/*
We will use these Queries from our previous SQL Project to extract data from Covid Dataset which will be further used in Tableau Project
*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Project..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2;



-- 2. 


Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Project..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc;


-- 3.

Select Location, Population, MAX(cast(total_cases as int)) as HighestInfectionCount,  Max((cast(total_cases as int)/population))*100 as PercentPopulationInfected
From Project..CovidDeaths
Where location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by Location, Population
order by PercentPopulationInfected desc;


-- 4.


Select Location, Population,date, MAX(cast(total_cases as int)) as HighestInfectionCount,  Max((cast(total_cases as int)/population))*100 as PercentPopulationInfected
From Project..CovidDeaths
Where location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by Location, Population, date
order by PercentPopulationInfected desc;