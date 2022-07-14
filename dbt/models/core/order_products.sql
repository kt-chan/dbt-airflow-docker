{{
    config(
        materialized='incremental',
        file_format='hudi',
        incremental_strategy='merge',
        options={
            'type': 'cow',
            'precombineKey': 'order_date',
        },
        unique_key='order_id,product_id'
    )
}}


with v_orders as (
    select * from  {{ ref('stg_orders') }}
), v_orderprodcts as (
    select  * from {{ ref('stg_order_products') }}
), v_products as (
    select * from  {{ source('instacart_raw', 'products') }}
), v_aisles as (
    select * from  {{ source('instacart_raw', 'aisles') }}
), v_departments as (
    select * from  {{ source('instacart_raw', 'departments') }}
)  select 
    t1.order_id, t1.user_id, t1.order_number, t1.order_dow, t1.order_hour_of_day, t1.days_since_prior_order, t1.days_since_prior_order_cum, t1.order_date
    , t2.product_id,	t2.add_to_cart_order,	t2.reordered
    , t3.product_name
    , t4.aisle_id, t4.aisle, t5.department_id, t5.department 
    from v_orders t1
    left join v_orderprodcts t2 on t1.order_id = t2.order_id
    left join  v_products t3 on t2.product_id = t3.product_id
    left join  v_aisles t4 on t3.aisle_id = t4.aisle_id
    left join  v_departments t5 on t3.department_id = t5.department_id