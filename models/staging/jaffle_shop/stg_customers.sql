with source as (

    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    ----- source() -------
    select * from {{ source('jaffle_shop', 'raw_customers') }}
    ------- ref() -----
    select * from {{ ref('raw_customers') }}
    #}

    select * from {{ source('jaffle_shop', 'raw_customers') }}

),

renamed as (

    select
        id as customer_id,
        first_name,
        last_name

    from source

)

select * from renamed