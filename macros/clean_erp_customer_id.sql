{% macro clean_erp_customer_id(column) %}
{#-
    Strips the 3-character NAS prefix (if present) and all hyphens from
    ERP customer IDs so they match the CRM customer key format used for
    joining.
    ERP raw format:  'NAS-AW-00011000'  or  'NASAW-00011000'
    CRM raw format:  'AW00011000'
    Only rows actually prefixed with NAS have those 3 characters dropped -
    this avoids corrupting any row that already arrives in CRM format.
    Usage:
        {{ clean_erp_customer_id('cid') }}  as customer_number
-#}
    case
        when upper(trim({{ column }})) like 'NAS%'
            then replace(substr(trim({{ column }}), 4), '-', '')
        else replace(trim({{ column }}), '-', '')
    end
{% endmacro %}