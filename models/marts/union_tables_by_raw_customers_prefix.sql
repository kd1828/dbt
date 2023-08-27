{#
union records in all tables which have same prefix
#}

{{ union_tables_by_prefix(
      database='dbt-tutorial-395913',
      schema='jaffle_shop', 
      prefix='raw_customers' 
      )
}}