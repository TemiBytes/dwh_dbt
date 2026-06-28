with source as (
    select * from {{ source('erp', 'erp_cust_demographics') }}
),

cleaned as (
    select 
        -- strip the 'NAS' prefix from cid where it exists
        -- result must match cst_key in crm_cust_info for the join to work 

        case 
            when upper(trim(cid)) like 'NAS%' THEN SUBSTRING(trim(cid), 4)
            else trim(cid)
        end as customer_number,

        -- birthdate: future dates are bad data , null them out
        -- a customer cannot be born in the future

        case 
            when try_cast(bdate as date) > current_date
                then null
            else try_cast(bdate as date)
        end as birthdate,

        -- normalise gender 

        case 
            when upper(trim(gen)) in ('MALE', 'M') then 'Male'
            when upper(trim(gen)) in ('FEMALE', 'F') then 'Female'
            else 'n/a'
        end as gender

        from source
)

select
    customer_number,
    birthdate,
    gender
from cleaned