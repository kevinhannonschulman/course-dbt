with source as (
    select * from {{ source('postgres', 'events') }}
)

, final as (
    select
        event_id
        , session_id
        , user_id
        , event_type
        , page_url
        , created_at as created_at_utc
        , order_id
        , product_id
    from source
)

select * from final