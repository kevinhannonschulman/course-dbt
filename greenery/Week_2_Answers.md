1. What is our user repeat rate? 99/124 = 79.83% repeat rate

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

2. What are good indicators of a user who will likely purchase again? What about indicators of users who are likely NOT to purchase again? If you had more data, what features would you want to look into to answer this question?

Good indicators of a user who will likely purchase again would be the user's total number of orders because multiple orders probably indicates that they will make more purchases in the future. Additionally, another useful indicator would be the user's distribution of event_type because a user who frequently adds an item to their cart and proceeds to checkout would be more likely to purchase again than a customer who merely views different products without going further.

Indicators of a user likely not the purchase again may include the use of a promo_id because this could indicate that the user was targeted by a promotional offer and so might only make one purchase instead of being a recurring customer. Additionally, a lower order total might indicate that the customer is trying the brand for the first time and may not order again versus a customer placing a larger order. 

If we had more data, I would be particularly interested in return rate because this would be predictive of whether a customer is happy with their purchase and are likely to make a future order.  Additionally, if Greenery added a subscription model in addition to standalone orders, a user adding a subscription would definitely be more likely to purchase again because they are actually signing up for a recurring order.