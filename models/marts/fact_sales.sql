{{
  config(
    materialized = 'incremental',
    unique_key = 'sales_key',
    incremental_strategy = 'merge',
  )
}}

with sales as (
    select * from {{ ref("int_sales_enriched") }}

    -- on incremental runs, only process orders newer than what's already loaded
    -- on first run, this block is ignored and all rows are loaded 
    {% if is_incremental() %}
        where order_date > (select max(order_date) from {{ this }})
    {% endif %}

),

dim_customers as (
    select * from {{ ref("dim_customers")}}
),

dim_products as (
    select * from {{ ref('dim_products')}}
),

dim_date as (
    select * from {{ ref('dim_date') }}
),

final as (
    select
        -- surrogate key: unique per order line (order_number alone is not unique — one order has many products)
        {{ dbt_utils.generate_surrogate_key(['s.order_number', 's.product_number']) }} as sales_key,

        -- natural key
        s.order_number,

        -- foreign keys to dimensions (surrogate keys)
        c.customer_key,
        p.product_key,
        d.date_key,

        -- dates(kept for convenience alongside date key)
        s.order_date,
        s.shipping_date,
        s.due_date,

        -- time grains (precomputed in intermediate layer)
        s.order_year,
        s.order_month,

        -- measures
        s.sales_amount,
        s.quantity,
        s.price

    from sales s 
    left join dim_customers c 
        on s.customer_id = c.customer_id
    left join dim_products  p
        on s.product_number = p.product_number
    left join dim_date d 
        on s.order_date = d.full_date
)

select * from final