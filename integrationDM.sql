CREATE TABLE IF NOT EXISTS date_final_dimension
AS (SELECT * FROM date_dimension UNION SELECT * FROM date_phsm_dimension);

ALTER TABLE date_final_dimension
ADD CONSTRAINT PK_date_final_dimension PRIMARY KEY (dateRep);	

CREATE TABLE IF NOT EXISTS country_final_dimension AS (SELECT inter.iso,
    iso_3166_1_numeric,
    geoId,
    country_territory_area,
    countriesAndTerritories,
    popData2019,
    continentExp,
    who_region FROM
    (SELECT DISTINCT
        (iso)
-- Taking the unique iso codes
    FROM
        (SELECT 
        iso
    FROM
        country_phsm_dimension UNION SELECT 
        countryterritoryCode
    FROM
        country_dimension) AS base
-- Regrouping the iso codes from the two country dimension tables 
        ) AS inter
        LEFT JOIN
    country_dimension ON country_dimension.countryterritoryCode = inter.iso
        LEFT JOIN
    country_phsm_dimension ON country_phsm_dimension.iso = inter.iso);
-- Adding the rest of the data from the two country dimension tables

ALTER TABLE country_final_dimension
ADD CONSTRAINT PK_country_final_dimension PRIMARY KEY (iso);	

ALTER TABLE pandemic_evolution_fact
-- The primary keys stay the same
DROP CONSTRAINT FK_country_dimension,
DROP CONSTRAINT FK_date_dimension,
-- Dropping the constraint from the former dimension tables
ADD CONSTRAINT FK_pandevol_country_final_dimension FOREIGN KEY (countryterritoryCode) REFERENCES country_final_dimension (iso),
ADD CONSTRAINT FK_pandevol_date_final_dimension FOREIGN KEY (dateRep) REFERENCES date_final_dimension (dateRep);
-- Add the foreign keys from the two new dimension tables

ALTER TABLE measures_fact
-- The primary keys stay the same
DROP CONSTRAINT FK_country_phsm_dimension,
DROP CONSTRAINT FK_date_start_dimension,
-- Dropping the constraint from the former dimension tables
ADD CONSTRAINT FK_meas_country_final_dimension FOREIGN KEY (iso) REFERENCES country_final_dimension (iso),
ADD CONSTRAINT FK_meas_date_final_dimension FOREIGN KEY (date_start) REFERENCES date_final_dimension (dateRep); 
-- Add the foreign keys from the two new dimension tables

-- The table who_taxonomy_dimension stays the same
