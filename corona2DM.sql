-- Student Name: Ambroise Reynier
-- Student Number : 20036699
-- Write your commands and/or comments below

-- Star schema

CREATE TABLE IF NOT EXISTS country_dimension AS (SELECT DISTINCT (countryterritoryCode),
    geoId,
    countriesAndTerritories,
    popData2019,
    continentExp FROM
    corona);

SET SQL_SAFE_UPDATES = 0;
-- To allow the deletion with a where without primary key

DELETE FROM country_dimension 
WHERE
    countryterritoryCode = '';
-- Delete the outliers to respect the characteristics of a primary key

ALTER TABLE country_dimension
ADD CONSTRAINT PK_country_dimension PRIMARY KEY (countryterritoryCode);

CREATE TABLE IF NOT EXISTS date_dimension AS (SELECT DISTINCT (STR_TO_DATE(dateRep, '%d/%m/%Y')) AS dateRep,
    day,
    month,
    year FROM
    corona);

ALTER TABLE date_dimension
ADD CONSTRAINT PK_date_dimension PRIMARY KEY (dateRep);	

CREATE TABLE IF NOT EXISTS pandemic_evolution_fact AS (SELECT STR_TO_DATE(dateRep, '%d/%m/%Y') AS dateRep,
    cases,
    deaths,
    countryterritoryCode FROM
    corona);

DELETE FROM pandemic_evolution_fact 
WHERE
    countryterritoryCode = '';
-- Delete the outliers to respect the characteristics of a primary key

ALTER TABLE pandemic_evolution_fact
ADD CONSTRAINT PK_pandemic_evolution_fact PRIMARY KEY (dateRep, countryterritoryCode),
ADD CONSTRAINT FK_country_dimension FOREIGN KEY (countryterritoryCode) REFERENCES country_dimension (countryterritoryCode),
ADD CONSTRAINT FK_date_dimension FOREIGN KEY (dateRep) REFERENCES date_dimension (dateRep);
