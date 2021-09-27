-- Student Name: Ambroise Reynier
-- Student Number : 20036699
-- Write your commands and/or comments below

CREATE TABLE IF NOT EXISTS 1NF AS (SELECT * FROM
    corona);

ALTER TABLE 1NF 
ADD CONSTRAINT PK_1NF PRIMARY KEY (dateRep, countryterritoryCode);

-- FROM 1NF to 2NF:

CREATE TABLE IF NOT EXISTS country AS (SELECT DISTINCT (countryterritoryCode),
    geoId,
    countriesAndTerritories,
    popData2019,
    continentExp FROM
    1NF);

SET SQL_SAFE_UPDATES = 0;
-- To allow the deletion with a where without primary key

DELETE FROM country 
WHERE
    countryterritoryCode = '';
-- Delete the outliers to respect the characteristics of a primary key

ALTER TABLE country
ADD CONSTRAINT PK_country PRIMARY KEY (countryterritoryCode);

CREATE TABLE IF NOT EXISTS pandemic_evolution AS (SELECT STR_TO_DATE(dateRep, '%d/%m/%Y') AS dateRep,
    cases,
    deaths,
    countryterritoryCode FROM
    1NF);

DELETE FROM pandemic_evolution 
WHERE
    countryterritoryCode = '';
-- Delete the outliers to respect the characteristics of a primary key

ALTER TABLE pandemic_evolution 
ADD CONSTRAINT PK_pandemic_evolution PRIMARY KEY (dateRep, countryterritoryCode),
ADD CONSTRAINT FK_country FOREIGN KEY (countryterritoryCode) REFERENCES country (countryterritoryCode);

-- FROM 2NF to 3NF:

-- 2NF and 3NF are the same