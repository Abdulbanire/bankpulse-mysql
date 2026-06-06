-- Create a Fact Table called fact_transactions 

DROP TABLE IF EXISTS fact_transactions;
CREATE TABLE fact_transactions (
transaction_id 		INT AUTO_INCREMENT PRIMARY KEY,
customer_id 		INT,
merchant_id 		INT,
date  				DATE,
transaction_amount	DECIMAL(12,2),
FOREIGN KEY(customer_id) 		REFERENCES dim_customer(customer_id),
FOREIGN KEY(merchant_id) 		REFERENCES dim_merchant(merchant_id),
FOREIGN KEY(date) 	REFERENCES dim_date(date)
);

INSERT INTO fact_transactions (
customer_id, 
merchant_id,
date,
transaction_amount)
SELECT 
c.customer_id,
m.merchant_id,
ctc.transaction_date,
ctc.transaction_amount
FROM customer_transactions_clean ctc
	JOIN dim_customer c ON ctc.customer_id = c.customer_id
    JOIN dim_merchant m ON ctc.merchant_name = m.merchant_id
						AND ctc.category = m.category
    JOIN dim_date d ON ctc.transaction_date = d.date;
    
INSERT INTO fact_transactions (customer_id, merchant_id, date, transaction_amount)
SELECT
  c.customer_id,
  m.merchant_id,
  ctc.transaction_date,
  ctc.transaction_amount
FROM customer_transactions_clean ctc
JOIN dim_customer c ON ctc.customer_id      = c.customer_id
JOIN dim_merchant m ON ctc.merchant_name    = m.merchant_name
                   AND ctc.category         = m.category
JOIN dim_date d     ON ctc.transaction_date = d.date;

SELECT * FROM fact_transactions;


