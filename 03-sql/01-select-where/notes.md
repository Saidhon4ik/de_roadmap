# SQL — SELECT & WHERE

## 1. Simple explanation
SELECT tells the database WHAT to retrieve.
WHERE tells the database WHICH rows to return.

## 2. Why it's needed
Every data pipeline starts with pulling data.
SELECT + WHERE is the most fundamental SQL operation.

## 3. Pipeline placement
Source → [SELECT/WHERE] → Python → PostgreSQL → dbt → Airflow → BigQuery

## 4. Input → Output
Input:  full table (employees)
Output: filtered rows with selected columns

## 5. Key syntax

-- Select specific columns
SELECT name, salary FROM employees;

-- Filter rows
SELECT name, salary FROM employees
WHERE department = 'Engineering';

-- Multiple conditions
SELECT name, salary FROM employees
WHERE department = 'Engineering' AND salary > 80000;

-- Operators
WHERE salary BETWEEN 50000 AND 90000
WHERE department IN ('HR', 'Finance')
WHERE name LIKE 'A%'
WHERE hire_date IS NULL

## 6. SQL execution order
FROM → WHERE → SELECT → ORDER BY → LIMIT

## 7. Common mistakes
- SELECT runs AFTER WHERE (can't filter by alias from SELECT)
- LIKE is case-sensitive in PostgreSQL
- Use single quotes for strings: 'Engineering' not "Engineering"

## 8. Interview questions
- What is the difference between WHERE and HAVING?
- In what order does SQL execute clauses?
- What does LIKE 'A%' mean?