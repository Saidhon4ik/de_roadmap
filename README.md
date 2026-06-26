# 🚀 Data Engineering Roadmap

Self-paced, intensive path to **Junior Data Engineer** level.
Goal: understand end-to-end pipelines, pass technical interviews, handle real company tasks.

## 🧱 Target Pipeline

```
Source Data → Python → PostgreSQL → dbt → Airflow → BigQuery → Dashboard
```

## 📊 Progress

> 🔄 Restarted from scratch — previous progress reset, going through all stages again from Stage 1.

| # | Stage | Status |
|---|-------|--------|
| 1 | Linux — terminal confidence | ⬜ Not started |
| 2 | Git — version control, teamwork | ⬜ Not started |
| 3 | SQL — junior-level queries | ⬜ Not started |
| 4 | PostgreSQL — database design | ⬜ Not started |
| 5 | Python — ETL scripts | ⬜ Not started |
| 6 | Docker — containerization | ⬜ Not started |
| 7 | DWH — data warehouse concepts | ⬜ Not started |
| 8 | dbt — data transformation | ⬜ Not started |
| 9 | Airflow — orchestration | ⬜ Not started |
| 10 | BigQuery — cloud warehouse | ⬜ Not started |
| 11 | GCP — cloud platform | ⬜ Not started |
| 12 | Kubernetes — deployment | ⬜ Not started |
| 13 | Semantic Layer — AtScale/BI layer | ⬜ Not started |
| 14 | Final Project — full pipeline | ⬜ Not started |

> Update this table as stages/topics get finished. ✅ = done, 🟡 = partial, 🔵 = in progress, ⬜ = not started.

## 📁 Repo Structure

```
de-roadmap/
├── README.md
├── 01-linux/
│   └── notes.md
├── 02-git/
│   └── notes.md
├── 03-sql/
│   ├── notes.md              # stage overview
│   ├── 01-select-where/
│   │   ├── notes.md          # theory (9-part structure)
│   │   └── practice.sql      # task solutions
│   └── 02-.../
├── 04-postgresql/
├── 05-python/
├── 06-docker/
├── 07-dwh/
├── 08-dbt/
├── 09-airflow/
├── 10-bigquery/
├── 11-gcp/
├── 12-kubernetes/
├── 13-semantic-layer/
└── 14-final-project/
```

**Rule:** one topic = one subfolder with `notes.md` (theory) + practice files (`.sql`, `.py`, etc).

## 📝 Topic Notes Format

Each topic in `notes.md` follows this structure:
1. Simple explanation
2. Why it's needed
3. Pipeline placement
4. Input → Output
5. Junior/Middle/Senior breakdown
6. Common mistakes
7. Practice task
8. Comprehension check
9. Mini interview questions

## 🔄 Workflow

1. Learn topic → write `notes.md`
2. Solve practice task → commit code file
3. `git commit -m "stage-3: SELECT & WHERE notes + practice"`
4. Update progress table above
5. Move to next topic/stage

---
*Built while learning — commits double as a study log and portfolio.*
