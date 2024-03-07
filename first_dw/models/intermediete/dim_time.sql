{{ config(schema='dbt', materialized='table') }}

select
    date_id,
    day_of_week,
    month,
    quarter,
    year
from {{ source('data_warehouse', 'time_dimension') }}
