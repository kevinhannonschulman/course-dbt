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
    select sum(page_view_sessions) as distinct_page_view_sessions
    , sum(checkout_sessions) as distinct_checkout_sessions
    , sum(checkout_sessions) / sum(page_view_sessions) as overall_conversion_rate
    from sessions_with_event_type
)

select * from final