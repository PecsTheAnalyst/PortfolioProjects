SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--select data that we are going to be using
SELECT location, date, total_cases,new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 1,2

--Total cases vs total deaths
--shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2


--looking at the total cases vs population
--shows what percentage of population got covid

SELECT location, date, population,total_cases, (total_cases/population)*100 DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2

--Countries that have the highest infection rate compared to population

SELECT location, population, MAX(total_cases) HighestInfectionCount, MAX((total_cases/population))*100 PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing Countries with Highest Death Count per Population


SELECT location, MAX(CAST(total_deaths as int)) TotalDeathCount 
FROM PortfolioProject..CovidDeaths
where continent is not null
--WHERE location like '%states%'
GROUP BY location
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT location, MAX(CAST(total_deaths as int)) TotalDeathCount 
FROM PortfolioProject..CovidDeaths
where continent is null
--WHERE location like '%states%'
GROUP BY location
ORDER BY TotalDeathCount DESC


--looking at total population vs vaccinations

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
,SUM(cast(Vac.new_vaccinations as int)) OVER (Partition By dea.location ORDER BY dea.location, dea.Date) as RollingpeopleVaccinated
,
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
	WHERE Dea.continent is not null
	order by 2,3

	--USE CTE
	with PopsVac (Continent, Location, Date, Population, New_Vaccinations, RollingpeopleVaccinated)
	as
	(
	SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
,SUM(CONVERT(int, Vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.Date) as RollingpeopleVaccinated
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
	WHERE Dea.continent is not null
	--order by 2,3
	)
	select *, (RollingpeopleVaccinated/Population)*100 vacperc
	from PopsVac
	




	--TEMP TABLE
	DROP TABLE IF EXISTS #PercentPopulationVaccinated
	CREATE TABLE #PercentPopulationVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingpeopleVaccinated numeric
	)
	Insert into #PercentPopulationVaccinated
		SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
,SUM(CONVERT(int, Vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.Date) as RollingpeopleVaccinated
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
	WHERE Dea.continent is not null
	--order by 2,3
	
	select *, (RollingpeopleVaccinated/Population)*100 
	from #PercentPopulationVaccinated

	--Creating views

	CREATE VIEW PercentPopulationVac as
	SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
,SUM(CONVERT(int, Vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.Date) as RollingpeopleVaccinated
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
	WHERE Dea.continent is not null
	--order by 2,3

	SELECT *
	FROM PercentPopulationVac