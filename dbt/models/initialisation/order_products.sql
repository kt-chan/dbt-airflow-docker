with v_orderprodcts as (
    select *
    from {{ source('instacart_raw_data', 'order_products__prior') }}
    UNION 
    select *
    from {{ source('instacart_raw_data', 'order_products__train') }}
), v_products as (
    select * from  {{ source('instacart_raw_data', 'products') }}
), v_aisles as (
    select * from  {{ source('instacart_raw_data', 'aisles') }}
), v_departments as (
    select * from  {{ source('instacart_raw_data', 'departments') }}
) select t1.*, t2.product_name, t3.aisle_id, t3.aisle, t4.department_id, t4.department 
    from v_orderprodcts t1
    left join  v_products t2 on t1.product_id = t2.product_id
    left join  v_aisles t3 on t2.aisle_id = t3.aisle_id
    left join  v_departments t4 on t2.department_id = t4.department_id