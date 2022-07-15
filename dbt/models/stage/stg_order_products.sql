select 
cast(order_id as int) as order_id
,	cast(product_id as int) as product_id
,	cast(add_to_cart_order as int) as add_to_cart_order
,	cast( reordered  as boolean) as reordered
from {{ source('instacart_raw', 'order_products') }}
where product_id is not null
and order_id in (select distinct order_id from {{ ref('stg_orders') }})
