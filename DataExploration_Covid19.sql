Select *
From PortfolioProject..CovidCases$
Where continent Is Not Null
and location = 'Malaysia'
Order By location, date;


Select *
From PortfolioProject..CovidVaccinations$
Where continent Is Not Null 
and location = 'Malaysia'
Order By location, date;


-- Exploring the location 

Select continent, location 
from PortfolioProject..CovidCases$
group by continent, location
order by 1, 2;


Select continent, location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidCases$
Where continent Is Not Null
Order By location, date;


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of people to die from covid19

Select continent, 
       location, 
	   date, 
	   total_cases, 
	   total_deaths, 
	   (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject..CovidCases$
Where continent Is Not Null
Order By location, date;


-- Looking at Total Cases vs Population
-- Shows the percentage of population infected with Covid

Select continent, 
	   location,
	   date, 
	   total_cases,
	   population, 
	   (total_cases/population)*100 as percentage_population_infected
From PortfolioProject..CovidCases$
Where continent Is Not Null
Order By location, date;


-- Looking at countries with highest infection rate compared to population

Select continent, 
       location, 
	   MAX(total_cases) as highest_infection_count, 
	   (MAX(total_cases)/population)*100 as percentage_population_infected
From PortfolioProject..CovidCases$
Where continent Is Not Null 
Group By continent, location, population
Order By percentage_population_infected desc;


-- Looking at countries with highest death count compared to population

Select continent, 
	   location, 
	   MAX(cast(total_deaths as numeric)) as total_death_count,
	   (MAX(cast(total_deaths as numeric))/MAX(population)) as percent_death
From PortfolioProject..CovidCases$
Where continent Is Not Null 
Group By continent, location
Order By total_death_count desc;


-- Looking at Covid cases globally

Select date, SUM(new_cases) as total_cases, 
             SUM(cast(new_deaths as numeric)) as total_deaths,
			 (SUM(cast(new_deaths as numeric))/SUM(new_cases))*100 as death_percentage
From PortfolioProject..CovidCases$
Where continent Is Not Null
Group By date
Order By 1, 2;


-- Shows global death percentage 

Select SUM(new_cases) as total_cases, 
       SUM(cast(new_deaths as numeric)) as total_deaths,
	   (SUM(cast(new_deaths as numeric))/SUM(new_cases))*100 as death_percentage
From PortfolioProject..CovidCases$
Where continent Is Not Null
Order By 1, 2;


-- Join Covid19 Cases table and Covid19 Vaccinations table
-- Shows daily doses administered

Select cc.continent, 
       cc.location, 
       cc.date, 
	   cc.population,
	   cc.new_cases,
	   cc.new_deaths,
	   cv.new_vaccinations
From PortfolioProject..CovidCases$ as cc
Join PortfolioProject..CovidVaccinations$ as cv
	On cc.location = cv.location and cc.date = cv.date
Where cc.continent Is Not Null
--	and cc.location = 'Malaysia'
Order By 2, 3;


-- Join Covid19 Cases table and Covid19 Vaccination table
-- Shows (cumulative) of doses administered

Select cc.continent, 
       cc.location, 
       cc.date, 
	   cc.population,
	   cc.total_cases,
	   cc.total_deaths,
	   SUM(cast(cv.new_vaccinations as bigint)) OVER (Partition By cc.location Order By cc.location, cc.date) as total_vaccinations
From PortfolioProject..CovidCases$ as cc
Join PortfolioProject..CovidVaccinations$ as cv
	On cc.location = cv.location and cc.date = cv.date
Where cc.continent Is Not Null
--	and cc.location = 'Malaysia'
Order By 2, 3;


-- Creating CTE to calculate percent (cumulative) doses administered in previous query

With CasesVaccination as 
	(Select cc.continent, 
	        cc.location, 
			cc.date, 
			cc.population, 
			cc.total_cases,
	        cc.total_deaths,
			SUM(cast(cv.new_vaccinations as bigint)) OVER (Partition By cc.location Order By cc.location, cc.date) as total_vaccinations
	From PortfolioProject..CovidCases$ as cc
	Join PortfolioProject..CovidVaccinations$ as cv
		On cc.location = cv.location and cc.date = cv.date
	Where cc.continent Is Not Null)

Select *, (total_vaccinations/population)*100 as percentage_total_vaccinations
From CasesVaccination
--Where location = 'Malaysia'
Order By 2, 3;


-- Creating temp table to calculate percent (cumulative) doses administered in previous query

Drop Table if exists #temp_CasesVaccination 
Create Table #temp_CasesVaccination 
	(continent varchar(255), 
	 location varchar(255), 
	 date datetime,
	 population numeric, 
	 total_cases numeric,
	 total_deaths numeric,
	 total_vaccinations numeric)

Insert Into #temp_CasesVaccination 
Select cc.continent, 
	   cc.location, 
	   cc.date, 
	   cc.population, 
	   cc.total_cases,
	   cc.total_deaths,
	   SUM(cast(cv.new_vaccinations as numeric)) OVER (Partition By cc.location Order By cc.location, cc.date) as total_vaccinations
From PortfolioProject..CovidCases$ as cc
Join PortfolioProject..CovidVaccinations$ as cv
	On cc.location = cv.location and cc.date = cv.date
Where cc.continent Is Not Null

Select *, (total_vaccinations/population)*100 as percentage_total_vaccinations
From #temp_CasesVaccination
--Where location = 'Malaysia'
Order By 2,3;



-- Shows global total cases, total deaths and total doses administered

Select SUM(cc.new_cases) as total_cases,
       SUM(cast(cc.new_deaths as int)) as total_deaths,  
	   SUM(cast(cv.new_vaccinations as bigint)) as total_vaccinations
From PortfolioProject..CovidCases$ as cc
Join PortfolioProject..CovidVaccinations$ as cv
	On cc.location = cv.location and cc.date = cv.date
Where cc.location = 'world'



-- Looking at global (cumulative) cases, deaths and doses administered 

Select cc.date, 
       SUM(cc.new_cases) as total_cases,
       SUM(cast(cc.new_deaths as int)) as total_deaths,  
	   SUM(cast(cv.new_vaccinations as bigint)) as total_vaccinations
From PortfolioProject..CovidCases$ as cc
Join PortfolioProject..CovidVaccinations$ as cv
	On cc.location = cv.location and cc.date = cv.date
Where cc.location = 'world'
Group By cc.date
Order By 1;



-- Looking at total case, total death and total doses administered accross continent

Select cc.location, 
       SUM(cc.new_cases) as total_cases,
       SUM(cast(cc.new_deaths as int)) as total_deaths,  
	   SUM(cast(cv.new_vaccinations as bigint)) as total_vaccinations
From PortfolioProject..CovidCases$ as cc
Join PortfolioProject..CovidVaccinations$ as cv
	On cc.location = cv.location and cc.date = cv.date
Where cc.continent is null 
	and cc.location not in ('world', 'european union', 'international', 'upper middle income', 'high income', 'lower middle income', 'low income')
Group By cc.location
Order By 2 desc;



---------------------------------------------------------------------------------------------------------------------------------------------------

--CREATING VIEW TO STORE DATA FOR VISUALISATION IN TABLEAU

-- 1. Global Covid Data

Drop View if exists GlobalCovidData;
Create View GlobalCovidData as
Select cc.continent, 
       cc.location, 
       cc.date, 
	   cc.population,
	   cc.new_cases,
	   cc.total_cases,
	   cc.new_deaths,
	   cc.total_deaths,
	   cv.new_vaccinations,
	   cv.total_vaccinations,
	   cv.people_vaccinated,
	   cv.people_fully_vaccinated
From PortfolioProject..CovidCases$ as cc
Join PortfolioProject..CovidVaccinations$ as cv
	On cc.location = cv.location and cc.date = cv.date
Where cc.continent Is Not Null;

Select * 
From GlobalCovidData
--Where location = 'Malaysia'
Order By 2, 3;



-- 2. Global Covid Data (with rank)

Drop View if exists GlobalCovidRanking;
Create View GlobalCovidRanking as
Select cc.continent,
       cc.location,
	   cc.population,
	   MAX(cc.total_cases) over (partition by cc.location) as total_people_infected,
	   (MAX(cc.total_cases) over (partition by cc.location))/cc.population*100 as percent_people_infected,
	   MAX(cast(cc.total_deaths as numeric)) over (partition by cc.location) as total_people_dead,
	   (MAX(cast(cc.total_deaths as numeric)) over (partition by cc.location))/(MAX(cc.total_cases) over (partition by cc.location))*100 as percent_people_dead,
	   MAX(cast(cv.people_vaccinated as numeric)) over (partition by cc.location) as total_people_vaaccinated,
	   MAX(cast(people_vaccinated_per_hundred as float)) over (partition by cc.location) as percent_people_vaccinated,
	   MAX(cast(cv.people_fully_vaccinated as numeric)) over (partition by cc.location) as total_fully_vaaccinated,
	   MAX(cast(people_fully_vaccinated_per_hundred as float)) over (partition by cc.location) as percent_fully_vaccinated
From PortfolioProject..CovidCases$ as cc
Join PortfolioProject..CovidVaccinations$ as cv
	On cc.location = cv.location and cc.date = cv.date
Where cc.continent Is Not Null;

Select *,
	   (percent_people_vaccinated - percent_fully_vaccinated) as percent_partly_vaccinated,
	   DENSE_RANK() Over (Order By population desc) as ranking_population,
	   DENSE_RANK() Over (Order By total_people_infected desc) as ranking_total_people_infected,
       DENSE_RANK() Over (Order By percent_people_infected desc) as ranking_percent_people_infected,
	   DENSE_RANK() Over (Order By total_people_dead desc) as ranking_total_people_dead,
	   DENSE_RANK() Over (Order By percent_people_dead desc) as ranking_percent_people_dead,
	   DENSE_RANK() Over (Order By total_people_vaaccinated desc) as ranking_total_people_vaaccinated,
	   DENSE_RANK() Over (Order By percent_people_vaccinated desc) as ranking_percent_people_vaccinated
From GlobalCovidRanking
Group By continent, location, population, total_people_infected, percent_people_infected, total_people_dead, percent_people_dead, 
         total_people_vaaccinated, percent_people_vaccinated, total_fully_vaaccinated, percent_fully_vaccinated
Order By location;










