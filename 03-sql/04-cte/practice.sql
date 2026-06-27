-- ============================================
-- PRACTICE: Subqueries & CTE
-- Table: employees_5000 (id, name, department, salary, hire_date)
-- ============================================

-- 1. Subquery — employees earning above average
SELECT name, salary
FROM employees_5000
WHERE salary > (SELECT AVG(salary) FROM employees_5000);

-- 2. Subquery in FROM — avg salary per department
SELECT dept, avg_sal
FROM (
    SELECT department AS dept, AVG(salary) AS avg_sal
    FROM employees_5000
    GROUP BY department
) AS dept_avg
ORDER BY avg_sal DESC;

-- 3. CTE — employees earning above average
WITH avg_sal AS (
    SELECT AVG(salary) AS avg FROM employees_5000
)
SELECT name, salary
FROM employees_5000, avg_sal
WHERE salary > avg_sal.avg;

-- 4. CTE — top earner per department
WITH ranked AS (
    SELECT name, department, salary,
           ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rn
    FROM employees_5000
)
SELECT name, department, salary
FROM ranked
WHERE rn = 1;

-- 5. Multiple CTEs
WITH
high_earners AS (
    SELECT * FROM employees_5000 WHERE salary > 80000
),
eng_only AS (
    SELECT * FROM high_earners WHERE department = 'Engineering'
)
SELECT name, salary FROM eng_only
ORDER BY salary DESC;