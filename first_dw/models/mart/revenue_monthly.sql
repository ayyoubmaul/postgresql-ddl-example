-- BUSINESS QUESTION
{{ config(schema='mart', materialized='table', alias='mart_revenue_monthly') }}

select
	SUM(quantity * revenue) as total_revenue
    , dt.month
    , dt.year
    , dp.product_name
from {{ ref('fact_sales') }} as fs
left join {{ ref('dim_time') }} as dt on fs.date_id = dt.date_id
left join {{ ref('dim_product') }} as dp on dp.product_id = fs.product_id
group by dt.month, dt.year, dp.product_name

-- where dt.month = 'Jan' and dt.year = 2024;
