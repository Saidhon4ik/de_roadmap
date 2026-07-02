-- ============================================
-- TASKS: Subqueries & CTE
-- Table: employees_5000 (id, name, department, salary, hire_date)
-- ============================================

-- TASK 1: Find employees earning above the overall average salary
-- (use subquery)
-- ANSWER:
SELECT name, salary
FROM employees_5000
WHERE salary > (SELECT AVG(salary) FROM employees_5000);

-- TASK 2: Same as TASK 1 but use CTE instead of subquery
-- ANSWER:
WITH avg_sal AS (
    SELECT AVG(salary) AS avg FROM employees_5000
)
SELECT name, salary
FROM employees_5000, avg_sal
WHERE salary > avg_sal.avg;

-- TASK 3: Find the highest paid employee in each department using CTE
-- ANSWER:
WITH ranked AS (
    SELECT name, department, salary,
           ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rn
    FROM employees_5000
)
SELECT name, department, salary
FROM ranked
WHERE rn = 1;

-- TASK 4: Find departments where average salary is above
-- the overall average salary (use CTE)
-- ANSWER:
WITH dept_avg AS (
    SELECT department, AVG(salary) AS avg_salary
    FROM employees_5000
    GROUP BY department
),
overall_avg AS (
    SELECT AVG(salary) AS avg FROM employees_5000
)
SELECT dept_avg.department, dept_avg.avg_salary
FROM dept_avg, overall_avg
WHERE dept_avg.avg_salary > overall_avg.avg;

-- TASK 5: Using multiple CTEs — first get high earners (salary > 80000),
-- then from those get only HR employees
-- ANSWER:
WITH high_earners AS (
    SELECT * FROM employees_5000 WHERE salary > 80000
),
hr_only AS (
    SELECT * FROM high_earners WHERE department = 'HR'
)
SELECT name, salary FROM hr_only;

-- TASK 6: Get the 2nd highest salary in each department using CTE
-- ANSWER:
WITH ranked AS (
    SELECT name, department, salary,
           DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dr
    FROM employees_5000
)
SELECT name, department, salary
FROM ranked
WHERE dr = 2;