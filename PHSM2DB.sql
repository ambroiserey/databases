-- Student Name: Ambroise Reynier
-- Student Number : 20036699
-- Write your commands and/or comments below

-- FROM UNF to 1NF:

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

CREATE TABLE IF NOT EXISTS 1NF_phsm AS (SELECT * FROM
    phsm);
    
ALTER TABLE 1NF_phsm 
ADD CONSTRAINT PK_1NF_phsm PRIMARY KEY (lineID);
    
-- I did not create a new table to separate the values from the column area_covered because some of them need to be considered as strings (for instance: "Occupied Palestinian Territory, Including East Jerusalem")

CREATE TABLE IF NOT EXISTS 2NF_phsm AS (SELECT * FROM
    1NF_phsm);

ALTER TABLE 2NF_phsm 
ADD CONSTRAINT PK_2NF_phsm PRIMARY KEY (lineID);

-- FROM 2NF to 3NF:

CREATE TABLE IF NOT EXISTS country_phsm AS (SELECT DISTINCT (iso),
    iso_3166_1_numeric,
    country_territory_area,
    who_region,
    admin_level FROM
    2NF_phsm
WHERE
    admin_level = 'national');
-- I used this where to only take into account states to improve the matching

SET SQL_SAFE_UPDATES = 0;
-- To allow the deletion with a where without primary key

DELETE FROM country_phsm 
WHERE
    iso = 'SDN' AND who_region = 'AFRO';
-- I decided to delete the remaining outlier of the iso column, according to the WHO, Soudan is in the EMRO region

ALTER TABLE country_phsm
DROP admin_level,
-- I dropped the admin_level because we do not need it anymore
ADD CONSTRAINT PK_country_phsm PRIMARY KEY (iso);

CREATE TABLE IF NOT EXISTS who_taxonomy AS (SELECT DISTINCT (who_code), who_category, who_subcategory, who_measure FROM
    2NF_phsm);

ALTER TABLE who_taxonomy
ADD CONSTRAINT PK_who_taxonomy PRIMARY KEY (who_code);

CREATE TABLE IF NOT EXISTS measures AS (SELECT lineID,
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
    2NF_phsm);
-- I did not create a new table to separate the values from the column area_covered because some of them need to be considered as strings (for instance: "Occupied Palestinian Territory, Including East Jerusalem")

ALTER TABLE measures
ADD CONSTRAINT PK_measures PRIMARY KEY (lineID),
ADD CONSTRAINT FK_country_phsm FOREIGN KEY (iso) REFERENCES country_phsm (iso),
ADD CONSTRAINT FK_who_taxonomy FOREIGN KEY (who_code) REFERENCES who_taxonomy (who_code);