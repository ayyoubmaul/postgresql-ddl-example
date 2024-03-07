-- BUSINESS QUESTION
{{ config(schema='mart', materialized='table', alias='mart_revenue_monthly') }}

select
	SUM(quantity * revenue) as total_revenue
    , dt.month
    , dt.year
from {{ ref('fact_sales') }} as fs
left join {{ ref('dim_time') }} as dt on fs.date_id = dt.date_id
group by dt.month, dt.year

-- where dt.month = 'Jan' and dt.year = 2024;
