CREATE DATABASE Bankpluse;

USE Bankpluse;
-- Creating the customer_transacation table 

CREATE TABLE Customer_Transacations (
customer_id INT NOT NULL, 
first_name varchar(50), 
surname varchar(50),
gender varchar(10) ,
birthdate DATE,
transaction_amount decimal(12,2) NOT NULL, 
transaction_date DATE NOT NULL, 
merchant_name varchar(100), 
category varchar(50)
); 

-- inspecting the data 

SELECT *
FROM Customer_Transacations;

SELECT *
FROM Customer_Transacations 
LIMIT 10; 

-- Check for nulls in the data 
SELECT  
SUM(CASE WHEN transaction_amount IS NULL THEN 1 ELSE 0 END) AS null_amounts,
SUM(CASE WHEN transaction_date IS NULL THEN 1 ELSE 0 END) AS null_date,
SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer
FROM Customer_Transacations;

-- Transactions Amount, Transaction Date and Customer id all have no null values which is cruical for the dataset. 

-- Creating a clean table pirtiosing the null values in the gender row 

CREATE TABLE Customer_transactions_clean AS
SELECT
customer_id,
COALESCE(first_name, 'Unknown') AS first_name,
COALESCE(surname, 'Unknown') AS surname,
COALESCE(NULLIF(UPPER(LEFT(gender, 1)), ''), 'U') AS gender, -- M /F / U
birthdate,
CAST(transaction_amount AS DECIMAL(12,2)) AS transaction_amount,
transaction_date,
COALESCE(merchant_name, 'Unknown Merchant') AS merchant_name,
COALESCE(category, 'Uncategorised') AS category
FROM customer_transactions
WHERE transaction_date IS NOT NULL
AND transaction_amount IS NOT NULL
AND customer_id IS NOT NULL ;

-- Verify clean data using aggeragate functions 
SELECT COUNT(*)  AS clean_rows,
	MIN(transaction_date) AS earliest_date,
    MAX(transaction_date) AS Latest_date, 
    MIN(transaction_amount) AS min_amount,
    MAX(transaction_amount) AS max_amount,
    COUNT(DISTINCT gender) AS number_of_gender,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT merchant_name) AS unique_merchants
	FROM customer_transactions_clean;
    
    







