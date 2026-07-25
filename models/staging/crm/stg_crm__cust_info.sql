with source as (
    select * from {{ source('crm', 'crm_cust_info') }}
),

cleaned as (
    select 
        --ids
        try_cast(cst_id as int) as customer_id,
        trim(cst_key) as customer_number,

        --names
        trim(cst_firstname) as first_name,
        trim(cst_lastname) as last_name,

        --normalise marital status - raw values are: 'M', 'S', or garbage
        case 
            when trim(cst_marital_status) = 'M' then 'Married'
            when trim(cst_marital_status) = 'S' then 'Single'
            else 'n/a'
        end as marital_status,

        -- normalise gender - raw values are 'F', 'M', or garbage
        case 
            when upper(trim(cst_gndr)) = 'F' then 'Female'
            when upper(trim(cst_gndr)) = 'M' then 'Male'
            else 'n/a'
        end as gender,

        --dates
        try_cast(cst_create_date as date) as create_date,

        --deduplication flag - we keep the most recent record for each customer based on the create_date
        row_number() over (partition by cst_id order by cst_create_date desc) as _row_num

        from source
        where cst_id is not null
)
select
    customer_id,
    customer_number,
    first_name,
    last_name,
    marital_status,
    gender,
    create_date
from cleaned
where _row_num = 1