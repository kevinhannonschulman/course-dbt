with events as (
    select * from {{ref ('stg_postgres_events') }}
)

, order_items as (
    
    select * from {{ref ('stg_postgres_order_items') }}
)

, products as (
    select * from {{ref ('stg_postgres_products') }}
)

, views as (
    select product_id
    , count(distinct session_id) as distinct_page_view_sessions
    from events
    where event_type = 'page_view'
    group by product_id
)

, orders as (
    select order_items.product_id
    , count(distinct events.session_id) as distinct_checkout_sessions
    from events
    left join order_items on events.order_id = order_items.order_id
    where events.order_id is not null
    group by order_items.product_id
)

, final as (
    select 
    products.name
    , views.product_id
    , views.distinct_page_view_sessions
    , orders.distinct_checkout_sessions
    from views
    join orders on views.product_id = orders.product_id
    join products on products.product_id = orders.product_id
)

select * from final