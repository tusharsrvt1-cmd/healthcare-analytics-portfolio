# Healthcare Claims Analytics Portfolio Project

End-to-end analytics project on a synthetic healthcare claims dataset — cleaned and analyzed in **Excel**, reproduced in **MySQL**, with a **Power BI** dashboard planned as the next step.

## Business Scenario

A healthcare payer wants visibility into claims performance: how much is being billed vs. paid, where claims are getting denied, how long processing takes, and which claim types and providers drive the most volume and cost. This project builds that analysis from raw claims data end to end.

## Dataset

Synthetic/fictional data generated for practice — **no real patient or PHI data is used.**

| Table | Rows | Description |
|---|---|---|
| Claims | 1,500 | Claim-level records: type, status, billed/allowed/paid amounts, processing time, denial reason |
| Members | 300 | Member demographics, plan type, state |
| Providers | 50 | Provider name, specialty, network status |
| Employees | 100 | Internal claims-processing staff |
| Raw_Messy_Data | 120 | Deliberately unclean sample used to practice data-cleaning steps |

## Tools Used

- **Microsoft Excel** — Excel Tables, `SUMIFS`/`COUNTIFS`/`AVERAGEIF`, PivotTables, charts, and a KPI dashboard
- **MySQL** — schema design, joins across claims/members/providers, aggregation, subqueries, CTEs, window functions
- **Power BI** — dashboard (in progress)

## Workflow

1. Clean raw/messy sample data in Excel
2. Build PivotTables, charts, and formula-driven KPIs in Excel
3. Load the cleaned data into MySQL and reproduce the same analysis in SQL
4. Build an interactive Power BI dashboard *(in progress)*
5. Document findings here

## Key Insights

- **1,500 claims** processed, totaling **38,699,571.80** billed and **15,781,234.96** paid
- Overall **denial rate: 19.4%** | **Average processing time: 5.3 days** | **SLA compliance (≤7 days): 78.7%**
- **Medical** claims have both the highest volume (399 claims) and the highest denial rate (20.6%) of any claim type
- Top denial drivers are **Eligibility Issues** (22.3% of all denials) and **Missing Documentation** (21.6%) — together accounting for nearly 44% of denied claims
- **Pharmacy** claims have the lowest denial rate (18.5%) and fastest average processing time (5.0 days)

*(All figures generated from the project's own Excel/SQL analysis — see `/excel` and `/sql`.)*

## Repository Contents

- **`Healthcare_Claims_Analytics_Portfolio_Project_Working.xlsx`** — raw + cleaned data, PivotTables, charts, and a formula-linked KPI dashboard
- **`healthcare_claims_analysis.sql`** — 24 queries: joins, aggregates, subqueries, CTEs, window functions
- **`README.md`** — this file

## SQL Highlights

The SQL script (`healthcare_claims_analysis.sql`) covers:
- Multi-table `JOIN`s (claims + members + providers)
- Aggregations with `GROUP BY` / `HAVING`
- Scalar subqueries for percentage-of-total metrics
- A `CASE WHEN` SLA-bucketing query
- A `RANK() OVER (PARTITION BY ...)` window function
- A `WITH` (CTE) rewrite of the denial-rate analysis

## Status

- [x] Data cleaning (Excel)
- [x] Excel analysis: PivotTables, charts, KPI dashboard
- [x] MySQL analysis: joins, aggregates, subqueries, CTEs, window functions
- [ ] Power BI dashboard
- [ ] Final write-up with dashboard screenshots

## Author

**Tushar Srivastava** — Healthcare Operations professional transitioning into healthcare analytics.
[LinkedIn](#) · [Email](mailto:tusharsrvt1@gmail.com)
