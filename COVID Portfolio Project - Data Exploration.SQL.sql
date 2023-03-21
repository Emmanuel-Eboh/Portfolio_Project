/*
COVID 19 Data Exploration.SQL

Skills Used; Joins, CTE's, Tem Tables, Windows Functions, Aggregate Functions, Creative Views, Converting Data Types
/*


SELECT 
     *
FROM
    CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3, 4


--SELECT 
--     *
--FROM
--    CovidVaccinations$
--ORDER BY 3, 4


-- Select Data that we are Going to be Using


SELECT 
     location,
	 date,
	 total_cases,
	 new_cases,
	 total_deaths,
	 population
FROM
    CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- Looking at Total Cases vs Total Deaths

SELECT 
     location,
	 date,
	 total_cases,
	 total_deaths,
	 (total_deaths/total_cases)*100 AS DeathPercentage
FROM
    CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- Looking at the Percentage of Death in Nigeria

SELECT 
     location,
	 date,
	 total_cases,
	 total_deaths,
	 (total_deaths/total_cases)*100 AS DeathPercentage
FROM
    CovidDeaths$
WHERE location LIKE '%nigeria%'
AND continent IS NOT NULL
ORDER BY 1, 2




-- Looking at the Total Cases vs Population
-- Shows What Population got Covid in Nigeria

SELECT 
     location,
	 date,
	 total_cases,
	 population,
	 (total_cases/population)*100 AS Percentage_Population
FROM
    CovidDeaths$
WHERE location LIKE '%nigeria%'
AND continent IS NOT NULL
ORDER BY 1, 2

-- Shows What Percentage Population got Covid in the World


SELECT 
     location,
	 date,
	 total_cases,
	 population,
	 (total_cases/population)*100 AS PercentagePopulation_Infected
FROM
    CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- Looking at Countries With Highest Infection Rate Compared to Population


SELECT 
     location,
	 population,
	 continent,
	 MAX(total_cases) AS HighestInfection_Count,
	 MAX((total_cases/population))*100 AS PercentagePopulation_Infected
FROM
    CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population, continent
ORDER BY PercentagePopulation_Infected DESC


-- Showing Countries with Highest Death Count per Population



SELECT 
     location,
	 continent,
	 MAX(CAST(total_deaths AS INT)) AS TotalDeath_Count
FROM
    CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, continent
ORDER BY TotalDeath_Count DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing Continent With the Highest Death Count per Population


SELECT 
     continent,
	 MAX(CAST(total_deaths AS INT)) AS TotalDeath_Count
FROM
    CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeath_Count DESC



-- GLOBAL NUMBERS


-- Showing Specific Global Numbers

SELECT 
	 SUM(new_cases) AS Total_Cases,
	 SUM(CAST(new_deaths AS INT)) AS Total_deaths,
	 SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM
    CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- Showing General Global Numbers per Dates

SELECT 
	 date,
	 SUM(new_cases) AS Total_Cases,
	 SUM(CAST(new_deaths AS INT)) AS Total_deaths,
	 SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM
    CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2


-- Joining the Tables(CovidDeaths & CovidVaccinations)


SELECT 
     *
FROM
    CovidDeaths$ AS dea
    JOIN CovidVaccinations$ AS vac
ON dea.location = vac.location
AND dea.date = vac.date



-- Looking at Total Population vs Vaccinations


SELECT 
     dea.continent,
	 dea.location,
	 dea.date,
	 dea.population,
	 vac.new_vaccinations
FROM
    CovidDeaths$ AS dea 
JOIN CovidVaccinations$ AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3



-- Showing New Vaccinations per Day

SELECT 
     dea.continent,
	 dea.location,
	 dea.date,
	 dea.population,
	 vac.new_vaccinations,
	 SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeople_Vaccinated
FROM
    CovidDeaths$ AS dea 
JOIN CovidVaccinations$ AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3



-- Looking at Total Population vs the Vaccinations



SELECT 
     dea.continent,
	 dea.location,
	 dea.date,
	 dea.population,
	 vac.new_vaccinations,
	 SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeople_Vaccinated
FROM
    CovidDeaths$ AS dea 
JOIN CovidVaccinations$ AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3




--- USE CTE

WITH PopvcVac (continent, location, date, population, new_vaccinations, RollingPeople_Vaccinated)
AS
(
SELECT 
     dea.continent,
	 dea.location,
	 dea.date,
	 dea.population,
	 vac.new_vaccinations,
	 SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeople_Vaccinated
FROM
    CovidDeaths$ AS dea 
JOIN CovidVaccinations$ AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT
     *,
	 (RollingPeople_Vaccinated/population)*100 AS PercentageOf_RollingPeople_Vaccinated_per_Population
FROM
    PopvcVac


--TEMP TABLE


DROP TABLE IF EXISTS #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
(
continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeople_Vaccinated NUMERIC     
)

INSERT INTO #percentpopulationvaccinated
SELECT 
     dea.continent,
	 dea.location,
	 dea.date,
	 dea.population,
	 vac.new_vaccinations,
	 SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeople_Vaccinated
FROM
    CovidDeaths$ AS dea 
JOIN CovidVaccinations$ AS vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL

SELECT
     *,
	 (RollingPeople_Vaccinated/population)*100 AS PercentageOf_RollingPeople_Vaccinated_per_Population
FROM
    #percentpopulationvaccinated



-- Creating View to Store Data for Later Visualization

-- VIEW 1

CREATE VIEW percentpopulationvaccinated AS 
SELECT 
     dea.continent,
	 dea.location,
	 dea.date,
	 dea.population,
	 vac.new_vaccinations,
	 SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeople_Vaccinated
FROM
    CovidDeaths$ AS dea 
JOIN CovidVaccinations$ AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT 
     *
FROM
    percentpopulationvaccinated


-- VIEW 2

CREATE VIEW Total_Cases_VS_Total_Deaths AS
SELECT 
     location,
	 date,
	 total_cases,
	 total_deaths,
	 (total_deaths/total_cases)*100 AS DeathPercentage
FROM
    CovidDeaths$
WHERE continent IS NOT NULL

SELECT 
     *
FROM 
    Total_Cases_VS_Total_Deaths



-- VIEW 3

CREATE VIEW Percentage_of_Population_that_got_Covid_Globally AS
SELECT 
     location,
	 date,
	 total_cases,
	 population,
	 (total_cases/population)*100 AS PercentagePopulation_Infected
FROM
    CovidDeaths$
WHERE continent IS NOT NULL


SELECT
     *
FROM
    Percentage_of_Population_that_got_Covid_Globally


-- VIEW 4

CREATE VIEW Countries_with_Highest_Infection_Rate_Compared_to_Population AS
SELECT 
     location,
	 population,
	 continent,
	 MAX(total_cases) AS HighestInfection_Count,
	 MAX((total_cases/population))*100 AS PercentagePopulation_Infected
FROM
    CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population, continent

SELECT 
     *
FROM
    Countries_with_Highest_Infection_Rate_Compared_to_Population


-- VIEW 5


CREATE VIEW Counteries_with_Highest_Death_Count_per_Population AS
SELECT 
     location,
	 continent,
	 MAX(CAST(total_deaths AS INT)) AS TotalDeath_Count
FROM
    CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, continent

SELECT 
     *
FROM
    Counteries_with_Highest_Death_Count_per_Population


-- VIEW 6

CREATE VIEW Continent_with_Highest_Death_Count_per_Population AS
SELECT 
     continent,
	 MAX(CAST(total_deaths AS INT)) AS TotalDeath_Count
FROM
    CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent


SELECT 
     *
FROM
    Continent_with_Highest_Death_Count_per_Population

















    


    



