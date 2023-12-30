

Select *
From PortfolioProject..CovidDeaths
Order by 3,4
Select *
From PortfolioProject.dbo.CovidVaccinations
Order by 3,4


-- Select Data that we are going to be starting with

Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
Where continent is not null 
Order by 1,2

--looking at Total Cases vs Total Deaths (Percentage)

AlTER Table PortfolioProject..CovidDeaths
ALTER COLUMN Total_Cases Float

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 As DeathPercentage
From PortfolioProject..CovidDeaths
Order by 1,2

-- Shows likelihood of dying if you contract covid in your country
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 As DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%States%'
And continent is not null 
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of Population got Covid


Select location,date,population,total_cases,(total_cases/Population)*100 As PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where Location like '%States%'
And continent is not null 
Order by 1,2


--Looking at Country With Highest infection compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location, Population
order by PercentPopulationInfected desc

--Show Countries With highest Death Count Per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



--Global Number
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


Select D.continent,D.location,D.date,D.population,V.new_vaccinations
,SUM(CONVERT(bigint,V.new_vaccinations)) OVER (Partition by D.Location order by D.Location
, D.Date) As  PeopleVaccinated
From PortfolioProject..CovidVaccinations V
Join PortfolioProject..CovidDeaths D
   On V.location=D.location
   And V.date=D.date
Where D.continent is not null
Order by 2,3


--Use Cte
With PopVsVac AS
(
Select D.continent,D.location,D.date,D.population,V.new_vaccinations
,SUM(CONVERT(bigint,V.new_vaccinations)) OVER (Partition by D.Location order by D.Location
, D.Date) As  PeopleVaccinated
From PortfolioProject..CovidVaccinations V
Join PortfolioProject..CovidDeaths D
   On V.location=D.location
   And V.date=D.date
Where D.continent is not null
--Order by 2,3
)
Select *,(PeopleVaccinated/Population)*100
From PopVsVac

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
