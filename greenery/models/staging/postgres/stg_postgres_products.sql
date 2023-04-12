with source as (
    select * from {{ source('postgres', 'products') }}
)

, renamed_recast as (
    select
        product_id
        , name
        , price
        , inventory
    from source
)

select * from renamed_recast