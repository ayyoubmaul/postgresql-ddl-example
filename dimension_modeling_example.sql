create schema store_trans;

CREATE TABLE store_trans.pos_sales (
	sale_id INT PRIMARY KEY,
	product_id INT,
	sale_date DATE,
	sale_time TIME,
	sale_amount DECIMAL(10, 2),
	store_id INT,
	register_id INT,
	cashier_id INT
);

CREATE TABLE store_trans.pos_products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(50),
    price DECIMAL(10, 2),
    supplier_id INT
);

CREATE TABLE store_trans.pos_stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(50),
    store_location VARCHAR(50)
);

create table pos_revenue (
	revenue_id INT,
	total_revenue DECIMAL(50, 2),
)

-- POS SALES
insert into store_trans.pos_sales values (1, 2, '2024-01-01', '07:00:00', 100.0, 1, 1, 1);
insert into store_trans.pos_sales values (2, 1, '2024-01-02', '08:00:00', 105.0, 1, 1, 1);

-- POS PRODUCTS
insert into store_trans.pos_products values (1, 'Mobil', 'Roda Empat', 1000000.0, 1);
insert into store_trans.pos_products values (2, 'Motor', 'Roda Dua', 12000.0, 1);

-- POS STORES
insert into store_trans.pos_stores values (1, 'A', 'Jakarta');
insert into store_trans.pos_stores values (2, 'B', 'Jogja');


------ DIMENSIONAL MODELING ----

CREATE TABLE store_trans.fact_sales (
  sale_id INT PRIMARY KEY,
  date_key INT,
  product_key INT,
  store_key INT,
  customer_key INT,
  sale_amount DECIMAL(10, 2),
  register_id INT,
  cashier_id INT,
  revenue DECIMAL(10, 2)
);


/**
insert into store_trans.fact_sales as
select 
	* 
	, total_revenue + (sales_amount * 10%) as revenue
from pos_sales
LEFT JOIN pos_revenue;
**/

insert into store_trans.fact_sales values (1, 1, 1, 1, 1, 100.0, 1, 1, 200.0);
insert into store_trans.fact_sales values (2, 2, 2, 2, 2, 105.0, 2, 2, 105);


CREATE TABLE dim_product (
  product_key INT PRIMARY KEY,
  product_name VARCHAR(50),
  category VARCHAR(50),
  price DECIMAL(10, 2),
  supplier_id INT
);


insert into store_trans.dim_product values (1, 'Mobil', 'Roda Empat', 1000000.0, 1);
insert into store_trans.dim_product values (2, 'Motor', 'Roda Dua', 12000000, 1);


CREATE TABLE dim_store (
  store_key INT PRIMARY KEY,
  store_name VARCHAR(50),
  store_location VARCHAR(50)
);

insert into store_trans.dim_store values (1, 'A', 'Jakarta');
insert into store_trans.dim_store values (2, 'B', 'Jogja');


--- DATA MART MARKETING --
-- how many revenue per stores

create table mart_marketing.mart_marketing_revenue (
	store_name VARCHAR(50),
	revenue DECIMAL(10, 2)
);

-- insert into table 
insert into mart_marketing.mart_marketing_revenue (
select 
	store_name,
	sum(revenue) as total_revenue
from fact_sales fs2 
left join dim_store ds on fs2.store_key = ds.store_key 
group by store_name);
