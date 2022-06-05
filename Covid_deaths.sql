select * from covid19.dbo.covidDeath
order by 3,4

--select * from covid19.dbo.covidVaccination
--order by 3,4

--select Data that wee are going to be using

select location,date,total_cases,new_cases,total_deaths from covid19..covidDeath
order by 1,2

--Looking at  total cases vs Total Deaths
select location,date,total_cases,total_deaths,cast(total_deaths as float)*100/cast(total_cases as float)
percentage_death from covid19..covidDeath
where location like 'Belgium'
order by 1,2

--Looking total cases vs population
select location,date,population,total_cases,
round(cast(total_cases as float)/cast(population as float),4)*100 
as total_case_percentage from  covid19..covidDeath
where location like 'Belgium'

--Country with Hightest Infection rated compared to population
select location,population,Max(total_cases) as HighestInfectionCount,
Max(round(cast(total_cases as float)/cast(population as float),4)*100)
as percentage_population_infect from  covid19..covidDeath
--where location like 'Belgium'
group by location,population
order by percentage_population_infect desc

--Country by Hightest Death count per population
select location,population,Max(total_deaths) as HighestDeathCount,
Max(round(cast(total_deaths as float)/cast(population as float),4)*100)
as percentage_population_death from  covid19..covidDeath
where  continent is not null
group by location,population
order by percentage_population_death desc

--Country by highest Death count
select location,Max(cast(total_deaths as float)) as TotalDeathCount from covid19..covidDeath
where continent is  null
group by location
order by 2 desc

--Let's break down by continent
select continent,max(cast(total_deaths as float)) as TotalDeathCount from covid19..covidDeath
where continent is not  null
group by continent
order by 2 desc

select distinct continent from covid19..covidDeath

--Global Numbers
select sum(cast(new_cases as float)) as total_new_cases,sum(cast(new_deaths as float)) as total_new_deaths,sum(cast(new_deaths as float))*100/sum(case when cast(new_cases as float)=0 then null else cast(new_cases as float) end )
percentage_death from covid19..covidDeath
where continent is not null
--group by date
order by 1,2 

--looking at total vaccination vs Population

select D.continent,D.location,D.date,D.population,V.new_vaccinations,
SUM(cast(V.new_vaccinations as float)) over (partition by D.location order by d.location,v.date) as total_vaccination
From COVID19..covidDeath D
join covid19..covidVaccination V on
D.date=V.date and
D.location=V.location
where D.continent is not null
order by 2,3

--Use CTE

With PopvsVac as (
select D.continent,D.location,D.date,D.population,V.new_vaccinations,
SUM(cast(V.new_vaccinations as float)) over (partition by D.location order by d.location,v.date) as total_vaccination
From COVID19..covidDeath D
join covid19..covidVaccination V on
D.date=V.date and
D.location=V.location
where D.continent is not null
--order by 2,3

)

select *,total_vaccination/population*100 as total_vaccination_per  from PopvsVac

--Temp table
Drop Table if exists #PercentPopulationVaccinated

 Create Table #PercentPopulationVaccinated
 (Continent nvarchar(255),
 Location nvarchar(255),
 date datetime,
 population nvarchar(255),
 new_vaccinations nvarchar(255),
 total_vaccination numeric
 )
 Insert into #PercentPopulationVaccinated
 select D.continent,D.location,D.date,D.population,V.new_vaccinations,
SUM(cast(V.new_vaccinations as float)) over (partition by D.location order by d.location,v.date) as total_vaccination
From COVID19..covidDeath D
join covid19..covidVaccination V on
D.date=V.date and
D.location=V.location
where D.continent is not null

select *,total_vaccination/population*100 as total_vaccination_per  from #PercentPopulationVaccinated

--Creating view  to data for later visualization

Create view PercentPopulationVaccinated as 
select D.continent,D.location,D.date,D.population,V.new_vaccinations,
SUM(cast(V.new_vaccinations as float)) over (partition by D.location order by d.location,v.date) as total_vaccination
From COVID19..covidDeath D
join covid19..covidVaccination V on
D.date=V.date and
D.location=V.location
where D.continent is not null



