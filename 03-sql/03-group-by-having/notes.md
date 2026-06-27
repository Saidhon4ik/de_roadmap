# SQL — GROUP BY & HAVING

## 1. Simple explanation
GROUP BY groups rows by a column value.
HAVING filters those groups (like WHERE but after grouping).

## 2. Why it's needed
To aggregate data — count, sum, average per category.
Core skill for any data analysis or reporting pipeline.

## 3. Pipeline placement
Source → [GROUP BY aggregations] → Python → PostgreSQL → dbt → Airflow → BigQuery

## 4. Input → Output
Input:  raw rows (employees)
Output: aggregated results per group (one row per department)

## 5. Key syntax

-- Count employees per department
SELECT department, COUNT(*) AS total
FROM employees
GROUP BY department;

-- Average salary per department
SELECT department, AVG(salary) AS avg_salary
FROM employees
GROUP BY department;

-- HAVING — filter groups
SELECT department, AVG(salary) AS avg_salary
FROM employees
GROUP BY department
HAVING AVG(salary) > 70000;

## 6. Aggregate functions
COUNT(*)     → count rows
SUM(salary)  → total salary
AVG(salary)  → average salary
MAX(salary)  → highest salary
MIN(salary)  → lowest salary

## 7. SQL execution order
FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT

## 8. Common mistakes
- Using WHERE instead of HAVING to filter aggregates
- Selecting columns not in GROUP BY
- Confusing COUNT(*) vs COUNT(column) — COUNT(column) ignores NULLs

## 9. Interview questions
- What is the difference between WHERE and HAVING?
- Can you use HAVING without GROUP BY?
- What does COUNT(*) vs COUNT(column) return?