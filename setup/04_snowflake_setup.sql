/* ============================================================
   DWH SNOWFLAKE SETUP
   Creates the core database, schema, warehouse, and role
   hierarchy for the DWH project (dbt writes, Tableau reads).
   ============================================================ */


-- ============================================================
-- 1. DATABASE, SCHEMA, WAREHOUSE
-- ============================================================

-- Project database
CREATE DATABASE IF NOT EXISTS DWH;

-- Schema that holds all tables, views, and stages
CREATE SCHEMA IF NOT EXISTS DWH.DWH_SCHEMA;

-- Compute warehouse. Auto-suspends after 60s idle to control cost,
-- and starts suspended so it only spins up on first query.
CREATE WAREHOUSE IF NOT EXISTS DWH_WH
    WAREHOUSE_SIZE       = 'MEDIUM'
    AUTO_SUSPEND         = 60
    AUTO_RESUME          = TRUE
    INITIALLY_SUSPENDED  = TRUE;


-- ============================================================
-- 2. ROLES
-- ============================================================

-- Used by dbt: full read/write access to DWH_SCHEMA
CREATE ROLE IF NOT EXISTS TRANSFORMER
    COMMENT = 'Role used by dbt - full read/write access to DWH';

-- Used by Tableau: read-only access to DWH_SCHEMA
CREATE ROLE IF NOT EXISTS REPORTER
    COMMENT = 'Read-only role for Tableau - SELECT on DWH_SCHEMA only';

-- Plug both roles into the SYSADMIN hierarchy so SYSADMIN
-- retains oversight of everything they create
GRANT ROLE TRANSFORMER TO ROLE SYSADMIN;
GRANT ROLE REPORTER    TO ROLE SYSADMIN;


-- ============================================================
-- 3. WAREHOUSE-LEVEL GRANTS
-- ============================================================
-- Both roles need USAGE on the warehouse to actually run queries,
-- independent of what they can see or do in the schema.

GRANT USAGE ON WAREHOUSE DWH_WH TO ROLE TRANSFORMER;
GRANT USAGE ON WAREHOUSE DWH_WH TO ROLE REPORTER;


-- ============================================================
-- 4. DATABASE-LEVEL GRANTS
-- ============================================================

GRANT USAGE ON DATABASE DWH TO ROLE TRANSFORMER;
GRANT USAGE ON DATABASE DWH TO ROLE REPORTER;

-- Only dbt needs to be able to create new schemas as the project grows
GRANT CREATE SCHEMA ON DATABASE DWH TO ROLE TRANSFORMER;


-- ============================================================
-- 5. SCHEMA-LEVEL GRANTS - TRANSFORMER (dbt, full DDL + DML)
-- ============================================================

-- Object creation rights within the schema
GRANT USAGE, CREATE TABLE, CREATE VIEW, CREATE STAGE,
      CREATE FILE FORMAT, CREATE SEQUENCE, CREATE STREAM, CREATE TASK
      ON SCHEMA DWH.DWH_SCHEMA TO ROLE TRANSFORMER;

-- Row-level access on objects that already exist
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE
      ON ALL TABLES IN SCHEMA DWH.DWH_SCHEMA TO ROLE TRANSFORMER;

GRANT SELECT
      ON ALL VIEWS IN SCHEMA DWH.DWH_SCHEMA TO ROLE TRANSFORMER;

-- Future grants: automatically cover tables/views dbt creates later,
-- so this script doesn't need to be re-run after every new model
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE
      ON FUTURE TABLES IN SCHEMA DWH.DWH_SCHEMA TO ROLE TRANSFORMER;

GRANT SELECT
      ON FUTURE VIEWS IN SCHEMA DWH.DWH_SCHEMA TO ROLE TRANSFORMER;


-- ============================================================
-- 6. SCHEMA-LEVEL GRANTS - REPORTER (Tableau, read-only)
-- ============================================================

GRANT USAGE ON SCHEMA DWH.DWH_SCHEMA TO ROLE REPORTER;

-- Existing objects
GRANT SELECT ON ALL TABLES IN SCHEMA DWH.DWH_SCHEMA TO ROLE REPORTER;
GRANT SELECT ON ALL VIEWS  IN SCHEMA DWH.DWH_SCHEMA TO ROLE REPORTER;

-- Future objects, so new dbt models are visible to Tableau automatically
GRANT SELECT ON FUTURE TABLES IN SCHEMA DWH.DWH_SCHEMA TO ROLE REPORTER;
GRANT SELECT ON FUTURE VIEWS  IN SCHEMA DWH.DWH_SCHEMA TO ROLE REPORTER;


-- ============================================================
-- 7. USER-ROLE ASSIGNMENT
-- ============================================================

GRANT ROLE TRANSFORMER TO USER temi;
GRANT ROLE REPORTER    TO USER temi;


-- ============================================================
-- 8. VERIFICATION
-- ============================================================

SHOW WAREHOUSES;
SHOW DATABASES;
SHOW SCHEMAS IN DATABASE DWH;
SHOW ROLES;