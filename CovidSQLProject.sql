select * 
from project..deaths
order by 3,4

-- select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from project..deaths
order by 1,2

-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from project..deaths
where location like '%states%'
order by 1,2


-- looking at total cases vs population
 --shows what percentage of population got covid
select location, date,population, total_cases , (total_deaths/population)*100 as percentpopulationinfected
from project..deaths
where location like '%states%'
order by 1,2

-- looking at countries with highes infection rate compared to population

select location, population , max(total_cases) as highesetInfectioncount,  max((total_deaths/population))*100 as percentpopulationinfected
from project..deaths
--where location like '%states%'
group by location,population
order by percentpopulationinfected desc

-- lets break things down by continent

-- showing continents with the highest death count per population
select continent,  max(cast(total_deaths as float) ) as totaldeathcount
from project..deaths
where continent is not null
group by continent
order by totaldeathcount desc



-- global numbers

select  date,sum( new_cases)as total_cases, sum(cast(new_deaths as float)) as total_deaths,sum(cast(new_deaths as float))/sum( new_cases) as DeathPercentage
from project..deaths
where continent is not null
group by date
order by 1,2

--looking at total population vs vaccinaitons



-- use cte 
with popvsvac(continent, location, date, population,new_vaccinations, rollingpeoplevaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated
--,(RollingPeopleVaccinated/population)*100 as totalvaccinatedpercentage
from project..deaths dea
join project..Vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, ( rollingpeoplevaccinated/population)*100
from popvsvac


--temptable
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(continent  nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated
--,(RollingPeopleVaccinated/population)*100 as totalvaccinatedpercentage
from project..deaths dea
join project..Vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

-- create view to store data for later visualization
create view percentpopulationvaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated
--,(RollingPeopleVaccinated/population)*100 as totalvaccinatedpercentage
from project..deaths dea
join project..Vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from percentpopulationvaccinated56 