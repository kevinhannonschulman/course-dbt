{{

    config(
        MATERIALIZED = 'table'
    )
}}

with orders as (

    select product_id
    , distinct_order_sessions
    from {{ ref('int_order_sessions_per_product') }}
)

, page_views as (

    select product_id
    , distinct_page_view_sessions
    from {{ ref('int_page_view_sessions_per_product') }}
)

, products as (

    select product_id, name
    from {{ ref('stg_postgres_products')}}
)

select products.name
    , page_views.distinct_page_view_sessions
    , orders.distinct_order_sessions
    , (orders.distinct_order_sessions / page_views.distinct_page_view_sessions) as conversion_rate
from page_views
left join orders on page_views.product_id = orders.product_id
left join products on page_views.product_id = products.product_id