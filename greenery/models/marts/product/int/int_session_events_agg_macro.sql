{{

    config(
        MATERIALIZED = 'table'
    )
}}

with events as (
    select * from {{ ref('stg_postgres_events')}}
)

, final as (
    SELECT
    user_id
    , session_id
    {%- for event_type in event_types %}
    , sum(case when event_type = '{{ event_type }}' then 1 else 0 end) as {{ event_type }}s
    {%- endfor %}
    , min(created_at_utc) as first_session_event_utc
    , max(created_at_utc) as last_session_event_utc
    from events
    group by user_id, session_id    
)

select * from final
