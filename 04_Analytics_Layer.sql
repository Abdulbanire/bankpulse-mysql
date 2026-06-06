-- Analytics Layer 
USE bankpluse;

-- Total Spend by category

SELECT m.category, SUM(ft.transaction_amount) AS total_spend
FROM fact_transactions ft
JOIN dim_merchant m ON ft.merchant_id = m.merchant_id
GROUP BY (m.category) WITH ROLLUP;

-- Top 10 highest spendong customers 

SELECT c.full_name,
 SUM(ft.transaction_amount) AS total_spend,
 RANK()OVER (ORDER BY SUM(transaction_amount) DESC) AS spend_rank
FROM fact_transactions ft
JOIN dim_customer c ON ft.customer_id = c.customer_id
GROUP BY full_name
LIMIT 10;

-- Monthly spend per category 

SELECT d.year, d.month, m.category, SUM(ft.transaction_amount) as total_spent
FROM fact_transactions ft
JOIN dim_date d ON ft.date = d.date
JOIN dim_merchant m ON ft.merchant_id = m.merchant_id
GROUP BY d.year, d.month , m.category;

-- Rolling 30 day spend customer 

SELECT c.full_name, d.date, ft.transaction_amount,
 SUM(ft.transaction_amount) OVER(PARTITION BY ft.customer_id 
 ORDER BY d.date 
 ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS rolling_30day_spend
 FROM fact_transactions ft
 JOIN dim_customer c ON ft.customer_id = c.customer_id 
 JOIN dim_date d ON ft.date = d.date
 ORDER BY c.customer_id, d.date;
 
 -- Anomaly detection - unusally large transaction 
 SELECT * ,
  'Anomaly' AS flag
 FROM(
 SELECT ft.transaction_id, c.full_name, ft.transaction_amount,
 AVG(ft.transaction_amount) 	OVER(PARTITION BY ft.customer_id) AS avg_spend,
 STDDEV(ft.transaction_amount) 	OVER(PARTITION BY ft.customer_id) AS stddev_spend 
 FROM fact_transactions ft 
 JOIN dim_customer c ON ft.customer_id = c.customer_id) AS Customer_stats
 WHERE transaction_amount > avg_spend
 ORDER BY transaction_amount DESC;
 
 SELECT
  ft.transaction_amount,
  AVG(ft.transaction_amount)    OVER (PARTITION BY ft.customer_id) AS avg_spend,
  STDDEV(ft.transaction_amount) OVER (PARTITION BY ft.customer_id) AS stddev_spend
FROM fact_transactions ft
LIMIT 20;

-- removed the partiton by because makes the window global — every row is compared against the average of all 50000 transactions. 
SELECT *,
  'Anomaly' AS flag
FROM (
  SELECT
    ft.transaction_id,
    c.full_name,
    ft.transaction_amount,
    AVG(ft.transaction_amount)    OVER () AS avg_spend,
    STDDEV(ft.transaction_amount) OVER () AS stddev_spend
  FROM fact_transactions ft
  JOIN dim_customer c ON ft.customer_id = c.customer_id
) AS customer_stats
WHERE transaction_amount > avg_spend + (2 * stddev_spend)
ORDER BY transaction_amount DESC;

-- 3706 returned as anomaly 
 

 
 
