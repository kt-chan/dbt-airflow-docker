with initial_dates as (
    -- Initialise with Monday, Jan 6th 2022 as the first day
    select *
    , COALESCE(days_since_prior_order, 0) as days_since_prior_order_v2
    -- Randomize the day of the first order
    , case order_number
        when 1 then timestamp '2020-01-01 00:00:00' + (round(random()) * 5 * INTERVAL '1 week') + INTERVAL '1 day' * order_dow + INTERVAL '1 hour' * order_hour_of_day
    end as random_date_v2
    from {{ source('instacart_raw', 'orders') }}
),
cumulative_dates as (
    select *
    , sum(days_since_prior_order_v2) over ( partition by user_id ORDER BY user_id asc, order_number ASC) as days_since_prior_order_cum
    , FIRST_VALUE(random_date_v2) OVER (PARTITION BY user_id ORDER BY order_number ASC ) as first_order 
    from initial_dates
)
select 
    cast(order_id as int)
    , cast(user_id as int)
    , cast(order_number as int)
    , cast(order_dow as int)
    , cast(order_hour_of_day as int)
    , days_since_prior_order 
    , days_since_prior_order_cum 
    , date_trunc('day', first_order + days_since_prior_order_cum * INTERVAL '1 day') + ( order_hour_of_day * INTERVAL '1 hour' ) as order_date
from cumulative_dates
where order_id is not null
limit 100000