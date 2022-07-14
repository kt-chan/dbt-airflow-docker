select 
cast(order_id as int) as order_id
,	cast(product_id as int) as product_id
,	cast(add_to_cart_order as int) as add_to_cart_order
,	cast( reordered  as boolean) as reordered
from {{ source('instacart_raw', 'order_products') }}
where order_id is not null and  product_id is not null
limit 100000
