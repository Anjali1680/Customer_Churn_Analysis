# Customer Churn Analysis (Telecom)

**Question:** Which customers leave, and where should retention effort go?
**Data:** IBM Telco Customer Churn dataset (public, 7,043 customers, 21 columns)
**Tools:** Python (Pandas, Matplotlib, Seaborn), SQL (PostgreSQL / SQLite)

## Files
| File | Description |
|---|---|
| `churn_analysis.ipynb` | Cleaning, exploratory analysis, charts and findings |
| `churn_queries.sql` | 9 SQL queries (aggregations, CASE, CTE + JOIN, window functions) |
| `churn_clean.csv` | Cleaned dataset used for the SQL queries |
| `Telco-Customer-Churn.csv` | Raw data |

## Key results
- 7,043 customers, **26.5% churned** (1,869), taking **$139K monthly revenue (30.5%)**
- Contract: month-to-month **42.7%** vs one-year 11.3% vs two-year 2.8%. Month-to-month customers account for **88.6% of all churn**
- Tenure: first-year customers churn at **47.4%**, vs 9.5% after 4+ years
- Fiber optic **41.9%** vs DSL 19.0%; electronic check **45.3%** vs ~16% for auto-pay
- High-risk segment (month-to-month + fiber + first year): **916 customers, 70.2% churn, $75K monthly revenue**
- Internet customers with both Tech Support and Online Security: **9.0%** churn vs **49.0%** with neither

## Run the SQL in PostgreSQL
```sql
CREATE TABLE churn (
  customerID TEXT PRIMARY KEY, gender TEXT, SeniorCitizen TEXT, Partner TEXT, Dependents TEXT,
  tenure INT, PhoneService TEXT, MultipleLines TEXT, InternetService TEXT, OnlineSecurity TEXT,
  OnlineBackup TEXT, DeviceProtection TEXT, TechSupport TEXT, StreamingTV TEXT, StreamingMovies TEXT,
  Contract TEXT, PaperlessBilling TEXT, PaymentMethod TEXT, MonthlyCharges NUMERIC, TotalCharges NUMERIC,
  Churn TEXT, churn_flag INT, tenure_group TEXT, charges_band TEXT
);
\copy churn FROM 'churn_clean.csv' CSV HEADER
```
Then run `churn_queries.sql`. The queries use standard SQL and were tested in SQLite.
Note: Q3 orders by `MIN(tenure)` so the tenure groups appear in order.

## Recommendations
1. Offer perks or discounts to move month-to-month customers onto 1- or 2-year plans.
2. Run onboarding calls and early-life offers for the high-risk first-year fiber segment.
3. Bundle Tech Support and Online Security for internet customers.
4. Incentivise electronic-check customers to switch to auto-pay.
