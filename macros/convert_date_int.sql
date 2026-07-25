{% macro convert_date_int(column)%}
{#- This macro converts a date integer to a date format -#}
    case 
        when length(trim({{column}})) != 8
            or try_cast({{column}} as int) <= 0
            then null
        else try_cast(
            left({{column}}, 4) || '-' ||
            substring({{column}}, 5, 2) || '-' ||
            right({{column}}, 2)
         as date)
    end
{% endmacro %}