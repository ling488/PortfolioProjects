Select *
From PortfolioProject2..CovidDeaths
Where continent is not null
Order by 3,4

Select *
From PortfolioProject2..CovidVaccinations
Order by 3,4

--looking into some important data

Select location, date, total_cases, new_cases, total_deaths, new_deaths, population
From PortfolioProject2..CovidDeaths
Order by 1,2

--total cases Vs total deaths, showing certain country death rate.

Select location, date, total_cases, total_deaths, (convert(int, total_deaths)/convert(int, total_cases))*100 as DeathPercentage
From PortfolioProject2..CovidDeaths
Where location like '%japan%'
Order by 1,2

--total cases Vs population, showing percentage of peple who got the Covid.

Select location, date, total_cases, population, (convert(int, total_cases)/population)*100 as InfectionPercent
From PortfolioProject2..CovidDeaths
Where location like '%states%'
Order by 1,2

--global death rate

Select sum( new_cases) as TotalCasesCount, sum(new_deaths) as TotalDeathCount, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage 
From PortfolioProject2..CovidDeaths
Where location is not null

--death counts per continent

Select location, max(convert(float, total_deaths)) as TotalDeathCount
From PortfolioProject2..CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount desc

--the above result looks inccorrect. looking to another way.

Select continent, sum(new_deaths) as TotalDeathCount
From PortfolioProject2..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--infection rate per country population

Select location, population, sum(new_cases) as TotalInfectionCount, sum(new_cases)/population*100 as percentPopulationInfection
From PortfolioProject2..CovidDeaths
Where continent is not null
Group by location, population
Order by percentPopulationInfection desc

--infection rate per country population and date

Select location, population, date, sum(new_cases) as TotalInfectionCount, sum(new_cases)/population*100 as percentInfection
From PortfolioProject2..CovidDeaths
Where continent is not null
Group by location, population, date
Order by 1, 3

--vaccinated vs population

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject2..CovidDeaths as dea
Join PortfolioProject2..CovidVaccinations as vac
 On dea.location = vac.location
 and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--use CTE

With PopVsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject2..CovidDeaths as dea
Join PortfolioProject2..CovidVaccinations as vac
 On dea.location = vac.location
 and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 PercentPepoleVaccinated
From PopVsVac
Order by 2, 3

--temp table

Drop table if exists #PercentPepoleVaccinated
Create table #PercentPepoleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population float,
New_vaccination float,
RollingPeopleVaccinated float
)
Insert into #PercentPepoleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject2..CovidDeaths as dea
Join PortfolioProject2..CovidVaccinations as vac
 On dea.location = vac.location
 and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100 PercentPepoleVaccinated
From #PercentPepoleVaccinated
Order by 2, 3

--use view

Create view PercentPepoleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject2..CovidDeaths as dea
Join PortfolioProject2..CovidVaccinations as vac
 On dea.location = vac.location
 and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100 PercentPepoleVaccinated
From PercentPepoleVaccinated
Order by 2, 3