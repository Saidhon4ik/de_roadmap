-- ============================================
-- TASKS: Window Functions
-- Table: employees_5000 (id, name, department, salary, hire_date)
-- ============================================

-- TASK 1: Rank employees by salary within each department
-- (use ROW_NUMBER, show name, department, salary, rank)
-- ANSWER:
SELECT name, department, salary,
       ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rn
FROM employees_5000;

-- TASK 2: Get the top 3 highest paid employees per department
-- ANSWER:
SELECT name, department, salary
FROM (
    SELECT name, department, salary,
           ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rn
    FROM employees_5000
) ranked
WHERE rn <= 3;

-- TASK 3: For each employee show their salary and
-- the previous employee salary (ordered by salary ASC)
-- ANSWER:
SELECT name, salary,
       LAG(salary) OVER (ORDER BY salary ASC) AS prev_salary
FROM employees_5000;

-- TASK 4: Show each employee's salary and
-- the average salary of their department in the same row
-- ANSWER:
SELECT name, department, salary,
       AVG(salary) OVER (PARTITION BY department) AS dept_avg
FROM employees_5000;

-- TASK 5: Calculate running total of salaries ordered by hire_date
-- ANSWER:
SELECT name, hire_date, salary,
       SUM(salary) OVER (ORDER BY hire_date) AS running_total
FROM employees_5000;

-- TASK 6: Find employees whose salary is above
-- their department average (use window function, not subquery)
-- ANSWER:
SELECT name, department, salary
FROM (
    SELECT name, department, salary,
           AVG(salary) OVER (PARTITION BY department) AS dept_avg
    FROM employees_5000
) t
WHERE salary > dept_avg;