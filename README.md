# BankPulse 🏦
> Retail Banking Transaction Analytics Pipeline — MySQL 8

A production-style end-to-end data engineering pipeline built on a real-world retail banking dataset. Raw customer transaction data flows through a three-layer SQL architecture — staging, dimensional modelling, and analytics — producing business-ready insights on customer spend, merchant trends, and transaction anomalies.

---

## Project Overview

A retail bank exports thousands of customer transactions from its core banking system as a raw CSV. This project builds the data infrastructure that turns that file into trusted, query-ready analytics — the same pipeline a data engineer at a bank would be expected to design and maintain.

**Dataset:** [Bank Customer Transactions — Kaggle](https://www.kaggle.com/datasets/bkcoban/customer-transactions)  
**Rows:** 50,000 transactions  
**Tool:** MySQL 8.0  

---

## Business Questions Answered

| Question | Analytics Layer |
|---|---|
| Which spending category drives the most volume? | Total spend by category with ROLLUP |
| Who are the top 10 highest-spending customers? | RANK() window function |
| How does spending change month by month per category? | Monthly spend GROUP BY year, month, category |
| What is each customer's rolling 30-day spend? | SUM() OVER (ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) |
| Which transactions are unusually large? | AVG() + STDDEV() anomaly detection |

---

## Pipeline Architecture

```
Raw CSV (Kaggle)
      │
      ▼
┌─────────────────────┐
│   Layer 1 — Staging │  01_staging.sql
│  stg_transactions   │  Load → Cast types → Handle nulls → Clean
└─────────────────────┘
      │
      ▼
┌──────────────────────────┐
│  Layer 2 — Dimensions    │  02_dimensions.sql
│  dim_customer            │  Age, age segment, gender normalisation
│  dim_merchant            │  Surrogate key via ROW_NUMBER()
│  dim_date                │  Calendar table via WITH RECURSIVE
└──────────────────────────┘
      │
      ▼
┌──────────────────────────┐
│  Layer 3 — Fact Table    │  03_fact_table.sql
│  fact_transactions       │  Star schema — FK joins to all dimensions
└──────────────────────────┘
      │
      ▼
┌──────────────────────────┐
│  Analytics Layer         │  04_analytics.sql
│  Window functions        │  Rankings, rolling spend, anomaly flags
└──────────────────────────┘
```

---

## Repository Structure

```
bankpulse-mysql/
├── data/
│   └── transactions.csv        ← from Kaggle (not committed — see below)
├── sql/
│   ├── 01_staging.sql
│   ├── 02_dimensions.sql
│   ├── 03_fact_table.sql
│   └── 04_analytics.sql
├── docs/
│   └── erd.png                 ← Entity Relationship Diagram
└── README.md
```

> The raw CSV is not committed to this repo. Download it from [Kaggle](https://www.kaggle.com/datasets/bkcoban/customer-transactions) and place it in the `data/` folder.

---

## Data Model — Star Schema

```
                    ┌──────────────┐
                    │ dim_customer │
                    │  customer_id │◄──┐
                    │  full_name   │   │
                    │  gender      │   │
                    │  age         │   │
                    │  age_segment │   │
                    └──────────────┘   │
                                       │
┌──────────────┐   ┌──────────────────┴───┐   ┌─────────────┐
│  dim_date    │   │   fact_transactions   │   │ dim_merchant│
│  date  ◄─────┼───┤  transaction_id (PK) ├───►  merchant_id│
│  year        │   │  customer_id  (FK)   │   │  merchant_name│
│  month       │   │  merchant_id  (FK)   │   │  category   │
│  quarter     │   │  date         (FK)   │   └─────────────┘
│  day_type    │   │  transaction_amount  │
└──────────────┘   └──────────────────────┘
```

---

## SQL Skills Demonstrated

**Staging layer**
- `CAST()` for type enforcement
- `COALESCE()` for null handling
- `NULLIF()` for empty string normalisation
- `UPPER(LEFT())` for text standardisation

**Dimension layer**
- `DISTINCT` to collapse to one row per entity
- `ROW_NUMBER() OVER()` to generate surrogate keys
- `TIMESTAMPDIFF()` to calculate customer age
- `CASE WHEN` to bucket customers into age segments
- `WITH RECURSIVE` to build a full calendar date spine

**Fact table**
- Star schema design with three foreign key constraints
- Multi-condition JOIN to resolve merchant dimension
- `AUTO_INCREMENT` primary key

**Analytics layer**
- `GROUP BY ... WITH ROLLUP` for category totals with grand total
- `RANK() OVER (PARTITION BY ... ORDER BY ...)` for customer spend rankings
- `SUM() OVER (ROWS BETWEEN 29 PRECEDING AND CURRENT ROW)` for rolling 30-day spend
- `AVG() + STDDEV() OVER()` for statistical anomaly detection

---

## How to Run

1. Download the dataset from [Kaggle](https://www.kaggle.com/datasets/bkcoban/customer-transactions)
2. Open MySQL Workbench and connect to your local MySQL 8 instance
3. Run the SQL files in order:

```sql
-- Run in this exact order
01_staging.sql       -- creates database, staging tables, loads CSV
02_dimensions.sql    -- builds dim_customer, dim_merchant, dim_date
03_fact_table.sql    -- builds fact_transactions with FK constraints
04_analytics.sql     -- runs all five business analytics queries
```

4. Use MySQL Workbench's **Table Data Import Wizard** to load `transactions.csv` into `stg_transactions`

---

## Key Findings

- **3,706 anomalous transactions** flagged — transactions more than 2 standard deviations above the global average spend
- Full star schema built on 50,000 transactions across multiple merchant categories and customer segments
- Rolling 30-day spend calculated per customer across the full transaction history

---

## Author

**Abdul** — Data Engineering Portfolio project demonstrate end-to-end data engineering skills in MySQL 8 — from raw CSV ingestion through dimensional modelling to window function analytics.
GitHub: github.com/Abdulbanire 
