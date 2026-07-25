with source as (

    select * from {{ source('erp', 'erp_prd_categories') }}

),

cleaned as (

    select
        -- id joins to category_id derived from crm_prd_info.prd_key
        trim(id)                                            as category_id,
        trim(cat)                                           as category,
        trim(subcat)                                        as subcategory,
        trim(maintenance)                                   as maintenance

    from source
    where trim(id) is not null
        and trim(id) != ''

)

select
    category_id,
    subcategory,
    category,
    maintenance
from cleaned