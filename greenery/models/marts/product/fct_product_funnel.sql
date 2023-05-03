{{

    config(
        MATERIALIZED = 'table'
    )
}}

with session_event_agg as (
    select session_id
    , case when page_views > 0 then 1 else 0 end as page_view_sessions
    , case when add_to_carts > 0 then 1 else 0 end as add_to_cart_sessions
    , case when checkouts > 0 then 1 else 0 end as checkout_sessions
    from {{ ref('int_session_events_agg') }}
)

, final as (
    select sum(add_to_cart_sessions) as distinct_add_to_cart_sessions
    , sum(page_view_sessions) as distinct_page_view_sessions
    , sum(checkout_sessions) as distinct_checkout_sessions
    , sum(add_to_cart_sessions) / sum(page_view_sessions) as add_to_cart_rate
    , sum(checkout_sessions) / sum(add_to_cart_sessions) as cart_to_checkout_rate
    , sum(checkout_sessions) / sum(page_view_sessions) as overall_conversion_rate
    from session_event_agg
)

select * from final