select *
from stg_postgres_orders
where delivered_at_utc < created_at_utc