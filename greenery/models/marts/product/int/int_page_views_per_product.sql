{{

    config(
        MATERIALIZED = 'table'
    )
}}

with events as (

    select * from {{ ref('stg_postgres_events') }}
)

, final as (

    select product_id
    , count(distinct session_id) as total_views
    from events
    where event_type = 'page_view'
    group by product_id
)

select * from final