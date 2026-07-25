with fact_sales as (
    select * from {{ ref('fact_sales') }}
),

dim_customers as (
    select * from {{ ref('dim_customers') }}
),

dim_products as (
    select * from {{ ref('dim_products') }}
),

aggregated as (
    select 
        -- time grain
        s.order_year,
        s.order_month,

        --dimensions to aggregate by
        p.category,
        p.subcategory,
        c.country,

        -- measures 
        count(distinct s.order_number) as total_orders,
        sum(s.quantity) as total_quantity,
        sum(s.sales_amount) as total_sales,
        avg(s.sales_amount) as avg_order_value,
        count(distinct c.customer_key) as total_customers 

    from fact_sales s 
    left join dim_customers c 
        on s.customer_key = c.customer_key 
    left join dim_products p 
        on s.product_key = p.product_key
    group by 
        s.order_year,
        s.order_month,
        p.category,
        p.subcategory,
        c.country
)

select * from aggregated