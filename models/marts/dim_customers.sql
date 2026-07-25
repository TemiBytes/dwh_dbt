with customers as (
    select * from {{ ref('int_customers_enriched') }}
),

final as (
    select 
        -- surrogate key: stable interger PK for joins in fact_sales
        {{dbt_utils.generate_surrogate_key(['customer_id'])}} as customer_key,

        -- natural keys
        customer_id,
        customer_number,

        -- personal details
        first_name,
        last_name,
        full_name,
        gender,
        marital_status,
        birthdate,
        
        -- location
        country,

        --derived age metrics (computed in intermediate layer)
        age,
        age_band,

        --dates
        create_date
    from customers
)

select * from final