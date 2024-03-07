{{ config(schema='dbt', materialized='table') }}

select
    product_id,
    product_name,
    category,
    price
from {{ source('data_warehouse', 'product_dimension') }}
