with raw_product as (

    select * from {{ source('jaffle_shop', 'product') }}

),

products as (

    select
        id,
        order_id,
        payment_method,
        amount,
        brand,
        product_name,
        price
    from raw_product

)

select *,
first_value(product_name) over w as most_exp_product,
last_value(product_name) over w 
                        as least_exp_product,

from products
window w as (partition by brand order by price desc
            range between unbounded preceding and unbounded following)
