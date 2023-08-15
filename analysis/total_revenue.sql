with payments as (
    
    select * from {{ ref('stg_payments') }}

),

aggregated as (

    select
    sum(amount) as total_revenue

    from payments
    -- where payments_status = 'success'

)

select * from aggregated