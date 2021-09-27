-- Student Name: Ambroise Reynier
-- Student Number : 20036699
-- Write your commands and/or comments below

-- 1) What were the most common measures taken?

SELECT 
    *
FROM
    (SELECT 
        who_measure, COUNT(who_measure) AS number_of_measures
    FROM
        measures_fact
    LEFT JOIN who_taxonomy_dimension ON measures_fact.who_code = who_taxonomy_dimension.who_code
    WHERE
        who_measure != ''
    GROUP BY who_measure) AS c_measure
ORDER BY number_of_measures DESC;

-- 2) What was the lenght of the first French lockdown?

SELECT 
    who_measure,
    SUM(DATEDIFF(date_end, date_start)) AS lockdown_lenght
FROM
    measures_fact
        LEFT JOIN
    who_taxonomy_dimension ON measures_fact.who_code = who_taxonomy_dimension.who_code
WHERE
    who_measure = 'Stay-at-home order'
        AND admin_level = 'national'
        AND iso = 'FRA'