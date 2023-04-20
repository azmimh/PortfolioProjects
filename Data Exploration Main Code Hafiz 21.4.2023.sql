
--This is my first SQL Project with the guidance of Alex The Analyst Youtube Channel (https://www.youtube.com/watch?v=qfyynHBFOsM&list=PLUaB-1hjhk8H48Pj32z4GZgGWyylqv85f&index=1)

-- 1. 
-- Determine the correct data is being imported

select *
from PortfolioProject..CovidDeathsCSV
order by 3,4

select *
from PortfolioProject..CovidVaccinationsCSV
order by 3,4

-- 2. 
-- Select Data that are going to be used

select location, date, total_cases, new_cases,total_deaths,population
from PortfolioProject..CovidDeathsCSV
order by 1,2

-- 3. 
-- Looking at Total Cases vs Total Deaths
-- set Total Cases and Total Deaths to numeric in design
-- where to chose location
-- is not null is parameter for continent

select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeathsCSV
where location like'%states%'
and continent is not null
order by 1,2

-- 4. 
-- Total Cases vs Population
-- Shows the percentage of population affected with covid

select location, date, total_cases,population,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeathsCSV
where location like'%states%'
and continent is not null
order by 1,2

-- 5.
-- Countries with Highest Infection Rate compared to Population

select location, population, MAX(total_cases) as Highesttotalcase, MAX (total_cases/population)*100 as PercentageInfectionRate
from PortfolioProject..CovidDeathsCSV
Group by Location, Population
order by PercentageInfectionRate desc

-- 6. 
-- Countries with Highest Death Count per population

select location, population, MAX(total_deaths) as Highesttotaldeath, MAX (total_deaths/population)*100 as PercentageDeath
from PortfolioProject..CovidDeathsCSV
Group by Location, population
order by PercentageDeath desc

--BREAKING THINGS DOWN BY CONTINENT

-- 7. 
-- Showing contintents with the highest death count per population

select location, continent, MAX(total_deaths) as Highesttotaldeath, MAX (total_deaths/population)*100 as PercentageDeath
from PortfolioProject..CovidDeathsCSV
where continent is not null
Group by Location, continent
order by PercentageDeath desc

-- 8. 
-- GLOBAL NUMBERS
-- Change Datatype to numeric in order to obtain devimal death percentage

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeathsCSV
where continent is not null 
order by 1,2

-- 9.
-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeathsCSV dea
Join PortfolioProject..CovidVaccinationsCSV vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- 10. 
-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeathsCSV dea
Join PortfolioProject..CovidVaccinationsCSV vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3