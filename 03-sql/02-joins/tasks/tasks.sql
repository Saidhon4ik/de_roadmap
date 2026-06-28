-- ============================================
-- TASKS: JOINs
-- Table: employees_5000 (id, name, department, salary, hire_date)
-- Note: using self JOIN — joining table with itself
-- ============================================

-- TASK 1: Get all pairs of employees from the same department
-- (show both names and department)
-- ANSWER:
select a.name as employee_1,b.name as employee_2,a.department
from employees_5000 a 
join employees_5000 b on a.department = b.department
where a.id != b.id 
order by department
limit 100; --to make the query faster and not to wait 100 years

-- TASK 2: Get all pairs where employee A earns more than employee B
-- in the same department (show both names and both salaries)
-- ANSWER:
SELECT a.name AS employee_1, b.name AS employee_2, 
       a.salary AS salary_1, b.salary AS salary_2, a.department
FROM employees_5000 a
JOIN employees_5000 b ON a.department = b.department
WHERE a.salary > b.salary
ORDER BY a.department
LIMIT 100;

-- TASK 3: Count how many colleagues each employee has
-- in their department (exclude themselves)
-- ANSWER:


-- TASK 4: For each employee, show the highest earner
-- in their department (show employee name + top earner name + salary)
-- ANSWER:


-- TASK 5: Find employees who earn less than the average salary
-- of their own department
-- ANSWER:


-- TASK 6: Get top 3 highest paid employees per department
-- (show name, department, salary)
-- ANSWER: