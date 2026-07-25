with products as (

    select * from {{ ref('int_products_enriched') }}

),

final as (

    select
        -- surrogate key: stable integer PK for joins in fact_sales
        {{ dbt_utils.generate_surrogate_key(['product_id']) }} as product_key,

        -- natural keys
        product_id,
        product_number,

        -- product details
        product_name,
        product_line,

        -- category details (from ERP via intermediate layer)
        category_id,
        category,
        subcategory,
        maintenance,

        -- financial attributes
        cost,
        cost_tier,

        -- dates
        start_date,
        end_date

    from products
    qualify row_number() over (
        partition by product_number
        order by end_date desc nulls first
    ) = 1

)

select * from final