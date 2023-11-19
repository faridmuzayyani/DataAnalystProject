SELECT * FROM CovidProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * FROM CovidProject..CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM CovidProject..CovidDeaths
WHERE location like '%states%' and continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as percent_population_infected
FROM CovidProject..CovidDeaths
--WHERE location like 'Indonesia'
WHERE continent is not null
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as highest_infection_count, MAX(total_cases/population)*100 as percent_population_infected
FROM CovidProject..CovidDeaths
--WHERE location like 'Indonesia'
WHERE continent is not null
GROUP BY location, population
ORDER BY percent_population_infected desc

--Showing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths as int)) as total_death_count
FROM CovidProject..CovidDeaths
--WHERE location like 'Indonesia'
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count desc

--LET'S BREAK THINGS DOWN BY CONTINENT (*)
--Showing continents with the highest death count per population

SELECT location, MAX(CAST(total_deaths as int)) as total_death_count
FROM CovidProject..CovidDeaths
--WHERE location like 'Indonesia'
WHERE continent is null
GROUP BY location
ORDER BY total_death_count desc

--GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_death, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM CovidProject..CovidDeaths
--WHERE location like '%states%' 
WHERE continent is not null
--ORDER BY date
ORDER BY 1,2

--Looking at Total Population vs Vacctinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location 
ORDER BY dea.location, dea.date) as rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

WITH PopvsVac(continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location 
ORDER BY dea.location, dea.date) as rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM PopvsVac

--TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location 
ORDER BY dea.location, dea.date) as rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (rolling_people_vaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location 
ORDER BY dea.location, dea.date) as rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated