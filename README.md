# FP&A Budget Variance Report — LATAM 2025

Financial reporting project analyzing budget variance, department performance 
and cost consistency across 2 regions and 5 LATAM countries. Built with BigQuery SQL.

## Business Context

Multi-country finance operations require consolidated visibility across entities, 
departments and time periods. This project replicates a real FP&A reporting workflow: 
extracting raw expense data, comparing actuals vs budget, and surfacing actionable 
insights for executive decision-making.

## Dataset

- **Source**: Google BigQuery
- **Tables**: `expenses` (480 rows) and `departments` (20 rows)
- **Coverage**: 5 countries (Argentina, Mexico, Colombia, Chile, Peru), 
  4 departments, 12 months (2025), Actual vs Budget
- **Schema**:
  - `expenses`: id, country, department, month (DATE), total (FLOAT), type (INTEGER: 1=Actual, 2=Budget)
  - `departments`: country, department, region, category

## Report Structure

| Section | Description |
|---|---|
| 1. Executive Summary | Actual vs Budget with absolute and % variance by country |
| 2. Region & Category Performance | Variance analysis grouped by region and cost category |
| 3. Monthly Consolidated Trend | Company-wide Actual spend with MoM absolute and % change |
| 4. Department Ranking | Top 3 departments by Actual spend per country with % weight |
| 5. Execution Consistency | STDDEV of monthly % variance per country — lower = more consistent |

## Tech Stack

- Google BigQuery (SQL)
- GitHub for version control

## Key SQL Concepts Applied

- Aggregations with `SUM(CASE WHEN)`
- Window functions: `RANK()`, `LAG()`, `SUM() OVER()`, `STDDEV()`
- CTEs for multi-step analysis
- Multi-key JOINs across fact and dimension tables
- `QUALIFY` for window function filtering