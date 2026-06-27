# 📊 BigQuery — Full Interview Q&A

*Stage 10 reference — architecture, storage, SQL, pipelines, performance, dbt, security, console features.*

---

## 🏗️ Architecture & Pricing

**1. What is BigQuery and how does it differ from a traditional relational DB?**
Ans: A serverless, fully managed cloud data warehouse by Google. Unlike PostgreSQL/MySQL (OLTP — built for transactions), BigQuery is OLAP — built for large analytical queries. No indexes, no vacuum, no server management.

**2. What is columnar storage and why is BQ faster on analytics?**
Ans: BQ stores data column by column instead of row by row. Querying 3 columns out of 100 reads only those 3. Less I/O = faster, cheaper queries.

**3. What's the difference between on-demand and flat-rate pricing?**
Ans: On-demand — pay per TB scanned. Flat-rate — buy a fixed slot capacity, pay a flat monthly fee regardless of usage. Flat-rate pays off at high, steady query volume.

**4. What is a "slot"?**
Ans: A unit of computational capacity used to execute queries. On-demand gives shared slots automatically; flat-rate reserves dedicated slots.

**5. What is capacity management (slot reservations)?**
Ans: Lets you purchase dedicated slot commitments and assign them to specific projects/folders — controls cost and guarantees performance instead of relying on shared on-demand capacity.

---

## 🗂️ Storage & Table Design

**6. What is a partitioned table, and what partition types exist?**
Ans: A table split into segments by a column's value, so BQ scans only relevant partitions. Types: ingestion time (`_PARTITIONTIME`), a DATE/TIMESTAMP column, or an INTEGER range.

**7. What is a clustered table?**
Ans: Data within each partition is sorted by one or more columns. BQ skips blocks that don't match the filter, reducing bytes scanned.

**8. Partitioning vs clustering — when to use which?**
Ans: Partitioning splits the table into physical segments (time-based filtering). Clustering sorts data within those segments (high-cardinality filters). Best combined.

**9. What is partition pruning?**
Ans: BQ automatically skips partitions that don't match the WHERE filter — filtering on the partition column cuts cost and query time dramatically.

**10. What are ARRAY and STRUCT? How do they differ?**
Ans: ARRAY is an ordered list of same-type values. STRUCT is a record with named fields of different types — a "row inside a row." Combine them: an ARRAY of STRUCTs.

**11. What are nested and repeated fields? Example?**
Ans: Nested = a STRUCT inside a row. Repeated = an ARRAY inside a row. Example: an `orders` table where each row has an `items` ARRAY of STRUCTs (`product_id`, `quantity`).

**12. What are wildcard tables?**
Ans: Query multiple tables sharing a prefix using `*`, e.g. `FROM project.dataset.events_*`. Filter with `_TABLE_SUFFIX`.

**13. What is an external table?**
Ans: References data outside BQ (e.g. GCS) without loading it in. Slower per-query, but useful for ad hoc exploration of raw/rarely-queried files.

**14. How does schema auto-detection work?**
Ans: When loading CSV/JSON, BQ samples the first rows and infers column names/types. Convenient, but can misdetect types — define schema explicitly in production.

---

## 🔌 Loading Data & Connecting Pipelines

**15. What are all the ways to get data into BigQuery? (map)**
Ans: Batch load (`bq load` / Python client), streaming insert (legacy API or Storage Write API), Pub/Sub subscription, Dataflow (Apache Beam), Data Transfer Service, Datastream (CDC), federated/external tables, or Airflow operators.

**16. How does `bq load` work?**
Ans: CLI command, batch-loads a file (CSV/JSON/Avro/Parquet) from GCS or local disk into a table. Free, not real-time.
```bash
bq load --source_format=CSV mydataset.mytable gs://bucket/file.csv schema.json
```

**17. How do you load data into BigQuery from Python?**
Ans: `google-cloud-bigquery` client: `load_table_from_dataframe()` (pandas), `load_table_from_file()`/`load_table_from_uri()` (file/GCS), or `insert_rows_json()` (legacy row-by-row streaming).

**18. Streaming insert vs Storage Write API?**
Ans: Legacy `tabledata.insertAll` — simple, no exactly-once guarantee, costlier per row. Storage Write API — newer, exactly-once semantics, batching, cheaper at scale.

**19. How do you connect Airflow to BigQuery?**
Ans: `google-cloud-bigquery` provider package. Key operators: `BigQueryInsertJobOperator` (run a SQL job), `GCSToBigQueryOperator` (load GCS file), `BigQueryCheckOperator` (data quality gate). Auth via service account key or Workload Identity.

**20. How does dbt connect to BigQuery?**
Ans: Configured in `profiles.yml` — project, dataset, location, auth method (service account JSON key or OAuth). Run `dbt debug` to verify before running models.

**21. Dataflow vs Data Transfer Service?**
Ans: Dataflow — custom Apache Beam pipelines (full control, more setup). Data Transfer Service — managed, no-code connectors for known sources (Google Ads, GA4, S3, Teradata) on a schedule.

**22. What is Dataflow based on?**
Ans: Apache Beam — an open-source unified model for batch and streaming. Dataflow is Google's managed runner for Beam pipelines.

**23. How do you connect Pub/Sub directly to BigQuery (no Dataflow)?**
Ans: Create a "BigQuery subscription" on a Pub/Sub topic — writes messages straight into a table. Needs schema match + `pubsub.subscriber` + `bigquery.dataEditor` roles.

**24. What is Datastream?**
Ans: A managed Change Data Capture (CDC) service — replicates row-level changes from operational DBs (PostgreSQL, MySQL, Oracle) into BigQuery near real-time, no custom ETL.

**25. What are federated queries?**
Ans: Querying data living in another engine (Cloud SQL, Spanner, or cross-cloud via BigQuery Omni) directly from BQ SQL using `EXTERNAL_QUERY()`, without copying it first.

**26. In a Python → PostgreSQL → dbt → Airflow → BigQuery pipeline, where does the BQ connection actually happen?**
Ans: Two places — dbt via `profiles.yml` for transform-and-load (main step), and Airflow directly (`BigQueryInsertJobOperator`, etc.) for orchestration: triggering loads, running checks, exporting results.

**27. How do you authenticate a pipeline to BigQuery?**
Ans: A service account JSON key, or Workload Identity Federation (no key file, used inside GCP — more secure). Needs `bigquery.dataEditor` (write) + `bigquery.jobUser` (run jobs).

**28. Simplest way to test a BigQuery connection before automating?**
Ans: `bq query "SELECT 1"` via CLI, or `bigquery.Client().query("SELECT 1").result()` in Python. For dbt: `dbt debug`.

**29. What is Dataform?**
Ans: Google-native tool for managing SQL-based transformation workflows directly inside BigQuery — version control, testing, and scheduling for SQL. An alternative to dbt, built into the GCP console rather than a separate CLI tool.

**30. What are scheduled queries?**
Ans: Run a saved query automatically on a recurring schedule (hourly/daily/etc.), writing results to a destination table — no external orchestrator needed. Good for simple recurring jobs; reach for Airflow/dbt once you have real dependency chains between steps.

---

## 🧮 SQL Features

**31. What are window functions? Examples?**
Ans: Calculations across a set of rows without collapsing them. `ROW_NUMBER()` — unique sequential number. `RANK()` — gaps on ties. `DENSE_RANK()` — no gaps.

**32. LAG vs LEAD?**
Ans: `LAG` reads a value from a previous row. `LEAD` reads a value from the following row. Common for day-over-day comparisons.

**33. What is a CTE (WITH clause) and why use it?**
Ans: A temporary named result set defined before the main query — readable, reusable. In BQ, CTEs aren't materialized; they re-execute each time referenced.

**34. How does UNNEST work?**
Ans: Converts an ARRAY into a set of rows, usually with `CROSS JOIN` or directly in `FROM`. Essential for repeated fields (ARRAYs of STRUCTs).

**35. APPROX_COUNT_DISTINCT vs COUNT(DISTINCT)?**
Ans: `COUNT(DISTINCT)` is exact but expensive at scale. `APPROX_COUNT_DISTINCT` uses HyperLogLog++ — very fast, ~1% error. Approximate for dashboards, exact for billing/compliance.

---

## ⚡ Performance & Cost

**36. Why is `SELECT *` bad in BigQuery?**
Ans: BQ charges by bytes scanned. `SELECT *` reads every column, even unused ones. Always select only what you need.

**37. How do you reduce query costs in BQ?**
Ans: Partition + cluster tables, avoid `SELECT *`, filter on the partition column, use materialized views for repeated heavy queries, use APPROX functions where exact precision isn't needed.

**38. What is a materialized view?**
Ans: A precomputed query result stored physically, refreshed incrementally as the base table changes. Faster/cheaper than re-running the original query.

**39. Materialized view vs regular view?**
Ans: A regular view is a saved query — re-executes every time. A materialized view stores the result physically and refreshes incrementally.

**40. Materialized view vs dbt incremental model — when to use which?**
Ans: Materialized view — BQ auto-manages refresh, good for simple aggregations. dbt incremental — you control the logic, better for complex transformations, testing, CI/CD.

**41. What is BI Engine?**
Ans: An in-memory analysis service that accelerates BI/dashboard queries (e.g. Looker Studio) by caching frequently-used data in memory — cuts dashboard latency dramatically.

---

## 🛠️ dbt-Specific

**42. What are dbt sources and how are they declared?**
Ans: Raw tables in your warehouse dbt didn't create. Declared in `schema.yml` under `sources:`, referenced via `{{ source('name', 'table') }}`.

**43. What is `ref()` in dbt and why use it?**
Ans: `{{ ref('model_name') }}` references another dbt model. Builds the DAG automatically so dbt knows execution order and dependencies.

**44. `dbt run` vs `dbt build`?**
Ans: `dbt run` only executes models. `dbt build` runs models + tests + snapshots + seeds in dependency order — the recommended command for full pipeline runs.

**45. What is a dbt incremental model? How does `is_incremental()` work?**
Ans: Only processes new/updated rows instead of rebuilding the whole table. `is_incremental()` is a Jinja condition — when true, filters for new data only (usually via a max timestamp comparison).

**46. How does `dbt test` work?**
Ans: Validates data after models run. Built-in tests: `unique`, `not_null`, `accepted_values`, `relationships`. Custom tests in SQL. Run with `dbt test`.

---

## 🔐 Security & Governance

**47. What IAM roles are needed for reading/writing in BQ?**
Ans: Reading — `roles/bigquery.dataViewer`. Writing — `roles/bigquery.dataEditor`. Running jobs — `roles/bigquery.jobUser`. Admin — `roles/bigquery.admin`.

**48. Dataset-level vs table-level access?**
Ans: Dataset-level — one IAM binding covers every table in the dataset. Table-level — fine-grained per-table control, harder to manage at scale.

**49. What is row-level security in BigQuery?**
Ans: Row Access Policies — filter which rows a user/group can see, defined as an expression tied to identity. Same table, different users see different rows.

**50. What are policy tags / metadata curation?**
Ans: Policy tags (via Data Catalog) classify columns (e.g. PII, sensitive) and enforce column-level access control through IAM. Metadata curation is tagging/organizing assets for discovery and governance.

**51. What is disaster recovery in BigQuery?**
Ans: BQ replicates data redundantly across zones within a region by default. For cross-region resilience, configure cross-region dataset replication or scheduled exports/backups to GCS in another region.

---

## 📡 Monitoring & Metadata

**52. How do you view query history in BQ?**
Ans: "Job history" in the BQ console, or `INFORMATION_SCHEMA.JOBS` via SQL — filter by user, time, status, bytes processed.

**53. What is INFORMATION_SCHEMA? Usage examples?**
Ans: Built-in metadata views. Examples: `INFORMATION_SCHEMA.TABLES` (list tables), `INFORMATION_SCHEMA.JOBS` (query history), `INFORMATION_SCHEMA.PARTITIONS` (partition stats).

**54. How do you track the cost of a specific query?**
Ans: Check "Bytes processed" in the BQ console results panel, or query `INFORMATION_SCHEMA.JOBS` → `total_bytes_processed`. Multiply by $5/TB for on-demand pricing.