{{

    config(
        MATERIALIZED = 'table'
    )
}}

with final as (
    select session_id
    , case when page_views > 0 then 1 else 0 end as page_view_sessions
    , case when add_to_carts > 0 then 1 else 0 end as add_to_cart_sessions
    , case when checkouts > 0 then 1 else 0 end as checkout_sessions
    from {{ ref('int_session_events_agg') }}
)

select * from final