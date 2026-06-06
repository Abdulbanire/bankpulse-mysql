-- Creating the dimensions for each row 

CREATE TABLE dim_customer AS 
SELECT 
customer_id,
first_name,
surname,
CONCAT(first_name, ' ', surname) AS 'full_name',
gender,
birthdate,

-- 	Age in full years as today 
CASE
	WHEN birthdate IS NULL THEN NULL 
    ELSE timestampdiff(YEAR, birthdate, CURDATE())
    END AS age,

-- Age bucket for segmentation analysis 
CASE 
	WHEN birthdate IS NULL THEN 'Unknown'
    WHEN TIMESTAMPDIFF(YEAR, birthdate, CURDATE()) < 25 THEN 'Under 25'
    WHEN TIMESTAMPDIFF(YEAR, birthdate, CURDATE()) BETWEEN 25 AND 34 THEN '25-34'
    WHEN TIMESTAMPDIFF(YEAR, birthdate, CURDATE()) BETWEEN 35 AND 44 THEN '35-44' 
    WHEN TIMESTAMPDIFF(YEAR, birthdate, CURDATE()) BETWEEN 45 AND 54 THEN '45-54'
    WHEN TIMESTAMPDIFF(YEAR, birthdate, CURDATE()) >= 55 THEN '55+' 
    END AS age_segment
    
FROM (	
SELECT DISTINCT 
customer_id,
first_name,
surname,
gender,
birthdate
FROM customer_transactions_clean
) AS unique_customer;

-- Verfiy dim_customer 

SELECT 
COUNT(*) AS 'total customers',
COUNT(Age) AS 'customer with age',
MAX(age) AS 'oldest age',
MIN(age) AS 'youngest age'
FROM dim_customer;

-- breakdown customer age segment
SELECT age_segment, COUNT(*) AS customers 
FROM dim_customer
GROUP BY age_segment
ORDER BY age_segment DESC;

-- Breakdown by gender 
SELECT gender, COUNT(*) AS Customers
FROM dim_customer
GROUP BY gender; 

-- create dim_merchant 

CREATE TABLE dim_merchant AS 
SELECT 
ROW_NUMBER() OVER(ORDER BY merchant_name) AS merchant_id,
merchant_name,
category
FROM (
	SELECT DISTINCT 
    merchant_name,
    category
    FROM customer_transactions_clean
    ) AS unique_merchants;
    
-- verify dim_merchant 

SELECT 
COUNT(*) AS total_merchant,
COUNT(DISTINCT category) AS total_categories 
FROM dim_merchant;

-- All categories 
SELECT category, COUNT(*) AS merchants
FROM dim_merchant
GROUP BY category
ORDER BY merchants DESC;

-- Create Calender table 

CREATE TABLE dim_date (
  date         DATE,
  year         INT,
  month        INT,
  day          INT,
  quarter      INT,
  week_number  INT,
  day_name     VARCHAR(10),
  month_name   VARCHAR(10),
  day_of_week  INT,
  day_type     VARCHAR(7),
  year_quarter VARCHAR(7)
);

-- using the recursive CTE
INSERT INTO dim_date
WITH RECURSIVE date_spine AS (
  SELECT MIN(transaction_date) AS dt FROM customer_transactions_clean
  UNION ALL
  SELECT dt + INTERVAL 1 DAY
  FROM date_spine
  WHERE dt < (SELECT MAX(transaction_date) FROM customer_transactions_clean)
)
SELECT
  dt,
  YEAR(dt),
  MONTH(dt),
  DAY(dt),
  QUARTER(dt),
  WEEK(dt, 1),
  DAYNAME(dt),
  MONTHNAME(dt),
  DAYOFWEEK(dt),
  CASE
    WHEN DAYOFWEEK(dt) IN (1,7) THEN 'Weekend'
    ELSE 'Weekday'
  END,
  CONCAT(YEAR(dt), '-Q', QUARTER(dt))
FROM date_spine;

-- Verify dim_date
SELECT 
COUNT(*) 			AS total_days,
MIN(date)			AS from_date,
MAX(date) 			AS to_date 
FROM dim_date;

-- Confirm weekday split looks right
SELECT day_type, COUNT(*) AS days
FROM dim_date
GROUP BY day_type;
        
        









 



