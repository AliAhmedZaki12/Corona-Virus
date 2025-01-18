
SELECT continent, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM [Corona Virus]..CovidDeaths$
WHERE location LIKE '%states%' 
  AND continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


SELECT 
    SUM(new_cases) AS total_cases, 
    SUM(CAST(ISNULL(new_deaths, 0) AS INT)) AS total_deaths, 
    SUM(CAST(ISNULL(new_deaths, 0) AS INT)) * 100.0 / SUM(new_cases) AS DeathPercentage
FROM [Corona Virus]..CovidDeaths$
WHERE continent IS NOT NULL;


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

Go

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


