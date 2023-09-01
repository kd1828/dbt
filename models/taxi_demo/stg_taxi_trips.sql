select *
from {{ source('jaffle_shop', 'yellow_tripdata_sample_2019_01') }}
