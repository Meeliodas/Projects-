
select *
from [Porfolio project].dbo.['owid-covid-data Vacs$']
where continent is not null
order by 3,4

--select *
--from [Porfolio project].dbo.['owid-covid-data Dea']
--order by 3,4

--Select data to be used 

select location, date, total_cases, new_cases, total_deaths, population
from [Porfolio project].dbo.['owid-covid-data Vacs$']
order by 1,2

--looking at total cases vs total deaths 
--shows the likely hood of dying of covid in your country

select location, date, total_cases, new_cases, total_deaths, ((CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100) as Deathprecent
from [Porfolio project].dbo.['owid-covid-data Vacs$']
where location like '%nigeria%'
order by 1,2 

--looking total case vs population
--shows the precentage of the country that got infected 

select location, date, Population, total_cases,  ((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100) as Infectedprecent 
from [Porfolio project].dbo.['owid-covid-data Vacs$']
--where location like '%nigeria%'
order by 1,2

--Finding the highest infection rated compared to population 

select location, Population, Max(total_cases) as highestinfectedcount,  MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100) as percentinfected
from [Porfolio project].dbo.['owid-covid-data Vacs$']
--where location like '%nigeria%'
Group by  location, population
order by percentinfected desc

--showing with countries with the highest death count per population

select location, Population, Max(cast(total_deaths as int)) as Totaldeathcount  --MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100) as percentinfected
from [Porfolio project].dbo.['owid-covid-data Vacs$']
--where location like '%nigeria%'
where continent is not null
Group by  location, population
order by Totaldeathcount desc

--by continent

select location, Max(cast(total_deaths as int)) as Totaldeathcount  --MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100) as percentinfected
from [Porfolio project].dbo.['owid-covid-data Vacs$']
--where location like '%nigeria%'
where continent is not null
Group by  location
order by Totaldeathcount desc

select location, Max(cast(total_deaths as int)) as Totaldeathcount  --MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100) as percentinfected
from [Porfolio project].dbo.['owid-covid-data Vacs$']
--where location like '%nigeria%'
where continent is null
Group by  location
order by Totaldeathcount desc

--showing the continent with highest death count

select continent, Max(cast(total_deaths as int)) as Totaldeathcount  --MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100) as percentinfected
from [Porfolio project].dbo.['owid-covid-data Vacs$']
--where location like '%nigeria%'
where continent is not null
Group by  continent
order by Totaldeathcount desc


--Global numbers

select  date, SUM(new_cases) as totalcases, SUM(cast (new_deaths AS)) as total_deaths, SUM(cast (float, new_deaths AS))/Nullif (SUM(float, new_cases))*100 
from [Porfolio project].dbo.['owid-covid-data Vacs$']
where location like '%nigeria%'
where continent is not null
Group by date
order by 1,2 

--looking at total population vs vacination

select dea.continent, vacs.location, dea.date, vacs.population, dea.new_vaccinations
, (SUM(convert(int, dea.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)) as Rollingvaccinated

 From [Porfolio project].dbo.['owid-covid-data Dea']  dea
join [Porfolio project].dbo.['owid-covid-data Vacs$']  vacs
	on dea.location = vacs.location
	and dea.date = vacs.date
where vacs.location is not null
Order by 2,3 

--use cte

with CTE_PopvsVac (continent, location, date, populaion, new_vaccination, Rollingvaccinated)
as
(
select dea.continent, vacs.location, dea.date, vacs.population, dea.new_vaccinations
, (SUM(convert(int, dea.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)) as Rollingvaccinated

 From [Porfolio project].dbo.['owid-covid-data Dea']  dea
join [Porfolio project].dbo.['owid-covid-data Vacs$']  vacs
	on dea.location = vacs.location
	and dea.date = vacs.date
where vacs.location is not null
--Order by 2,3
)
select *, (Rollingvaccinated/populaion)*100
from CTE_PopvsVac

--temp table
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric, 
RollingVaccinated numeric
)


insert into #PercentPopulationVaccinated
select dea.continent, vacs.location, dea.date, vacs.population, dea.new_vaccinations
, (SUM(convert(int, dea.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)) as Rollingvaccinated

 From [Porfolio project].dbo.['owid-covid-data Dea']  dea
join [Porfolio project].dbo.['owid-covid-data Vacs$']  vacs
	on dea.location = vacs.location
	and dea.date = vacs.date
--where vacs.location is not null
--Order by 2,3

select *, (Rollingvaccinated/Population)*100
from #PercentPopulationVaccinated

--creating view for visualization

create view PercentPopulationVaccinated as
select dea.continent, vacs.location, dea.date, vacs.population, dea.new_vaccinations
, (SUM(convert(int, dea.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)) as Rollingvaccinated

 From [Porfolio project].dbo.['owid-covid-data Dea']  dea
join [Porfolio project].dbo.['owid-covid-data Vacs$']  vacs
	on dea.location = vacs.location
	and dea.date = vacs.date
where vacs.location is not null
--Order by 2,3

select *
from PercentPopulationVaccinated