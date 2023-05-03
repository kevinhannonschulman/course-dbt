{{

    config(
        MATERIALIZED = 'table'
    )
}}

with sessions_with_event_type as (
    select *
    from {{ ref('int_sessions_with_event_type') }}
)

, final as (
    select sum(add_to_cart_sessions) as distinct_add_to_cart_sessions
    , sum(page_view_sessions) as distinct_page_view_sessions
    , sum(checkout_sessions) as distinct_checkout_sessions
    , sum(add_to_cart_sessions) / sum(page_view_sessions) as add_to_cart_rate
    , sum(checkout_sessions) / sum(add_to_cart_sessions) as cart_to_checkout_rate
    , sum(checkout_sessions) / sum(page_view_sessions) as overall_conversion_rate
    from sessions_with_event_type
)

select * from final