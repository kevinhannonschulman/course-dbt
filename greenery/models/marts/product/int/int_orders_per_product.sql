{{

    config(
        MATERIALIZED = 'table'
    )
}}

with events as (

    select * from {{ ref('stg_postgres_events') }}
)

, order_items as (
    
    select * from {{ ref('stg_postgres_order_items')}}
)

, final as (

    select order_items.product_id
    , count(distinct events.session_id) as total_orders
    from events
    left join order_items on events.order_id = order_items.order_id
    where events.order_id is not null
    group by order_items.product_id
)

select * from final