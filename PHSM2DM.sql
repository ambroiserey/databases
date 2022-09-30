-- Star schema

ALTER TABLE phsm
MODIFY who_id VARCHAR(255),
MODIFY who_region VARCHAR(255),
MODIFY country_territory_area VARCHAR(255),
MODIFY iso VARCHAR(255),
MODIFY admin_level VARCHAR(255),
MODIFY who_code VARCHAR(255),
MODIFY who_category VARCHAR(255),
MODIFY who_subcategory VARCHAR(255),
MODIFY who_measure VARCHAR(255),
MODIFY measure_stage VARCHAR(255),
MODIFY prev_measure_number VARCHAR(255),
MODIFY following_measure_number VARCHAR(255),
MODIFY reason_ended VARCHAR(255),
MODIFY enforcement VARCHAR(255),
MODIFY non_compliance_penalty VARCHAR(255);
-- Modify the type of columns to avoid key lenght problems later (error 1170)

CREATE TABLE IF NOT EXISTS country_phsm_dimension AS (SELECT DISTINCT (iso),
    iso_3166_1_numeric,
    country_territory_area,
    who_region,
    admin_level FROM
    phsm
WHERE
    admin_level = 'national');
-- I used this where to only take into account states to improve the matching

SET SQL_SAFE_UPDATES = 0;
-- To allow the deletion with a where without primary key

DELETE FROM country_phsm_dimension 
WHERE
    iso = 'SDN' AND who_region = 'AFRO';
-- I decided to delete the remaining outlier of the iso column, according to the WHO Soudan is in the EMRO region

ALTER TABLE country_phsm_dimension
DROP admin_level,
-- I dropped the admin_level because we do not need it anymore
ADD CONSTRAINT PK_country_phsm_dimension PRIMARY KEY (iso);

CREATE TABLE IF NOT EXISTS who_taxonomy_dimension AS (SELECT DISTINCT (who_code), who_category, who_subcategory, who_measure FROM
    phsm);

ALTER TABLE who_taxonomy_dimension
ADD CONSTRAINT PK_who_taxonomy_dimension PRIMARY KEY (who_code);

CREATE TABLE IF NOT EXISTS date_phsm_dimension AS (SELECT DISTINCT (date_rep), DAY(date_rep), MONTH(date_rep), YEAR(date_rep) FROM
    (SELECT 
        STR_TO_DATE(date_start, '%d/%m/%Y') AS date_rep
    FROM
        phsm UNION SELECT 
        STR_TO_DATE(date_end, '%d/%m/%Y') AS date_rep
    FROM
        phsm) AS rep);
-- I did this union to have the dates from both date_start and date_end in case some dates were not comprised in date_start

ALTER TABLE date_phsm_dimension
ADD CONSTRAINT PK_date_phsm_dimension PRIMARY KEY (date_rep);

CREATE TABLE IF NOT EXISTS measures_fact AS (SELECT lineID,
    who_id,
    iso,
    who_code,
    admin_level,
    area_covered,
    comments,
    STR_TO_DATE(date_start, '%d/%m/%Y') AS date_start,
    measure_stage,
    prev_measure_number,
    following_measure_number,
    STR_TO_DATE(date_end, '%d/%m/%Y') AS date_end,
    reason_ended,
    targeted,
    enforcement,
    non_compliance_penalty FROM
    phsm);
-- I did not create a new table to separate the values from the column area_covered because many of them need to be considered as strings (for instance: "Occupied Palestinian Territory, Including East Jerusalem")

ALTER TABLE measures_fact
ADD CONSTRAINT PK_measures_dimension PRIMARY KEY (lineID, iso, who_code, date_start),
-- I added lineID to the primary keys in order to avoid unavoidable redundancies (some were not pure duplicates), however, it was not possible to create a dimension table with lineID as a primary key (as per the definition of a star schema)
ADD CONSTRAINT FK_country_phsm_dimension FOREIGN KEY (iso) REFERENCES country_phsm_dimension (iso),
ADD CONSTRAINT FK_who_taxonomy_dimension FOREIGN KEY (who_code) REFERENCES who_taxonomy_dimension (who_code),
ADD CONSTRAINT FK_date_start_dimension FOREIGN KEY (date_start) REFERENCES date_phsm_dimension (date_rep);
