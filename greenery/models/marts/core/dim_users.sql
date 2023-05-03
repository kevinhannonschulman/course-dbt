{{

    config(
        MATERIALIZED = 'table'
    )
}}

with users as (
    select * from {{ ref('stg_postgres_users') }}
)

,addresses as (
    select * from {{ ref('stg_postgres_addresses') }}
)


select
    user_id
    ,first_name
    ,last_name
    ,first_name||' '||last_name as full_name
    ,email
    ,phone_number
    ,created_at_utc
    ,updated_at_utc
    ,address
    ,zip_code
    ,state
    ,country

from users
left join addresses
    on users.address_id = addresses.address_id 