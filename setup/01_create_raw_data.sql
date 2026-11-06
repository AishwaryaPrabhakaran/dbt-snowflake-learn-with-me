-- =====================================================================
-- dbt on Snowflake: learn with me
-- Day 2 setup: creates a small "education company" with messy raw data
-- Run in Snowsight with: Run All (the down-arrow next to the Run button)
-- Safe to re-run: everything uses IF NOT EXISTS / OR REPLACE
-- =====================================================================

-- 1. Compute, cost guard, database and schemas
USE ROLE ACCOUNTADMIN;
CREATE WAREHOUSE IF NOT EXISTS dbt_wh
  WAREHOUSE_SIZE = XSMALL AUTO_SUSPEND = 60 AUTO_RESUME = TRUE INITIALLY_SUSPENDED = TRUE;
CREATE RESOURCE MONITOR IF NOT EXISTS dbt_monitor WITH CREDIT_QUOTA = 5
  TRIGGERS ON 90 PERCENT DO SUSPEND ON 100 PERCENT DO SUSPEND_IMMEDIATE;
ALTER WAREHOUSE dbt_wh SET RESOURCE_MONITOR = dbt_monitor;
USE WAREHOUSE dbt_wh;

CREATE DATABASE IF NOT EXISTS marketing_db;
CREATE SCHEMA IF NOT EXISTS marketing_db.raw;   -- bronze: untouched source data
CREATE SCHEMA IF NOT EXISTS marketing_db.dev;   -- where your dbt models build
CREATE SCHEMA IF NOT EXISTS marketing_db.prod;  -- production, used later

-- 2. LEADS: 3,000 enquiries, Jul to Oct 2026, messy on purpose
--    (mixed-case sources with extra spaces, a city spelled two ways)
CREATE OR REPLACE TABLE marketing_db.raw.leads AS
SELECT
  1000 + ROW_NUMBER() OVER (ORDER BY SEQ4())                                   AS lead_id,
  ARRAY_CONSTRUCT('Google','google ','Meta','META','Referral','Organic')
      [UNIFORM(0, 5, RANDOM())]::STRING                                         AS source,
  ARRAY_CONSTRUCT('chennai','Chennai ','Bengaluru','Coimbatore','Hyderabad')
      [UNIFORM(0, 4, RANDOM())]::STRING                                         AS city,
  DATEADD('minute', UNIFORM(0, 175680, RANDOM()), '2026-07-01'::TIMESTAMP)      AS created_at,
  '9' || LPAD(UNIFORM(0, 999999999, RANDOM())::STRING, 9, '0')                  AS phone
FROM TABLE(GENERATOR(ROWCOUNT => 3000));

-- 3. 50 duplicate leads: same person (same phone), new lead_id, 5 minutes later
INSERT INTO marketing_db.raw.leads
SELECT 9000 + ROW_NUMBER() OVER (ORDER BY lead_id), source, city,
       DATEADD('minute', 5, created_at), phone
FROM marketing_db.raw.leads SAMPLE (50 ROWS);

-- 4. ENROLMENTS: Referral converts best, Meta worst (a story to discover later)
CREATE OR REPLACE TABLE marketing_db.raw.enrolments AS
SELECT
  lead_id,
  DATEADD('day', UNIFORM(3, 40, RANDOM()), created_at)::DATE                  AS enrol_date,
  ARRAY_CONSTRUCT(25000, 40000, 60000)[UNIFORM(0, 2, RANDOM())]::NUMBER        AS fee,
  ARRAY_CONSTRUCT(0, 0, 0.1, 0.2)[UNIFORM(0, 3, RANDOM())]::NUMBER(3,2)        AS discount
FROM marketing_db.raw.leads
WHERE lead_id < 9000
  AND UNIFORM(1, 100, RANDOM()) <= CASE LOWER(TRIM(source))
        WHEN 'referral' THEN 30 WHEN 'meta' THEN 6 ELSE 12 END;

-- 5. AD_SPEND: daily spend for the paid sources; amount stored as TEXT (messy!)
CREATE OR REPLACE TABLE marketing_db.raw.ad_spend AS
SELECT DATEADD('day', d.n, '2026-07-01'::DATE)                    AS spend_date,
       s.source,
       TO_VARCHAR(ROUND(UNIFORM(8000, 15000, RANDOM()) * s.mult)) AS amt
FROM (SELECT ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1 AS n
      FROM TABLE(GENERATOR(ROWCOUNT => 123))) d
CROSS JOIN (SELECT 'Google' AS source, 1.0 AS mult UNION ALL SELECT 'Meta', 0.7) s;

-- 6. Check: expect ~3,050 leads, ~300-400 enrolments (random), 246 ad_spend rows
SELECT 'leads' AS tbl, COUNT(*) AS row_count FROM marketing_db.raw.leads
UNION ALL SELECT 'enrolments', COUNT(*) FROM marketing_db.raw.enrolments
UNION ALL SELECT 'ad_spend',   COUNT(*) FROM marketing_db.raw.ad_spend;
