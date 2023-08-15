with source as (
    
    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ ref('raw_payments') }}

),

renamed as (

    select
        id as payment_id,
        order_id,
        payment_method,
        status,
        -- amount is stored in cents, convert it to dollars
        {{ cents_to_dollars('amount', 4) }} as amount,
        created as created_at
    from source

)

select * from renamed
