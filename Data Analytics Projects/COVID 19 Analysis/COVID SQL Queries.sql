use Portfolio

----- calculating the death rate -----

select date, location, total_cases, total_deaths , round((total_deaths/ total_cases)*100,3) as Deathrate from CovidDeaths$  where continent is not null order by location,date

------ calculating total cases vs population -----

select date, location, total_cases, population , round((total_cases/population)*100,3) as Infectedrate from CovidDeaths$ where continent is not null order by location,date


------ Highest infected countries ------

select location, population,  max(total_cases) as HighestInfected, max(round((total_cases/population)*100,3)) as  HighestInfectedrate from CovidDeaths$ where continent is not null group by location, population  order by HighestInfectedrate desc


------ Least infected countries ------

select location, population,  min(total_cases) as HighestInfected, min(round((total_cases/population)*100,3)) as  HighestInfectedrate from CovidDeaths$ where continent is not null group by location, population  order by HighestInfectedrate desc



------ Highest death count countries ------

select location, population,  max(cast(total_deaths as int)) as Maximumdeaths  from CovidDeaths$ where continent is not null group by location, population  order by Maximumdeaths desc



------ Highest death count continents ------

select continent,  max(cast(total_deaths as int)) as Maximumdeaths  from CovidDeaths$ where continent is not null group by continent order by Maximumdeaths desc







---------------------------- VISUALIZATION QUERIES --------------------------------------------------



----- Data Cleaning -----

update CovidDeaths$ set continent = location  where continent is null 
update CovidVaccinations$ set continent = location  where continent is null 


--1. Death Rate

Create view DeathRate as
select sum(total_cases) as Total_cases, sum(cast(total_deaths as int)) as Total_Deaths , round((sum(cast(total_deaths as int))/ sum(total_cases))*100,3) as Deathrate from CovidDeaths$ 
select * from DeathRate

--2. Total Deaths by continent

Create view ContinentDeaths as

select continent, sum(cast(total_deaths as int)) as TotalDeath_count from CovidDeaths$ where continent not in ('World', 'International','European Union') group by continent order by TotalDeath_count desc offset 0 rows
select * from ContinentDeaths

--3. Highest Infected Count by location and date 

Create view HighlyInfected as
Select date, continent, Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths$
Group by date, continent,  Location, Population
order by PercentPopulationInfected desc offset 0 rows
select * from HighlyInfected


--4. Population and Vaccinations

Create view VaccinationsView as
select d.continent, d.location ,d.date, d.population, v.new_vaccinations , sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as RollingVaccination  from CovidDeaths$ d join CovidVaccinations$ v on d.location = v.location and d.date = v.date order by d.continent, d.location ,d.date offset 0 rows
select * from VaccinationsView

