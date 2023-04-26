{% macro event_types() %}
    
{% set event_types = dbt_utils.get_column_values(table = ref('stg_postgres_events'), column= 'event_type') %}

{% endmacro %}