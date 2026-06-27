# SQL — Subqueries & CTE

## 1. Simple explanation
Subquery — a query inside another query.
CTE (Common Table Expression) — a named subquery defined with WITH.

## 2. Why it's needed
Break complex queries into readable steps.
Reuse the same subquery multiple times without repeating code.

## 3. Pipeline placement
Source → [CTE/Subquery logic] → Python → PostgreSQL → dbt → Airflow → BigQuery

## 4. Input → Output
Input:  raw table
Output: filtered/transformed result using intermediate steps

## 5. Key syntax

-- Subquery in WHERE
SELECT name, salary FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- Subquery in FROM
SELECT dept, avg_sal
FROM (
    SELECT department AS dept, AVG(salary) AS avg_sal
    FROM employees
    GROUP BY department
) AS dept_avg;

-- CTE
WITH avg_sal AS (
    SELECT AVG(salary) AS avg FROM employees
)
SELECT name, salary
FROM employees, avg_sal
WHERE salary > avg_sal.avg;

-- Multiple CTEs
WITH
high_earners AS (
    SELECT * FROM employees WHERE salary > 80000
),
eng_only AS (
    SELECT * FROM high_earners WHERE department = 'Engineering'
)
SELECT * FROM eng_only;

## 6. CTE vs Subquery
CTE         → readable, reusable, easier to debug
Subquery    → inline, can be harder to read when nested

## 7. Common mistakes
- Referencing CTE outside the query it belongs to
- Forgetting comma between multiple CTEs
- Using ORDER BY inside CTE (not allowed in PostgreSQL)

## 8. Interview questions
- What is a CTE and when would you use it?
- What is the difference between CTE and subquery?
- Can you reference a CTE multiple times in the same query?