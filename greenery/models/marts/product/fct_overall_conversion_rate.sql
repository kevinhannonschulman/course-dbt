{{

    config(
        MATERIALIZED = 'table'
    )
}}

with events_distinct_session_type as (

    select session_id
    , MAX(case when checkouts > 0 then 1 else 0 end) as checkouts
    , MAX(case when page_views > 0 then 1 else 0 end) as page_views
    from {{ ref('int_session_events_agg') }}
    group by session_id
)

, agg as (

    select sum(events_distinct_session_type.page_views) as num_views
    , sum(events_distinct_session_type.checkouts) as num_checkouts
    from events_distinct_session_type

)

, final as (
    select num_views
    , num_checkouts
    , (num_checkouts / num_views) as overall_conversion_rate
    from agg
)

select * from final