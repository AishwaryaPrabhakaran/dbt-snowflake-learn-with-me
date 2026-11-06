# Day 1: What dbt is, and why data teams use it

## The problem
A team keeps dozens of SQL scripts that someone runs by hand "in the right order". None of them are tested, and two dashboards show two different CAC numbers because two people defined "enrolment" differently.

## dbt in one line
dbt turns your **SELECT statements** into **tables and views inside your warehouse**, runs them **in the correct order**, **tests** the results and **documents** everything.
It is the **T in ELT**: data is loaded raw first (by tools like Fivetran or Airbyte), then dbt transforms it with SQL. dbt doesn't extract or load data, and it isn't a database.

## Key ideas
- **Model** = one `.sql` file containing one `SELECT`. The file name is the model name. You never write `CREATE TABLE`.
- **`{{ ref('stg_leads') }}`** = "read from the model stg_leads". dbt replaces it with the full table name (for example `MARKETING_DB.DEV.STG_LEADS`).
- **DAG** (dependency graph): dbt reads every `ref()` and draws who-needs-whom. `dbt run` builds models in that order and runs independent models in parallel. It's like Excel: if `C1 = A1 + B1`, Excel calculates A1 and B1 first.
- **Environments**: the same code builds into `dev` while you work and into `prod` when deployed, because ref() fills in the right schema.
- **Tests**: `unique`, `not_null`, `accepted_values` and `relationships` are declared in YAML and checked with `dbt test`.
- **Materializations**: `view` (default), `table`, `incremental`, `ephemeral`.

## Layers (dbt vs medallion)
| dbt layer | Medallion | What happens |
|---|---|---|
| sources | Bronze | raw tables, untouched |
| staging (`stg_`) | Silver | one per source table: rename, cast, clean. No joins. |
| intermediate (`int_`) | Silver/Gold | joins and business logic |
| marts (`fct_`, `dim_`) | Gold | the final star schema that BI tools read |

Memory trick: staging = washing and chopping, intermediate = cooking, marts = the plated dish.
