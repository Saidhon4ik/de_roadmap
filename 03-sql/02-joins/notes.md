# SQL — JOINs

## 1. Simple explanation
JOIN combines rows from two or more tables based on a related column.

## 2. Why it's needed
Real data is split across multiple tables.
JOIN lets you pull related data together in one query.

## 3. Pipeline placement
Source → [JOIN tables] → Python → PostgreSQL → dbt → Airflow → BigQuery

## 4. Input → Output
Input:  two separate tables (employees + departments)
Output: one combined result set

## 5. Key syntax

-- INNER JOIN — only matching rows from both tables
SELECT e.name, e.salary, d.department
FROM employees e
INNER JOIN departments d ON e.department = d.department;

-- LEFT JOIN — all rows from left + matches from right (NULL if no match)
SELECT e.name, d.location
FROM employees e
LEFT JOIN departments d ON e.department = d.department;

-- Self JOIN — join a table with itself
SELECT a.name AS employee, b.name AS colleague
FROM employees a
JOIN employees b ON a.department = b.department
WHERE a.id != b.id;

## 6. JOIN types
INNER JOIN  → only matches
LEFT JOIN   → all from left + matches from right
RIGHT JOIN  → all from right + matches from left
FULL JOIN   → all from both tables

## 7. Common mistakes
- Forgetting ON clause → cartesian product (every row x every row)
- Using wrong JOIN type → missing or extra rows
- Not using aliases → confusing column names from both tables

## 8. Interview questions
- What is the difference between INNER and LEFT JOIN?
- What happens if you JOIN without ON?
- When would you use a self JOIN?