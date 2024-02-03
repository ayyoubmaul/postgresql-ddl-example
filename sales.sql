-- DATA SOURCE --

CREATE TABLE pos_sales (
sale_id INT PRIMARY KEY,
product_id INT,
sale_date DATE,
sale_time TIME,
sale_amount DECIMAL(10, 2),
store_id INT,
register_id INT,
cashier_id INT
);

CREATE TABLE pos_products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(50),
    price DECIMAL(10, 2),
    supplier_id INT
);

CREATE TABLE pos_stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(50),
    store_location VARCHAR(50)
);

CREATE TABLE crm_customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    email VARCHAR(50),
    phone VARCHAR(50),
    address VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    zip_code VARCHAR(10)
);

CREATE TABLE crm_sales (
    sale_id INT PRIMARY KEY,
    customer_id INT,
    sale_amount DECIMAL(10, 2),
    product_id INT
);


-- DATA MODELING --
-- dim_date create table
CREATE TABLE dim_date (
  date_key INTEGER PRIMARY KEY,
  date DATE NOT NULL,
  day_of_week INTEGER NOT NULL,
  week INTEGER NOT NULL,
  month INTEGER NOT NULL,
  quarter INTEGER NOT NULL,
  year INTEGER NOT NULL
);

-- dim_date populate
INSERT INTO dim_date (date_key, date, day_of_week, week, month, quarter, year)
SELECT 
  TO_CHAR(sale_date, 'YYYYMMDD')::integer AS date_key,
  sale_date AS date,
  EXTRACT(DOW FROM sale_date) AS day_of_week,
  EXTRACT(WEEK FROM sale_date) AS week,
  EXTRACT(MONTH FROM sale_date) AS month,
  EXTRACT(QUARTER FROM sale_date) AS quarter,
  EXTRACT(YEAR FROM sale_date) AS year
FROM (
  SELECT DISTINCT sale_date
  FROM pos_sales
) AS subquery;


select * from dim_date;

-- Create the dim_product dimension table
CREATE TABLE dim_product (
  product_key INT PRIMARY KEY,
  product_name VARCHAR(50),
  category VARCHAR(50),
  price DECIMAL(10, 2),
  supplier_id INT
);

-- Populate the dim_product dimension table with data
INSERT INTO dim_product (product_key, product_name, category, price, supplier_id)
SELECT 
  product_id AS product_key,
  product_name,
  category,
  price,
  supplier_id
FROM pos_products;

-- Create the dim_store dimension table
CREATE TABLE dim_store (
  store_key INT PRIMARY KEY,
  store_name VARCHAR(50),
  store_location VARCHAR(50)
);

-- Populate the dim_store dimension table with data
INSERT INTO dim_store (store_key, store_name, store_location)
SELECT 
  store_id AS store_key,
  store_name,
  store_location
FROM pos_stores;


-- Create the dim_customer dimension table
CREATE TABLE dim_customer (
  customer_key INT PRIMARY KEY,
  customer_name VARCHAR(50),
  email VARCHAR(50),
  phone VARCHAR(50),
  address VARCHAR(100),
  city VARCHAR(50),
  state VARCHAR(50),
  zip_code VARCHAR(10)
);

-- Populate the dim_customer dimension table with data
INSERT INTO dim_customer (customer_key, customer_name, email, phone, address, city, state, zip_code)
SELECT 
  customer_id AS customer_key,
  customer_name,
  email,
  phone,
  address,
  city,
  state,
  zip_code
FROM crm_customers;

-- Create the fact_sales fact table
CREATE TABLE fact_sales (
  sale_id INT PRIMARY KEY,
  date_key INT,
  product_key INT,
  store_key INT,
  customer_key INT,
  sale_amount DECIMAL(10, 2),
  register_id INT,
  cashier_id INT,
  revenue DECIMAL(10, 2),
  FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
  FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
  FOREIGN KEY (store_key) REFERENCES dim_store(store_key),
  FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key)
);

-- Populate the fact_sales fact table with data
INSERT INTO fact_sales (sale_id, date_key, product_key, store_key, customer_key, sale_amount, register_id, cashier_id, revenue)
SELECT 
  pos_sales.sale_id,
  TO_CHAR(sale_date, 'YYYYMMDD')::integer AS date_key,
  pos_sales.product_id AS product_key,
  pos_sales.store_id AS store_key,
  crm_sales.customer_id AS customer_key,
  pos_sales.sale_amount,
  pos_sales.register_id,
  pos_sales.cashier_id,
  pos_sales.sale_amount * pos_products.price AS revenue
FROM pos_sales
LEFT JOIN crm_sales ON pos_sales.sale_id = crm_sales.sale_id
LEFT JOIN pos_products ON pos_sales.product_id = pos_products.product_id;


-- Create the daily_revenue_per_store data mart table
CREATE TABLE daily_revenue_per_store (
  date DATE,
  store_name VARCHAR(50),
  store_location VARCHAR(50),
  revenue DECIMAL(10, 2)
);

-- Populate the daily_revenue_per_store data mart table with data
INSERT INTO daily_revenue_per_store (date, store_name, store_location, revenue)
SELECT 
  dim_date.date,
  dim_store.store_name,
  dim_store.store_location,
  SUM(fact_sales.revenue) AS revenue
FROM 
	fact_sales
JOIN 
	dim_date 
	ON fact_sales.date_key = dim_date.date_key
JOIN 
	dim_store 
	ON fact_sales.store_key = dim_store.store_key
GROUP BY 
	dim_date.date, dim_store.store_name, dim_store.store_location;
	
-- Rename the daily_revenue_per_store data mart table
-- convention <dimensions>_<time granularity>_dm
ALTER TABLE daily_revenue_per_store RENAME TO sales_daily_revenue_per_store_dm;

-- Create the Sales_Daily_Revenue_Per_Customer_DM data mart table
CREATE TABLE sales_daily_revenue_per_customer_dm (
  date DATE,
  customer_name VARCHAR(50),
  email VARCHAR(50),
  phone VARCHAR(50),
  address VARCHAR(100),
  city VARCHAR(50),
  state VARCHAR(50),
  zip_code VARCHAR(10),
  revenue DECIMAL(10, 2)
);

-- Populate the Sales_Daily_Revenue_Per_Customer_DM data mart table with data for the specified date
INSERT INTO sales_daily_revenue_per_customer_dm (date, customer_name, email, phone, address, city, state, zip_code, revenue)
SELECT 
  dim_date.date,
  dim_customer.customer_name,
  dim_customer.email,
  dim_customer.phone,
  dim_customer.address,
  dim_customer.city,
  dim_customer.state,
  dim_customer.zip_code,
  SUM(fact_sales.revenue) AS revenue
FROM fact_sales
JOIN dim_customer ON fact_sales.customer_key = dim_customer.customer_key
JOIN dim_date ON fact_sales.date_key = dim_date.date_key
-- WHERE dim_date.date = '2023-04-08' -- Replace this with the date you want to query
GROUP BY dim_date.date, dim_customer.customer_name, dim_customer.email, dim_customer.phone, dim_customer.address, dim_customer.city, dim_customer.state, dim_customer.zip_code;
