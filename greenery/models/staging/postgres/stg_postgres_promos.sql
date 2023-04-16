with source as (
    select * from {{ source('postgres', 'promos') }}
)

, final as (
    select
        promo_id as promo_desc
        , discount
        , status
    from source
)

select * from final