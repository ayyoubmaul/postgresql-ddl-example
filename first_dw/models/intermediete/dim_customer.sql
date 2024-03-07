{{ config(schema='dbt', materialized='table') }}

select
    customer_id,
    customer_name,
    email,
    phone_number
from {{ source('data_warehouse', 'customer_dimension') }}
