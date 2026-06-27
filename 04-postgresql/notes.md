# Stage 4 — PostgreSQL

## Position in Pipeline
```
SQL (language) → ⭐ PostgreSQL (database engine) ← Python (connects to it next)
```

SQL is the language. PostgreSQL is the engine that understands it and stores data on disk. After learning SQL syntax in Stage 3, here we learn how the engine itself works: data types, constraints, transactions, schema design.

---

## Table of Contents
1. CREATE TABLE & Constraints
2. Schema Design (normalization)
3. Data Migration (INSERT INTO ... SELECT)
4. Transactions
5. Normalization (1NF / 2NF / 3NF)

---

## 1. CREATE TABLE & Constraints

```sql
CREATE TABLE departments (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE employees_new (
    id            SERIAL PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    department_id INTEGER REFERENCES departments(id),
    salary        NUMERIC(10, 2),
    hire_date     DATE
);
```

### Constraints explained

| Constraint | What it does |
|---|---|
| `SERIAL` | Auto-increment id (INTEGER + sequence). No need to insert id manually. |
| `PRIMARY KEY` | UNIQUE + NOT NULL. One per table. Main row identifier. |
| `UNIQUE` | Prevents duplicate values. Multiple allowed per table. |
| `NOT NULL` | Field cannot be empty. |
| `REFERENCES` | Foreign Key — value must exist in the referenced table. |

### PRIMARY KEY vs UNIQUE

| | PRIMARY KEY | UNIQUE |
|---|---|---|
| Uniqueness | ✅ | ✅ |
| NOT NULL | ✅ required | ❌ can be NULL |
| Per table | Only one | Multiple allowed |
| Purpose | Main row identifier | Just prevents duplicates |

```sql
id    SERIAL PRIMARY KEY  -- main identifier
email VARCHAR UNIQUE      -- just no duplicates, not the identifier
```

### Foreign Key in action

```sql
-- departments has only id 1 (HR), 2 (Engineering), 3 (Marketing)
INSERT INTO employees_new (name, department_id) VALUES ('Sam', 1);   -- OK
INSERT INTO employees_new (name, department_id) VALUES ('Eli', 999); -- ERROR
-- ERROR: insert violates foreign key constraint
-- department 999 does not exist in departments table
```

This is called **referential integrity** — impossible to create a record pointing to nothing.

---

## 2. Schema Design

### Why split one table into two?

Bad design — department stored as plain text:
```
employees_5000: id | name | department | salary | hire_date
                1  | Sam  | HR         | 74000  | 2013-02-03
                2  | Eli  | HR         | 68000  | 2015-12-21
```

Problem: if "HR" gets renamed to "Human Resources" → update thousands of rows. Risk of inconsistency.

Good design — department stored as id (FK):
```
departments: id | name
             1  | HR
             2  | Engineering

employees_new: id | name | department_id | salary
               1  | Sam  | 1             | 74000
               2  | Eli  | 1             | 68000
```

Rename "HR" → update **one row** in departments. Automatically reflected everywhere via JOIN.

### Reassemble with JOIN

```sql
SELECT e.name, d.name AS department, e.salary, e.hire_date
FROM employees_new e
JOIN departments d ON e.department_id = d.id;
```

Output looks exactly like the original table, but data is stored separately — text is pulled from departments only when needed.

---

## 3. Data Migration

### Migrate from old flat table to normalized structure

```sql
-- Step 1: populate departments from existing data
INSERT INTO departments (name)
SELECT DISTINCT department FROM employees_5000;

-- Step 2: migrate employees with correct department_id
INSERT INTO employees_new (name, department_id, salary, hire_date)
SELECT
    e.name,
    d.id,
    e.salary,
    e.hire_date
FROM employees_5000 e
JOIN departments d ON e.department = d.name;
```

`INSERT INTO ... SELECT` — inserts query results directly into another table, no manual copy-paste.

### Reset and start over

```sql
TRUNCATE departments, employees_new RESTART IDENTITY CASCADE;
```

- `TRUNCATE` — deletes all rows (faster than DELETE)
- `RESTART IDENTITY` — resets SERIAL counter back to 1
- `CASCADE` — required because employees_new references departments via FK

---

## 4. Transactions

A transaction groups multiple operations into one atomic unit — either **all succeed** or **none do**.

```
BEGIN     → open transaction (start a "draft")
COMMIT    → save permanently, everyone sees changes
ROLLBACK  → discard everything, as if nothing happened
```

### Successful transaction

```sql
BEGIN;

INSERT INTO employees_new (name, department_id, salary, hire_date)
VALUES ('John Doe', 1, 65000, '2024-01-15');

SELECT * FROM employees_new WHERE name = 'John Doe';
-- only we can see this change (isolation)

COMMIT;
-- now saved permanently, visible to everyone
```

### Rolling back

```sql
BEGIN;

UPDATE employees_new SET salary = 999999 WHERE id = 1;

SELECT * FROM employees_new WHERE id = 1;
-- salary shows 999999 (only inside this transaction)

ROLLBACK;

SELECT * FROM employees_new WHERE id = 1;
-- salary back to original, as if UPDATE never happened
```

### Real scenario — transfer employee to another department

```sql
BEGIN;

-- check current department
SELECT e.name, d.name AS department
FROM employees_new e
JOIN departments d ON e.department_id = d.id
WHERE e.id = 1;

-- move to Engineering (id=2)
UPDATE employees_new SET department_id = 2 WHERE id = 1;

-- verify change
SELECT e.name, d.name AS department
FROM employees_new e
JOIN departments d ON e.department_id = d.id
WHERE e.id = 1;

COMMIT;
```

### Key rules

```
ALWAYS use WHERE id = ...   not WHERE name = ... (names are not unique!)
Server crash mid-transaction = PostgreSQL auto-ROLLBACK, nothing is saved
Uncommitted changes are visible only to you (transaction isolation)
```

---

## 5. Normalization — 1NF / 2NF / 3NF

Goal: every fact is stored exactly once.

### Starting point — bad table

```
id | customer | products                | city
1  | Saidkhon | phone, laptop, keyboard | Tashkent
2  | Saidkhon | monitor                 | Tashkent
3  | John     | phone                   | London
```

Problems:
- Multiple values in one cell (`products`)
- Duplicated data (`Saidkhon`, `Tashkent` repeated)
- No protection against typos (`Tashkent` vs `Tashkant`)

### 1NF — one value per cell

**Rule:** no lists, arrays, or comma-separated values in a single cell.

```
-- BEFORE
1 | Saidkhon | phone, laptop, keyboard | Tashkent

-- AFTER 1NF (split into separate rows)
id | customer | city     | product
1  | Saidkhon | Tashkent | phone
1  | Saidkhon | Tashkent | laptop
1  | Saidkhon | Tashkent | keyboard
2  | Saidkhon | Tashkent | monitor
3  | John     | London   | phone
```

New problem: `Saidkhon` and `Tashkent` now duplicated 3 times → 2NF.

### 2NF — remove partial dependencies

**Rule:** remove columns that describe something other than the record itself.

Ask yourself: "Does this column describe the order, or something else (the customer, the product)?"

```
product  → describes the order ✅ keep
city     → describes the customer ❌ move to customers table
customer → describes the customer ❌ move to customers table
```

```
customers                        orders
┌────┬──────────┬──────────┐     ┌────┬─────────────┬──────────┐
│ id │ name     │ city     │     │ id │ customer_id │ product  │
├────┼──────────┼──────────┤     ├────┼─────────────┼──────────┤
│ 1  │ Saidkhon │ Tashkent │     │ 1  │ 1           │ phone    │
│ 2  │ John     │ London   │     │ 2  │ 1           │ laptop   │
└────┴──────────┴──────────┘     │ 3  │ 1           │ keyboard │
                                  │ 4  │ 1           │ monitor  │
                                  │ 5  │ 2           │ phone    │
                                  └────┴─────────────┴──────────┘
```

`Tashkent` stored once. Saidkhon moves → update **one row** in customers.

### 3NF — remove transitive dependencies

**Rule:** non-key columns must depend only on the primary key, not on each other.

```
customers
┌────┬──────────┬───────────┬────────────┐
│ id │ name     │ city      │ country    │
├────┼──────────┼───────────┼────────────┤
│ 1  │ Saidkhon │ Tashkent  │ Uzbekistan │
│ 2  │ John     │ London    │ UK         │
│ 3  │ Ali      │ Samarkand │ Uzbekistan │  ← Uzbekistan duplicated
└────┴──────────┴───────────┴────────────┘
```

Problem: `country` depends on `city`, not on customer `id`. This is a transitive dependency (`id → city → country`).

```
cities                           customers
┌────┬───────────┬────────────┐  ┌────┬──────────┬─────────┐
│ id │ name      │ country    │  │ id │ name     │ city_id │
├────┼───────────┼────────────┤  ├────┼──────────┼─────────┤
│ 1  │ Tashkent  │ Uzbekistan │  │ 1  │ Saidkhon │ 1       │
│ 2  │ London    │ UK         │  │ 2  │ John     │ 2       │
│ 3  │ Samarkand │ Uzbekistan │  │ 3  │ Ali      │ 3       │
└────┴───────────┴────────────┘  └────┴──────────┴─────────┘
```

`Uzbekistan` now stored once.

### Summary

| Form | Rule | Example |
|---|---|---|
| 1NF | One value per cell | "phone, laptop" → separate rows |
| 2NF | Remove columns describing something other than the record | city describes customer → move to customers |
| 3NF | Remove dependencies between non-key columns | city → country → move to cities |

---

## Interview Questions

**Q: What is SERIAL?**
A: Auto-increment counter. PostgreSQL generates id automatically (1, 2, 3...) on each insert. No need to specify id manually. Under the hood it's INTEGER + a sequence object.

**Q: Difference between PRIMARY KEY and UNIQUE?**
A: PRIMARY KEY = UNIQUE + NOT NULL, only one per table, main row identifier. UNIQUE just prevents duplicates, multiple allowed per table, can be NULL.

**Q: What happens if you try to delete a customer who has orders?**
A: PostgreSQL throws a foreign key constraint error and blocks the deletion. You must first delete or reassign the related orders. This is referential integrity.

**Q: What happens to an uncommitted transaction if the server crashes?**
A: PostgreSQL automatically rolls it back on restart. Uncommitted data is never saved.

**Q: Explain normalization in simple terms.**
A: Breaking one table into multiple to eliminate duplicate data. 1NF = one value per cell. 2NF = remove columns that describe something other than the record. 3NF = remove dependencies between non-key columns. Goal: every fact stored exactly once.

**Q: Is 3NF always necessary?**
A: Not always. In data warehouses (OLAP), denormalization is common for read performance. Normalization matters most in transactional systems (OLTP) where data changes frequently.