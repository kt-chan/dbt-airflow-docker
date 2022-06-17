with v_orderprodcts as (
    select * from  {{ ref('order_products_union') }}
), v_products as (
    select * from  {{ source('instacart_raw', 'products') }}
), v_aisles as (
    select * from  {{ source('instacart_raw', 'aisles') }}
), v_departments as (
    select * from  {{ source('instacart_raw', 'departments') }}
) select t1.*, t2.product_name, t3.aisle_id, t3.aisle, t4.department_id, t4.department 
    from v_orderprodcts t1
    left join  v_products t2 on t1.product_id = t2.product_id
    left join  v_aisles t3 on t2.aisle_id = t3.aisle_id
    left join  v_departments t4 on t2.department_id = t4.department_id