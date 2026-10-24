-- Customer Churn Analysis (Telecom) - SQL queries
-- Table: churn  (loaded from churn_clean.csv). Standard SQL, runs on PostgreSQL and SQLite.
-- Load in PostgreSQL: create the table first (see README), then \copy churn FROM 'churn_clean.csv' CSV HEADER

-- Q1. Overall churn rate and monthly revenue at risk
SELECT COUNT(*) AS customers,
       SUM(churn_flag) AS churned,
       ROUND(100.0 * SUM(churn_flag) / COUNT(*), 1) AS churn_rate_pct,
       ROUND(SUM(CASE WHEN churn_flag = 1 THEN MonthlyCharges END), 0) AS monthly_revenue_lost,
       ROUND(100.0 * SUM(CASE WHEN churn_flag = 1 THEN MonthlyCharges END) / SUM(MonthlyCharges), 1) AS pct_of_monthly_revenue
FROM churn;

-- Q2. Churn by contract type
SELECT Contract, COUNT(*) AS customers,
       ROUND(100.0 * AVG(churn_flag), 1) AS churn_rate_pct
FROM churn
GROUP BY Contract
ORDER BY churn_rate_pct DESC;

-- Q3. Churn by tenure group
SELECT tenure_group, COUNT(*) AS customers,
       ROUND(100.0 * AVG(churn_flag), 1) AS churn_rate_pct
FROM churn
GROUP BY tenure_group
ORDER BY MIN(tenure);

-- Q4. Churn by internet service and payment method
SELECT InternetService, PaymentMethod, COUNT(*) AS customers,
       ROUND(100.0 * AVG(churn_flag), 1) AS churn_rate_pct
FROM churn
GROUP BY InternetService, PaymentMethod
HAVING COUNT(*) >= 100
ORDER BY churn_rate_pct DESC
LIMIT 5;

-- Q5. High-risk segment: month-to-month + fiber optic + first-year customers
SELECT COUNT(*) AS customers,
       ROUND(100.0 * AVG(churn_flag), 1) AS churn_rate_pct,
       ROUND(SUM(MonthlyCharges), 0) AS monthly_revenue
FROM churn
WHERE Contract = 'Month-to-month' AND InternetService = 'Fiber optic' AND tenure <= 12;

-- Q6. Does add-on support reduce churn? (internet customers only)
SELECT TechSupport, OnlineSecurity, COUNT(*) AS customers,
       ROUND(100.0 * AVG(churn_flag), 1) AS churn_rate_pct
FROM churn
WHERE InternetService <> 'No'
GROUP BY TechSupport, OnlineSecurity
ORDER BY churn_rate_pct DESC;

-- Q7. Rank contract types within each charges band by churn (window function)
SELECT charges_band, Contract, churn_rate_pct,
       RANK() OVER (PARTITION BY charges_band ORDER BY churn_rate_pct DESC) AS risk_rank
FROM (
  SELECT charges_band, Contract, ROUND(100.0 * AVG(churn_flag), 1) AS churn_rate_pct
  FROM churn
  GROUP BY charges_band, Contract
) x
ORDER BY charges_band, risk_rank;

-- Q8. Share of all churn contributed by each contract type (window function)
SELECT Contract, SUM(churn_flag) AS churned,
       ROUND(100.0 * SUM(churn_flag) / SUM(SUM(churn_flag)) OVER (), 1) AS share_of_all_churn_pct
FROM churn
GROUP BY Contract
ORDER BY churned DESC;

-- Q9. How many times riskier is each contract type than the average customer? (CTE + JOIN)
WITH overall AS (
  SELECT AVG(churn_flag) AS overall_rate FROM churn
),
by_contract AS (
  SELECT Contract, COUNT(*) AS customers, AVG(churn_flag) AS contract_rate
  FROM churn
  GROUP BY Contract
)
SELECT b.Contract, b.customers,
       ROUND(100.0 * b.contract_rate, 1) AS churn_rate_pct,
       ROUND(b.contract_rate / o.overall_rate, 2) AS risk_multiple_vs_avg
FROM by_contract b
CROSS JOIN overall o
ORDER BY risk_multiple_vs_avg DESC;
