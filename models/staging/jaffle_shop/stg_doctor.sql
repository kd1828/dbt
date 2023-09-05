with raw_doctor as (
        select * from {{ source('jaffle_shop', 'doctors') }}
)


{#
--Solution:

SELECT d1.*
FROM raw_doctor d1
JOIN raw_doctor d2
ON d1.hospital = d2.hospital
and d1.speciality <> d2.speciality 
and d1.id <> d2.id
#}

--Sub Question:
--Now find the doctors who work in same hospital irrespective of their speciality.

SELECT d1.*
FROM raw_doctor d1
JOIN raw_doctor d2
ON d1.hospital = d2.hospital
--and d1.speciality <> d2.speciality 
and d1.id <> d2.id