# COVID-19 Analysis 

This project focuses on analyzing COVID-19 data using SQL. It aims to extract key insights about deaths, cases, and vaccinations across different locations and continents. The analysis uses advanced SQL techniques such as aggregations, window functions, temporary tables, and views to produce meaningful results.

---

## Objectives

1. **Summarize total deaths by continent**
2. **Calculate total cases, total deaths, and death percentages globally**
3. **Track daily vaccinations and cumulative vaccinated population**
4. **Compute the percentage of vaccinated population for each location**
5. **Create reusable data structures like temporary tables and views**

---

## SQL Queries Breakdown

### 1. Total Deaths by Continent
```sql
SELECT continent, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM [Corona Virus]..CovidDeaths$
WHERE location LIKE '%states%'
  AND continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;
```
- **Purpose**: Calculate the total number of deaths due to COVID-19 for each continent and sort the results in descending order.
- **Key Features**:
  - Filters out rows where the continent is NULL.
  - Focuses on locations containing the word "states."

---

### 2. Global Cases, Deaths, and Death Percentage
```sql
SELECT
    SUM(new_cases) AS total_cases,
    SUM(CAST(ISNULL(new_deaths, 0) AS INT)) AS total_deaths,
    SUM(CAST(ISNULL(new_deaths, 0) AS INT)) * 100.0 / SUM(new_cases) AS DeathPercentage
FROM [Corona Virus]..CovidDeaths$
WHERE continent IS NOT NULL;
```
- **Purpose**: Compute global totals for cases, deaths, and the percentage of deaths relative to cases.
- **Key Features**:
  - Replaces NULL values in `new_deaths` with zero for accurate calculations.

---

### 3. Daily Vaccinations and Cumulative Counts
```sql
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    ISNULL(dea.new_vaccinations, 0) AS new_vaccinations,
    SUM(CONVERT(INT, ISNULL(vac.new_vaccinations, 0)))
        OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM [Corona Virus]..CovidDeaths$ dea
JOIN [Corona Virus]..CovidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;
```
- **Purpose**: Display daily vaccination counts and calculate the cumulative number of vaccinated people by location and date.
- **Key Features**:
  - Uses a window function to calculate cumulative totals.
  - Combines data from deaths and vaccinations tables using a join.

---

### 4. Vaccination Percentage by Population
```sql
WITH PopvsVac AS (
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        ISNULL(vac.new_vaccinations, 0) AS new_vaccinations,
        SUM(CONVERT(INT, ISNULL(vac.new_vaccinations, 0)))
            OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
    FROM [Corona Virus]..CovidDeaths$ dea
    JOIN [Corona Virus]..CovidVaccinations$ vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated * 100.0 / Population) AS VaccinationPercentage
FROM PopvsVac;
```
- **Purpose**: Compute the percentage of vaccinated population for each location over time.
- **Key Features**:
  - Uses a Common Table Expression (CTE) for clarity and reusability.
  - Calculates vaccination percentages as a derived column.

---

### 5. Temporary Table for Vaccination Analysis
```sql
IF OBJECT_ID('tempdb..#PercentPopulationVaccinated') IS NOT NULL
    DROP TABLE #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO #PercentPopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    ISNULL(vac.new_vaccinations, 0) AS new_vaccinations,
    SUM(CONVERT(INT, ISNULL(vac.new_vaccinations, 0)))
        OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM [Corona Virus]..CovidDeaths$ dea
JOIN [Corona Virus]..CovidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date;

SELECT *, (RollingPeopleVaccinated * 100.0 / Population) AS VaccinationPercentage
FROM #PercentPopulationVaccinated;
```
- **Purpose**: Create a temporary table to store vaccination data for further analysis.
- **Key Features**:
  - Temporary table facilitates reusability in complex workflows.

---

### 6. View for Vaccination Data
```sql
CREATE VIEW [Percent PopulationVaccinated] AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    ISNULL(vac.new_vaccinations, 0) AS new_vaccinations,
    SUM(CONVERT(INT, ISNULL(vac.new_vaccinations, 0)))
        OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM [Corona Virus]..CovidDeaths$ dea
JOIN [Corona Virus]..CovidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
```
- **Purpose**: Create a reusable view for analyzing vaccination data efficiently.

---


## Key SQL Concepts Used

- **Aggregations**: `SUM`, `ISNULL`
- **Window Functions**: `OVER (PARTITION BY ... ORDER BY ...)`
- **Common Table Expressions (CTEs)**: Simplify complex queries.
- **Temporary Tables**: Facilitate intermediate data storage.
- **Views**: Provide reusable query structures.


