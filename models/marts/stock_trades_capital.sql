with buys as (
    select name,
    SUM(price) AS total_buys
    from {{ source('jaffle_shop', 'stock_trades') }}
    where operation = 'Buy'
    group by name
),

sells as (
    select name,
    SUM(price) AS total_sells
    from {{ source('jaffle_shop', 'stock_trades') }}
    where operation = 'Sell'
    group by name
)

select S.name,
    (S.total_sells - B.total_buys) AS capital_gain_loss,
    B.total_buys, S.total_sells
from buys B
join sells S on B.name = S.name
order by s.total_sells desc