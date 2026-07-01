-- ============================================
-- FP&A Budget Variance Report — LATAM 2025
-- Author: Julian Issidoro
-- Source: portfolioprojects-202606.roadmap_data
-- Tables: expenses, departments
-- ============================================


-- -----------------------------------------------
-- SECTION 1: Executive Summary by Country
-- Total Actual, Budget, absolute and % variance
-- Ordered by highest deviation
-- -----------------------------------------------
WITH actuals AS(
  SELECT
  country,
  ROUND(SUM(CASE WHEN type = 1 THEN total END),2) AS actual,
  SUM(CASE WHEN type = 2 THEN total END) AS budget

  FROM `portfolioprojects-202606.roadmap_data.expenses`

  GROUP BY country
)

SELECT
country,
actual,
budget,
ROUND((actual - budget),2) AS abs_var,
ROUND((((actual / budget) -1) * 100),2) AS per_var

FROM actuals

ORDER BY per_var DESC


-- -----------------------------------------------
-- SECTION 2: Performance by Region and Category
-- Actual and Budget by category (Core Business,
-- Growth, Support) with % variance
-- -----------------------------------------------
WITH region_total AS (
SELECT
  d.region,
  d.category,
  ROUND(SUM(CASE WHEN type = 1 THEN total END),2) as total,
  ROUND(SUM(CASE WHEN type = 2 THEN total END),2) as budget

FROM `portfolioprojects-202606.roadmap_data.expenses`e
LEFT JOIN `portfolioprojects-202606.roadmap_data.departments`d
  ON e.country = d.country AND e.department = d.department
GROUP BY d.region, d.category
)


SELECT
region,
category,
total,
budget,
ROUND(((total / budget) -1) * 100, 2) AS perc_var


FROM region_total
ORDER BY region, perc_var DESC


-- -----------------------------------------------
-- SECTION 3: Monthly Consolidated Trend
-- Total company Actual per month with MoM
-- absolute and % variation
-- -----------------------------------------------
WITH total_company AS (
SELECT
  EXTRACT (MONTH FROM month) AS month,
  ROUND(SUM(CASE WHEN type = 1 THEN total END),2) as total,
  ROUND(SUM(CASE WHEN type = 2 THEN total END),2) as budget

FROM `portfolioprojects-202606.roadmap_data.expenses`e

GROUP BY month
)


SELECT
month,
total,
budget,
ROUND((total - budget), 2) AS abs_var,
ROUND(((total / budget) -1) * 100, 2) AS perc_var,
ROUND(total - LAG (total, 1) OVER (ORDER BY month),2) AS MoM_var,
ROUND((total / (LAG (total, 1) OVER (ORDER BY month)) -1) * 100,2) AS MoM_per


FROM total_company

-- -----------------------------------------------
-- SECTION 4: Department Ranking by Country
-- Top 3 departments by Actual spend per country
-- with % weight over country total
-- -----------------------------------------------
WITH department_total AS (
SELECT
  d.department,
  e.country,
  ROUND(SUM(total),2) as dep_total
FROM `portfolioprojects-202606.roadmap_data.expenses`e
LEFT JOIN `portfolioprojects-202606.roadmap_data.departments`d
  ON e.country = d.country AND e.department = d.department
WHERE type = 1
GROUP BY d.department, e.country
)

SELECT
RANK() OVER (PARTITION BY country ORDER BY dep_total DESC) AS dept_ranking,
department,
country,
dep_total,
ROUND(SUM(dep_total) OVER (PARTITION BY country),2) as ctry_total,
ROUND(SUM(dep_total) OVER (PARTITION BY country, department) / SUM(dep_total) OVER (PARTITION BY country),2) AS peso_ov_ctry
FROM department_total

QUALIFY dept_ranking <= 3

ORDER BY country, dept_ranking


-- -----------------------------------------------
-- SECTION 5: Execution Consistency by Country
-- STDDEV of monthly % variance per country
-- Lower = more consistent budget execution
-- -----------------------------------------------
WITH total_month AS(
SELECT
country,
EXTRACT (MONTH FROM month) AS month,
SUM(CASE WHEN type = 1 THEN total END) AS actual,
SUM(CASE WHEN type = 2 THEN total END) AS bdgt

FROM `portfolioprojects-202606.roadmap_data.expenses`
GROUP BY country, month
)

SELECT
country,
ROUND((STDDEV((actual / bdgt) -1) * 100),4) AS std_dev_month

FROM total_month
GROUP BY country
ORDER BY std_dev_month
