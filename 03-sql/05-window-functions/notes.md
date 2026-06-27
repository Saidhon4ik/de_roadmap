# SQL — Window Functions

## 1. Simple explanation
Window functions perform calculations across a set of rows
related to the current row — without collapsing them like GROUP BY.

## 2. Why it's needed
Ranking, running totals, comparing each row to its group average.
Essential for analytics and DE reporting pipelines.

## 3. Pipeline placement
Source → [Window Functions] → Python → PostgreSQL → dbt → Airflow → BigQuery

## 4. Input → Output
Input:  raw rows
Output: same rows + extra calculated column (rank, lag, running total)

## 5. Key syntax

-- ROW_NUMBER — unique rank per partition
SELECT name, department, salary,
       ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rn
FROM employees;

-- RANK — same rank for ties, skips next number
-- DENSE_RANK — same rank for ties, does not skip

-- LAG — previous row value
SELECT name, salary,
       LAG(salary) OVER (ORDER BY salary) AS prev_salary
FROM employees;

-- LEAD — next row value
SELECT name, salary,
       LEAD(salary) OVER (ORDER BY salary) AS next_salary
FROM employees;

-- SUM OVER — running total
SELECT name, salary,
       SUM(salary) OVER (ORDER BY hire_date) AS running_total
FROM employees;

## 6. RANK vs DENSE_RANK vs ROW_NUMBER
Salaries:     100, 90, 90, 80
ROW_NUMBER:   1,   2,  3,  4
RANK:         1,   2,  2,  4
DENSE_RANK:   1,   2,  2,  3

## 7. Common mistakes
- Confusing PARTITION BY (group within window) with GROUP BY (collapses rows)
- Forgetting ORDER BY inside OVER() for LAG/LEAD/running totals
- Using window functions in WHERE (not allowed — use CTE instead)

## 8. Interview questions
- What is the difference between ROW_NUMBER, RANK, DENSE_RANK?
- Can you use window functions in WHERE clause?
- What does PARTITION BY do?