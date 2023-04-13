1. How many users do we have?
Answer: 130 users

<details>


```sql

select count(distinct user_id) from dev_db.dbt_kevinhannon95gmailcom.stg_postgres_users 

```

</details>

2. On average, how many orders do we receive per hour?
Answer: 7.52 orders per hour

<details>


```sql

with date_trunc as (
select date_trunc(hour, created_at_utc) as hour_created
count (*) as order_count
from dev_db.dbt_kevinhannon95gmailcom.stg_postgres_orders group by hour_created
)

select avg (order_count) as avg_orders_per_hours from date_trunc

```

</details>

3. On average, how long does an order take from being placed to being delivered?
Answer: 3.89 days

<details>


```sql

select avg(datediff(day, created_at_utc, delivered_at_utc)) from dev_db.dbt_kevinhannon95gmailcom.stg_postgres_orders

```

</details>

4. How many users have only made one purchase? Two purchases? Three+ purchases?
Answer: 1 purchase: 25 users, 2 purchases: 28 users, 3+ purchases: 71 users

<details>


```sql

with order_count as (

select user_id,
count(order_id) as num_orders
from dev_db.dbt_kevinhannon95gmailcom.stg_postgres_orders
group by user_id
)

select num_orders, count(user_id)
from order_count group by num_orders order by num_orders asc

```

</details>

5. On average, how many unique sessions do we have per hour?
Answer: 16.33

<details>


```sql

with unique_sessions as (

select date_trunc(hour, created_at_utc) as hour_created
 , count(distinct(session_id)) as unique_session_count
 from dev_db.dbt_kevinhannon95gmailcom.stg_postgres_events group by hour_created
)

select avg(unique_session_count) from unique_sessions

```

</details>