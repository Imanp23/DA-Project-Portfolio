/*
Covid 19 Data Exploration 
*/


-- Select Data to be explored


SELECT [location]
      ,[date]
      ,[total_cases]
      ,[new_cases]
      ,[total_deaths]
      ,[population]
  FROM [Portfolio Project].[dbo].['COVID DEATHS]
  ORDER BY 1,2



-- Total Cases vs Total Deaths


SELECT [location]
      ,[date]
      ,[total_cases]
      ,[total_deaths]
      ,((1.0*CAST(total_deaths AS int)) / CAST(total_cases AS int))*100.0 as deathpercentage
  FROM [Portfolio Project].[dbo].['COVID DEATHS]
  ORDER BY 1,2



-- Total Cases vs Population


SELECT [location]
      ,[date]
      ,[total_cases]
      ,population
      ,((1.0*total_cases) / population)*100.0 as percentagepopulationinfected
  FROM ['COVID DEATHS]
  ORDER BY 1,2



-- Countries with Highest Infection Rate compared to Population

SELECT Location
      ,Population
      ,MAX(total_cases) as HighestInfectionCount
	  ,MAX((total_cases/population))*100 as PercentPopulationInfected
FROM ['COVID DEATHS]
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc



-- Countries with Highest Death Count per Population


SELECT Location
      ,MAX(Total_deaths) as TotalDeathCount
FROM ['COVID DEATHS]
WHERE continent is not null 
GROUP BY Location
ORDER BY TotalDeathCount DESC



-- Percentages and Totals by Continent

	-- Highest death count per population


SELECT continent 
      ,MAX(total_deaths) totaldeathcount
      ,population
FROM ['COVID DEATHS]
WHERE continent is NOT NULL
GROUP BY continent, population
ORDER BY 2 DESC



-- GLOBAL NUMBERS


SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM ['COVID DEATHS]
WHERE continent is not null 
ORDER BY 1,2



-- Total Population vs Vaccinations


SELECT dth.continent
      ,dth.location
	  ,dth.date
	  ,dth.population
	  ,vac.new_vaccinations
      ,SUM(CONVERT(int,vac.new_vaccinations)) OVER 
	  (PARTITION BY dth.Location Order by dth.location, dth.Date) as RollingPeopleVaccinated
FROM ['COVID DEATHS] dth
JOIN CovidVaccinations$ vac
	ON dth.location = vac.location
	AND dth.date = vac.date
WHERE dth.continent IS NOT NULL 
ORDER BY 2,3



-- Using CTE to perform Calculation on Partition By in previous query


WITH popvsvac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dth.continent
      ,dth.location
	  ,dth.date
	  ,dth.population
	  ,vac.new_vaccinations
      ,SUM(CONVERT(int,vac.new_vaccinations)) OVER 
	  (PARTITION BY dth.Location Order by dth.location, dth.Date) as RollingPeopleVaccinated
FROM ['COVID DEATHS] dth
JOIN CovidVaccinations$ vac
	ON dth.location = vac.location
	AND dth.date = vac.date
WHERE dth.continent IS NOT NULL 
)
SELECT *, (RollingPeopleVaccinated/Population)*100 percentpopulationvaccinated
FROM popvsvac



-- Using Temp Table to perform Calculation on Partition By in previous query


DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dth.continent
      ,dth.location
	  ,dth.date
	  ,dth.population
	  ,vac.new_vaccinations
      ,SUM(CONVERT(int,vac.new_vaccinations)) OVER 
	  (PARTITION BY dth.Location Order by dth.location, dth.Date) as RollingPeopleVaccinated
FROM ['COVID DEATHS] dth
JOIN CovidVaccinations$ vac
	ON dth.location = vac.location
	AND dth.date = vac.date

SELECT *
      ,(RollingPeopleVaccinated/Population)*100 percentvaccinated
FROM #PercentPopulationVaccinated




-- Creating View to store data for later visualizations


CREATE VIEW Percent_PopulationVaccinated AS
SELECT dth.continent
      ,dth.location
	  ,dth.date
	  ,dth.population
	  ,vac.new_vaccinations
      ,SUM(CONVERT(int,vac.new_vaccinations)) OVER 
	  (PARTITION BY dth.Location Order by dth.location, dth.Date) as RollingPeopleVaccinated
FROM ['COVID DEATHS] dth
JOIN CovidVaccinations$ vac
	ON dth.location = vac.location
	AND dth.date = vac.date
WHERE dth.continent IS NOT NULL
