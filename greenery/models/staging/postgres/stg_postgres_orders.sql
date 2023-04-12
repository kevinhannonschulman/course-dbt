with source as (
    select * from {{source('postgres', 'orders')}}
)

, renamed_recast as (
    select
        shipping_cost
        , address_id
        , tracking_id
        , shipping_service
        , user_id
        , promo_id as promo_desc
        , delivered_at as delivered_at_utc
        , order_total
        , status
        , estimated_delivery_at as estimated_delivery_at_utc
        , order_cost
    from source

select * from renamed_recast

)