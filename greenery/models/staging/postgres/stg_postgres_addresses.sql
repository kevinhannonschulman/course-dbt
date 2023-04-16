with source as (
    select * from {{ source('postgres', 'addresses') }}
)

, final as (
    SELECT
        address_id
        , address
        , state
        , lpad(zipcode, 5, 0) as zip_code
        , country
    from source
)

select * from final