--SELECT * 
--FROM [dbo].[CovidVaccinations]
--ORDER BY 3, 4

SELECT * 
FROM [dbo].[CovidDeaths]


-- Select data that we are ging to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From [dbo].[CovidDeaths]
ORDER BY 1, 2


-- Lookng at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
From [dbo].[CovidDeaths]
Where Location like '%States%'
ORDER BY 1, 2

-- looking at Total Cases vs Population

Select Location, date, total_cases, population, (total_cases/population) *100 as CasesPercentage
From [dbo].[CovidDeaths]
Where Location like '%States%'
ORDER BY 1, 2

--Looking at Contries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HigheastInfectionCount, MAX(total_cases/population) *100 as CasesPercentage
From [dbo].[CovidDeaths]
-- Where Location like '%States%'
Group by location, population
Order By CasesPercentage desc


-- Global Numbers
Select continent, SUM(new_cases) as HigheastInfectionCount, MAX(total_cases/population) *100 as CasesPercentage
From [dbo].[CovidDeaths]
-- Where Location like '%States%'
Group by continent
Order By CasesPercentage

-- Showing countries with highest death count per population
Select date, SUM(new_cases) as TotalCasesAcount, SUM(cast(new_death as int)) as TotalNewDeathCount, TotalNewDeathCount/TotalCasesAcount as DeathPerCentage
From [dbo].[CovidDeaths]
-- Where Location like '%States%'
Where continent is not NULL
Group by date
Order By 1, 2

-- Showing coninents with the highest dath count per population

Select continent, MAX(cast(total_deaths as int))as TotalDeathCount
From [dbo].[CovidDeaths]
-- Where Location like '%States%'
Where continent is not NULL
Group by continent
Order By TotalDeathCount desc




-- Global Numbers
Select date, sum(new_cases) total_cases, sum(cast(new_deaths as int)) total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage
From [dbo].[CovidDeaths]
where continent is not NULL and new_cases <> 0
Group by date
order by 1, 2



Select SUM(new_cases) as TotalCasesCount
,Sum(cast(new_deaths as int)) as TotalDeaths
,(Sum(cast(new_deaths as int))/SUM(new_cases)) *100 as DeathsPercentage
From [dbo].[CovidDeaths]
Where continent is not NULL
--Group by continent
Order By 1, 2

-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
From [dbo].[CovidVaccinations] vac
Join [dbo].[CovidDeath] dea
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
order by 2, 3


-- Use CTE
With PopvasVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
From [dbo].[CovidVaccinations] vac
Join [dbo].[CovidDeath] dea
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvasVac

--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
From [dbo].[CovidVaccinations] vac
Join [dbo].[CovidDeath] dea
On dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not NULL
--order by 2, 3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



-- Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
From [dbo].[CovidVaccinations] vac
Join [dbo].[CovidDeath] dea
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
--Order by 2, 3

Select *
From PercentPopulationVaccinated

