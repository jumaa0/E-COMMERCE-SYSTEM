------------------------------------------- customer table
CREATE TABLE customer(
cust_id int ,
cust_firstname varchar(20),
cust_lastname varchar(20),
cust_gender varchar(1),
cust_DOB int,
cust_country varchar(20),
cust_city varchar(20),
cust_street varchar(20),
cust_zip int,
CONSTRAINT pk_customer PRIMARY KEY (cust_id)
)

GO

--------------------------------------------------customer_phone
CREATE TABLE customer_phone(
cust_id int,
phone int ,
CONSTRAINT pk_customer_phone PRIMARY KEY (cust_id,phone),
constraint fk_customer_phone foreign key (cust_id) references customer ON DELETE CASCADE ON UPDATE CASCADE
)

GO
--------------------------------------- payment table(deleted)
CREATE TABLE payment(
pay_id  int,
pay_method varchar(50),
cust_id int,
CONSTRAINT pk_payment PRIMARY KEY (pay_id),
CONSTRAINT fk_payment FOREIGN KEY (cust_id) REFERENCES customer ON DELETE CASCADE ON UPDATE CASCADE
)

GO


-----------------------------------category table
CREATE TABLE category(
category_id int,
category_name varchar(50),
CONSTRAINT pk_category PRIMARY KEY (category_id)
)
GO

-----------------------------------------------------subcategory table
CREATE TABLE subcategory(
subcategory_id int,
subcategory_name varchar(50),
category_id int,
CONSTRAINT pk_subcategory PRIMARY KEY (subcategory_id), 
CONSTRAINT fk_subcategory FOREIGN KEY (category_id) REFERENCES category  ON DELETE CASCADE ON UPDATE CASCADE
)

GO

------------------------------------------- product table
CREATE TABLE product(
product_id int,
product_name varchar(50),
product_unit_price int,
product_cost int,
subcategory_id int,
CONSTRAINT pk_product PRIMARY KEY (product_id), 
CONSTRAINT fk_product FOREIGN KEY (subcategory_id) REFERENCES subcategory  ON DELETE CASCADE ON UPDATE CASCADE

)
GO

------------------------------------------------- order table 
CREATE TABLE orders(
order_id int,
order_date date ,
order_subtotal int,
order_total_tax int,
order_total_freight int,
order_total_due int,
order_arrival_time datetime,
order_shape_method varchar(20),
order_shape_city varchar(20),
cart_id int,
cart_total_amt int, 
cart_qty int, 
CONSTRAINT pk_orders PRIMARY KEY (order_id) 
)

GO


------------------------------------ customer_order
CREATE TABLE customer_order(
order_id int, 
cust_id int,
CONSTRAINT pk_customer_order primary key (order_id),
CONSTRAINT fk_custome_order FOREIGN KEY (cust_id) REFERENCES customer ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT fk_custome_order_orders FOREIGN KEY (order_id) REFERENCES orders ON DELETE CASCADE ON UPDATE CASCADE
)


GO


--------------------------------------- order_detail table
CREATE TABLE order_details(
order_det_id int,
order_det_quantity int,
order_det_linetotal int,
order_id int, 
product_id int,
CONSTRAINT pk_order_details PRIMARY KEY (order_det_id), 
CONSTRAINT fk_orders_order_details FOREIGN KEY (order_id) REFERENCES orders ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT fk_produc_order_details FOREIGN KEY (product_id) REFERENCES product ON DELETE CASCADE ON UPDATE CASCADE
)

GO

---------------------------------------------- store table
CREATE TABLE store(
store_id int,
store_name varchar(50),
store_rigion varchar(50),
CONSTRAINT pk_store PRIMARY KEY (store_id)
)

GO
----------------------------------------------product_store table
CREATE TABLE product_store(
store_id int,
product_id int,
CONSTRAINT pk_product_store PRIMARY KEY (product_id,store_id), 
CONSTRAINT fk_product_product_store FOREIGN KEY (product_id) REFERENCES product  ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT fk_store_product_store FOREIGN KEY (store_id) REFERENCES store  ON DELETE CASCADE ON UPDATE CASCADE
)

GO
--------------------------------------------- supplier table 
create table supplier(
supplier_id int,
supp_name varchar(50),
CONSTRAINT pk_supp_id PRIMARY KEY (supplier_id)
)

GO
-------------------------------------------product_supplier table
CREATE TABLE product_supplier(
supplier_id int,
product_id int,
CONSTRAINT pk_product_supplier PRIMARY KEY (product_id,supplier_id), 
CONSTRAINT fk_product_product_supplier FOREIGN KEY (product_id) REFERENCES product  ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT fk_supplier_product_supplier FOREIGN KEY (supplier_id) REFERENCES supplier  ON DELETE CASCADE ON UPDATE CASCADE
)

GO
------------------------------------------------- brand table 
CREATE TABLE brand(
brand_id int,
brand_name varchar(50),
brand_country varchar(50),
brand_st_date date,
CONSTRAINT pk_brand PRIMARY KEY (brand_id)

)

GO
---------------------------------------------------product_brand table
CREATE TABLE product_brand(
brand_id int,
product_id int,
CONSTRAINT pk_product_brand PRIMARY KEY (product_id,brand_id), 
CONSTRAINT fk_product_product_brand FOREIGN KEY (product_id) REFERENCES product  ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT fk_brand_product_brand FOREIGN KEY (brand_id) REFERENCES brand  ON DELETE CASCADE ON UPDATE CASCADE

)
GO