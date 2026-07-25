-- ephemeral model: compiles as a CTE inside downstream models
-- no physical table or view is created in snowflake
-- joins all three customer staging models and resolves data conflicts

with crm_customers as (
    select * from {{ ref('stg_crm__cust_info') }}
),
erp_demographics as (
    select * from {{ ref('stg_erp__cust_demographics') }}
),
erp_location as (
    select * from {{ ref('stg_erp__cust_location') }}
),

enriched as (
    select 
        -- ids
        c.customer_id,
        c.customer_number,

        -- names
        c.first_name,
        c.last_name,
        c.first_name || ' ' || c.last_name as full_name,
        
        -- marital status from CRM (only source of truth for this field)
        c.marital_status,
        
        -- gender: CRM is the primary source
        -- ERP is the fallback when CRM has no valid value
        case 
            when c.gender != 'n/a' then c.gender
            else coalesce(d.gender, 'n/a')
        end as gender,

        -- birthdate from ERP only (CRM does not have this field)
        d.birthdate,

        --derived age
        case 
            when d.birthdate is not null then datediff('year', d.birthdate, current_date())
            else null
        end as age,

        -- derived: age band for segmentation in dim_customers
        case 
            when datediff(year,d.birthdate, current_date()) < 20 then 'Under 20'
            when datediff(year,d.birthdate, current_date()) between 20 and 29 then '20-29'
            when datediff(year,d.birthdate, current_date()) between 30 and 39 then '30-39'
            when datediff(year,d.birthdate, current_date()) between 40 and 49 then '40-49'
            when datediff(year,d.birthdate, current_date()) between 50 and 59 then '50-59'
            when datediff(year,d.birthdate, current_date()) >= 60 then '60+'
            else 'n/a'
        end as age_band,

        -- location from ERP
        l.country,

        --dates
        c.create_date
    from crm_customers c
    left join erp_demographics d 
        on c.customer_number  = d.customer_number 
    left join erp_location l
        on c.customer_number = l.customer_number
)

select * from enriched