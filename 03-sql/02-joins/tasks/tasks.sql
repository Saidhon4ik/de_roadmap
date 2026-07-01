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
select a.name,a.department,count(b.id) as counter1
from employees_5000 a
join employees_5000 b on a.department = b.department
where a.name != b.name
group by a.name,a.department
order by a.department
limit 100;

-- TASK 4: For each employee, show the highest earner
-- in their department (show employee name + top earner name + salary)
-- ANSWER:
SELECT a.name AS employee, b.name AS top_earner, b.salary AS top_salary
FROM employees_5000 a
JOIN employees_5000 b ON a.department = b.department
WHERE b.salary = (
    SELECT MAX(salary) 
    FROM employees_5000 c 
    WHERE c.department = a.department
)
ORDER BY a.department
LIMIT 100;


-- TASK 5: Find employees who earn less than the average salary
-- of their own department
-- ANSWER:
SELECT a.name, a.department, a.salary
FROM employees_5000 a
WHERE a.salary < (
    SELECT AVG(b.salary)
    FROM employees_5000 b
    WHERE b.department = a.department
)
ORDER BY a.department
LIMIT 100;

-- TASK 6: Get top 3 highest paid employees per department
-- (show name, department, salary)
-- ANSWER:
SELECT name, department, salary
FROM (
    SELECT name, department, salary,
           ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rn
    FROM employees_5000
) ranked
WHERE rn <= 3
ORDER BY department, salary DESC;