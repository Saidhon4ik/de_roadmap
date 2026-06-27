# 📊 BigQuery — Full Interview Q&A

> **Complete reference for BigQuery interviews** — architecture, storage, SQL, pipelines, performance, dbt, security, monitoring, and more.

---

## 📑 Table of Contents

1. [🏗️ Architecture & Pricing](#️-architecture--pricing)
2. [🗂️ Storage & Table Design](#️-storage--table-design)
3. [🔌 Loading Data & Connecting Pipelines](#-loading-data--connecting-pipelines)
4. [🧮 SQL Features](#-sql-features)
5. [⚡ Performance & Cost Optimization](#-performance--cost-optimization)
6. [🛠️ dbt-Specific](#️-dbt-specific)
7. [🔐 Security & Governance](#-security--governance)
8. [📡 Monitoring & Metadata](#-monitoring--metadata)
9. [🧠 Advanced / Bonus](#-advanced--bonus)

---

## 🏗️ Architecture & Pricing

**Q1. What is BigQuery and how does it differ from a traditional relational DB?**
> A serverless, fully managed cloud data warehouse by Google. Unlike PostgreSQL/MySQL (OLTP — built for transactions), BigQuery is OLAP — built for large analytical queries. No indexes, no vacuum, no server management.

**Q2. What is columnar storage and why is BQ faster on analytics?**
> BQ stores data column by column instead of row by row. Querying 3 columns out of 100 reads only those 3. Less I/O = faster, cheaper queries.

**Q3. What's the difference between on-demand and flat-rate pricing?**
> On-demand — pay per TB scanned. Flat-rate — buy a fixed slot capacity, pay a flat monthly fee regardless of usage. Flat-rate pays off at high, steady query volume.

**Q4. What is a "slot"?**
> A unit of computational capacity used to execute queries. On-demand gives shared slots automatically; flat-rate reserves dedicated slots.

**Q5. What is capacity management (slot reservations)?**
> Lets you purchase dedicated slot commitments and assign them to specific projects/folders — controls cost and guarantees performance instead of relying on shared on-demand capacity.

**Q6. What is the difference between BigQuery's storage and compute layers?**
> BQ separates storage (Colossus — Google's distributed file system) from compute (Dremel — the query engine). This means you can scale each independently and only pay for what you use. Compute spins up on demand per query.

---

## 🗂️ Storage & Table Design

**Q7. What is a partitioned table, and what partition types exist?**
> A table split into segments by a column's value, so BQ scans only relevant partitions. Types: ingestion time (`_PARTITIONTIME`), a DATE/TIMESTAMP column, or an INTEGER range.

**Q8. What is a clustered table?**
> Data within each partition is sorted by one or more columns. BQ skips blocks that don't match the filter, reducing bytes scanned.

**Q9. Partitioning vs clustering — when to use which?**
> Partitioning splits the table into physical segments (time-based filtering). Clustering sorts data within those segments (high-cardinality filters). Best combined.

**Q10. What is partition pruning?**
> BQ automatically skips partitions that don't match the WHERE filter — filtering on the partition column cuts cost and query time dramatically.

**Q11. What are ARRAY and STRUCT? How do they differ?**
> ARRAY is an ordered list of same-type values. STRUCT is a record with named fields of different types — a "row inside a row." Combine them: an ARRAY of STRUCTs.

**Q12. What are nested and repeated fields? Example?**
> Nested = a STRUCT inside a row. Repeated = an ARRAY inside a row. Example: an `orders` table where each row has an `items` ARRAY of STRUCTs (`product_id`, `quantity`).

**Q13. What are wildcard tables?**
> Query multiple tables sharing a prefix using `*`, e.g. `FROM project.dataset.events_*`. Filter with `_TABLE_SUFFIX`.

**Q14. What is an external table?**
> References data outside BQ (e.g. GCS) without loading it in. Slower per-query, but useful for ad hoc exploration of raw/rarely-queried files.

**Q15. How does schema auto-detection work?**
> When loading CSV/JSON, BQ samples the first rows and infers column names/types. Convenient, but can misdetect types — define schema explicitly in production.

**Q16. What is table expiration?**
> You can set an expiration timestamp on a table or partition so BQ automatically deletes it after a certain time. Useful for temp/staging tables to avoid manual cleanup and unnecessary storage costs.

**Q17. What is time travel in BigQuery?**
> BQ retains historical snapshots of your data for up to 7 days. You can query a table as it existed at a past point using `FOR SYSTEM_TIME AS OF` — useful for recovery from accidental deletes or bad writes.

---

## 🔌 Loading Data & Connecting Pipelines

**Q18. What are all the ways to get data into BigQuery?**
> Batch load (`bq load` / Python client), streaming insert (legacy API or Storage Write API), Pub/Sub subscription, Dataflow (Apache Beam), Data Transfer Service, Datastream (CDC), federated/external tables, or Airflow operators.

**Q19. How does `bq load` work?**
> CLI command, batch-loads a file (CSV/JSON/Avro/Parquet) from GCS or local disk into a table. Free, not real-time.
```bash
bq load --source_format=CSV mydataset.mytable gs://bucket/file.csv schema.json
```

**Q20. How do you load data into BigQuery from Python?**
> `google-cloud-bigquery` client: `load_table_from_dataframe()` (pandas), `load_table_from_file()`/`load_table_from_uri()` (file/GCS), or `insert_rows_json()` (legacy row-by-row streaming).

**Q21. Streaming insert vs Storage Write API?**
> Legacy `tabledata.insertAll` — simple, no exactly-once guarantee, costlier per row. Storage Write API — newer, exactly-once semantics, batching, cheaper at scale.

**Q22. How do you connect Airflow to BigQuery?**
> `google-cloud-bigquery` provider package. Key operators: `BigQueryInsertJobOperator` (run a SQL job), `GCSToBigQueryOperator` (load GCS file), `BigQueryCheckOperator` (data quality gate). Auth via service account key or Workload Identity.

**Q23. How does dbt connect to BigQuery?**
> Configured in `profiles.yml` — project, dataset, location, auth method (service account JSON key or OAuth). Run `dbt debug` to verify before running models.

**Q24. Dataflow vs Data Transfer Service?**
> Dataflow — custom Apache Beam pipelines (full control, more setup). Data Transfer Service — managed, no-code connectors for known sources (Google Ads, GA4, S3, Teradata) on a schedule.

**Q25. What is Dataflow based on?**
> Apache Beam — an open-source unified model for batch and streaming. Dataflow is Google's managed runner for Beam pipelines.

**Q26. How do you connect Pub/Sub directly to BigQuery (no Dataflow)?**
> Create a "BigQuery subscription" on a Pub/Sub topic — writes messages straight into a table. Needs schema match + `pubsub.subscriber` + `bigquery.dataEditor` roles.

**Q27. What is Datastream?**
> A managed Change Data Capture (CDC) service — replicates row-level changes from operational DBs (PostgreSQL, MySQL, Oracle) into BigQuery near real-time, no custom ETL.

**Q28. What are federated queries?**
> Querying data living in another engine (Cloud SQL, Spanner, or cross-cloud via BigQuery Omni) directly from BQ SQL using `EXTERNAL_QUERY()`, without copying it first.

**Q29. In a Python → PostgreSQL → dbt → Airflow → BigQuery pipeline, where does the BQ connection actually happen?**
> Two places — dbt via `profiles.yml` for transform-and-load (main step), and Airflow directly (`BigQueryInsertJobOperator`, etc.) for orchestration: triggering loads, running checks, exporting results.

**Q30. How do you authenticate a pipeline to BigQuery?**
> A service account JSON key, or Workload Identity Federation (no key file, used inside GCP — more secure). Needs `bigquery.dataEditor` (write) + `bigquery.jobUser` (run jobs).

**Q31. Simplest way to test a BigQuery connection before automating?**
> `bq query "SELECT 1"` via CLI, or `bigquery.Client().query("SELECT 1").result()` in Python. For dbt: `dbt debug`.

**Q32. What is Dataform?**
> Google-native tool for managing SQL-based transformation workflows directly inside BigQuery — version control, testing, and scheduling for SQL. An alternative to dbt, built into the GCP console.

**Q33. What are scheduled queries?**
> Run a saved query automatically on a recurring schedule (hourly/daily/etc.), writing results to a destination table — no external orchestrator needed. Good for simple recurring jobs; use Airflow/dbt once you have real dependency chains.

---

## 🧮 SQL Features

**Q34. What are window functions? Examples?**
> Calculations across a set of rows without collapsing them. `ROW_NUMBER()` — unique sequential number. `RANK()` — gaps on ties. `DENSE_RANK()` — no gaps.

**Q35. LAG vs LEAD?**
> `LAG` reads a value from a previous row. `LEAD` reads a value from the following row. Common for day-over-day comparisons.

**Q36. What is a CTE (WITH clause) and why use it?**
> A temporary named result set defined before the main query — readable, reusable. In BQ, CTEs aren't materialized; they re-execute each time referenced.

**Q37. How does UNNEST work?**
> Converts an ARRAY into a set of rows, usually with `CROSS JOIN` or directly in `FROM`. Essential for repeated fields (ARRAYs of STRUCTs).

**Q38. APPROX_COUNT_DISTINCT vs COUNT(DISTINCT)?**
> `COUNT(DISTINCT)` is exact but expensive at scale. `APPROX_COUNT_DISTINCT` uses HyperLogLog++ — very fast, ~1% error. Approximate for dashboards, exact for billing/compliance.

**Q39. What is MERGE in BigQuery?**
> A DML statement that performs INSERT, UPDATE, or DELETE on a target table based on a join with a source — useful for upserts (insert if new, update if exists). Common in incremental pipeline patterns.

**Q40. What is EXCEPT and REPLACE in SELECT?**
> `SELECT * EXCEPT (col1)` excludes specific columns. `SELECT * REPLACE (expr AS col)` substitutes a column's value inline. Useful alternatives to listing every column explicitly.

**Q41. What are scripting and procedural statements in BQ?**
> BigQuery supports `DECLARE`, `SET`, `IF`, `LOOP`, `WHILE`, and `CALL` (stored procedures) — letting you write multi-step logic directly in SQL without an external orchestrator.

---

## ⚡ Performance & Cost Optimization

**Q42. Why is `SELECT *` bad in BigQuery?**
> BQ charges by bytes scanned. `SELECT *` reads every column, even unused ones. Always select only what you need.

**Q43. How do you reduce query costs in BQ?**
> Partition + cluster tables, avoid `SELECT *`, filter on the partition column, use materialized views for repeated heavy queries, use APPROX functions where exact precision isn't needed.

**Q44. What is a materialized view?**
> A precomputed query result stored physically, refreshed incrementally as the base table changes. Faster/cheaper than re-running the original query.

**Q45. Materialized view vs regular view?**
> A regular view is a saved query — re-executes every time. A materialized view stores the result physically and refreshes incrementally.

**Q46. Materialized view vs dbt incremental model — when to use which?**
> Materialized view — BQ auto-manages refresh, good for simple aggregations. dbt incremental — you control the logic, better for complex transformations, testing, CI/CD.

**Q47. What is BI Engine?**
> An in-memory analysis service that accelerates BI/dashboard queries (e.g. Looker Studio) by caching frequently-used data in memory — cuts dashboard latency dramatically.

**Q48. What is query plan explanation (EXPLAIN)?**
> BQ doesn't have a traditional EXPLAIN, but after running a query you can inspect the **Execution Details** tab in the console — it shows query stages, steps, slot usage, and where time was spent. Useful for diagnosing slow queries.

**Q49. What is a shuffle in BigQuery and why does it matter?**
> A shuffle happens when BQ needs to redistribute data across workers (e.g. during JOINs or GROUP BY). Heavy shuffles are expensive — proper partitioning and clustering reduce unnecessary data movement.

---

## 🛠️ dbt-Specific

**Q50. What are dbt sources and how are they declared?**
> Raw tables in your warehouse dbt didn't create. Declared in `schema.yml` under `sources:`, referenced via `{{ source('name', 'table') }}`.

**Q51. What is `ref()` in dbt and why use it?**
> `{{ ref('model_name') }}` references another dbt model. Builds the DAG automatically so dbt knows execution order and dependencies.

**Q52. `dbt run` vs `dbt build`?**
> `dbt run` only executes models. `dbt build` runs models + tests + snapshots + seeds in dependency order — the recommended command for full pipeline runs.

**Q53. What is a dbt incremental model? How does `is_incremental()` work?**
> Only processes new/updated rows instead of rebuilding the whole table. `is_incremental()` is a Jinja condition — when true, filters for new data only (usually via a max timestamp comparison).

**Q54. How does `dbt test` work?**
> Validates data after models run. Built-in tests: `unique`, `not_null`, `accepted_values`, `relationships`. Custom tests in SQL. Run with `dbt test`.

**Q55. What are dbt snapshots?**
> A dbt feature for tracking slowly changing dimensions (SCD Type 2) — captures historical states of a row over time by recording `dbt_valid_from` and `dbt_valid_to` timestamps. Stored as a separate snapshot table.

**Q56. What is dbt's DAG?**
> A Directed Acyclic Graph — dbt builds this automatically based on `ref()` and `source()` calls. It defines the execution order of models and ensures dependencies run first. Visualized with `dbt docs generate && dbt docs serve`.

---

## 🔐 Security & Governance

**Q57. What IAM roles are needed for reading/writing in BQ?**
> Reading — `roles/bigquery.dataViewer`. Writing — `roles/bigquery.dataEditor`. Running jobs — `roles/bigquery.jobUser`. Admin — `roles/bigquery.admin`.

**Q58. Dataset-level vs table-level access?**
> Dataset-level — one IAM binding covers every table in the dataset. Table-level — fine-grained per-table control, harder to manage at scale.

**Q59. What is row-level security in BigQuery?**
> Row Access Policies — filter which rows a user/group can see, defined as an expression tied to identity. Same table, different users see different rows.

**Q60. What are policy tags / column-level security?**
> Policy tags (via Data Catalog) classify columns (e.g. PII, sensitive) and enforce column-level access control through IAM — users without the right tag binding can't read that column.

**Q61. What is disaster recovery in BigQuery?**
> BQ replicates data redundantly across zones within a region by default. For cross-region resilience, configure cross-region dataset replication or scheduled exports/backups to GCS in another region.

**Q62. What is VPC Service Controls in the context of BQ?**
> A GCP security feature that creates a perimeter around BQ (and other APIs) — prevents data exfiltration by blocking access from outside the defined perimeter, even from authenticated users.

---

## 📡 Monitoring & Metadata

**Q63. How do you view query history in BQ?**
> "Job history" in the BQ console, or `INFORMATION_SCHEMA.JOBS` via SQL — filter by user, time, status, bytes processed.

**Q64. What is INFORMATION_SCHEMA? Usage examples?**
> Built-in metadata views. Examples: `INFORMATION_SCHEMA.TABLES` (list tables), `INFORMATION_SCHEMA.JOBS` (query history), `INFORMATION_SCHEMA.PARTITIONS` (partition stats).

**Q65. How do you track the cost of a specific query?**
> Check "Bytes processed" in the BQ console results panel, or query `INFORMATION_SCHEMA.JOBS` → `total_bytes_processed`. Multiply by $5/TB for on-demand pricing.

**Q66. What is Cloud Monitoring + BQ?**
> You can set up alerts in Cloud Monitoring for BQ metrics — slot utilization, job failures, bytes processed. Useful for cost anomaly detection and SLA monitoring in production pipelines.

---

## 🧠 Advanced / Bonus

**Q67. What is BigQuery Omni?**
> Extends BQ to run queries on data stored in AWS S3 or Azure Blob Storage — without moving the data. Uses the same BQ SQL interface across clouds.

**Q68. What is BigQuery ML (BQML)?**
> Lets you train and run ML models directly in BigQuery using SQL — linear regression, logistic regression, k-means, XGBoost, and more. No Python or separate ML infrastructure needed for basic models.

**Q69. What is the difference between DML and DDL in BigQuery?**
> DDL (Data Definition Language) — `CREATE`, `DROP`, `ALTER` (table structure). DML (Data Manipulation Language) — `INSERT`, `UPDATE`, `DELETE`, `MERGE` (data itself). BQ supports both but DML can be expensive — avoid row-by-row updates.

**Q70. What is a snapshot table in BigQuery?**
> A read-only copy of a table at a specific point in time, stored separately. Cheaper than a full copy — BQ stores only the delta. Useful for lightweight backups before risky operations.

---

*Last updated: 2026 | Based on hands-on GCP practice + BigQuery documentation*