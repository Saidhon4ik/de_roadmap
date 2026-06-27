-- ============================================
-- TASKS: SELECT & WHERE
-- Solve each task below. Write your answer under each comment.
-- Table: employees (id, name, department, salary, hire_date)
-- ============================================

-- TASK 1: Select name and department of all employees in 'Marketing'
-- ANSWER:
select name,department
from employees_5000
where department = 'Marketing';


-- TASK 2: Select all employees with salary greater than 90000
-- ANSWER:
select * from employees_5000
where salary > 90000;


-- TASK 3: Select name and salary of employees hired after 2020-01-01
-- ANSWER:
select name, salary
from employees_5000
where hire_date > '2020-01-01';

-- TASK 4: Select employees from 'HR' or 'Finance' departments
-- ANSWER:
select * from employees_5000
where department in ('HR', 'Finance');

-- TASK 5: Select top 10 employees by salary (highest first)
-- ANSWER:
select * from employees_5000
order by salary desc
limit 10;

-- TASK 6: Select employees whose name starts with 'J'
-- ANSWER:
select * from employees_5000
where name like 'J%';

-- TASK 7: Select employees with salary between 50000 and 70000
-- (use BETWEEN)
-- ANSWER:
select * from employees_5000
where salary between 50000 and 70000;

-- TASK 8: Select name, department, salary — order by department A→Z,
-- then by salary highest first
-- ANSWER:
select name,department,salary 
from employees_5000
order by department asc ,salary desc;