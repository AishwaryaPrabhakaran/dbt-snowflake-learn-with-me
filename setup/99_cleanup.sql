-- Removes everything this project created. Run only when you are finished.
-- Also delete the dbt project in Workspaces (... menu > Delete).
USE ROLE ACCOUNTADMIN;
DROP DATABASE IF EXISTS marketing_db;
DROP WAREHOUSE IF EXISTS dbt_wh;
DROP RESOURCE MONITOR IF EXISTS dbt_monitor;
