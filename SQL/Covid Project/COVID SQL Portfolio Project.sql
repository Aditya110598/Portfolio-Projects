/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Subquery, Window Functions, Aggregate Functions, Creating Views, Converting Data Types, Alias
*/

Select *
From project.dbo.CovidDeaths
Where continent is not null 
order by 3,4;

Select *
From project.dbo.CovidVaccinations
Where continent is not null 
order by 3,4;


-- Selecting the Data that we will be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From Project.dbo.CovidDeaths
Where continent is not null 
order by 1,2;

Select continent, location, date, new_vaccinations, total_vaccinations
From project.dbo.CovidVaccinations
Where continent is not null
order by 2,3;

Select Location, date, total_cases, new_cases, total_deaths, population
From Project.dbo.CovidDeaths
Where location like '%india%' and continent is not null 
order by 1,2;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (cast(total_deaths as int)/cast(total_cases as int))*100 as Death_Percentage
From Project..CovidDeaths
Where location like '%india%'
and continent is not null 
order by 1,2;


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases, (cast(total_cases as int) /population)*100 as Percent_Population_Infected
From Project..CovidDeaths
--Where location like '%india%'
order by 1,2;


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as Highest_Infection_Count,  Max((cast(total_cases as int) /population))*100 as Percent_Population_Infected
From Project..CovidDeaths
--Where location like '%india%'
Group by Location, population
order by Percent_Population_Infected desc;


-- Countries with Highest Death Count per Population

Select Location, MAX(Total_deaths) as TotalDeathCount
From Project..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc;



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(Total_deaths) as TotalDeathCount
From Project..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc;



-- Total cases, Total deaths, Death Percentage worldwide irrespective of Continent and Location

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths) / SUM(New_Cases)*100 as DeathPercentage
From Project..CovidDeaths
--Where location like '%states%'
where continent is not null 
order by 1,2;



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select a.continent, a.location, a.date, a.population, b.new_vaccinations, 
SUM(CONVERT(bigint,b.new_vaccinations)) OVER (Partition by a.Location Order by a.location, a.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population)*100 as PercentPopulationVaccinated
From Project..CovidDeaths as a
Join Project..CovidVaccinations as b
	On a.location = b.location
	and a.date = b.date
where a.continent is not null 
order by 2,3;

/* new column created using the SELECT statement cannot be directly used to create a new column in the table. 
   The reason is that the SELECT statement does not actually modify the underlying data in the table or view. 
   Instead, it creates a result set that is based on the data in the table or view.
   We can use a Common Table Expression (CTE) to define a subquery and then reference it in the main query to create the new column.
*/

With cte
as
(
Select a.continent, a.location, a.date, a.population, b.new_vaccinations,
SUM(CONVERT(bigint,b.new_vaccinations)) OVER (Partition by a.Location Order by a.location, a.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population)*100 as PercentPopulationVaccinated
From Project..CovidDeaths a
Join Project..CovidVaccinations b
	On a.location = b.location
	and a.date = b.date
where a.continent is not null 
--order by 2,3;
)
Select cte.*, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From cte;

-- We can solve the same problem using Subquery as well

SELECT 
s.*, (s.RollingPeopleVaccinated / s.population) * 100 AS PercentPopulationVaccinated
FROM 
(SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations,
SUM(CONVERT(bigint,b.new_vaccinations)) OVER (PARTITION BY a.Location ORDER BY a.location, a.Date) AS RollingPeopleVaccinated
FROM Project..CovidDeaths as a
JOIN Project..CovidVaccinations as b 
     ON a.location = b.location 
     and a.date = b.date 
WHERE a.continent IS NOT NULL) as s;


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select a.continent, a.location, a.date, a.population, b.new_vaccinations,
SUM(CONVERT(bigint,b.new_vaccinations)) OVER (Partition by a.Location Order by a.location, a.Date) as RollingPeopleVaccinated
From Project..CovidDeaths a
Join Project..CovidVaccinations b
	On a.location = b.location
	and a.date = b.date
where a.continent is not null;

select * from PercentPopulationVaccinated;