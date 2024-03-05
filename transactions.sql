create schema if not exists data_warehouse;

create table data_warehouse.invoice (
	id INT,
	date date,
	product varchar(50),
	total_price INT
);

create table data_warehouse.invoice_item (
	id INT,
	invoice_id INT,
	client_id INT,
	item_name varchar(50),
	quantity INT,
	price INT
);

create table data_warehouse.client (
	id INT,
	city_id INT,
	city varchar(50),
	name varchar(50),
	address varchar(50)
);

insert into  data_warehouse.invoice values (1, '2023-01-01', 'alat tulis', 8500);
insert into  data_warehouse.invoice values (2, '2023-09-09', 'alat tulis', 2500);
insert into  data_warehouse.invoice values (3, '2023-10-10', 'alat tulis', 5000);
insert into  data_warehouse.invoice values (4, '2024-01-01', 'pecah belah', 100000);


insert into  data_warehouse.invoice_item values (1, 1, 2, 'pensil', 2, 3000);
insert into  data_warehouse.invoice_item values (2, 1, 2, 'buku', 1, 2500);
insert into  data_warehouse.invoice_item values (3, 2, 1, 'buku', 1, 2500);
insert into  data_warehouse.invoice_item values (4, 3, 3, 'gelas', 2, 50000);

insert into data_warehouse.client values (1, 1, 'Yogyakarta', 'Sulton', 'Jl. Sultan Agung');
insert into data_warehouse.client values (2, 2, 'Jakarta', 'Abe', 'Jl. Gatot Subroto');
insert into data_warehouse.client values (3, 3, 'Solo', 'Yuni', 'Jl. RE Martadinata');


select * from data_warehouse.client;
select * from data_warehouse.invoice;
select * from data_warehouse.invoice_item;


-- CREATE DIMENSIONAL MODELLING
-- CREATE FACT_SALES
create table data_warehouse.fact_sales as
select
	total_price,
	client_id,
	invoice_id
from
	data_warehouse.invoice_item as ii
left join data_warehouse.invoice as i on ii.invoice_id = i.id;

select * from data_warehouse.fact_sales;


-- CREATE DIM_CLIENT
create table data_warehouse.dim_client as
select
	id,
	name,
	address
from data_warehouse.client c;


-- HOW MANY ORDERS SOLD IN Jl. RE Martadinata
select
	COUNT(invoice_id) as total_order
from data_warehouse.fact_sales as fs
left join data_warehouse.dim_client as dc on fs.client_id = dc.id
where address = 'Jl. RE Martadinata';

-- HOW MANY TOTAL REVENUE OF SALES IN Jl. Gatot Subroto
select
	SUM(total_price) as total_revenue
from data_warehouse.fact_sales as fs
left join data_warehouse.dim_client as dc on fs.client_id = dc.id
where address = 'Jl. Gatot Subroto';
