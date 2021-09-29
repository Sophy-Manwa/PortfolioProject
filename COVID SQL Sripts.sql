USE [Portfolio Project]
GO

SELECT * 
FROM dbo.['Covid Vaccinations$']
ORDER BY 3, 4 


SELECT *
FROM [dbo].[Covid_Deaths$]
WHERE continent is not null
ORDER BY 1,2


--SELECT DATA THAT WE ARE GOING TO USE

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM [dbo].[Covid_Deaths$]
WHERE continent is not null
ORDER BY 1,2

--lOOKING AT TOTAL CASES
SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [dbo].[Covid_Deaths$]
WHERE location like '%kenya%'
ORDER BY 1,2

--lOOKING AT TOTAL CASES VS TOTAL POPULATION
--SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID
SELECT location,date,total_cases,population,(total_cases/population)*100 as PercentPopulation
FROM [dbo].[Covid_Deaths$]
WHERE continent is not null
--WHERE location like '%kenya%' 
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population)*100) as PercentPopulationInfected
FROM [dbo].[Covid_Deaths$]
WHERE continent is not null
GROUP BY population, location
ORDER BY PercentPopulationInfected desc

--Showing countries with highest death count
SELECT location,MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM [dbo].[Covid_Deaths$]
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--Lets Break things down by continent

--Showing the continents with the highest death count per population

SELECT continent,MAX(CAST(total_deaths AS int)) as TotalDeathCount 
FROM [dbo].[Covid_Deaths$]
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS

SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [dbo].[Covid_Deaths$]
--WHERE location like '%kenya%'
--GROUP BY date
ORDER BY 1,2

--Looking at Total Population vs Vaccinations
--SET ANSI_WARNINGS OFF
SELECT dea.continent, dea.location,dea.date,dea.population,Vac.new_vaccinations,SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated--,(RollingPeopleVaccinated /population)*100
FROM [dbo].[Covid_Deaths$] dea
Join  dbo.['Covid Vaccinations$'] Vac
 on dea.location= Vac.location
 and dea.date = Vac.date
 WHERE dea.continent is not null
 ORDER BY 2,3

 ---USE CTE
 With popvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
 as
 (
 SELECT dea.continent, dea.location,dea.date,dea.population,Vac.new_vaccinations,SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated--,(RollingPeopleVaccinated /population)*100
FROM [dbo].[Covid_Deaths$] dea
Join  dbo.['Covid Vaccinations$'] Vac
 on dea.location= Vac.location
 and dea.date = Vac.date
 WHERE dea.continent is not null
 --ORDER BY 2,3
 )
 SELECT * ,(RollingPeopleVaccinated/population)*100 
 FROM popvsVac

 
 ---TEMP Table
 
 DROP TABLE IF EXISTS dbo.percentpopulationvaccinated
 CREATE TABLE #percentpopulationvaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric,
 )

INSERT INTO #percentpopulationvaccinated
SELECT dea.continent, dea.location,dea.date,dea.population,Vac.new_vaccinations,SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated--,(RollingPeopleVaccinated /population)*100
FROM [dbo].[Covid_Deaths$] dea
Join  dbo.['Covid Vaccinations$'] Vac
 on dea.location= Vac.location
 and dea.date = Vac.date
 WHERE dea.continent is not null
 --ORDER BY 2,3
  
 SELECT * ,(RollingPeopleVaccinated/population)*100 
 FROM percentpopulationvaccinated

 --Creating View
CREATE View percentpopulationvaccinated as
SELECT dea.continent, dea.location,dea.date,dea.population,Vac.new_vaccinations,SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated--,(RollingPeopleVaccinated /population)*100
FROM [dbo].[Covid_Deaths$] dea
Join  dbo.['Covid Vaccinations$'] Vac
 on dea.location= Vac.location
 and dea.date = Vac.date
 WHERE dea.continent is not null
 --ORDER BY 2,3


SELECT * 
 FROM percentpopulationvaccinated
