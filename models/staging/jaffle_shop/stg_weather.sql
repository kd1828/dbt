with raw_weather as (

    select * from {{ source('jaffle_shop', 'weather') }}

)

select id, city, temperature, day
from (
        select *,
        case when temperature < 0
                    and lead(temperature) over (order by id) < 0
                    and lead(temperature,2) over (order by id) < 0
                then 'Yes'
            when temperature < 0
                    and lag(temperature) over (order by id) < 0
                    and lead(temperature) over (order by id) < 0
                then 'Yes'
            when temperature < 0
                    and lag(temperature) over (order by id) < 0
                    and lag(temperature,2) over (order by id) < 0
                then 'Yes'
        end as consecutive_3_days_cold_temp
        from raw_weather
        order by id
) as result
where result.consecutive_3_days_cold_temp = 'Yes