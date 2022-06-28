{{
    config(
        materialized='incremental',
        file_format='hudi',
        unique_key='order_id,product_id'
    )
}}



with v_orderprodcts as (
    select *
    from {{ source('instacart_raw', 'order_products__prior') }}
    UNION 
    select *
    from {{ source('instacart_raw', 'order_products__train') }}
) select 
    cast(t1.order_id as int)
,	cast(t1.product_id as int)
,	cast(t1.add_to_cart_order as int)
,	cast( t1.reordered  as boolean)
    from v_orderprodcts t1
where order_id is not null and  product_id is not null 