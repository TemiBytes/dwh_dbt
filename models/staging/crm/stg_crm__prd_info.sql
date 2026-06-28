with source as (
    select * from {{ source('crm', 'crm_prd_info') }}   
),
cleaned as (
        select
        -- ids
        try_cast(prd_id as int) as product_id,

        --extract category id from the product key 
        -- prd_key format: 'CO-RF-FR-R92B-58'
        split_part(prd_key, '-', 1) as category_id,

        trim(prd_key) as product_number,
        trim(prd_nm) as product_name,

        -- cost: nulls and negatives are bad data, default to 0
        case 
            when try_cast(prd_cost as int) is null then 0
            when try_cast(prd_cost as int) < 0 then 0
            else try_cast(prd_cost as int)
        end as cost,

        -- normalise product line codes
        case 
            when upper(trim(prd_line)) = 'R' then 'Road'
            when upper(trim(prd_line)) = 'M' then 'Mountain'
            when upper(trim(prd_line)) = 'S' then 'Sport'
            when upper(trim(prd_line)) = 'T' then 'Touring'
            else 'n/a'
        end as product_line,

        --dates
        try_cast(prd_start_dt as date) as start_date,
        try_cast(prd_end_dt as date) as end_date

    from source
    where prd_id is not null
)

select 
    product_id,
    category_id,
    product_number,
    product_name,
    cost,
    product_line,
    start_date,
    end_date
from cleaned