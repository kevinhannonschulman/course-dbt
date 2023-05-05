**Part 1. dbt Snapshots**

*1. Which products had their inventory change from week 3 to week 4?*

Answer: Bamboo (decreased from 44 to 23), Monstera (decreased from 50 to 31), Philodendron (increased from 15 to 30), Pothos (increased from 0 to 20), String of Pearls (increased from 0 to 10), ZZ Plant (decreased from 53 to 41)

*2. Now that we have 3 weeks of snapshot data, can you use the inventory changes to determine which products had the most fluctuations in inventory? Did we have any items go out of stock in the last 3 weeks?*

The products that had the most fluctuations in inventory were Monstera, Philodendron, Pothos, String of Pearls (4 fluctuations), Bamboo and ZZ Plant (3 fluctuations). Two products (Pothos and String of Pearls) briefly went out of stock in the last 3 weeks.

**Part 2. Modeling challenge**

*1. How are our users moving through the product funnel?*

|DISTINCT_ADD_TO_CART_SESSIONS|DISTINCT_PAGE_VIEW_SESSIONS|DISTINCT_CHECKOUT_SESSIONS|ADD_TO_CART_RATE|CART_TO_CHECKOUT_RATE|OVERALL_CONVERSION_RATE|
|-----------------------------|---------------------------|--------------------------|----------------|---------------------|-----------------------|
|467                          |578                        |361                       |0.807958        |0.773019             |0.624567               |


<details>


```sql

with sessions_with_event_type as (
    select *
    from {{ ref('int_sessions_with_event_type') }}
)

, final as (
    select sum(add_to_cart_sessions) as distinct_add_to_cart_sessions
    , sum(page_view_sessions) as distinct_page_view_sessions
    , sum(checkout_sessions) as distinct_checkout_sessions
    , sum(add_to_cart_sessions) / sum(page_view_sessions) as add_to_cart_rate
    , sum(checkout_sessions) / sum(add_to_cart_sessions) as cart_to_checkout_rate
    , sum(checkout_sessions) / sum(page_view_sessions) as overall_conversion_rate
    from sessions_with_event_type
)

select * from final

```

</details>

578 sessions resulted in a page view, 467 sessions resulted in the user adding a product to their cart and 361 sessions resulted in the user completing a purchase.

*2. Which steps in the funnel have largest drop off points?*

The largest drop off points in the funnel are between customers adding a product to their cart and successfully checking out (77.3% cart-to-checkout conversion rate) followed by customers viewing a product and then adding it to their cart (80.8% add_to_cart conversion rate).

*3. Use an exposure on your product analytics model to represent that this is being used in downstream BI tools.*

I added the exposure in models/marts/product as _product_exposures.yml.

**Part 3: Reflection questions**

*3A. dbt next steps for you: if you are thinking about moving to analytics engineering, what skills have you picked that give you the most confidence in pursuing this next step?*

Over the past four weeks, the most important skills I've picked up that give me confidence about pursuing analytics engineering are learning the best practices for dimensional modeling in dbt as well as developing my understanding of more advanced features such as macros, snapshots and packages. Aside from technical skills, I've also sharpened my understanding about how to approach business questions using dbt with an emphasis on modeling data in a way that enables different stakeholders to answer their own current questions as well as long-term tracking of business goals so models don't need to be constantly rewritten in the future to answer the same types of questions.

*3B. Setting up for production / scheduled dbt run of your project: how would you go about setting up a production/scheduled dbt run of your project in an ideal state?*

I previously used dbt Cloud for a personal project so I would most likely continue using it to set up a production/scheduled dbt run of this project. Specifically, I like that dbt Cloud already includes functionality such as a scheduler, notifications for failed job runs via email or Slack, and model timing information that would most likely require help from a data engineering team if I needed to build those features from scratch so it would be an ideal solution for a startup or small data team.

I would likely include the following steps for each scheduled run: dbt build (run models, test tests, snapshot snapshots, seed seeds), dbt source freshness (to verify the freshness of source data), and dbt docs generate. I would run all models at least once daily although models with frequent changes (e.g. fluctuating inventory throughout the day) would need to be run much more frequently to stay aware of any potential issues. In terms of metadata, I would be interested in run_results.json, which will provide valuable information about how efficiently my models and tests are performing over time, as well as manifest.json, which would be important for understanding how my project is configured and to track how different models, sources and exposures are interconnected.