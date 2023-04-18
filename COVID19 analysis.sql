Select *
From PortfolioProject..CovidDeaths
order by location, date

Select *
From PortfolioProject..CovidVaccinations
order by location, date


Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by location, date


-- Looking at total cases vs toatal deaths
-- Shows the the percent of the infected population that have died in the United Staes on that date
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percent_infected
From PortfolioProject..CovidDeaths
where location like '%states%'
order by  date

-- Looking at Total Cases vs Population
-- Shiws the percent of United States population that was infected on that date
Select location, date, total_cases, population, (total_cases/population)*100 as infected_percent
From PortfolioProject..CovidDeaths
where location like '%states%'
order by  date


--Looking at Countries with highest Infection rate compared to population
Select location, population, MAX(total_cases) as highest_infection_count , Max(total_cases/population)*100 as highest_infected_percent
From PortfolioProject..CovidDeaths
group by location, population
order by highest_infected_percent desc


--Looking at Countries with highest Death counts
Select location, population, MAX(CAST(total_deaths as int)) as highest_death_count , Max(total_deaths/population)*100 as highest_death_percent
From PortfolioProject..CovidDeaths
where continent is not null -- excludes world, and the continents
group by location, population
order by highest_death_count desc



--Looking at Countries with highest Death counts
Select location, MAX(CAST(total_deaths as int)) as highest_death_count , Max(total_deaths/population)*100 as highest_death_percent
From PortfolioProject..CovidDeaths
where (continent is null) and (location != 'World') and (location != 'International')
group by location
order by highest_death_count desc


-- GLOBAL NUMBERS
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as death_percent
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by  date


--Looking at Total Population vs Vacccinations in a temp table
DROP TABLE IF EXISTS #TempCovid 
CREATE TABLE #TempCovid(
continent varchar(255),
location varchar(255),
date date, -- changed the data type to just date
population float,
new_vaccinations int,
total_vaccinations int
)

INSERT INTO #TempCovid
Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) Over (Partition by vac.location Order by vac.date) as total_vaccinations
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vac
	on deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null
order by deaths.location, deaths.date

-- Temp Table with vaccination deails along with rolling total vaccination by date
Select *
From #TempCovid
where continent is not null and new_vaccinations is not null
order by location, date

-- Alter and Update Table

Alter Table #TempCovid
Add percent_vaccinated float;

Update #TempCovid
Set percent_vaccinated = (total_vaccinations/population)*100

Select *
From #TempCovid
where continent is not null  and total_vaccinations is not null and location like '%states%'
order by location, date

-- Percent of the population vaccinated by 2021-4-30 fpr each country
Select location, Max(percent_vaccinated) as total_percent_vaccinated
From #TempCovid
Group by location
order by location


