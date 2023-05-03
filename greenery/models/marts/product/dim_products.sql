with products as (
    select * from {{ ref('stg_postgres_products') }}
)

, final as (
    select product_id
    , name
    , price
    , inventory
    from products
)

select * from final