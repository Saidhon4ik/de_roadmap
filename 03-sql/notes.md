# Stage 3 — SQL

## Position in Pipeline
```
Linux → Git → ⭐ SQL ← PostgreSQL (next)
```

SQL is the language you use to talk to any database. Every tool in the DE stack (dbt, BigQuery, Airflow) relies on SQL under the hood.

---

## Table Used for Practice
```
employees_5000 (id, name, department, salary, hire_date)
departments: Finance, Engineering, HR, Marketing
```

---

## 1. SELECT + WHERE + ORDER BY

```sql
-- Basic filter + sort
SELECT name, salary
FROM employees_5000
WHERE department = 'Engineering' AND salary > 50000
ORDER BY salary DESC;

-- COUNT per department, only show > 10 employees
SELECT department, COUNT(*) AS people_in_dep
FROM employees_5000
GROUP BY department
HAVING COUNT(*) > 10;
```

**Key rules:**
- `WHERE` filters rows before grouping — cannot use aggregate functions here
- `HAVING` filters after `GROUP BY` — use for `COUNT`, `SUM`, `AVG` etc.
- `ORDER BY DESC` = largest first, `ASC` = smallest first (default)

---

## 2. Self-Join

A table joined to itself using two aliases. Used to compare rows within the same table.

```sql
SELECT
    e1.name AS employee_1,
    e2.name AS employee_2,
    e1.department,
    e1.salary - e2.salary AS salary_diff
FROM employees_5000 e1
JOIN employees_5000 e2
    ON e1.department = e2.department
    AND e1.salary > e2.salary;
```

**How it works:**
- `e1` and `e2` are two "copies" of the same table
- `ON e1.department = e2.department` — only compare people in the same department
- `e1.salary > e2.salary` — removes self-comparison AND duplicate reverse pairs (Sam-Eli AND Eli-Sam)

Without the salary condition, you'd get a cartesian product (every row × every row = millions of pairs).

---

## 3. CASE

Conditional column — checks conditions top to bottom, first match wins.

```sql
SELECT name, department, salary,
CASE
    WHEN salary < 40000 THEN 'low'
    WHEN salary BETWEEN 40000 AND 80000 THEN 'mid'
    ELSE 'high'
END AS salary_category
FROM employees_5000;
```

**Key rules:**
- Order of conditions matters — first `TRUE` wins, rest are skipped
- `BETWEEN` includes both boundaries (40000 and 80000)
- `ELSE` is the catch-all if nothing matches

---

## 4. CTE (Common Table Expression)

A temporary named result set that exists only during the query. Makes complex queries readable.

```sql
-- Find employees earning above their department average
WITH dept_avg AS (
    SELECT department, AVG(salary) AS avg_salary
    FROM employees_5000
    GROUP BY department
)
SELECT e.name, e.department, e.salary, d.avg_salary
FROM employees_5000 e
JOIN dept_avg d ON e.department = d.department
WHERE e.salary > d.avg_salary;
```

**CTE vs Subquery:** same result, but CTE is more readable and can be referenced multiple times in the same query.

---

## 5. Window Functions

Run calculations across related rows without collapsing them (unlike GROUP BY).

### Ranking functions

| Function | Behavior with duplicates |
|---|---|
| `ROW_NUMBER()` | Unique number for every row: 1, 2, 3, 4 |
| `RANK()` | Gaps on ties: 1, 1, 3, 4 |
| `DENSE_RANK()` | No gaps on ties: 1, 1, 2, 3 |

```sql
-- Top 3 salary per department (exactly 3 rows per dept)
WITH ranked AS (
    SELECT name, department, salary,
        ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rnk
    FROM employees_5000
)
SELECT * FROM ranked WHERE rnk <= 3;
```

**ROW_NUMBER vs DENSE_RANK:**
- `ROW_NUMBER` → always exactly N rows ("give me top 3 people")
- `DENSE_RANK` → may return more if there are ties ("give me everyone in top 3 salaries")

### Offset functions

```sql
-- Previous hire date within same department
SELECT name, department, hire_date,
    LAG(hire_date) OVER (PARTITION BY department ORDER BY hire_date) AS prev_hire_date
FROM employees_5000;
```

| Function | What it returns |
|---|---|
| `LAG(col)` | Value from the previous row (NULL for first row) |
| `LEAD(col)` | Value from the next row (NULL for last row) |

**Key difference from ranking functions:**
- `RANK/ROW_NUMBER/DENSE_RANK` → "What position am I?"
- `LAG/LEAD` → "What did my neighbor have?"

---

## 6. Indexes & EXPLAIN ANALYZE

### Creating an index

Rule for composite index: **equality (=) column first, range (>, <) column second**.

```sql
-- For: WHERE department = 'Marketing' AND hire_date > '2023-01-01'
CREATE INDEX idx_dept_hiredate ON employees_5000 (department, hire_date);
```

Why this order? Think of a phone book sorted by last name then first name. You can find "Ivanov" easily. But searching by first name only ("Ivan") is useless because Ivans are scattered everywhere. Same logic: filter by equality first, then narrow by range.

### EXPLAIN ANALYZE

`EXPLAIN ANALYZE` actually executes the query and shows the real execution plan.

```sql
EXPLAIN ANALYZE
SELECT * FROM employees_5000
WHERE department = 'Marketing' AND hire_date > '2023-01-01';
```

**What to look for:**
1. `Seq Scan` vs `Index Scan` — is the index being used?
2. `actual time` — real execution time in ms
3. `rows estimated` vs `rows actual` — big gap = stale statistics, run `ANALYZE`

**Index exists but still Seq Scan? Common reasons:**
- Table is small (full scan is faster than jumping through index)
- Function used on column: `WHERE LOWER(department) = 'marketing'` breaks the index
- Statistics are stale

---

## Interview Questions

**Q: Difference between WHERE and HAVING?**
A: WHERE filters rows before GROUP BY. HAVING filters after GROUP BY — used for aggregate functions like COUNT, SUM, AVG.

**Q: Difference between ROW_NUMBER, RANK, DENSE_RANK?**
A: All rank rows, but handle duplicates differently. ROW_NUMBER always gives unique numbers. RANK skips numbers after ties (1,1,3). DENSE_RANK never skips (1,1,2).

**Q: What is a self-join?**
A: Joining a table to itself using two aliases. Used to compare rows within the same table — for example, finding employees who earn more than their colleagues in the same department.

**Q: Index exists but query still does Seq Scan — why?**
A: Table too small, function applied to the indexed column in WHERE, or stale statistics.

**Q: CTE vs Subquery?**
A: Same result. CTE is more readable, can be referenced multiple times. Subquery is inline and can only be used once.