**Part 1: Create new models to answer the first two questions**

*1. What is our overall conversion rate?* Answer: 62.45%

<details>


```sql

with events_distinct_session_type as (

    select count(distinct(session_id))
    , sum(case when checkouts > 0 then 1 else 0 end) as checkouts
    , sum(case when page_views > 0 then 1 else 0 end) as page_views
    from {{ ref('int_session_events_agg') }}
    group by session_id
)

, agg as (

    select sum(events_distinct_session_type.page_views) as distinct_view_sessions
    , sum(events_distinct_session_type.checkouts) as distinct_checkout_sessions
    from events_distinct_session_type

)

, final as (
    select distinct_view_sessions
    , distinct_checkout_sessions
    , (distinct_checkout_sessions / distinct_view_sessions) as overall_conversion_rate
    from agg
)

select * from final

```

</details>

*2. What is our conversion rate by product?*

| NAME                | DISTINCT_PAGE_VIEW_SESSIONS | DISTINCT_ORDER_SESSIONS | CONVERSION_RATE |
|---------------------|-----------------------------|-------------------------|-----------------|
| Pothos              | 61                          | 21                      | 0.344262        |
| Bamboo              | 67                          | 36                      | 0.537313        |
| Philodendron        | 62                          | 30                      | 0.483871        |
| Monstera            | 49                          | 25                      | 0.510204        |
| String of pearls    | 64                          | 39                      | 0.609375        |
| ZZ Plant            | 63                          | 34                      | 0.539683        |
| Snake Plant         | 73                          | 29                      | 0.397260        |
| Orchid              | 75                          | 34                      | 0.453333        |
| Birds Nest Fern     | 78                          | 33                      | 0.423077        |
| Calathea Makoyana   | 53                          | 27                      | 0.509434        |
| Peace Lily          | 66                          | 27                      | 0.409091        |
| Bird of Paradise    | 60                          | 27                      | 0.450000        |
| Fiddle Leaf Fig     | 56                          | 28                      | 0.500000        |
| Ficus               | 68                          | 29                      | 0.426471        |
| Pilea Peperomioides | 59                          | 28                      | 0.474576        |
| Angel Wings Begonia | 61                          | 24                      | 0.393443        |
| Jade Plant          | 46                          | 22                      | 0.478261        |
| Arrow Head          | 63                          | 35                      | 0.555556        |
| Majesty Palm        | 67                          | 33                      | 0.492537        |
| Spider Plant        | 59                          | 28                      | 0.474576        |
| Money Tree          | 56                          | 26                      | 0.464286        |
| Cactus              | 55                          | 30                      | 0.545455        |
| Devil's Ivy         | 45                          | 22                      | 0.488889        |
| Alocasia Polly      | 51                          | 21                      | 0.411765        |
| Pink Anthurium      | 74                          | 31                      | 0.418919        |
| Dragon Tree         | 62                          | 29                      | 0.467742        |
| Aloe Vera           | 65                          | 32                      | 0.492308        |
| Rubber Plant        | 54                          | 28                      | 0.518519        |
| Ponytail Palm       | 70                          | 28                      | 0.400000        |
| Boston Fern         | 63                          | 26                      | 0.412698        |

<details>


```sql

with orders as (

    select product_id
    , distinct_order_sessions
    from {{ ref('int_distinct_order_sessions_per_product') }}
)

, page_views as (

    select product_id
    , distinct_page_view_sessions
    from {{ ref('int_distinct_page_view_sessions_per_product') }}
)

, products as (

    select product_id, name
    from {{ ref('stg_postgres_products')}}
)

select products.name
    , page_views.distinct_page_view_sessions
    , orders.distinct_order_sessions
    , (orders.distinct_order_sessions / page_views.distinct_page_view_sessions) as conversion_rate
from page_views
left join orders on page_views.product_id = orders.product_id
left join products on page_views.product_id = products.product_id

```

</details>

*3. Why might certain products be converting at higher/lower rates than others?*

I think price is likely a key determinant of whether a customer actually makes a purchase. For example, products with higher prices will probably have lower conversion rates because there will probably be fewer people who are able and willing to buy a more expensive item than a cheaper item. Similarly, products that are sold at competing stores might have lower conversion rates as customers shop around to find the best price for that particular item. Also, if the website has a review mechanism, negative reviews of a product would likely lead to a lower conversion rate as well.

**Part 2: Create a macro to simplify part of a model(s)**

I created and documented a macro to aggregate event types per session when each event_type is passed through the macro to simplify the repetitive 'case when' statement that I previously used in int_session_events_agg.

**Part 3: Add a post hook to your project to apply grants to the role “reporting”.**

Added!

**Part 4: Install a package (i.e. dbt-utils, dbt-expectations) and apply one or more of the macros to your project**

I installed dbt-utils and dbt-expectations and used multiple macros. Specifically, I used dbt_utils.accepted_range in my intermediate and fact .yml files to validate that certain columns only contained values greater than zero and I used dbt_utils.get_column_values in a Jinja expression in int_session_events_agg to set environment variables. I also used dbt_expectations.expect_column_values_to_be_of_type in my intermediate and fact .yml files to confirm the data type of columns that should contain timestamp_ntz data. Lastly, I created a macro, event_type_sums, to aggregate event types per session when each event_type is passed through the macro.

**Part 5: Show (using dbt docs and the model DAGs) how you have simplified or improved a DAG using macros and/or dbt packages.**

I improved my DAG by utilizing the macros within packages such as dbt_utils and dbt_expectations to verify accepted ranges and data types within my intermediate and fact models. Additionally, I created a macro to aggregate event types per session which simplifies the repetitive 'case when' statement that I previously used in int_session_events_agg.

**Part 6: dbt Snapshots**

*1. Which products had their inventory change from week 2 to week 3?*

Answer: Pothos (decreased from 20 to 0), Philodendron (decreased from 25 to 15), Bamboo (decreased from 56 to 44), ZZ Plant (decreased from 89 to 53), Monstera (decreased from 64 to 50), String of Pearls (decreased from 10 to 0)