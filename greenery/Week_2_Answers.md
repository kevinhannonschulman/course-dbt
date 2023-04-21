**Part 1. Models**

*1. What is our user repeat rate?* 

Answer: 79.84% repeat rate

<details>


```sql

with orders_cohort as (

    select user_id
    , count(distinct(order_id)) as user_orders
    from dev_db.dbt_kevinhannon95gmailcom.stg_postgres_orders
    group by 1
)

, users_bucket as (

    select
        user_id
        , (user_orders = 1)::int as has_one_purchase
        , (user_orders = 2)::int as has_two_purchases
        , (user_orders = 3)::int as has_three_purchases
        , (user_orders >= 2)::int as has_two_plus_purchases
    from orders_cohort
)

select
    sum(has_one_purchase) as one_purchase
    , sum(has_two_purchases) as two_purchases
    , sum(has_three_purchases) as three_purchases
    , sum(has_two_plus_purchases) as two_plus_purchases
    , count(distinct user_id) as num_users_w_purchase
    , div0(two_plus_purchases, num_users_w_purchase) as repeat_rate
from users_bucket

```

</details>

*2. What are good indicators of a user who will likely purchase again? What about indicators of users who are likely NOT to purchase again? If you had more data, what features would you want to look into to answer this question?*

Good indicators of a user who will likely purchase again would be the user's total number of orders because multiple orders probably indicates that they will make more purchases in the future. Additionally, another useful indicator would be the user's distribution of event_type because a user who frequently adds an item to their cart and proceeds to checkout would be more likely to purchase again than a customer who merely views different products without going further.

Indicators of a user likely not to purchase again may include the use of a promo_id because this could indicate that the user was targeted by a promotional offer and so might only make one purchase instead of being a recurring customer. Additionally, a lower order total might indicate that the customer is trying the brand for the first time and may not order again versus a customer placing a larger order. 

If we had more data, I would be particularly interested in return rate because this would be predictive of whether a customer is happy with their purchase and are likely to make a future order.  Additionally, if Greenery added a subscription model in addition to standalone orders, a user adding a subscription would definitely be more likely to purchase again because they are actually signing up for a recurring order.

*3. Explain the product mart models you added. Why did you organize the models in the way you did?*

I created 4 intermediate models primarily focused on aggregating different metrics such as page views and orders by joining different staging tables. int_session_events_agg is an aggregation of session events (e.g. add_to_cart, page_view) grouped by user_id and session_id. int_daily_views_per_product counts the total daily number of page views per product per day. Finally, int_page_views_per_product counts the total number of page views per product_id while int_orders_per_product counts the total number of orders per product_id.

I created 2 fact models, fct_page_views and fct_conversion_rate. I created fct_page_views by joining int_session_events_agg with stg_postgres_users to build upon the intermediate model by adding user information (e.g. first_name,email) as well as the duration of each session. I created fct_conversion_rate to find out which products are receiving a lot of traffic but are not converting into actual purchases. fct_conversion_rate joins two intermediate tables (int_page_views_per_product, int_orders_per_product) as well as stg_postgres_products to produce the conversion rate by dividing orders and page views.

I organized the models in the way I did because each intermediate model produces business logic that could be reusable in future fact models. For example, the number of daily views per product will likely vary depending on the items being sold and seasonal trends so it makes sense to have a reusable model to produce that information rather than starting from scratch each time. In terms of fact models, both models describe events such as total views and orders per product, conversion rate, session events (e.g. add_to_cart, checkout) and session duration that can then be brought into BI tools for business users to analyze.

**Part 2. Tests**

*1. What assumptions are you making about each model? (i.e. why are you adding each test?)*

I created a singular test, valid_delivery_date.sql, that assumes that there are no instances of delivered_at_utc being earlier than created_at_utc because that would mean that the order was delivered before it was placed. Also, I created another singular test that runs a datediff between the estimated delivery date and actual delivery date on stg_postgres_orders and checks if there's a difference of greater than one week. If that test failed, it could indicate that an order was lost during shipping which could then be passed along to a customer service team for follow-up.

Regarding generic tests, I mainly used the unique and not_null tests on id columns (e.g. user_id, order_id) because these values should always be present in each table and should also be unique. Additonally, I used generic relationship tests to ensure a correct relation between the same column in different tables. For example, order_id in stg_postgres_orders should have a match in stg_postgres_events as the customer moves through the product funnel. In my fact models, I used the positive_values test for values that should never be less than zero such as total_views, total_orders and conversion_rate.

*2. Did you find any “bad” data as you added and ran tests on your models? How did you go about either cleaning the data in the dbt model or adjusting your assumptions/tests?*

I received an error for the not_null test on my tracking_id column in my stg_postgres_orders table which was surprising because I assumed that every order would have a unique tracking id. However, upon looking at the data, I found that orders that are still being prepared do not yet have a tracking number which explains why some orders had a null value for tracking_id. I also assumed that order_id and product_id would be unique in stg_postgres_events but different site events (e.g. checkout, package_shipped) for the same order are connected by the same order_id and product_id so the test failed on those events. It also looks like there are 9 entries in stg_postgres_orders with the same tracking_id while I assumed that every order would have a unique tracking_id although perhaps those orders have multiple boxes for one shipment with all sharing the same tracking_id.

Additionally, I used a relationships test between address_id from stg_postgres_addresses to stg_postgres_users but received 61 errors which probably indicates that stg_postgres_users consists of users who have registered their information on the site while stg_postgres_addresses likely encompasses everyone who has ordered, registered or not, thus the disparity.  Similarly, I thought address_id would be unique in stg_postgres_users but that test also produced an error which likely means that multiple users are ordering from the same address.

*3. Your stakeholders at Greenery want to understand the state of the data each day. Explain how you would ensure these tests are passing regularly and how you would alert stakeholders about bad data getting through.*

I would ensure that tests are passing regularly by scheduling a dbt test after every scheduled dbt run (at least once per day if not more frequent) and creating an alert system using Slack every time a test failed so stakeholders would be immediately aware about bad data getting through and the analytics engineering team could quickly resolve the problem.

**Part 3. dbt Snapshots**

*1. Which products had their inventory change from week 1 to week 2?*

Answer: Pothos (decreased from 40 to 20), Philodendron (decreased from 51 to 25), Monstera (decreased from 77 to 64), String of Pearls (decreased from 58 to 10)