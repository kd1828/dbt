
{%- set country_code = "FR" -%}

with raw_enegery as (

    select * from {{ source("jaffle_shop", "subset_energy_capacity") }}

),

energy as (
    select * from raw_enegery
)

select *
from energy 
--where country = { country_code }