select *
from stg_postgres_orders
where datediff(day, estimated_delivery_at_utc, delivered_at_utc) > 7