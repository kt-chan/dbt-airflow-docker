with v_orderprodcts as (
    select * from  {{ ref('order_products_union') }}
), v_orders as (
    select * from  {{ ref('clean_orders') }}
), v_products as (
    select * from  {{ source('instacart_raw', 'products') }}
), v_aisles as (
    select * from  {{ source('instacart_raw', 'aisles') }}
), v_departments as (
    select * from  {{ source('instacart_raw', 'departments') }}
)  select 
    t1.order_id,	t1.product_id,	t1.add_to_cart_order,	t1.reordered
    , t2.user_id, t2.order_number, t2.order_dow, t2.order_hour_of_day, t2.days_since_prior_order, t2.days_since_prior_order_cum, t2.order_date
    , t3.product_name, t4.aisle_id, t4.aisle, t5.department_id, t5.department 
    from v_orderprodcts t1
    left join v_orders t2 on t1.order_id = t2.order_id
    left join  v_products t3 on t1.product_id = t3.product_id
    left join  v_aisles t4 on t3.aisle_id = t4.aisle_id
    left join  v_departments t5 on t3.department_id = t5.department_id