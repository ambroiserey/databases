-- 1) What is the global case fatality ratio of the coronavirus?

SELECT 
    SUM(deaths) / SUM(cases) * 100 AS global_case_fatility_ratio
FROM
    pandemic_evolution_fact;

-- 2) Which countries have best reduced the spread of the coronavirus?

SELECT 
    countriesAndTerritories,
    SUM(cases) / popData2019 * 100 AS cases_ratio
FROM
    pandemic_evolution_fact
        LEFT JOIN
    country_dimension ON pandemic_evolution_fact.countryterritoryCode = country_dimension.countryterritoryCode
GROUP BY countriesAndTerritories
ORDER BY cases_ratio ASC;


