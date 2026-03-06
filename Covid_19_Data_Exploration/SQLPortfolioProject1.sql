SELECT *
FROM PortfolioProject..CovidDeaths
--WHERE continent is NOT NULL
ORDER BY 3,4 


--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4 

-- Select Data that we're going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1, 2


-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract Covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE total_cases <> 0 and location like '%states%' 
and continent is NOT NULL
ORDER BY 1, 2


-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases / population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
and continent is NOT NULL
ORDER BY 1, 2


-- Looking at countries with highest infection rate compared to population 

SELECT location, population, MAX( total_cases) AS HighestInfectionCount, max((total_cases / population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is NOT NULL
GROUP BY population, location
ORDER BY PercentPopulationInfected desc


-- Showing countries with the highest death count per population 

SELECT location, population, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is NOT NULL
GROUP BY population, location
ORDER BY TotalDeathCount desc


-- Let's Break Things Down by Continent

-- Showing the Continents with the highest death counts

SELECT location,  MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is NULL and location in ('Africa', 'Asia', 'Europe', 'North America', 'Oceania', 'South America', 'World', 'European Union (27)')
GROUP BY  location
ORDER BY TotalDeathCount desc


-- Global Numbers


SELECT  date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentaheGlobally 
FROM PortfolioProject..CovidDeaths
--WHERE total_cases <> 0  
where new_cases <> 0  and continent is NOT NULL
GROUP BY date
ORDER BY 1, 2



-- Looking at Total Population vs  Vaccinations 

 -- USE CTE
 with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
 as 
 (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
 
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --ORDER by 2,3
)

 SELECT *, (RollingPeopleVaccinated/Population)*100
 FROM PopvsVac
 



-- Temp Table


DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
 
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --ORDER by 2,3

 Select *, (RollingPeopleVaccinated/Population)*100
 FROM #PercentPopulationVaccinated


 -- Creating view to store data for later visualizations 

 CREATE View PercentPopulationVaccinated as
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
 
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
--ORDER by 2,3

Select *
from PercentPopulationVaccinated
