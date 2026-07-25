-- COPY INTO uses subquery to map positional columns ($1,$2...) to named columns
-- SKIP_HEADER=1 means header row is already discarded by the file format

COPY INTO DWH.DWH_SCHEMA.crm_cust_info
FROM (SELECT $1,$2,$3,$4,$5,$6,$7 FROM @DWH.DWH_SCHEMA.raw_stage/cust_info.csv t)
ON_ERROR = 'CONTINUE';

COPY INTO DWH.DWH_SCHEMA.crm_prd_info
FROM (SELECT $1,$2,$3,$4,$5,$6,$7 FROM @DWH.DWH_SCHEMA.raw_stage/prd_info.csv t)
ON_ERROR = 'CONTINUE';

COPY INTO DWH.DWH_SCHEMA.crm_sales_details
FROM (SELECT $1,$2,$3,$4,$5,$6,$7,$8,$9 FROM @DWH.DWH_SCHEMA.raw_stage/sales_details.csv t)
ON_ERROR = 'CONTINUE';

COPY INTO DWH.DWH_SCHEMA.erp_cust_demographics
FROM (SELECT $1,$2,$3 FROM @DWH.DWH_SCHEMA.raw_stage/CUST_AZ12.csv t)
ON_ERROR = 'CONTINUE';

COPY INTO DWH.DWH_SCHEMA.erp_cust_location
FROM (SELECT $1,$2 FROM @DWH.DWH_SCHEMA.raw_stage/LOC_A101.csv t)
ON_ERROR = 'CONTINUE';

COPY INTO DWH.DWH_SCHEMA.erp_prd_categories
FROM (SELECT $1,$2,$3,$4 FROM @DWH.DWH_SCHEMA.raw_stage/PX_CAT_G1V2.csv t)
ON_ERROR = 'CONTINUE';