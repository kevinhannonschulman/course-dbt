**Part 1: Create new models to answer the first two questions**

*1. What is our overall conversion rate?* Answer: 62.45%

<details>


```sql

with events_distinct_session_type as (

    select session_id
    , MAX(case when checkouts > 0 then 1 else 0 end) as checkouts
    , MAX(case when page_views > 0 then 1 else 0 end) as page_views
    from {{ ref('int_session_events_agg') }}
    group by session_id
)

, agg as (

    select sum(events_distinct_session_type.page_views) as num_views
    , sum(events_distinct_session_type.checkouts) as num_checkouts
    from events_distinct_session_type

)

, final as (
    select num_views
    , num_checkouts
    , (num_checkouts / num_views) as overall_conversion_rate
    from agg
)

select * from final

```

</details>

*2. What is our conversion rate by product?*

| NAME                | TOTAL_VIEWS | TOTAL_ORDERS | CONVERSION_RATE |
|---------------------|-------------|--------------|-----------------|
| Pothos              | 61          | 21           | 0.344262        |
| Bamboo              | 67          | 36           | 0.537313        |
| Philodendron        | 62          | 30           | 0.483871        |
| Monstera            | 49          | 25           | 0.510204        |
| String of pearls    | 64          | 39           | 0.609375        |
| ZZ Plant            | 63          | 34           | 0.539683        |
| Snake Plant         | 73          | 29           | 0.397260        |
| Orchid              | 75          | 34           | 0.453333        |
| Birds Nest Fern     | 78          | 33           | 0.423077        |
| Calathea Makoyana   | 53          | 27           | 0.509434        |
| Peace Lily          | 66          | 27           | 0.409091        |
| Bird of Paradise    | 60          | 27           | 0.450000        |
| Fiddle Leaf Fig     | 56          | 28           | 0.500000        |
| Ficus               | 68          | 29           | 0.426471        |
| Pilea Peperomioides | 59          | 28           | 0.474576        |
| Angel Wings Begonia | 61          | 24           | 0.393443        |
| Jade Plant          | 46          | 22           | 0.478261        |
| Arrow Head          | 63          | 35           | 0.555556        |
| Majesty Palm        | 67          | 33           | 0.492537        |
| Spider Plant        | 59          | 28           | 0.474576        |
| Money Tree          | 56          | 26           | 0.464286        |
| Cactus              | 55          | 30           | 0.545455        |
| Devil's Ivy         | 45          | 22           | 0.488889        |
| Alocasia Polly      | 51          | 21           | 0.411765        |
| Pink Anthurium      | 74          | 31           | 0.418919        |
| Dragon Tree         | 62          | 29           | 0.467742        |
| Aloe Vera           | 65          | 32           | 0.492308        |
| Rubber Plant        | 54          | 28           | 0.518519        |
| Ponytail Palm       | 70          | 28           | 0.400000        |
| Boston Fern         | 63          | 26           | 0.412698        |

<details>


```sql

with orders as (

    select product_id
    , total_orders
    from {{ ref('int_orders_per_product') }}
)

, page_views as (

    select product_id
    , total_views
    from {{ ref('int_page_views_per_product') }}
)

, products as (

    select product_id, name
    from {{ ref('stg_postgres_products')}}
)

select products.name
    , page_views.total_views
    , orders.total_orders
    , (orders.total_orders / page_views.total_views) as conversion_rate
from page_views
left join orders on page_views.product_id = orders.product_id
left join products on page_views.product_id = products.product_id

```

</details>

*3. Why might certain products be converting at higher/lower rates than others?*

I think price is likely a key determinant of whether a customer actually makes a purchase. For example, products with higher prices will probably have lower conversion rates because there will probably be fewer people who are able and willing to buy a more expensive item than a cheaper item. Similarly, products that are sold at competing stores might have lower conversion rates as customers shop around to find the best price for that particular item. Also, if the website has a review mechanism, negative reviews of a product would likely lead to a lower conversion rate as well.

**Part 2: Create a macro to simplify part of a model(s)**



**Part 6: dbt Snapshots**

*1. Which products had their inventory change from week 2 to week 3?*

Answer: Pothos (decreased from 20 to 0), Philodendron (decreased from 25 to 15), Bamboo (decreased from 56 to 44), ZZ Plant (decreased from 89 to 53), Monstera (decreased from 64 to 50), String of Pearls (decreased from 10 to 0)