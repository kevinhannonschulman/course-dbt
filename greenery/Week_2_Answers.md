**Part 1. Models**

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

**Part 2. Tests**

Did you find any “bad” data as you added and ran tests on your models? How did you go about either cleaning the data in the dbt model or adjusting your assumptions/tests?

I received an error for the not_null test on my tracking_id column in my stg_postgres_orders table which was surprising because I assumed that every order would have a unique tracking id. However, upon looking at the data, I found that orders that are still being prepared do not yet have a tracking number which explains why some orders had a null value for tracking_id. I also assumed that order_id and product_id would be unique in stg_postgres_events but different site events (e.g. checkout, package_shipped) for the same order are connected by the same order_id and product_id so the test failed on those events. It also looks like there are 9 entries in stg_postgres_orders with the same tracking_id while I assumed that every order would have a unique tracking_id although perhaps those orders have multiple boxes for one shipment with all sharing the same tracking_id.

Additionally, I used a relationships test between address_id from stg_postgres_addresses to stg_postgres_users but received 61 errors which probably indicates that stg_postgres_users consists of users who have registered their information on the site while stg_postgres_addresses likely encompasses everyone who has ordered, registered or not, hence the disparity.  Similarly, I thought address_id would be unique in stg_postgres_users but that test also produced an error which likely means that multiple users are ordering from the same address.