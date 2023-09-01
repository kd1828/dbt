with childstat_count_by_gender as (

    select A.*, count(*) over (partition by A.GENDER order by A.GENDER) as GENDER_COUNTS from {{ source('jaffle_shop','childstat') }} as A

),

childstat_total_of_weight_by_gender as (

    select A.GENDER, A.FIRSTNAME, A.WEIGHT,
            sum(A.WEIGHT) over (partition by A.GENDER order by A.WEIGHT) as WT_RUN from {{ source('jaffle_shop','childstat') }} as A                        

),

childstat_total_of_height_by_gender as (

    select A.*,
            max(A.HEIGHT) over (partition by A.GENDER order by A.GENDER) as MAX_HT from {{ source('jaffle_shop','childstat') }} as A                        

),

childstat_distinct_of_height_by_gender as (

    select A.*,
            count(distinct A.HEIGHT) over (partition by A.GENDER) as DIST_HT from {{ source('jaffle_shop','childstat') }} as A                        

),

childstat_distinct_of_by_gender as (

    select A.*,
            count(distinct A.GENDER) over () as DIST_GENDER from {{ source('jaffle_shop','childstat') }} as A                        

),

childstat_total_weight_by_gender as (

    select A.*,
            count(*) over (partition by A.GENDER, (BIRTHDATE)) as CNT_GBY from {{ source('jaffle_shop','childstat') }} as A                        
                order by A.GENDER, A.BIRTHDATE

),

childstat_row_no_order_by_asceding as (

    select A.*,
            row_number() over (order by A.GENDER) as RNUM from {{ source('jaffle_shop','childstat') }} as A                        

),

childstat_row_no_by_gender as (

    select A.*,
            row_number() over (partition by A.GENDER order by A.BIRTHDATE) as RNUM from {{ source('jaffle_shop','childstat') }} as A                        
                order by A.GENDER, A.BIRTHDATE
)

--select * from childstat_count_by_gender

--select * from childstat_total_of_weight_by_gender

--select * from childstat_total_of_height_by_gender

--select * from childstat_distinct_of_height_by_gender

select * from childstat_row_no_by_gender