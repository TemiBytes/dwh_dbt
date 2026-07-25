with source as (
    select * from {{ source('crm', 'crm_sales_details') }}   
),

cleaned as (
    select 
        -- ids
        trim(sls_ord_num) as order_number,
        trim(sls_prd_key) as product_number,
        try_cast(sls_cust_id as int) as customer_id,

        -- dates ae stored as YYYYMMDD integer strings e.g '20101229'
        -- invalid dates (0, negatives, wrong length) are nulled out 

        case 
            when length(trim(sls_order_dt)) != 8
                or try_cast(sls_order_dt as int) <= 0
                then null
            else try_cast(
                left(sls_order_dt, 4) || '-' ||
                substring(sls_order_dt, 5, 2) || '-' ||
                right(sls_order_dt, 2)
             as date)
        end as order_date,

        case 
            when length(trim(sls_ship_dt)) != 8
                or try_cast(sls_ship_dt as int) <= 0
                then null
            else try_cast(
                left(sls_ship_dt, 4) || '-' ||
                substring(sls_ship_dt, 5, 2) || '-' ||
                right(sls_ship_dt, 2)
             as date)
        end as shipping_date,

        case 
            when length(trim(sls_due_dt)) != 8
                or try_cast(sls_due_dt as int) <= 0
                then null
            else try_cast(
                left(sls_due_dt, 4) || '-' ||
                substring(sls_due_dt, 5, 2) || '-' ||
                right(sls_due_dt, 2)
             as date)
        end as due_date,

        -- financial fields: cross validate sales, quantity , price
        case 
            when try_cast(sls_sales as int) is null 
                or try_cast(sls_sales as int) <= 0
                or try_cast(sls_sales as int) != try_cast(sls_quantity as int) * abs(try_cast(sls_price as int))
            then try_cast(sls_quantity as int) * try_cast(sls_price as int)
            else try_cast(sls_sales as int)
        end as sales_amount,

        try_cast(sls_quantity as int) as quantity,

        case 
            when try_cast(sls_price as int) is null 
                or try_cast(sls_price as int) <= 0
            then try_cast(sls_sales as int) / nullif(try_cast(sls_quantity as int), 0)
            else try_cast(sls_price as int)
        end as price
            
    from source
    where sls_ord_num is not null
)

select 
    order_number,
    product_number,
    customer_id,
    order_date,
    shipping_date,
    due_date,
    sales_amount,
    quantity,
    price
from cleaned