/*
In this project, we are going to do a data exploration from covid 19 dataset
about covid death and covid vaccinations
*/

SELECT *
FROM CovidDeaths
WHERE [continent] is null
ORDER BY 3,4

-- Looking at Total Cases vs Total Deaths

SELECT [location], total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM CovidDeaths
--WHERE [location] LIKE '%indo%'
ORDER BY 1,2

-- Looking at total cases vs populations

SELECT [location], total_cases, population, (total_cases/population) * 100 as CasesPercentage
FROM CovidDeaths
WHERE [location] LIKE '%indo%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT [location], population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected
FROM CovidDeaths
GROUP BY [location], population
ORDER BY PercentPopulationInfected DESC

-- Showing countries with highest death count 
SELECT [location],MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY [location]
ORDER BY TotalDeathCount DESC

-- Showing countries with highest death count by continent
SELECT [location],MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent is null and [location] not like '%income%'
GROUP BY [location]
ORDER BY TotalDeathCount DESC

-- Global Numbers
SELECT [location], sum(new_cases) as total_cases , sum(new_deaths) as total_deaths, 
(sum(new_deaths)/ nullif(sum(new_cases),0))*100 as deathpercentage
FROM CovidDeaths
WHERE continent is not null 
group by [location]
ORDER BY 1,2

-- Aggregate with vaccinations data
-- Looking at total populations vs vaccinations

SELECT dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.[location], dea.date) as RollingPeopleVaccinated
From CovidDeaths as dea
Join CovidVaccinations as vac
    on dea.[location] = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null --and dea.[location] like '%indo%'
ORDER BY 2, 3 

-- Use cte to know the percentage of people get vaccinated over the populations
WITH popvac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
( 
    SELECT dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations,
    sum(vac.new_vaccinations) over (partition by dea.location order by dea.[location], dea.date) as RollingPeopleVaccinated
    From CovidDeaths as dea
    Join CovidVaccinations as vac
        on dea.[location] = vac.location
        and dea.date = vac.date
    WHERE dea.continent is not null
)

select *, (RollingPeopleVaccinated/Population) * 100 as vaccinatedpercentage
from popvac

-- using temp table
DROP TABLE IF EXISTS #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
(
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)

INSERT INTO #percentpopulationvaccinated
SELECT dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.[location], dea.date) as RollingPeopleVaccinated
From CovidDeaths as dea
Join CovidVaccinations as vac
    on dea.[location] = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null 

SELECT *
FROM #percentpopulationvaccinated

CREATE VIEW PercentPopulationVaccinated as 
    SELECT dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations,
    sum(vac.new_vaccinations) over (partition by dea.location order by dea.[location], dea.date) as RollingPeopleVaccinated
    From CovidDeaths as dea
    Join CovidVaccinations as vac
        on dea.[location] = vac.location
        and dea.date = vac.date
    WHERE dea.continent is not null --and dea.[location] like '%indo%'
--ORDER BY 2, 3 
    
SELECT *
FROM PercentPopulationVaccinated