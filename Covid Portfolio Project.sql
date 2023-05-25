select * from PortfolioProject..CovidDeaths
order by 3,4;

-- we see that some continents are mentioned as null. due to this our calculcations may vary a bit so to get over it. where continent is null, the continent value is mentioned in location 

select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;

--select * from PortfolioProject..CovidVaccinations
--order by 3,4;

-- Select data that we are going to use

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;

-- Looking at Total Cases vs Total Deaths 

-- Shows the likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths
--where location = 'India'
where continent is not null
order by 1,2;

-- Looking at Total cases vs Population

--Shows what percentage of population were infected by covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected  
from PortfolioProject..CovidDeaths
where location = 'India' and  continent is not null
order by 1,2;


--Looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as HighestPercentPopulationInfected  
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by HighestPercentPopulationInfected desc

-- Showing countries with highest death percentage per population

select location, population, max(cast(total_deaths as int)) as HighestDeaths, max((cast(total_deaths as int)/population)*100) as Percentagehighestdeathpopulation 
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by Percentagehighestdeathpopulation desc


---- Showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null -- and location='China'
group by location
order by TotalDeathCount desc

-- Lets break things down by continent

--showing the continents with hightest death counts

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where continent is  null -- and location='China'
group by continent
order by TotalDeathCount desc

-- Global numbers

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercent
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2


select  sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercent
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
--order by 1,2


select * from PortfolioProject..CovidVaccinations

--Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join
PortfolioProject..CovidVaccinations as vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by vac.new_vaccinations desc

--Using CTE(Common Table Expression, CTE is a named temporary result set which is used to manipulate the complex sub-queries data. 
--This exists for the scope of a statement.)

With PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join
PortfolioProject..CovidVaccinations as vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
)
Select *,(RollingPeopleVaccinated/population)*100  from PopvsVac

--Temp Table

drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(200),
Location  nvarchar(200),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join
PortfolioProject..CovidVaccinations as vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null;

Select *,(RollingPeopleVaccinated/population)*100  from #PercentPopulationVaccinated;


-- Create View

Create view PercentPopulationVaccinated as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join
PortfolioProject..CovidVaccinations as vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated


















