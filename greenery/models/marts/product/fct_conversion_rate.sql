{{

    config(
        MATERIALIZED = 'table'
    )
}}

with orders as (

    select product_id
    , total_orders
    from {{ ref('int_orders_per_product') }}
)

, page_views as (

    select product_id
    , total_views
    from {{ ref('int_page_views_per_product') }}
)

, products as (

    select product_id, name
    from {{ ref('stg_postgres_products')}}
)

select products.name
    , page_views.total_views
    , orders.total_orders
    , (orders.total_orders / page_views.total_views) as conversion_rate
from page_views
left outer join orders on page_views.order_id = orders.order_id
left outer join products on page_views.order_id = products.order_id