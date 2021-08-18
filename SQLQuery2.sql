/*
COVID-19 Data Exploration
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- Data Exploration

-- Selecting the data that we are going to be using
select 
	location, date, total_cases, new_cases, cast(total_deaths as int), population
from 
	[PortfolioProject-01]..['covid-deaths$'] 
order by
	3 desc


-- Total Cases vs Total Deaths in the U.S.
select
	location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from 
	[PortfolioProject-01]..['covid-deaths$']
where
	location like '%States%'
	and
	continent is not null 
order by
	1,2


-- Total Cases vs. Population in the U.S.
select
	location, date, population, total_cases, (total_cases/population)*100 as percent_infected
from 
	[PortfolioProject-01]..['covid-deaths$']
where
	location = 'United States'
and
	date >= '2020-04-01' 
order by
	1,2


-- Countries with Highest Infection Rate per Capita
select
	location, MAX(population) as total_population, MAX(total_cases) as total_cases, (MAX(total_cases) / MAX(population)) * 100 as percent_infected
from
	[PortfolioProject-01]..['covid-deaths$']
group by
	location
order by
	percent_infected desc


-- Countires with Highest Death Count per Capita from Covid-19
select
	location, MAX(population) as total_population, MAX(total_deaths) as total_deaths, (MAX(total_deaths) / MAX(population)) * 100 as percent_deceased
from
	[PortfolioProject-01]..['covid-deaths$']
group by
	location
order by
	percent_deceased desc


-- Countries with Most Total Deaths from Covid-19
select
	location, MAX(CAST(total_deaths as int)) as total_deaths
from
	[PortfolioProject-01]..['covid-deaths$']
where
	continent is not null
	or
	location = 'European Union'
group by
	location
order by
	total_deaths desc


-- Covid numbers by continent


-- Total Deaths by Continent
select
	location, MAX(CAST(total_deaths as bigint)) as total_deaths
from
	[PortfolioProject-01]..['covid-deaths$']
where
	continent is null
group by
	location
order by
	total_deaths desc


-- Continents with Highest Death Count per Capita
select
	location,
	MAX(total_cases) as total_cases,
	MAX(total_deaths) as total_deaths, 
	MAX(population) as population,
	max(total_deaths/population)*100 as 'percent',
	max(total_deaths/population)*100000 as mortality_rate,
	MAX(total_deaths/total_cases)*100 as fatality_percent
from
	[PortfolioProject-01]..['covid-deaths$']
where
	continent is null
	and
	location != 'international'
group by
	location
order by
	'fatality_percent' desc



-- Global Numbers


-- Current Global Covid-19 deaths as of 08/08/2021
select
	location, 
	MAX(cast(total_cases as bigint)) as total_cases,
	MAX(cast(total_deaths as bigint)) as total_deaths
from
	[PortfolioProject-01]..['covid-deaths$']
where
	continent is null
group by
	location
order by 
	total_deaths desc


-- Global Numbers Over Time
select
	CAST(date as date) as date, 
	total_cases as total_cases, 
	total_deaths as total_deaths, 
	total_deaths / total_cases * 100 as case_fatality_rate
from
	[PortfolioProject-01]..['covid-deaths$']
where
	location = 'World'


	-- Joins


-- Joining Tables
select
	*
from
	[PortfolioProject-01]..['covid-deaths$'] deaths
join
	[PortfolioProject-01]..['covid-vaccinations$'] vac
	on
		deaths.location = vac.location
	and
		deaths.date = vac.date
order by deaths.location, deaths.date


-- Vaccination Statistics


-- Regional Vaccination rate as of 08/08/2021
select
	deaths.location as location, 
	MAX(cast(deaths.date as date)),
	MAX(deaths.population) as population,
	max(vac.people_fully_vaccinated) as vaccinated,
	max(vac.people_fully_vaccinated / deaths.population) * 100  as percent_vaccinated
from
	[PortfolioProject-01]..['covid-deaths$'] deaths
join
	[PortfolioProject-01]..['covid-vaccinations$'] vac
	on
		deaths.location = vac.location
	and
		deaths.date = vac.date
where
	deaths.continent is null
	and
	deaths.location != 'International'
group by
	deaths.location
order by
	percent_vaccinated


-- Calculating Total Vaccinations Over Time
select
	deaths.date,
	vac.continent,
	vac.location,
	deaths.population,
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as float)) 
		over (partition by deaths.location order by deaths.date) as calc_total_vaccinations,
	vac.total_vaccinations as reported_total_vaccinations
from
	[PortfolioProject-01]..['covid-deaths$'] deaths
join
	[PortfolioProject-01]..['covid-vaccinations$'] vac
	on
		deaths.location = vac.location
	and
		deaths.date = vac.date
where
	deaths.continent is not null
order by deaths.location, deaths.date
-- Several countries appear to have inconsistancies between reported daily vaccinations and their total vaccinations.


-- using CTE's

-- Calculating vaccination percentage over time 
with vac_table (date, continent, location, population, new_vac, total_vac)
	as
	(
	select
		deaths.date,
		vac.continent,
		vac.location,
		deaths.population,
		vac.new_vaccinations,
		SUM(cast(vac.new_vaccinations as float)) 
			over (partition by deaths.location order by deaths.date) as calc_total_vaccinations
	from
		[PortfolioProject-01]..['covid-deaths$'] deaths
	join
		[PortfolioProject-01]..['covid-vaccinations$'] vac
		on
			deaths.location = vac.location
		and
			deaths.date = vac.date
	where
		deaths.continent is not null
	)
select
	*, (total_vac / population * 100)/2 as vac_rate
from
	vac_table
order by 
	location, date


-- Using Temp Tables


drop table if exists VaccinationPercentage
create table VaccinationPercentage
	(
	date date,
	continent nvarchar(255),
	location nvarchar(255),
	population numeric,
	new_vac numeric,
	total_vac numeric
	)

insert into VaccinationPercentage
	select
		deaths.date,
		vac.continent,
		vac.location,
		deaths.population,
		vac.new_vaccinations,
		SUM(cast(vac.new_vaccinations as float)) 
			over (partition by deaths.location order by deaths.date) as calc_total_vaccinations
	from
		[PortfolioProject-01]..['covid-deaths$'] deaths
	join
		[PortfolioProject-01]..['covid-vaccinations$'] vac
		on
			deaths.location = vac.location
		and
			deaths.date = vac.date
	
select
	*
from
	VaccinationPercentage

-- Views


drop view if exists VaccinationRate
create View VaccinationRate
	as
		select
			deaths.date,
			vac.continent,
			vac.location,
			deaths.population,
			vac.new_vaccinations,
			SUM(cast(vac.new_vaccinations as float)) 
				over (partition by deaths.location order by deaths.date) as calc_total_vaccinations
		from
			[PortfolioProject-01]..['covid-deaths$'] deaths
		join
			[PortfolioProject-01]..['covid-vaccinations$'] vac
			on
				deaths.location = vac.location
			and
				deaths.date = vac.date


select *
from VaccinationRate