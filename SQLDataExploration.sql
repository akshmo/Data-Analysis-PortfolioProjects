Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Select data we're gonna be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2

--Looking at Total Cases vs Population
--Shows what % of population got Covid

Select location, date, total_cases, population, (total_cases/population)*100 DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2

--Looking at countries with highest infection rate compared to population

Select location, population, Max(total_cases) HighestInfectionCount, Max((total_cases/population))*100 PercentPopulationInfected 
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by location, population
Order by PercentPopulationInfected

--Showing countries with highest death count per population

Select location, Max(cast (total_deaths as int)) TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
Order by TotalDeathCount Desc

--LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, Max(cast (total_deaths as int)) TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount Desc

--GLOBAL NUMBERS

Select Sum(new_cases), Sum(cast(new_deaths as int)), Sum(cast(new_deaths as int))/Sum(new_cases)*100 DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
Order by 1,2

--JOINING THE TWO TABLES
--Looking at Total population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Order by 2,3

--Use CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
--Order by 2,3
)
Select*, (RollingPeopleVaccinated/population)*100
From PopvsVac

--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
--Order by 2,3

Select*, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Creating view to store data for  later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated 



