
create database inverter_db;
use inverter_db;
show tables;

select * from inv;

select count(*) from inv;


------- Find Mean Values


select 
avg(Power_INV1_unit1) as mean_Power_INV1_unit1, 
avg(Power_INV1_unit2) as mean_Power_INV1_unit2, 
avg(Power_INV2_unit1) as mean_Power_INV2_unit1,
avg(Power_INV2_unit2) as mean_Power_INV2_unit2
from inv;
       
       
------- Find Median Values

select 
Power_INV1_unit1 as median_Power_INV1_unit1, 
Power_INV1_unit2 as median_Power_INV1_unit2, 
Power_INV2_unit1 as median_Power_INV2_unit1,
Power_INV2_unit2 as median_Power_INV2_unit2
from 
(
select Power_INV1_unit1, Power_INV1_unit2, Power_INV2_unit1, Power_INV2_unit2,
row_number() over (order by Power_INV1_unit1, Power_INV1_unit2, Power_INV2_unit1, Power_INV2_unit2)
as row_num,
count(*) over () as total_count
from inv
) as subquery
where row_num = (total_count + 1) / 2 or row_num = (total_count + 2) / 2;


------- Find Mode Values

select
Power_INV1_unit1 as mode_Power_INV1_unit1,
Power_INV1_unit2 as mode_Power_INV1_unit2,
Power_INV2_unit1 as mode_Power_INV2_unit1,
Power_INV2_unit2 as mode_Power_INV2_unit2
from 
(
select  Power_INV1_unit1, Power_INV1_unit2, Power_INV2_unit1, Power_INV2_unit2, 
count(*) as frequency
from inv
group by  Power_INV1_unit1, Power_INV1_unit2, Power_INV2_unit1, Power_INV2_unit2
order by frequency Desc
limit 1
) as subquery;


------- Variance


select 
variance(Power_INV1_unit1) as variance_Power_INV1_unit1, 
variance(Power_INV1_unit2) as variance_Power_INV1_unit2, 
variance(Power_INV2_unit1) as variance_Power_INV2_unit1,
variance(Power_INV2_unit2) as variance_Power_INV2_unit2
from inv
limit 0, 100;



------- Standard Deviation


select 
stddev(Power_INV1_unit1) as stddev_Power_INV1_unit1, 
stddev(Power_INV1_unit2) as stddev_Power_INV1_unit2, 
stddev(Power_INV2_unit1) as stddev_Power_INV2_unit1,
stddev(Power_INV2_unit2) as stddev_Power_INV2_unit12
from inv
limit 0, 100;


------------- RANGE

select
max(Power_INV1_unit1) - min(Power_INV1_unit1) as range_Power_INV1_unit1, 
max(Power_INV1_unit2) - min(Power_INV1_unit2) as range_Power_INV1_unit2, 
max(Power_INV2_unit1) -min(Power_INV2_unit1) as range_Power_INV2_unit1,
max(Power_INV2_unit2) -min(Power_INV2_unit2) as range_Total_Power_INV2_unit2
from inv;


--------------- Third and Fourth Moment Business Decision
-- skewness and kurkosis 

select

---------- Skewness and Kurtosis for Power_INV1_unit1

(
        SUM(POWER(Power_INV1_unit1 - (SELECT AVG(Power_INV1_unit1) FROM inv), 3)) / 
        (COUNT(*) * POWER((SELECT STDDEV(Power_INV1_unit1) FROM inv), 3))
    ) AS Power_INV1_unit1_skewness,
    (
        (SUM(POWER(Power_INV1_unit1 - (SELECT AVG(Power_INV1_unit1) FROM inv), 4)) / 
        (COUNT(*) * POWER((SELECT STDDEV(Power_INV1_unit1) FROM inv), 4))) - 3
    ) AS Power_INV1_unit1_kurtosis,
    
    
    --------- Skewness and Kurtosis for Power_INV1_unit2

(
        SUM(POWER(Power_INV1_unit2 - (SELECT AVG(Power_INV1_unit2) FROM inv), 3)) / 
        (COUNT(*) * POWER((SELECT STDDEV(Power_INV1_unit2) FROM inv), 3))
    ) AS Power_INV1_unit2_skewness,
    (
        (SUM(POWER(Power_INV1_unit2 - (SELECT AVG(Power_INV1_unit2) FROM inv), 4)) / 
        (COUNT(*) * POWER((SELECT STDDEV(Power_INV1_unit2) FROM inv), 4))) - 3
    ) AS Power_INV1_unit2_kurtosis,
    
    
       --------- Skewness and Kurtosis for Power_INV2_unit1

(
        SUM(POWER(Power_INV2_unit1 - (SELECT AVG(Power_INV2_unit1) FROM inv), 3)) / 
        (COUNT(*) * POWER((SELECT STDDEV(Power_INV2_unit1) FROM inv), 3))
    ) AS Power_INV2_unit1_skewness,
    (
        (SUM(POWER(Power_INV2_unit1 - (SELECT AVG(Power_INV2_unit1) FROM inv), 4)) / 
        (COUNT(*) * POWER((SELECT STDDEV(Power_INV2_unit1) FROM inv), 4))) - 3
    ) AS Power_INV2_unit1_kurtosis,
    
    
         --------- Skewness and Kurtosis for Power_INV2_unit2

(
        SUM(POWER(Power_INV2_unit2 - (SELECT AVG(Power_INV2_unit2) FROM inv), 3)) / 
        (COUNT(*) * POWER((SELECT STDDEV(Power_INV2_unit2) FROM inv), 3))
    ) AS Power_INV2_unit2_skewness,
    (
        (SUM(POWER(Power_INV2_unit2 - (SELECT AVG(Power_INV2_unit2) FROM inv), 4)) / 
        (COUNT(*) * POWER((SELECT STDDEV(Power_INV2_unit2) FROM inv), 4))) - 3
    ) AS Power_INV2_unit2_kurtosis

    from inv;




-- ------------------------------------------  data processing / cleaning   ------------------------------------- 
-- 1. Remove Duplicates

SELECT DATE_TIME, Power_INV1_unit1, Power_INV1_unit2, Power_INV2_unit1, Power_INV2_unit2, COUNT(*)
FROM inv
GROUP BY DATE_TIME, Power_INV1_unit1, Power_INV1_unit2, Power_INV2_unit1, Power_INV2_unit2
HAVING COUNT(*) > 1;

-- no duplicates


-- 2. Handle Outliers

WITH percentiles AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Power_INV1_unit1) AS q1_col1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Power_INV1_unit1) AS q3_col1,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Power_INV1_unit2) AS q1_col2,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Power_INV1_unit2) AS q3_col2,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Power_INV2_unit1) AS q1_col3,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Power_INV2_unit1) AS q3_col3,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Power_INV2_unit2) AS q1_col4,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Power_INV2_unit2) AS q3_col4
    FROM inv
)
SELECT
    *,
    q3_col1 - q1_col1 AS iqr_col1,
    q3_col2 - q1_col2 AS iqr_col2,
    q3_col3 - q1_col3 AS iqr_col3,
    q3_col4 - q1_col4 AS iqr_col4,
    q1_col1 - 1.5 * (q3_col1 - q1_col1) AS lower_bound_col1,
    q3_col1 + 1.5 * (q3_col1 - q1_col1) AS upper_bound_col1,
    q1_col2 - 1.5 * (q3_col2 - q1_col2) AS lower_bound_col2,
    q3_col2 + 1.5 * (q3_col2 - q1_col2) AS upper_bound_col2,
    q1_col3 - 1.5 * (q3_col3 - q1_col3) AS lower_bound_col3,
    q3_col3 + 1.5 * (q3_col3 - q1_col3) AS upper_bound_col3,
    q1_col4 - 1.5 * (q3_col4 - q1_col4) AS lower_bound_col4,
    q3_col4 + 1.5 * (q3_col4 - q1_col4) AS upper_bound_col4
FROM
    inv,
    percentiles
WHERE
    Power_INV1_unit1 < q1_col1 - 1.5 * (q3_col1 - q1_col1) OR
    Power_INV1_unit1 > q3_col1 + 1.5 * (q3_col1 - q1_col1) OR
    Power_INV1_unit2 < q1_col2 - 1.5 * (q3_col2 - q1_col2) OR
    Power_INV1_unit2 > q3_col2 + 1.5 * (q3_col2 - q1_col2) OR
    Power_INV2_unit1 < q1_col3 - 1.5 * (q3_col3 - q1_col3) OR
    Power_INV2_unit1 > q3_col3 + 1.5 * (q3_col3 - q1_col3) OR
    Power_INV2_unit2 < q1_col4 - 1.5 * (q3_col4 - q1_col4) OR
    Power_INV2_unit2 > q3_col4 + 1.5 * (q3_col4 - q1_col4);
    
SET sql_safe_updates = 0;
DELETE FROM inv
WHERE Power_INV1_unit1 < 0 
   OR Power_INV1_unit2 < 0
   OR Power_INV2_unit1 < 0
   OR Power_INV2_unit2 < 0;
   
-- 3. Standardize Timestamp Format
ALTER TABLE inv MODIFY DATE_TIME DATETIME;
select * from inv;

-- Validate Data Consistency
-- Ensure there are no null values in key columns.

SELECT * FROM inv
WHERE DATE_TIME IS NULL
   OR Power_INV1_unit1 IS NULL
   OR Power_INV1_unit2 IS NULL
   OR Power_INV2_unit1 IS NULL
   OR Power_INV2_unit2 IS NULL;
   

select * from inv;

-- 6. Export Cleaned Data
-- After cleaning, save the cleaned data for further use.


select * from inv;
select count(*)from inv;


-- ------------------------------------------ after cleaning --------------------------------------------------------
show tables;

select * from inv_cd;
select 
avg(Power_INV1_unit1) as mean_Power_INV1_unit1, 
avg(Power_INV1_unit2) as mean_Power_INV1_unit2, 
avg(Power_INV2_unit1) as mean_Power_INV2_unit1,
avg(Power_INV2_unit2) as mean_Power_INV2_unit2
from inv;

------- Find Median Values

select 
Power_INV1_unit1 as median_Power_INV1_unit1, 
Power_INV1_unit2 as median_Power_INV1_unit2, 
Power_INV2_unit1 as median_Power_INV2_unit1,
Power_INV2_unit2 as median_Power_INV2_unit2
from 
(
select Power_INV1_unit1, Power_INV1_unit2, Power_INV2_unit1, Power_INV2_unit2,
row_number() over (order by Power_INV1_unit1, Power_INV1_unit2, Power_INV2_unit1, Power_INV2_unit2)
as row_num,
count(*) over () as total_count
from inv
) as subquery
where row_num = (total_count + 1) / 2 or row_num = (total_count + 2) / 2;


------- Find Mode Values

select
Power_INV1_unit1 as mode_Power_INV1_unit1,
Power_INV1_unit2 as mode_Power_INV1_unit2,
Power_INV2_unit1 as mode_Power_INV2_unit1,
Power_INV2_unit2 as mode_Power_INV2_unit2
from 
(
select  Power_INV1_unit1, Power_INV1_unit2, Power_INV2_unit1, Power_INV2_unit2, 
count(*) as frequency
from inv
group by  Power_INV1_unit1, Power_INV1_unit2, Power_INV2_unit1, Power_INV2_unit2
order by frequency Desc
limit 1
) as subquery;


------- Variance


select 
variance(Power_INV1_unit1) as variance_Power_INV1_unit1, 
variance(Power_INV1_unit2) as variance_Power_INV1_unit2, 
variance(Power_INV2_unit1) as variance_Power_INV2_unit1,
variance(Power_INV2_unit2) as variance_Power_INV2_unit2
from inv
limit 0, 100;



------- Standard Deviation


select 
stddev(Power_INV1_unit1) as stddev_Power_INV1_unit1, 
stddev(Power_INV1_unit2) as stddev_Power_INV1_unit2, 
stddev(Power_INV2_unit1) as stddev_Power_INV2_unit1,
stddev(Power_INV2_unit2) as stddev_Power_INV2_unit12
from inv
limit 0, 100;


------------- RANGE

select
max(Power_INV1_unit1) - min(Power_INV1_unit1) as range_Power_INV1_unit1, 
max(Power_INV1_unit2) - min(Power_INV1_unit2) as range_Power_INV1_unit2, 
max(Power_INV2_unit1) -min(Power_INV2_unit1) as range_Power_INV2_unit1,
max(Power_INV2_unit2) -min(Power_INV2_unit2) as range_Total_Power_INV2_unit2
from inv;


--------------- Third and Fourth Moment Business Decision
-- skewness and kurkosis 

select

---------- Skewness and Kurtosis for Power_INV1_unit1

(
        SUM(POWER(Power_INV1_unit1 - (SELECT AVG(Power_INV1_unit1) FROM inv), 3)) / 
        (COUNT(*) * POWER((SELECT STDDEV(Power_INV1_unit1) FROM inv), 3))
    ) AS Power_INV1_unit1_skewness,
    (
        (SUM(POWER(Power_INV1_unit1 - (SELECT AVG(Power_INV1_unit1) FROM inv), 4)) / 
        (COUNT(*) * POWER((SELECT STDDEV(Power_INV1_unit1) FROM inv), 4))) - 3
    ) AS Power_INV1_unit1_kurtosis,
    
    
    --------- Skewness and Kurtosis for Power_INV1_unit2

(
        SUM(POWER(Power_INV1_unit2 - (SELECT AVG(Power_INV1_unit2) FROM inv), 3)) / 
        (COUNT(*) * POWER((SELECT STDDEV(Power_INV1_unit2) FROM inv), 3))
    ) AS Power_INV1_unit2_skewness,
    (
        (SUM(POWER(Power_INV1_unit2 - (SELECT AVG(Power_INV1_unit2) FROM inv), 4)) / 
        (COUNT(*) * POWER((SELECT STDDEV(Power_INV1_unit2) FROM inv), 4))) - 3
    ) AS Power_INV1_unit2_kurtosis,
    
    
       --------- Skewness and Kurtosis for Power_INV2_unit1

(
        SUM(POWER(Power_INV2_unit1 - (SELECT AVG(Power_INV2_unit1) FROM inv), 3)) / 
        (COUNT(*) * POWER((SELECT STDDEV(Power_INV2_unit1) FROM inv), 3))
    ) AS Power_INV2_unit1_skewness,
    (
        (SUM(POWER(Power_INV2_unit1 - (SELECT AVG(Power_INV2_unit1) FROM inv), 4)) / 
        (COUNT(*) * POWER((SELECT STDDEV(Power_INV2_unit1) FROM inv), 4))) - 3
    ) AS Power_INV2_unit1_kurtosis,
    
    
         --------- Skewness and Kurtosis for Power_INV2_unit2

(
        SUM(POWER(Power_INV2_unit2 - (SELECT AVG(Power_INV2_unit2) FROM inv), 3)) / 
        (COUNT(*) * POWER((SELECT STDDEV(Power_INV2_unit2) FROM inv), 3))
    ) AS Power_INV2_unit2_skewness,
    (
        (SUM(POWER(Power_INV2_unit2 - (SELECT AVG(Power_INV2_unit2) FROM inv), 4)) / 
        (COUNT(*) * POWER((SELECT STDDEV(Power_INV2_unit2) FROM inv), 4))) - 3
    ) AS Power_INV2_unit2_kurtosis

    from inv;











---------------------------------------------------- WMS_REPORT DATASET ------------------------------------------------------------

create database wms_report;
use wms_report;
show tables;

select * from wms_dataset;

select count(*) from wms_dataset;

-- before data cleaning
-- 4th business moment

------- Find Mean Values


select 
avg(GII_wms) as mean_GII_wms,
avg(MODULE_TEMP_1) as mean_MODULE_TEMP_1, 
avg(RAIN) as mean_RAIN,
avg(AMBIENT_TEMPRETURE) as mean_AMBIENT_TEMPRETURE
from wms_dataset;
       
       
------- Find Median Values

select 
GII_wms as median_GII_wms, 
MODULE_TEMP_1 as median_MODULE_TEMP_1, 
RAIN as median_RAIN,
AMBIENT_TEMPRETURE as median_AMBIENT_TEMPRETURE
from 
(
select GII_wms, MODULE_TEMP_1, RAIN, AMBIENT_TEMPRETURE,
row_number() over (order by GII_wms, MODULE_TEMP_1, RAIN, AMBIENT_TEMPRETURE)
as row_num,
count(*) over () as total_count
from wms_dataset
) as subquery
where row_num = (total_count + 1) / 2 or row_num = (total_count + 2) / 2;


------- Find Mode Values

select
GII_wms as mode_GII_wms,
MODULE_TEMP_1 as mode_MODULE_TEMP_1,
RAIN as mode_RAIN,
AMBIENT_TEMPRETURE as mode_AMBIENT_TEMPRETURE
from 
(
select  GII_wms, MODULE_TEMP_1, RAIN, AMBIENT_TEMPRETURE, 
count(*) as frequency
from wms_dataset
group by  GII_wms, MODULE_TEMP_1, RAIN, AMBIENT_TEMPRETURE
order by frequency Desc
limit 1
) as subquery;


------- Variance


select 
variance(GII_wms) as variance_GII_wms, 
variance(MODULE_TEMP_1) as variance_MODULE_TEMP_1, 
variance(RAIN) as variance_RAIN,
variance(AMBIENT_TEMPRETURE) as variance_AMBIENT_TEMPRETURE
from wms_dataset
limit 0, 100;



------- Standard Deviation


select 
stddev(GII_wms) as stddev_GII_wms, 
stddev(MODULE_TEMP_1) as stddev_MODULE_TEMP_1, 
stddev(RAIN) as stddev_RAIN,
stddev(AMBIENT_TEMPRETURE) as stddev_AMBIENT_TEMPRETURE
from wms_dataset
limit 0, 100;


------------- RANGE

select
max(GII_wms) - min(GII_wms) as range_GII_wms, 
max(MODULE_TEMP_1) - min(MODULE_TEMP_1) as range_MODULE_TEMP_1, 
max(RAIN) -min(RAIN) as range_RAIN,
max(AMBIENT_TEMPRETURE) -min(AMBIENT_TEMPRETURE) as range_AMBIENT_TEMPRETURE
from wms_dataset;		


--------------- Third and Fourth Moment Business Decision
-- skewness and kurkosis 

select

---------- Skewness and Kurtosis for GII_wms

(
        SUM(POWER(GII_wms - (SELECT AVG(GII_wms) FROM wms_dataset), 3)) / 
        (COUNT(*) * POWER((SELECT STDDEV(GII_wms) FROM wms_dataset), 3))
    ) AS GII_wms_skewness,
    (
        (SUM(POWER(GII_wms - (SELECT AVG(GII_wms) FROM wms_dataset), 4)) / 
        (COUNT(*) * POWER((SELECT STDDEV(GII_wms) FROM wms_dataset), 4))) - 3
    ) AS GII_wms_kurtosis,
    
    
    --------- Skewness and Kurtosis for MODULE_TEMP_1

(
        SUM(POWER(MODULE_TEMP_1 - (SELECT AVG(MODULE_TEMP_1) FROM wms_dataset), 3)) / 
        (COUNT(*) * POWER((SELECT STDDEV(MODULE_TEMP_1) FROM wms_dataset), 3))
    ) AS MODULE_TEMP_1_skewness,
    (
        (SUM(POWER(MODULE_TEMP_1 - (SELECT AVG(MODULE_TEMP_1) FROM wms_dataset), 4)) / 
        (COUNT(*) * POWER((SELECT STDDEV(MODULE_TEMP_1) FROM wms_dataset), 4))) - 3
    ) AS MODULE_TEMP_1_kurtosis,
    
    
       --------- Skewness and Kurtosis for RAIN

(
        SUM(POWER(RAIN - (SELECT AVG(RAIN) FROM wms_dataset), 3)) / 
        (COUNT(*) * POWER((SELECT STDDEV(RAIN) FROM wms_dataset), 3))
    ) RAIN_skewness,
    (
        (SUM(POWER(RAIN - (SELECT AVG(RAIN) FROM wms_dataset), 4)) / 
        (COUNT(*) * POWER((SELECT STDDEV(RAIN) FROM wms_dataset), 4))) - 3
    ) AS RAIN_kurtosis,
    
    
         --------- Skewness and Kurtosis for AMBIENT_TEMPRETURE

(
        SUM(POWER(AMBIENT_TEMPRETURE - (SELECT AVG(AMBIENT_TEMPRETURE) FROM wms_dataset), 3)) / 
        (COUNT(*) * POWER((SELECT STDDEV(AMBIENT_TEMPRETURE) FROM wms_dataset), 3))
    ) AS AMBIENT_TEMPRETURE_skewness,
    (
        (SUM(POWER(AMBIENT_TEMPRETURE - (SELECT AVG(AMBIENT_TEMPRETURE) FROM wms_dataset), 4)) / 
        (COUNT(*) * POWER((SELECT STDDEV(AMBIENT_TEMPRETURE) FROM wms_dataset), 4))) - 3
    ) AS AMBIENT_TEMPRETURE_kurtosis

    from wms_dataset;



-- ------------------------------------------  data processing / cleaning   -------------------------------------



-- 2. Check for Missing Values
-- Though this dataset has no missing values, here’s how to check

SELECT * 
FROM wms_dataset
WHERE DATE_TIME IS NULL
   OR GII_wms IS NULL
   OR MODULE_TEMP_1 IS NULL
   OR RAIN IS NULL
   OR AMBIENT_TEMPRETURE IS NULL;
   
-- no Missing Values:


-- 5. Standardize Data
-- Convert the DATE_TIME column to a proper DATETIME format:

ALTER TABLE wms_dataset
MODIFY COLUMN DATE_TIME datetime,
MODIFY COLUMN GII_wms DECIMAL(10, 2),
MODIFY COLUMN MODULE_TEMP_1 DECIMAL(10, 2),
MODIFY COLUMN RAIN DECIMAL(10, 2),
MODIFY COLUMN AMBIENT_TEMPRETURE DECIMAL(10, 2);

DESCRIBE wms_dataset;


-- 3. Remove Duplicate Entries
-- Ensure no duplicate timestamps exist:

SELECT DATE_TIME, GII_wms, MODULE_TEMP_1, RAIN, AMBIENT_TEMPRETURE, COUNT(*) AS count
FROM wms_dataset
GROUP BY DATE_TIME, GII_wms, MODULE_TEMP_1, RAIN, AMBIENT_TEMPRETURE
HAVING COUNT(*) > 1;

select * from wms_dataset;
--  no duplicates

-- 4. Handle Outliers
-- Filter or replace outliers based on logical ranges.
WITH percentiles AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY GII_wms) AS q1_col1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY GII_wms) AS q3_col1,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY MODULE_TEMP_1) AS q1_col2,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY MODULE_TEMP_1) AS q3_col2,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY RAIN) AS q1_col3,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY RAIN) AS q3_col3,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY AMBIENT_TEMPRETURE) AS q1_col4,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY AMBIENT_TEMPRETURE) AS q3_col4
    FROM inv
)
SELECT
    *,
    q3_col1 - q1_col1 AS iqr_col1,
    q3_col2 - q1_col2 AS iqr_col2,
    q3_col3 - q1_col3 AS iqr_col3,
    q3_col4 - q1_col4 AS iqr_col4,
    q1_col1 - 1.5 * (q3_col1 - q1_col1) AS lower_bound_col1,
    q3_col1 + 1.5 * (q3_col1 - q1_col1) AS upper_bound_col1,
    q1_col2 - 1.5 * (q3_col2 - q1_col2) AS lower_bound_col2,
    q3_col2 + 1.5 * (q3_col2 - q1_col2) AS upper_bound_col2,
    q1_col3 - 1.5 * (q3_col3 - q1_col3) AS lower_bound_col3,
    q3_col3 + 1.5 * (q3_col3 - q1_col3) AS upper_bound_col3,
    q1_col4 - 1.5 * (q3_col4 - q1_col4) AS lower_bound_col4,
    q3_col4 + 1.5 * (q3_col4 - q1_col4) AS upper_bound_col4
FROM
    inv,
    percentiles
WHERE
    GII_wms < q1_col1 - 1.5 * (q3_col1 - q1_col1) OR
    GII_wms > q3_col1 + 1.5 * (q3_col1 - q1_col1) OR
    MODULE_TEMP_1 < q1_col2 - 1.5 * (q3_col2 - q1_col2) OR
    MODULE_TEMP_1 > q3_col2 + 1.5 * (q3_col2 - q1_col2) OR
    RAIN < q1_col3 - 1.5 * (q3_col3 - q1_col3) OR
    RAIN > q3_col3 + 1.5 * (q3_col3 - q1_col3) OR
    AMBIENT_TEMPRETURE < q1_col4 - 1.5 * (q3_col4 - q1_col4) OR
    AMBIENT_TEMPRETURE > q3_col4 + 1.5 * (q3_col4 - q1_col4);

SET sql_safe_updates = 0;
DELETE FROM wms_dataset
WHERE DATE_TIME  < 0 
   OR  GII_wms < 0
   OR MODULE_TEMP_1 < 0
   OR RAIN < 0
   OR AMBIENT_TEMPRETURE < 0;


select * from wms_dataset;

select count(*)from wms_dataset;


-- ----------------------------------------------------- -after data cleaning --------------------------------------------------------------------
-- 4th business moment

------- Find Mean Values


select 
avg(GII_wms) as mean_GII_wms,
avg(MODULE_TEMP_1) as mean_MODULE_TEMP_1, 
avg(RAIN) as mean_RAIN,
avg(AMBIENT_TEMPRETURE) as mean_AMBIENT_TEMPRETURE
from wms_dataset;
       
       
------- Find Median Values

select 
GII_wms as median_GII_wms, 
MODULE_TEMP_1 as median_MODULE_TEMP_1, 
RAIN as median_RAIN,
AMBIENT_TEMPRETURE as median_AMBIENT_TEMPRETURE
from 
(
select GII_wms, MODULE_TEMP_1, RAIN, AMBIENT_TEMPRETURE,
row_number() over (order by GII_wms, MODULE_TEMP_1, RAIN, AMBIENT_TEMPRETURE)
as row_num,
count(*) over () as total_count
from wms_dataset
) as subquery
where row_num = (total_count + 1) / 2 or row_num = (total_count + 2) / 2;


------- Find Mode Values

select
GII_wms as mode_GII_wms,
MODULE_TEMP_1 as mode_MODULE_TEMP_1,
RAIN as mode_RAIN,
AMBIENT_TEMPRETURE as mode_AMBIENT_TEMPRETURE
from 
(
select  GII_wms, MODULE_TEMP_1, RAIN, AMBIENT_TEMPRETURE, 
count(*) as frequency
from wms_dataset
group by  GII_wms, MODULE_TEMP_1, RAIN, AMBIENT_TEMPRETURE
order by frequency Desc
limit 1
) as subquery;


------- Variance


select 
variance(GII_wms) as variance_GII_wms, 
variance(MODULE_TEMP_1) as variance_MODULE_TEMP_1, 
variance(RAIN) as variance_RAIN,
variance(AMBIENT_TEMPRETURE) as variance_AMBIENT_TEMPRETURE
from wms_dataset
limit 0, 100;



------- Standard Deviation


select 
stddev(GII_wms) as stddev_GII_wms, 
stddev(MODULE_TEMP_1) as stddev_MODULE_TEMP_1, 
stddev(RAIN) as stddev_RAIN,
stddev(AMBIENT_TEMPRETURE) as stddev_AMBIENT_TEMPRETURE
from wms_dataset
limit 0, 100;


------------- RANGE

select
max(GII_wms) - min(GII_wms) as range_GII_wms, 
max(MODULE_TEMP_1) - min(MODULE_TEMP_1) as range_MODULE_TEMP_1, 
max(RAIN) -min(RAIN) as range_RAIN,
max(AMBIENT_TEMPRETURE) -min(AMBIENT_TEMPRETURE) as range_AMBIENT_TEMPRETURE
from wms_dataset;		


--------------- Third and Fourth Moment Business Decision
-- skewness and kurkosis 

select

---------- Skewness and Kurtosis for GII_wms

(
        SUM(POWER(GII_wms - (SELECT AVG(GII_wms) FROM wms_dataset), 3)) / 
        (COUNT(*) * POWER((SELECT STDDEV(GII_wms) FROM wms_dataset), 3))
    ) AS GII_wms_skewness,
    (
        (SUM(POWER(GII_wms - (SELECT AVG(GII_wms) FROM wms_dataset), 4)) / 
        (COUNT(*) * POWER((SELECT STDDEV(GII_wms) FROM wms_dataset), 4))) - 3
    ) AS GII_wms_kurtosis,
    
    
    --------- Skewness and Kurtosis for MODULE_TEMP_1

(
        SUM(POWER(MODULE_TEMP_1 - (SELECT AVG(MODULE_TEMP_1) FROM wms_dataset), 3)) / 
        (COUNT(*) * POWER((SELECT STDDEV(MODULE_TEMP_1) FROM wms_dataset), 3))
    ) AS MODULE_TEMP_1_skewness,
    (
        (SUM(POWER(MODULE_TEMP_1 - (SELECT AVG(MODULE_TEMP_1) FROM wms_dataset), 4)) / 
        (COUNT(*) * POWER((SELECT STDDEV(MODULE_TEMP_1) FROM wms_dataset), 4))) - 3
    ) AS MODULE_TEMP_1_kurtosis,
    
    
       --------- Skewness and Kurtosis for RAIN

(
        SUM(POWER(RAIN - (SELECT AVG(RAIN) FROM wms_dataset), 3)) / 
        (COUNT(*) * POWER((SELECT STDDEV(RAIN) FROM wms_dataset), 3))
    ) RAIN_skewness,
    (
        (SUM(POWER(RAIN - (SELECT AVG(RAIN) FROM wms_dataset), 4)) / 
        (COUNT(*) * POWER((SELECT STDDEV(RAIN) FROM wms_dataset), 4))) - 3
    ) AS RAIN_kurtosis,
    
    
         --------- Skewness and Kurtosis for AMBIENT_TEMPRETURE

(
        SUM(POWER(AMBIENT_TEMPRETURE - (SELECT AVG(AMBIENT_TEMPRETURE) FROM wms_dataset), 3)) / 
        (COUNT(*) * POWER((SELECT STDDEV(AMBIENT_TEMPRETURE) FROM wms_dataset), 3))
    ) AS AMBIENT_TEMPRETURE_skewness,
    (
        (SUM(POWER(AMBIENT_TEMPRETURE - (SELECT AVG(AMBIENT_TEMPRETURE) FROM wms_dataset), 4)) / 
        (COUNT(*) * POWER((SELECT STDDEV(AMBIENT_TEMPRETURE) FROM wms_dataset), 4))) - 3
    ) AS AMBIENT_TEMPRETURE_kurtosis

    from wms_dataset;






