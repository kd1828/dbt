{#
{{
    config (
        materialized = 'incremental'
    )
}}
#}

with source as (

    select * from {{ source('jaffle_shop', 'raw_orders') }}

    {% if is_incremental() %}
        where order_date >= (select max(order_date) from {{ this }})
    {% endif %}

),

renamed as (

    select
        id as order_id,
        user_id as customer_id,
        order_date,
        status

    from source

    {{ limit_data_in_dev(column_name = 'order_date', dev_days_of_data = 1500) }}

)

select * from renamed