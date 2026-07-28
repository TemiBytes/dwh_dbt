with sales as (
    select * from {{ ref('stg_crm__sales_details') }}
),

enriched as (
    select 
        order_number,
        product_number,
        customer_id,

        --dates
        order_date,
        shipping_date,
        due_date,

        -- time grains for aggregation on marts
        year(order_date) as order_year,
        month(order_date) as order_month,

        sales_amount,
        quantity,
        price
    from sales
    where order_date is not null
    and year(order_date) between 2011 and 2013
)

select * from enriched