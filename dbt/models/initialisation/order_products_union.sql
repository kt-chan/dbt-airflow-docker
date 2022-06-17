with v_orderprodcts as (
    select *
    from {{ source('instacart_raw', 'order_products__prior') }}
    UNION 
    select *
    from {{ source('instacart_raw', 'order_products__train') }}
) select *
    from v_orderprodcts 