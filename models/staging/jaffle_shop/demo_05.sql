with raw_product as (

    select * from {{ source('jaffle_shop', 'product') }}

),

raw_doctor as (
        select * from {{ source('jaffle_shop', 'doctors') }}
),

raw_login_details as (
        select * from {{ source('jaffle_shop', 'login_details') }}
),

raw_students as (
        select * from {{ source('jaffle_shop', 'students') }}
)

{#
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
#}

{#
--Solution:

SELECT d1.*
FROM raw_doctor d1
JOIN raw_doctor d2
ON d1.hospital = d2.hospital
and d1.speciality <> d2.speciality 
and d1.id <> d2.id
#}


{#
--Sub Question:

Now find the doctors who work in same hospital irrespective of their speciality.

SELECT d1.*
FROM raw_doctor d1
JOIN raw_doctor d2
ON d1.hospital = d2.hospital
--and d1.speciality <> d2.speciality 
and d1.id <> d2.id
#}

{#
select *,
case when user_name = lead(user_name) over (order by login_id)
and  user_name = lead(user_name,2) over (order by login_id)
then user_name
else null
end as repeated_names
from raw_login_details
#}

{#
SELECT distinct repeated_name
FROM (
      SELECT *,
      CASE WHEN user_name = LEAD(user_name) OVER (ORDER BY login_id)
      and user_name = LEAD(user_name,2) OVER (ORDER BY login_id)
      then user_name
      else null
      end as repeated_name
      FROM raw_login_details
      order by login_id
) x
WHERE x.repeated_name is not null
#}

select *
from raw_students

