-- ============================================
-- PRACTICE: SELECT & WHERE
-- Table: employees (id, name, department, salary, hire_date)
-- ============================================

-- 1. Select all columns
SELECT * FROM employees;

-- 2. Select specific columns
SELECT name, salary FROM employees;

-- 3. Filter by department
SELECT name, salary
FROM employees
WHERE department = 'Engineering';

-- 4. Multiple conditions with AND
SELECT name, salary
FROM employees
WHERE department = 'Engineering' AND salary > 80000;

-- 5. OR condition
SELECT name, department
FROM employees
WHERE department = 'HR' OR department = 'Finance';

-- 6. IN operator (same as multiple OR)
SELECT name, department
FROM employees
WHERE department IN ('HR', 'Finance');

-- 7. BETWEEN
SELECT name, salary
FROM employees
WHERE salary BETWEEN 60000 AND 90000;

-- 8. LIKE — names starting with 'A'
SELECT name FROM employees
WHERE name LIKE 'A%';

-- 9. ORDER BY salary descending
SELECT name, salary
FROM employees
ORDER BY salary DESC;

-- 10. LIMIT — top 5 highest paid
SELECT name, salary
FROM employees
ORDER BY salary DESC
LIMIT 5;