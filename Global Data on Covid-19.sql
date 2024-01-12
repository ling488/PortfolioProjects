Select *
From PortfolioProject2..CovidDeaths
Where continent is not null
Order by 3,4

Select *
From PortfolioProject2..CovidVaccinations
Order by 3,4

--looking into some important data

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject2..CovidDeaths
Order by 1,2

--total cases Vs total deaths, showing certain country death rate.

Select location, date, total_cases, total_deaths, (convert(int, total_deaths)/convert(int, total_cases))*100 as DeathPercentage
From PortfolioProject2..CovidDeaths
Where location like '%japan%'
Order by 1,2

--total cases Vs population, showing percentage of peple who got the Covid.
Select location, date, total_cases, total_deaths, population, (convert(int, total_cases)/population)*100 as PercentPopulationInfection
From PortfolioProject2..CovidDeaths
Where location like '%states%'
Order by 1,2

--countries with highest infection rate compared to population

Select location, Max(convert(int, total_cases)) as totalInfectionAccount, Max((convert(int, total_cases)/population)*100) as PercentPopulationInfection
From PortfolioProject2..CovidDeaths
Where continent is not null
Group by location
Order by PercentPopulationInfection desc

--countries with highest death count

Select location, Max(cast(total_deaths as int)) as TotalDeathcount
From PortfolioProject2..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

--countries with highest death rate compared to population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount, Max((convert(int, total_deaths)/population)*100) as PercentPopulationDeath
From PortfolioProject2..CovidDeaths
Where continent is not null
Group by location
Order by PercentPopulationDeath desc

--looking into global death counts

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject2..CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount desc


--continuing to break things down by continent

Select continent, Sum(new_cases) as TotalCasesCount, Sum(new_deaths) as TotalDeathCount, (Sum(new_deaths)/Sum(new_cases))*100 as DeathPercentage
From PortfolioProject2..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--total population Vs vaccinations

Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject2..CovidDeaths as dea
Join PortfolioProject2..CovidVaccinations as vac
 On dea.location = vac.location
 and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
From PortfolioProject2..CovidDeaths as dea
Join PortfolioProject2..CovidVaccinations as vac
 On dea.location = vac.location
 and dea.date = vac.date
Where dea.continent is not null

)
Select *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
From PopvsVac

--temp table
Drop Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated 
Select  dea.continent, dea.location, dea.date, dea.population, convert(numeric, vac.new_vaccinations)
, SUM(convert(numeric, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
From PortfolioProject2..CovidDeaths as dea
Join PortfolioProject2..CovidVaccinations as vac
 On dea.location = vac.location
 and dea.date = vac.date

Select *, (RollingPeopleVaccinated/population)*100 as PercentagePopulationVaccinated
From #PercentPopulationVaccinated

--use view

Create View PercentPopulationVaccinated as
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject2..CovidDeaths as dea
Join PortfolioProject2..CovidVaccinations as vac
 On dea.location = vac.location
 and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated