-- dim_date is generated entirely from a date spine macro
-- no source table needed - dbt_utils.date_spine genrates every date
-- between the start and end dates as a row

with date_spine as  (
      {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2010-01-01' as date)",
        end_date="cast('2030-12-31' as date)"
    ) }} 
),

final as (
    select 
        -- surrogate key: integer in YYYYMMDD format for fast joins
        cast(date_day as date) as full_date,
        to_number(to_char(date_day, 'YYYYMMDD')) as date_key,

        -- year 
        year(date_day) as year,

        -- quarter
        quarter(date_day) as quarter,

        -- month
        month(date_day) as month_number,
        monthname(date_day) as month_name,

        -- week
        weekofyear(date_day) as week_of_year,

        -- day
        dayofweek(date_day) as day_of_week,
        dayname(date_day) as day_name,


        --flags
        case
            when dayofweek(date_day) in (1,7) then true 
            else false
        end as is_weekend
    
    from date_spine

)

select * from final