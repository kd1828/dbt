with raw_login_details as (
        select * from {{ source('jaffle_shop', 'login_details') }}
),

raw_students as (
        select * from {{ source('jaffle_shop', 'students') }}
)

{#

select *,
case when user_name = lead(user_name) over (order by login_id)
and  user_name = lead(user_name,2) over (order by login_id)
then user_name
else null
end as repeated_names
from raw_login_details

#}

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