# Day 2: Raw data + a dbt project inside Snowflake

## Part A: create the raw data
1. In Snowsight, go to **Projects → Workspaces → + Add new → SQL File** and name it `setup_raw_data.sql`.
2. Paste [`../setup/01_create_raw_data.sql`](../setup/01_create_raw_data.sql).
3. Click the **down-arrow next to the Run button → Run All**.
4. The last result shows the row counts: about 3,050 leads, 300–400 enrolments (the data is random) and 246 ad_spend rows.

### Gotchas I hit
- **The Run button runs only the statement your cursor is on.** Use Run All, or press Ctrl+A first.
- **"Object does not exist or not authorized"** with ACCOUNTADMIN usually means the wrong context, not missing permission. That's why the script uses full names (`database.schema.table`) everywhere.

## Part B: create the dbt project
1. **+ Add new → dbt Project**
2. Fill in: Project name `marketing_dbt`, Role `ACCOUNTADMIN`, Warehouse `DBT_WH`, Database `MARKETING_DB`, Schema `DEV` → **Create**.
3. Look at the generated files:
   - **`dbt_project.yml`** says **what** to build: the project name, where the models are, and the default materialization (`+materialized: view`).
   - **`profiles.yml`** says **where** to build it: the role, warehouse, database and schema. `target: dev` is the default.
   - **`models/example/`** contains two sample models. The second one uses `{{ ref('my_first_dbt_model') }}`.
4. In the command dropdown (top right), choose **Run** → ▶. Both models should say `OK`.
5. Choose **Compile** → ▶, then open the **DAG** tab to see the arrow between the two models.
6. Check **Databases → MARKETING_DB → DEV**: `my_first_dbt_model` is a **table** and `my_second_dbt_model` is a **view**.

If you get a role error, run this once (with your own username):
`ALTER USER "<your_username>" SET DEFAULT_SECONDARY_ROLES = ('ALL');`

## What I learned
- The **most specific setting wins**: `{{ config(materialized='table') }}` inside a model overrides `dbt_project.yml`, which overrides dbt's default (view).
- `ref()` is what tells dbt the build order.
- Teaser: `models/example/schema.yml` has `unique` and `not_null` tests, and the first model contains a NULL id, so **Test** will fail on purpose. More on tests soon.

## Try it yourself
1. What's the difference between `dbt_project.yml` and `profiles.yml`?
2. Change `my_second_dbt_model` to a table using `config()`, then run again. What changed in DEV?
