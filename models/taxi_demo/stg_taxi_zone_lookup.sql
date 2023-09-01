select *
from {{ source('jaffle_shop', 'taxi_zone_lookup') }}
