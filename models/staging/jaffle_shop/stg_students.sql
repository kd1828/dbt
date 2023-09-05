with raw_students as (
        select * from {{ source('jaffle_shop', 'students') }}
)

select *,
case when lead(student_name) over (order by id) is null then student_name
    when mod(id,2) = 1 then lead(student_name) over (order by id)
    when mod(id,2) = 0 then lag(student_name) over (order by id) 
end as new_student_name
from raw_students student
order by id