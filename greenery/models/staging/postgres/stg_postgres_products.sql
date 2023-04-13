with source as (
    select * from {{ source('postgres', 'products') }}
)

, final as (
    select
        product_id
        , name
        , price
        , inventory
    from source
)

select * from final