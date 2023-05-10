/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


-- The covid deaths dataset shows that when the "continent" value is NULL they decided to allocated the continent name within "location"
-- it will be as best practice to not query it
select *
from covid..CovidDeaths$
where continent is not null
order by 3,4



--select Data that we are going to be using

Select location,date, total_cases, new_cases, total_deaths, population
from Covid..CovidDeaths$
where continent is not null
order by 1,2



-- Total Cases vs Total Deaths
-- It will be interpreted as the chance percentage of dying if you get covid

Select location, date, total_cases, total_deaths,( total_deaths/total_cases)*100 as Deathpercentage
from Covid..CovidDeaths$
where location = 'Australia'
order by 1,2


--Looking at all Total cases vs Total deaths worldwide (Death Percentage)

Select location, date, total_cases, total_deaths,( total_deaths/total_cases)*100 as Deathpercentage
from Covid..CovidDeaths$
order by 1,2


-- Total Cases vs Population
-- it will be interpreted as the percentage of the population that got covid.

Select location, date, total_cases, population,(total_cases/population)*100 as InfectionRate
from Covid..CovidDeaths$
where location = 'Australia'
order by 1,2


-- Countries with the highest infection rate


Select location, population, MAx(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionRate
from Covid..CovidDeaths$
group by location, population
order by 4 desc


-- Australia infection rate

Select location, population, MAx(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionRate
from Covid..CovidDeaths$
Where location= 'Australia'
group by location, population


--Countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Covid..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

--Continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount --total_deaths is not integer so using CAST will convert it to integer
from Covid..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc


--Global numbers by date, total cases, total deaths, death percentage

select date, sum(new_cases) as total_cases, sum(cast (new_deaths as int)) as total_deaths, 
sum(cast (new_deaths as int))/sum(new_cases)*100 as death_percentage
from covid..CovidDeaths$
where continent is not null
group by date
order by 1,2




-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum( cast( vac.new_vaccinations as int) ) over ( partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from Covid..CovidDeaths$ dea
join covid..CovidVaccinations$ vac
    on dea.location = vac.location
      and dea.date=vac.date
	  where dea.continent is not null




-- Using CTE to perform Calculation on Partition By in previous query

--Total population vs vaccionations
with PopVSvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum( cast( vac.new_vaccinations as int) ) over ( partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from Covid..CovidDeaths$ dea
join covid..CovidVaccinations$ vac
    on dea.location = vac.location
      and dea.date=vac.date
	  where dea.continent is not null
	  
	  )
	  select *,(RollingPeopleVaccinated/population)*100
	  from  PopVSvac


--Using Temp Table to perform Calculation on Partition By in previous query

create table #PercentPopulationVaccinated
( continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccionations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum( cast( vac.new_vaccinations as int) ) over ( partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from Covid..CovidDeaths$ dea
join covid..CovidVaccinations$ vac
    on dea.location = vac.location
      and dea.date=vac.date
	  where dea.continent is not null 

	  select *,(RollingPeopleVaccinated/population)*100
	  from   #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

--use Covid database instead of master 

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum( cast( vac.new_vaccinations as int) ) over ( partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from Covid..CovidDeaths$ dea
join covid..CovidVaccinations$ vac
    on dea.location = vac.location
      and dea.date=vac.date
	  where dea.continent is not null 