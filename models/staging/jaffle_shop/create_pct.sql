select 
    YEAR, COUNTRY, SOLAR_CAPACITY, TOTAL_CAPACITY, RENEWABLES_CAPACITY,
    cast(SOLAR_CAPACITY as int64) / cast(TOTAL_CAPACITY as int64) AS SOLAR_PCT,
    cast(RENEWABLES_CAPACITY as int64) / cast(TOTAL_CAPACITY as int64) AS RENEWABLES_PCT
from {{ source("jaffle_shop", "subset_energy_capacity") }}
where TOTAL_CAPACITY is not NULL
    and TOTAL_CAPACITY <> 0
    and SOLAR_CAPACITY <> 0
    and RENEWABLES_CAPACITY <> 0