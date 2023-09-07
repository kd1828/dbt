with raw_enegery as (

    select * from {{ source("jaffle_shop", "subset_energy_capacity") }}

),

energy as (select * from raw_enegery)

{% set country_code = "FR" %}

select *
from energy
where country = "FR"