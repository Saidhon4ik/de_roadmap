-- ============================================
-- TASKS: GROUP BY & HAVING
-- Table: employees_5000 (id, name, department, salary, hire_date)
-- ============================================

-- TASK 1: Count total employees per department
-- ANSWER:
SELECT department, COUNT(*) AS total
FROM employees_5000
GROUP BY department;

-- TASK 2: Get average salary per department, ordered highest first
-- ANSWER:
SELECT department, AVG(salary) AS avg_salary
FROM employees_5000
GROUP BY department
ORDER BY avg_salary DESC;

-- TASK 3: Find departments where total salary exceeds 5,000,000
-- ANSWER:
SELECT department, SUM(salary) AS total_salary
FROM employees_5000
GROUP BY department
HAVING SUM(salary) > 5000000;

-- TASK 4: Get max salary per department, only show departments
-- where max salary > 90000
-- ANSWER:
SELECT department, MAX(salary) AS max_salary
FROM employees_5000
GROUP BY department
HAVING MAX(salary) > 90000;

-- TASK 5: Count employees hired after 2019-01-01 per department
-- ANSWER:
SELECT department, COUNT(*) AS total
FROM employees_5000
WHERE hire_date > '2019-01-01'
GROUP BY department;

-- TASK 6: Get department with the most employees
-- ANSWER:
SELECT department, COUNT(*) AS total
FROM employees_5000
GROUP BY department
ORDER BY total DESC
LIMIT 1;