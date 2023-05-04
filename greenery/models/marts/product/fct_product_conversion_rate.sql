{{

    config(
        MATERIALIZED = 'table'
    )
}}

with unique_sessions_per_product as (
    select * from {{ ref('int_unique_session_type_per_product') }}
)

, final as (
    select name
    , distinct_page_view_sessions
    , distinct_checkout_sessions
    , distinct_checkout_sessions / distinct_page_view_sessions as conversion_rate
    from unique_sessions_per_product
)

select * from final