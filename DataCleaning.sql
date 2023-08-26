SELECT *
FROM CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4



Select Location, date, total_cases, new_cases, total_deaths, population
FROM FirstProject.dbo.CovidDeaths
ORDER BY 1,2

-- 
-- Shows likelihood off dying if you have cavid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM FirstProject.dbo.CovidDeaths
WHERE location like '%Vietnam%'
ORDER BY 1,2

--Total cases vs population
-- Shows what percentage of population got Covid
Select Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
FROM FirstProject.dbo.CovidDeaths
WHERE location like '%Vietnam%'
ORDER BY 1,2

-- Country with the Highest infection rate comnpared to population

Select Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as HighestDeathPercentage
FROM FirstProject.dbo.CovidDeaths
--WHERE location like '%Vietnam%'
GROUP BY location, population
ORDER BY HighestDeathPercentage DESC

--Showing the country with the highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM FirstProject.dbo.CovidDeaths
--WHERE location like '%Vietnam%'
WHERE continent is not null
GROUP BY location 
ORDER BY TotalDeathCount DESC

--Break thing down by continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM FirstProject.dbo.CovidDeaths
--WHERE location like '%Vietnam%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Showing the continent with the highest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM FirstProject.dbo.CovidDeaths
--WHERE location like '%Vietnam%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global number

Select SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as NewDeathPercentage --, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM FirstProject.dbo.CovidDeaths
--WHERE location like '%Vietnam%'
WHERE continent is not null
--GROUP BY date 
ORDER BY 1,2


--Looking at Total Population vs Vaccination

WITH PopVsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations AS int)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM FirstProject.dbo.CovidDeaths as dea
JOIN FirstProject..CovidVaccinations as vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as VaccinationsRate
From PopVsVac



--Use CTE, number of lolums in CTE must equal to number of column in the SQL

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
()

--Temp Table, Note: Should use DROP Table if exists when using temp table

DROP Table if exists #PercentPopulationVaccinated1
Create Table #PercentPopulationVaccinated1
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT into #PercentPopulationVaccinated1
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(Cast(vac.new_vaccinations AS int)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM FirstProject.dbo.CovidDeaths as dea
JOIN FirstProject..CovidVaccinations as vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated1


--Create View to store data for later visualation
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(Cast(vac.new_vaccinations AS int)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM FirstProject.dbo.CovidDeaths as dea
JOIN FirstProject..CovidVaccinations as vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
