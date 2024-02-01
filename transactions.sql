create schema if not exists test;

create table test.invoice (
	id INT,
	date date,
	product varchar(50),
	total_price INT
);

create table test.invoice_item (
	id INT,
	invoice_id INT,
	client_id INT,
	item_name varchar(50),
	quantity INT,
	price INT
);

create table test.client (
	id INT,
	city_id INT,
	city varchar(50),
	name varchar(50),
	address varchar(50)
);

insert into  test.invoice values (1, '2023-01-01', 'alat tulis', 8500);
insert into  test.invoice values (2, '2023-09-09', 'alat tulis', 2500);
insert into  test.invoice values (3, '2023-10-10', 'alat tulis', 5000);
insert into  test.invoice values (4, '2024-01-01', 'pecah belah', 100000);


insert into  test.invoice_item values (1, 1, 2, 'pensil', 2, 3000);
insert into  test.invoice_item values (2, 1, 2, 'buku', 1, 2500);
insert into  test.invoice_item values (3, 2, 1, 'buku', 1, 2500);
insert into  test.invoice_item values (4, 3, 3, 'gelas', 2, 50000);

insert into test.client values (1, 1, 'Yogyakarta', 'Sulton', 'Jl. Sultan Agung');
insert into test.client values (2, 2, 'Jakarta', 'Abe', 'Jl. Gatot Subroto');
insert into test.client values (3, 3, 'Solo', 'Yuni', 'Jl. RE Martadinata');

