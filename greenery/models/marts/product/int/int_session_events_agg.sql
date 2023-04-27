{{

    config(
        MATERIALIZED = 'table'
    )
}}

{%- set event_types = dbt_utils.get_column_values(
    table=ref('stg_postgres_events'),
    column='event_type'
) -%}

with final as (
    SELECT
    user_id
    , session_id
    {%- for event in event_types %}
    , {{event_type_sums(event)}} as {{event}}s
    {%- endfor %}
    , min(created_at_utc) as first_session_event_utc
    , max(created_at_utc) as last_session_event_utc
    from {{ ref('stg_postgres_events')}}
    group by user_id, session_id    
)

select * from final