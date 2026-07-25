-- ephemeral model: joins poduct and category staging models
-- derives cost_tier for segmentation in dim_products

with crm_products as (
    select * from {{ ref ('stg_crm__prd_info') }}
),
erp_categories as (
    select * from {{ ref ('stg_erp__prd_categories') }}
),
enriched as (
    select
       -- ids
       p.product_id,
       p.product_number,
       p.category_id,

       -- names
       p.product_name,

       -- category details from erp
       c.category,
       c.subcategory,
       c.maintenance,

       -- product attributes
       p.cost,
       p.product_line,
       p.start_date,
       p.end_date,

       --derived: cost tier for segmentation in dim_products
       case
            when p.cost < 100 then 'Low'
            when p.cost between 100 and 500 then 'Mid'
            when p.cost between 501 and 1500 then 'High'
            when p.cost > 1500 then 'Premium'
            else 'n/a'
       end as cost_tier

    from crm_products p
    left join erp_categories c
        on p.category_id = c.category_id
)

select * from enriched