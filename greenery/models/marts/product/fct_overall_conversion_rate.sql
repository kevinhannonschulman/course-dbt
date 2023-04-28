{{

    config(
        MATERIALIZED = 'table'
    )
}}

with events_distinct_session_type as (

    select distinct(session_id)
    , max(case when checkouts > 0 then 1 else 0 end) as checkouts
    , max(case when page_views > 0 then 1 else 0 end) as page_views
    from {{ ref('int_session_events_agg') }}
    group by session_id
)

, agg as (

    select sum(events_distinct_session_type.page_views) as distinct_view_sessions
    , sum(events_distinct_session_type.checkouts) as distinct_checkout_sessions
    from events_distinct_session_type

)

, final as (
    select distinct_view_sessions
    , distinct_checkout_sessions
    , (distinct_checkout_sessions / distinct_view_sessions) as overall_conversion_rate
    from agg
)

select * from final