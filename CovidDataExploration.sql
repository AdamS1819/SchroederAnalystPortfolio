select *
from CovidProject..CovidDeaths
order by 3, 4

select *
from CovidProject..CovidVaccines
order by 3, 4

-- Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from CovidProject.. CovidDeaths
order by 1, 2

--Looking at countries with highest percent pop infected

Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as PercentPopInfected
from PortProject.. CovidDeaths
group by location, population
order by PercentPopInfected desc

-- Countries with highest infection rates

Select location, population, date, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopInfected
from PortProject..CovidDeaths
group by location, population, date
order by PercentPopInfected desc
--Countries with highest death counts

Select location, sum(cast(new_deaths as bigint)) as TotalDeathCount 
From PortProject.. CovidDeaths
where continent is null
and location not in ('World', 'Upper middle income', 'High income', 'Lower middle income', 'European Union', 'Low income', 'International')
group by location
order by TotalDeathCount desc

--Same thing by continent
--Showing continents with the highest death count

Select continent, max(cast(total_deaths as int)) as TotalDeathCount 
From PortProject.. CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Daily global counts

Select date, sum(new_cases) as dailyCases, sum(cast(new_deaths as int)) as dailyDeathCount, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
From CovidProject..CovidDeaths
where continent is not null
group by date
order by 1, 2


--Global totals

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as totalDeathCount, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
From PortProject..CovidDeaths
where continent is not null
--group by date
order by 1, 2

-- Total pop vs vaccines

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order
by dea.location, dea.date) as RollingVaccinations
from CovidProject.. CovidDeaths dea
join CovidProject..CovidVaccines vac
	on dea.location = vac.location
	and	dea.date = vac.date
where dea.continent is not null
order by 2, 3

With PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinations)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order
by dea.location, dea.date) as RollingVaccinations
from CovidProject.. CovidDeaths dea
join CovidProject..CovidVaccines vac
	on dea.location = vac.location
	and	dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingVaccinations/population)*100
from PopvsVac

DROP Table if exists #PopulationVaccinations
Create table #PopulationVaccinations
(
continent nvarchar(255), 
location nvarchar(255),
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingVaccinations numeric
)

Insert into #PopulationVaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order
by dea.location, dea.date) as RollingVaccinations
from CovidProject.. CovidDeaths dea
join CovidProject..CovidVaccines vac
	on dea.location = vac.location
	and	dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

select *, (RollingVaccinations/population)*100
from #PopulationVaccinations

--Creating view to store data
Create view PopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order
by dea.location, dea.date) as RollingVaccinations
from CovidProject.. CovidDeaths dea
join CovidProject..CovidVaccines vac
	on dea.location = vac.location
	and	dea.date = vac.date
where dea.continent is not null
--order by 2, 3