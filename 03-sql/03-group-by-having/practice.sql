-- ============================================
-- PRACTICE: GROUP BY & HAVING
-- Table: employees_5000 (id, name, department, salary, hire_date)
-- ============================================

-- 1. Count employees per department
SELECT department, COUNT(*) AS total
FROM employees_5000
GROUP BY department;

-- 2. Average salary per department
SELECT department, AVG(salary) AS avg_salary
FROM employees_5000
GROUP BY department;

-- 3. Max and min salary per department
SELECT department, MAX(salary) AS max_sal, MIN(salary) AS min_sal
FROM employees_5000
GROUP BY department;

-- 4. Total salary per department
SELECT department, SUM(salary) AS total_salary
FROM employees_5000
GROUP BY department;

-- 5. HAVING — departments with avg salary > 70000
SELECT department, AVG(salary) AS avg_salary
FROM employees_5000
GROUP BY department
HAVING AVG(salary) > 70000;

-- 6. WHERE + GROUP BY — only Engineering and HR, then group
SELECT department, COUNT(*) AS total
FROM employees_5000
WHERE department IN ('Engineering', 'HR')
GROUP BY department;

-- 7. ORDER BY after GROUP BY
SELECT department, AVG(salary) AS avg_salary
FROM employees_5000
GROUP BY department
ORDER BY avg_salary DESC;