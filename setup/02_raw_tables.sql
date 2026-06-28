-- All columns VARCHAR — type casting handled in dbt staging models
CREATE OR REPLACE TABLE DWH.DWH_SCHEMA.crm_cust_info (
    cst_id VARCHAR, cst_key VARCHAR, cst_firstname VARCHAR,
    cst_lastname VARCHAR, cst_marital_status VARCHAR,
    cst_gndr VARCHAR, cst_create_date VARCHAR
);

CREATE OR REPLACE TABLE DWH.DWH_SCHEMA.crm_prd_info (
    prd_id VARCHAR, prd_key VARCHAR, prd_nm VARCHAR,
    prd_cost VARCHAR, prd_line VARCHAR,
    prd_start_dt VARCHAR, prd_end_dt VARCHAR
);

CREATE OR REPLACE TABLE DWH.DWH_SCHEMA.crm_sales_details (
    sls_ord_num VARCHAR, sls_prd_key VARCHAR, sls_cust_id VARCHAR,
    sls_order_dt VARCHAR, sls_ship_dt VARCHAR, sls_due_dt VARCHAR,
    sls_sales VARCHAR, sls_quantity VARCHAR, sls_price VARCHAR
);

CREATE OR REPLACE TABLE DWH.DWH_SCHEMA.erp_cust_demographics (
    cid VARCHAR, bdate VARCHAR, gen VARCHAR
);

CREATE OR REPLACE TABLE DWH.DWH_SCHEMA.erp_cust_location (
    cid VARCHAR, cntry VARCHAR
);

CREATE OR REPLACE TABLE DWH.DWH_SCHEMA.erp_prd_categories (
    id VARCHAR, cat VARCHAR, subcat VARCHAR, maintenance VARCHAR
);