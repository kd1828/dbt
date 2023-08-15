{#-
select * from {{ source('snowplow', 'events') }}

{{ limit_data_in_dev(column_name='order_data', dev=1000) }}
#}
