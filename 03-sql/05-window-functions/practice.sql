-- ============================================
-- PRACTICE: Window Functions
-- Table: employees_5000 (id, name, department, salary, hire_date)
-- ============================================

-- 1. ROW_NUMBER — rank employees by salary within department
SELECT name, department, salary,
       ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rn
FROM employees_5000;

-- 2. RANK — with gaps on ties
SELECT name, department, salary,
       RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rnk
FROM employees_5000;

-- 3. DENSE_RANK — no gaps on ties
SELECT name, department, salary,
       DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dense_rnk
FROM employees_5000;

-- 4. LAG — previous employee salary (ordered by salary)
SELECT name, salary,
       LAG(salary) OVER (ORDER BY salary) AS prev_salary
FROM employees_5000;

-- 5. LEAD — next employee salary
SELECT name, salary,
       LEAD(salary) OVER (ORDER BY salary) AS next_salary
FROM employees_5000;

-- 6. Running total of salary by hire date
SELECT name, hire_date, salary,
       SUM(salary) OVER (ORDER BY hire_date) AS running_total
FROM employees_5000;

-- 7. Average salary per department alongside each row
SELECT name, department, salary,
       AVG(salary) OVER (PARTITION BY department) AS dept_avg
FROM employees_5000;

-- 8. Top 1 earner per department using ROW_NUMBER
SELECT name, department, salary
FROM (
    SELECT name, department, salary,
           ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rn
    FROM employees_5000
) ranked
WHERE rn = 1;