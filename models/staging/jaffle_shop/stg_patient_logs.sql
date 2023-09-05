with raw_patient_logs as (
        select * from {{ source('jaffle_shop', 'patient_logs') }}
)

select EXTRACT(MONTH FROM date_visit) as _month,
        date_visit,
        account_id, 
        patient_id
from raw_patient_logs
order by _month