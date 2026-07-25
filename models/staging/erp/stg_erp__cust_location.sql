with source as (

    select * from {{ source('erp', 'erp_cust_location') }}

),

cleaned as (

    select
        -- same NAS prefix strip as erp_cust_demographics
        -- cid must match cst_key in crm_cust_info for the join to work
        {{ clean_erp_customer_id('cid') }} as customer_number,

        -- normalise country values — raw data has codes, full names,
        -- inconsistent casing, and blanks all mixed together
        case
            when trim(cntry) is null
                or trim(cntry) = ''     then 'n/a'
            when upper(trim(cntry))
                in ('US', 'USA')        then 'United States'
            when upper(trim(cntry))
                = 'DE'                  then 'Germany'
            when upper(trim(cntry))
                = 'AU'                  then 'Australia'
            when upper(trim(cntry))
                = 'GB'                  then 'United Kingdom'
            when upper(trim(cntry))
                = 'FR'                  then 'France'
            when upper(trim(cntry))
                = 'CA'                  then 'Canada'
            else trim(cntry)
        end                                                 as country

    from source

)

select
    customer_number,
    country
from cleaned