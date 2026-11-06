# dbt on Snowflake: learn with me

I'm learning **dbt** (data build tool) step by step and sharing every day's work here, so you can practise alongside me.
Everything runs **inside Snowflake** (Snowsight → Workspaces), so there's nothing to install. A free Snowflake trial is enough.

![dbt explained](assets/dbt-explained.gif)

## What we're building

A marketing analytics model for a (fictional) education company:

```
raw (bronze)                 staging (silver)        marts (gold)
leads        ─┐
enrolments   ─┼──▶  stg_leads, stg_enrolments,  ──▶  dim_source, fct_enrolments,
ad_spend     ─┘     stg_ad_spend                      CAC & conversion by source
```

The raw data is **messy on purpose**, just like in real life:

| Problem | Example | Fixed in |
|---|---|---|
| Inconsistent text | `'Google'`, `'google '`, `'META'` | staging |
| Same city, two spellings | `'chennai'`, `'Chennai '` | staging |
| Duplicate leads | ~50 people submitted the form twice (same phone) | staging + tests |
| Wrong data type | ad spend amount stored as text | staging |

## Progress

| Day | Topic | Notes |
|---|---|---|
| 1 | What dbt is: ELT, models, `ref()`, the DAG | [day-01](days/day-01-what-is-dbt.md) |
| 2 | Set up raw data + a dbt project in Snowflake, first `dbt run` | [day-02](days/day-02-setup.md) |
| 3 | Sources + first staging model (`stg_leads`) | coming soon |

## Quick start

1. Sign up for a [Snowflake free trial](https://signup.snowflake.com/).
2. In Snowsight, open **Projects → Workspaces**, create a SQL file, paste [`setup/01_create_raw_data.sql`](setup/01_create_raw_data.sql) and choose **Run All**.
3. Follow [Day 2](days/day-02-setup.md) to create the dbt project.
4. When you're done, [`setup/99_cleanup.sql`](setup/99_cleanup.sql) removes everything.

**Cost:** the script creates an XSMALL warehouse that suspends after 60 seconds, plus a resource monitor that stops it at 5 credits.

## Learning with me?

Star the repo, try each day, and open an issue if you get stuck. I'd love to hear how it goes.

Official docs: [dbt Projects on Snowflake tutorial](https://docs.snowflake.com/en/user-guide/tutorials/dbt-projects-on-snowflake-getting-started-tutorial)
