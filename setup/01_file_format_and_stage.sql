-- FILE FORMAT: defines how Snowflake parses incoming CSV files
CREATE OR REPLACE FILE FORMAT DWH.DWH_SCHEMA.csv_format
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL = TRUE
    SKIP_HEADER = 1
    TRIM_SPACE = TRUE;

-- STAGE: internal landing zone for CSV files before COPY INTO
CREATE OR REPLACE STAGE DWH.DWH_SCHEMA.raw_stage
    FILE_FORMAT = DWH.DWH_SCHEMA.csv_format;