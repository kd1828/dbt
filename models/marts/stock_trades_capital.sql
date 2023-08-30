with
    buys as (
        select name, sum(price) as total_buys
        from {{ source("jaffle_shop", "stock_trades") }}
        where operation = 'Buy'
        group by name
    ),

    sells as (
        select name, sum(price) as total_sells
        from {{ source("jaffle_shop", "stock_trades") }}
        where operation = 'Sell'
        group by name
    )

select
    s.name,
    (s.total_sells - b.total_buys) as capital_gain_loss,
    b.total_buys,
    s.total_sells
from buys b
join sells s using (name)
order by s.total_sells desc