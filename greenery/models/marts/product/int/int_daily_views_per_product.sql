{{

    config(
        MATERIALIZED = 'table'
    )
}}

with events as (
    select * from {{ ref('stg_postgres_events')}}
)

, products as (
    select * from {{ ref('stg_postgres_products')}}
)

, final as (

    select 
    events.product_id, products.name
    , count(distinct events.session_id) as page_views
    , date_trunc(day, events.created_at_utc) as day
    from events
    inner join products on events.product_id = products.product_id
    where event_type = 'page_view'
    group by events.product_id, products.name, day

)

select * from final