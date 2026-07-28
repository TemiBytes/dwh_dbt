CREATE OR REPLACE SCHEMA DWH.AUDIT;

CREATE OR REPLACE TABLE DWH.AUDIT.DBT_AUDIT (
    INVOCATION_ID string,
    run_started_at timestamp,
    dbt_command string,
    target_profile string,
    target_name string,
    target_user string,
    dbt_version string
);