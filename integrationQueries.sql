-- 1) Is there a correlation between the number of measures and the case fatality ratio?

SELECT 
    country_final_dimension.iso,
    countriesAndTerritories,
    COUNT(who_measure) AS number_of_measures,
    case_fatality_ratio,
    ROUND(COUNT(who_measure) / case_fatality_ratio) AS coefficient
FROM
    (SELECT 
        countryterritoryCode,
            SUM(deaths) / SUM(cases) * 100 AS case_fatality_ratio
    FROM
        pandemic_evolution_fact
    GROUP BY countryterritoryCode) AS base
        LEFT JOIN
    measures_fact ON measures_fact.iso = base.countryterritoryCode
        LEFT JOIN
    country_final_dimension ON country_final_dimension.iso = base.countryterritoryCode
        LEFT JOIN
    who_taxonomy_dimension ON who_taxonomy_dimension.who_code = measures_fact.who_code
WHERE
    countriesAndTerritories IS NOT NULL
        AND case_fatality_ratio != '0'
GROUP BY country_final_dimension.iso
ORDER BY coefficient ASC;

-- 2) Is there a correlation between the lenght of the lockdown (enforced by most countries in the world) and the case fatality ratio?

SELECT 
    iso,
    countriesAndTerritories,
    lockdown_lenght,
    case_fatality_ratio,
    ROUND(lockdown_lenght / case_fatality_ratio) AS coefficient
FROM
    (SELECT 
        who_measure,
            country_final_dimension.iso,
            countriesAndTerritories,
            SUM(DATEDIFF(date_end, date_start)) AS lockdown_lenght,
            case_fatality_ratio,
            admin_level
    FROM
        (SELECT 
        dateRep,
            countryterritoryCode,
            SUM(deaths) / SUM(cases) * 100 AS case_fatality_ratio
    FROM
        pandemic_evolution_fact
    GROUP BY countryterritoryCode) AS base
    LEFT JOIN measures_fact ON measures_fact.iso = base.countryterritoryCode
    LEFT JOIN country_final_dimension ON country_final_dimension.iso = base.countryterritoryCode
    LEFT JOIN who_taxonomy_dimension ON who_taxonomy_dimension.who_code = measures_fact.who_code
    WHERE
        who_measure = 'Stay-at-home order'
            AND admin_level = 'national'
    GROUP BY countriesAndTerritories) AS inter
WHERE
    lockdown_lenght > 0
        AND case_fatality_ratio != '0'
ORDER BY coefficient ASC;
