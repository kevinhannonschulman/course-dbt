{{

    config(
        MATERIALIZED = 'table'
    )
}}

with final as (
    SELECT
    user_id
    , session_id
    {{ agg_event_types ('stg_postgres_events', 'event_type') }}
    , min(created_at_utc) as first_session_event_utc
    , max(created_at_utc) as last_session_event_utc
    from {{ ref('stg_postgres_events')}}
    group by user_id, session_id    
)

select * from final