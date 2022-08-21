Select *
From [Project Portfolio]..CovidDeaths

--Update Empty Spaces to Null

Update CovidDeaths
Set continent = Nullif(continent, ' ')

Select *
From [Project Portfolio]..CovidVaccinations

Update CovidVaccinations
Set continent = Nullif(continent, ' ')

Select *
From [Project Portfolio]..CovidDeaths
Where continent is not null
order by 3,4

--Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, Try_Cast(total_deaths as numeric)/Try_Cast(total_cases as numeric)*100 as Percentage_of_Death
From [Project Portfolio]..CovidDeaths
Where continent is not null
order by 1,2

--Total Cases vs Population

Select location, date, total_cases, population, Try_Cast(total_deaths as numeric)/Try_Cast(population as numeric)*100 as Percentage_of_Population_Infected
From [Project Portfolio]..CovidDeaths
Where continent is not null
order by 1,2

--Highest Infection rate compared to Population

Select location, population, MAX(total_cases) as Highest_Infection_Count, MAX(Try_cast(total_cases as numeric)/Try_cast(population as numeric))*100 as Percent_of_Population_Infected
From [Project Portfolio]..CovidDeaths
Group by location, population
order by Percent_of_Population_Infected desc

--Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as Total_Death_Count
From [Project Portfolio]..CovidDeaths
Where continent is not null 
Group by Location
order by Total_Death_Count desc

--Continents with Highest Death Count per Population

Select continent, MAX(cast(total_deaths as int)) as Total_Death_Count
From [Project Portfolio]..CovidDeaths
Where continent is not null 
Group by continent
order by Total_Death_Count desc

--Global Numbers

Select SUM(Try_cast(new_cases as numeric)) as total_cases, SUM(Try_cast(new_deaths as numeric)) as total_deaths, SUM(Try_cast(new_deaths as numeric))/SUM(Try_cast(new_cases as numeric))*100 as Percentage_of_Death
From [Project Portfolio]..CovidDeaths
where continent is not null 
order by 1,2

--Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_Count_of_Vaccinated
From [Project Portfolio]..CovidDeaths dea
Join [Project Portfolio]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--Caculation on Partition by in Previous Query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Count_of_People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_Count_of_Vaccinated
From [Project Portfolio]..CovidDeaths dea
Join [Project Portfolio]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (Rolling_Count_of_People_Vaccinated/Try_cast(Population as numeric))*100
From PopvsVac

--Temp Table
Drop Table if exists #Percent_of_population_Vaccinated
Create Table #Percent_of_population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population bigint,
New_vaccinations numeric,
Rolling_Count_of_People_Vaccinated numeric
)
Insert into #Percent_of_population_Vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_Count_of_People_Vaccinated
From [Project Portfolio]..CovidDeaths dea
Join [Project Portfolio]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (Rolling_Count_of_People_Vaccinated/Population)*100
From #Percent_of_population_Vaccinated

--Creating View for Visualization

Create View Percent_of_population_Vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_Count_of_People_Vaccinated
From [Project Portfolio]..CovidDeaths dea
Join [Project Portfolio]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
