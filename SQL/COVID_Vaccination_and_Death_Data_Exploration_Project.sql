USE [Portfolio Projects];

SELECT *
FROM CovidDeaths$
ORDER BY 3,4;

--SELECT *
--FROM CovidVaccinations$
--ORDER BY 3,4;

--select data we are going to be useing

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
ORDER BY 1,2;

--looking at the percentage of total_cases VS total_deaths

SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths$
WHERE location like '%ethiopia'
ORDER BY date;

--looking at total cases vs population

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths$
WHERE location like '%ethiopia'
ORDER BY date;

--looking at countries with highest infection rate vs population

SELECT location, population, MAX(total_cases) AS HghestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths$
--WHERE location like '%ethiopia'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc;

--looking at countries with highest death rate per population

SELECT location, MAX(cast(Total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- break things down by continent
--looking at continents with highest death count per population

SELECT continent, MAX(cast(Total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--global numbers

SELECT  SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths AS int))/SUM(new_cases))*100 AS DeathPercentage
FROM CovidDeaths$
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;

-- looking at total population vs vacinations using a CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)AS RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac;


--Temp table

DROP TABLE IF EXISTS #PercetPopulationVaccinated
CREATE TABLE #PercetPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_Vaccinaions numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercetPopulationVaccinated
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	on dea.location = vac.location
	AND DEA.date = vac.date
	
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercetPopulationVaccinated;

GO 

-- Creating View to Store data for later visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
    ON dea.location = vac.location
    AND DEA.date = vac.date
WHERE dea.continent IS NOT NULL
;

SELECT * 
FROM PercentPopulationVaccinated;