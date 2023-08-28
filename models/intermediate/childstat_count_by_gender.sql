with childstat_count_by_gender as (

    select GENDER, count(*) as GENDER_COUNTS from {{ source('jaffle_shop','childstat') }}
    group by GENDER
)

select * from childstat_count_by_gender