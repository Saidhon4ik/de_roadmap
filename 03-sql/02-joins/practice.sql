-- ============================================
-- PRACTICE: JOINs
-- Tables:
--   employees (id, name, department, salary, hire_date)
--   departments (id, department, location, budget)
-- ============================================

-- 1. INNER JOIN — employees with their department info
SELECT e.name, e.salary, d.department
FROM employees_5000 e
INNER JOIN departments d ON e.department = d.department;

-- 2. LEFT JOIN — all employees, with department info if exists
SELECT e.name, e.salary, d.location
FROM employees_5000 e
LEFT JOIN departments d ON e.department = d.department;

-- 3. LEFT JOIN — find employees with NO matching department (NULL check)
SELECT e.name, e.department
FROM employees_5000 e
LEFT JOIN departments d ON e.department = d.department
WHERE d.department IS NULL;

-- 4. JOIN + WHERE — Engineering employees with department location
SELECT e.name, e.salary, d.location
FROM employees_5000 e
INNER JOIN departments d ON e.department = d.department
WHERE e.department = 'Engineering';

-- 5. JOIN + ORDER BY
SELECT e.name, e.salary, d.location
FROM employees_5000 e
INNER JOIN departments d ON e.department = d.department
ORDER BY e.salary DESC;

-- 6. Self JOIN — employees in the same department
SELECT a.name AS employee, b.name AS colleague, a.department
FROM employees_5000 a
JOIN employees_5000 b ON a.department = b.department
WHERE a.id != b.id
LIMIT 10;