SELECT * 
FROM CovidDeaths
WHERE continent IS NOT NULL
order by 3,4


-- SELECT Data we're going to be using
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country (rough estimates)
SELECT location,date,total_cases,total_deaths, TRY_CAST(total_deaths AS numeric) / TRY_CAST(total_cases AS numeric)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%costa%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location,date,total_cases,population, TRY_CAST(total_cases AS numeric) / TRY_CAST(population AS numeric)*100 AS InfectionPercentage
FROM CovidDeaths
WHERE location like '%costa%'
ORDER BY 1,2

-- Looking at Countries with highest infection rate compared to population

SELECT
  location, MAX(TRY_CAST(total_cases AS numeric)) AS HighestInfectionCount, population, MAX(TRY_CAST(total_cases AS numeric)) * 100.0 / population AS InfectionPercentage
FROM CovidDeaths
GROUP BY location,population
ORDER BY InfectionPercentage DESC;


-- This shows the countries with the highest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Broken down by continent
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS
SELECT
  date,
  SUM(TRY_CAST(new_cases AS INT)) AS TotalCases,
  SUM(TRY_CAST(new_deaths AS NUMERIC)) AS TotalDeaths,
  CASE
    WHEN SUM(TRY_CAST(new_cases AS INT)) = 0 THEN NULL
    ELSE SUM(TRY_CAST(new_deaths AS INT)) * 100.0 / SUM(TRY_CAST(new_cases AS INT))
  END AS DeathPercentage
FROM
  CovidDeaths
WHERE
  continent IS NOT NULL
GROUP BY
	date
ORDER BY
  1,2

-- Looking at Total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(TRY_CAST(vac.new_vaccinations AS NUMERIC)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingpeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON  dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- USE CTE
WITH PopVsVac (continent,location,date,population,New_Vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(TRY_CAST(vac.new_vaccinations AS NUMERIC)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingpeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON  dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, ( RollingPeopleVaccinated/population)*100
FROM PopVsVac


-- Creating view for later data visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(TRY_CAST(vac.new_vaccinations AS NUMERIC)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingpeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON  dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated

