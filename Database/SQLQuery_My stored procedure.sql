


						------------------------------------------------------>>>>> Part 1 <<<<<<-----------------------------------------------------

--------->>>>(1) Registration procedure that takes many parameters to make a registration
CREATE PROC registration_proc 
	@fname VARCHAR(50),
	@lname VARCHAR(50),
	@gender VARCHAR(50),
	@zip VARCHAR(50),
	@country VARCHAR(50),
	@city VARCHAR(50),
	@age INT,
	@phone VARCHAR(11),
	@email VARCHAR(50),
	@password VARCHAR(50)

AS
	declare @lastcutomerid int ---- declare variable that the last id from (scope_identity)

	---- check if this customer has an account or new customer
	IF(EXISTS(SELECT *  FROM customers WHERE email = @email))
		BEGIN
			SELECT 'this email is already used' AS error_messagee
		END
	---- if the customer is new will enter all info. that are required from him
	ELSE 
		BEGIN
			INSERT INTO customers(fname,lname,age,gender,zip_code,country,city,email,password)
			VALUES(@fname,@lname,@age,@gender,@zip,@country,@city,@email,@password)
			SET @lastcutomerid = scope_identity()  --returns the last identity value in the same scope(table that we work on)
			INSERT INTO customer_Phone(Customer_ID , Phone)
			VALUES(@lastcutomerid , @phone)
		END

------------------>>>>>>>>>>>>>>>>>>>>>>>>>>>>(2)Login_procedure that takes two parameters email and password
CREATE PROC Login_Proc
	@email VARCHAR(50),
	@password VARCHAR(50)
AS
	----check if the email and password is exists 
	IF(EXISTS(select * FROM customers WHERE email = @email AND password = @password))
		BEGIN 
			SELECT 'successful login ' AS verify_message
		END
	ELSE 
		BEGIN
			SELECT 'email or password not correct' AS login_error
		END

EXEC Login_Proc 'ahmed.hassan@yahoo.com' , 'password1' ------> give successful login 
EXEC Login_Proc 'ahmed.hassan@yahoo.com' , 'password' -------> email or password not correct


----------------------->>>>>>>>>>>>>(3)view products provided details by our e commerce
CREATE PROC products_in_e_commerce
AS
	SELECT Category_name , Subcategory_name , Product_name , price
	FROM Category AS c INNER JOIN  subcategory AS sc
	ON c.Category_ID = sc.Category_ID
	INNER JOIN	Products AS p 
	ON p.subcategory_ID = sc.Subcategory_ID

EXEC products_in_e_commerce

----------------------------->>>>>>>>>>>>>(4)add_cart_procedure (add products to cart) 

ALTER PROC add_product_cart_procedure
	@product_id INT,
	@customer_id INT,
	@quantity INT
AS
	declare @counter INT 
	SET @counter = 0
	WHILE @counter < COUNT(@product_id)
		BEGIN
			INSERT INTO cart(product_id,customer_id,quantity)
			VALUES(@product_id,@customer_id,@quantity)
			SET @counter +=1
		END

EXEC add_product_cart_procedure 4,3,4 
EXEC add_product_cart_procedure 3,3,7
SELECT * FROM cart

------------------------>>>>>>>>>>>>>>>>> (5)cart_product_details_procedure view products details in the cart
CREATE PROC cart_product_details_procedure
	@customer_id INT
AS
	SELECT customer_id , c.product_id , p.price*c.quantity AS total_pay
	FROM cart AS c INNER JOIN Products AS p
	ON c.product_id = p.Product_ID
	WHERE c.customer_id = @customer_id 

EXEC cart_product_details_procedure 3


--------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>(6) view price of products added to the cart
CREATE PROC total_price_of_products_in_cart
	@customer_id INT
AS 
	SELECT 
		SUM(c.quantity*p.price) AS cart_subtotal , 
		SUM(c.quantity*p.price)*0.14 AS tax ,
		SUM(c.quantity*p.price)*0.07 AS freight, 
		SUM(c.quantity*p.price)*1.21 AS total_pay
	FROM products  AS p INNER JOIN cart AS c
	ON c.product_id = p.Product_ID 
	WHERE c.customer_id = @customer_id

EXEC total_price_of_products_in_cart 3




------------------------->>>>>>>>>>>>>>>>>(7)update quantity of products in the cart
ALTER PROC cart_products_update
	@newproduct_id INT,
	@customer_id INT,
	@newquantity INT, 
	@add_sub varchar(1)

AS
				IF(EXISTS(SELECT * FROM cart WHERE  product_id =  @newproduct_id )) 
					BEGIN
						IF @add_sub = '+' 
							BEGIN
								UPDATE cart
								SET quantity = quantity + @newquantity
								WHERE customer_id = @customer_id and product_id = @newproduct_id
							END
						IF @add_sub = '-'
							BEGIN
								UPDATE cart
								SET quantity = quantity - @newquantity
								WHERE customer_id = @customer_id and product_id = @newproduct_id
							END
					END
				ELSE 
					BEGIN	
						INSERT INTO cart(product_id,customer_id,quantity)
						VALUES(@newproduct_id,@customer_id,@newquantity)
					END

-----execute the stored procedure 
EXEC cart_products_update 3,4,1,''
EXEC cart_products_update 4,4,1,''
EXEC cart_products_update 5,4,1,'+'
EXEC cart_products_update 5,4,1,'-'
select * from cart


--------------------------------------->>>>>>>>>>>(8) empty the cart cart 
ALTER PROC empty_cart_from_products_procedure
	@customer_id INT

AS
	DELETE FROM cart 
	WHERE customer_id = @customer_id 

-----execute the stored procedure 
EXEC empty_cart_from_products_procedure 4



--------------------------------->>>>>>>>>>> (9)make order from products added to the cart
CREATE PROC choose_order_products_from_cart
	@customer_id INT,
	@payment_method VARCHAR(50),
	@shipping_city VARCHAR(50)
AS
	DECLARE @order_id INT 
	INSERT INTO orders(customer_id,payment_method,shipping_city)
	VALUES(@customer_id,@payment_method,@shipping_city)
	SET @order_id = SCOPE_IDENTITY()

	DECLARE @product_id INT , @quantit INT
	INSERT INTO order_details(quantity,product_id,order_id)
	SELECT product_id, quantity , @order_id
	FROM cart
	WHERE customer_id = @customer_id

	DELETE FROM cart
	WHERE customer_id = @customer_id

choose_order_products_from_cart 4,'Cash','Fayoum'

select * from cart

select * from rating

---------------------------------->>>>>>>>>>>>>(10)rate the service
CREATE PROC create_rating_survey
	@survey_id INT, 
	@overall_rate INT,
	@delivery_rate INT, 
	@customer_service_rate INT,
	@loyality VARCHAR(3),
	@product_quality_rate INT,
	@customer_id INT
AS 
	INSERT INTO rating(survey_id,overall_rate,delivery_rate,customer_service_rate,loyality,product_quality_rate,customer_id)
	VALUES(@survey_id,@overall_rate,@delivery_rate,@customer_service_rate,@loyality,@product_quality_rate,@customer_id)



--------------------------->>>>>>>>>>>>>>>>>>>(11) search about product by enter keywords
CREATE PROC search_about_product
	@product_letters VARCHAR(50)
AS 
	SELECT Product_name  , price , Subcategory_name , Category_name
	FROM Products AS  p INNER JOIN  subcategory AS sc 
	ON p.subcategory_ID = sc.Subcategory_ID 
	INNER JOIN 	Category c
	ON sc.Category_ID = c.Category_ID
	WHERE Product_name LIKE '%'+ @product_letters +'%'


select product_name from Products

EXEC search_about_product 'ean'


----------------------------->>>>>>>>>>>>>>(12) view all products that he bought from us.
CREATE PROC all_products_in_our_commerce
AS
	SELECT Product_name  , price , Subcategory_name , Category_name
	FROM Products AS  p INNER JOIN  subcategory AS sc 
	ON p.subcategory_ID = sc.Subcategory_ID 
	INNER JOIN 	Category c
	ON sc.Category_ID = c.Category_ID

EXEC all_products_in_our_commerce

select * from rating


							----------------------------------------------------->>>>> Part 2 <<<<<<-----------------------------------------------------
-------------------------->>>>>>>>>>>(1) view averrage  of customer rates 
ALTER PROC customer_rates
AS
	SELECT  AVG(overall_rate) AS Average_Over_all_rate,
		   AVG(delivery_rate) AS Average_delivery_rate,
		   AVG(customer_service_rate) AS Average_customer_service_rate,
		   AVG(product_quality_rate) AS Average_product_quality_rate
	FROM rating

------------------------>>>>>>>>>>>>(2) view what rates affecting loyality
CREATE PROC customer_rates_based_on_loyality 
AS
	SELECT loyality, AVG(overall_rate) AS Average_Over_all_rate,
		   AVG(delivery_rate) AS Average_delivery_rate,
		   AVG(customer_service_rate) AS Average_customer_service_rate,
		   AVG(product_quality_rate) AS Average_product_quality_rate
	FROM rating
	GROUP BY loyality

EXEC customer_rates_based_on_loyality

------------------------>>>>>>>>>>>>>(3) view overall sales details
ALTER PROC total_sale_details
AS
	SELECT  total_sales = SUM(total_due),
			total_taxes = SUM(total_tax), 
			total_freight = SUM(total_freight), 
			total_subtotal = SUM(sub_total) 
	FROM orders

EXEC total_sale_details


---------------------->>>>>>>>>>>>>>>>>>(4) total sales per age.
ALTER PROC get_totalsales_by_age_category
AS 
	DECLARE @categories TABLE(age_category VARCHAR(20) , total_sales INT)
	INSERT INTO @categories(age_category,total_sales)
	SELECT 
	  age = CASE	
				WHEN age < 25 THEN  'Under 25'
				WHEN age BETWEEN 25 AND 35 THEN  '25-35'
				WHEN age BETWEEN 35 AND 45 THEN  '35-45'
				WHEN age BETWEEN 45 AND 55 THEN  '45-55'
				WHEN age >55 THEN  'over 55'
			 END,
	  SUM(total_due) 
	FROM orders AS o INNER JOIN customers AS c 
	ON o.customer_id = c.customer_id
	GROUP BY age
	SELECT SUM(total_sales) AS total_sales , age_category
	FROM @categories 
	GROUP BY age_category

EXEC get_totalsales_by_age_category

------------------------------>>>>>>>>>>>>>>(5)view total sales per gender
ALTER PROC get_totalsales_by_gender
AS
	SELECT gender , SUM(total_due) AS total_sales
	FROM customers AS c INNER JOIN orders AS o 
	ON c.customer_id = o.customer_id 
	GROUP BY gender

EXEC get_totalsales_by_gender


--------------------------------->>>>>>>>>>>>>>>(6) view total sales per city
CREATE PROC get_totalsales_by_city
AS 
	SELECT city , SUM(total_due) AS total_sales
	FROM customers AS c INNER JOIN orders AS o 
	ON c.customer_id = o.customer_id
	GROUP BY city

EXEC get_totalsales_by_city

-------------------------------->>>>>>>>>>>>>>>>>(7)total sales per month
ALTER PROC get_totalsales_by_year
AS 
	SELECT SUM(total_due) AS total_sales , 
			DATEPART(YEAR, order_date) AS Year_of_order
	FROM orders 
	GROUP BY DATEPART(YEAR, order_date)

EXEC get_totalsales_by_year

-------------------------------->>>>>>>>>>>>>>>>>>>(8)total sales per Quarter
CREATE PROC get_totalsales_by_Quarter
AS 
	SELECT SUM(total_due) AS total_sales , 
	       DATEPART(QUARTER, order_date) AS Quarter_of_order
	FROM orders 
	GROUP BY DATEPART(QUARTER, order_date)

EXEC get_totalsales_by_Quarter

-------------------------------->>>>>>>>>>>>>>>>>>>>(9)total sales per Month
ALTER PROC get_totalsales_by_MONTH
AS 
	SELECT TOP 5 SUM(total_due) AS total_sales , 
			DATEPART(MONTH, order_date) AS Month_of_order ,
			DATENAME(MONTH, order_date) AS Month_of_order
	FROM  orders 
	GROUP BY DATEPART(MONTH, order_date),
	         DATENAME(MONTH, order_date)
	ORDER BY SUM(total_due) DESC

EXEC get_totalsales_by_MONTH



-------------------------------->>>>>>>>>>>>>>>(10)total sales per DAY
ALTER PROC get_totalsales_by_DAy
AS 
	SELECT TOP 10 SUM(total_due) AS total_sales , 
			DATEPART(DAY, order_date) AS DAY_of_order ,
			DATENAME(WEEKDAY, order_date) AS DAY_of_order
	FROM orders 
	GROUP BY DATEPART(DAY, order_date),DATENAME(WEEKDAY, order_date)
	ORDER BY SUM(total_due) DESC

EXEC get_totalsales_by_DAy

-------------------------------->>>>>>>>>>>>>>>>>>>>>>>>(11) top 10 products 
ALTER PROC top_prod_Name_totalsales
AS
	SELECT TOP 10 SUM(total_due) AS top_total_sales,SUM(total_due) AS Lower_total_sales,Product_name
	FROM  orders AS o INNER JOIN order_details od   
	ON o.order_id = od.order_id 
	INNER JOIN Products AS p
	ON od.product_id = p.Product_ID
	GROUP BY Product_name
	ORDER BY SUM(total_due) DESC 

EXEC top_prod_Name_totalsales

------------------------------->>>>>>>>>>>>>>>>>>>>>(12)lowest 10 products

CREATE PROC LOWER_prod_Name_totalsales
AS
	SELECT TOP 10 SUM(total_due) AS Lower_total_sales,Product_name
	FROM  orders AS o INNER JOIN order_details od   
	ON o.order_id = od.order_id 
	INNER JOIN Products AS p
	ON od.product_id = p.Product_ID
	GROUP BY Product_name
	ORDER BY SUM(total_due) ASC

EXEC LOWER_prod_Name_totalsales


-------------------------------->>>>>>>>>>>>>>>>>>>>(13)total sales  of all products in each month
CREATE PROC totalsales_each_product_by_MONTH
AS 
	SELECT  SUM(total_due) AS total_sales , 
			DATEPART(MONTH, order_date) AS Month_of_order ,
			DATENAME(MONTH, order_date) AS Month_of_order,Product_name
			
	FROM  orders AS o INNER JOIN order_details od   
	ON o.order_id = od.order_id 
	INNER JOIN Products AS p
	ON od.product_id = p.Product_ID
	GROUP BY DATEPART(MONTH, order_date),
	         DATENAME(MONTH, order_date),
			 Product_name
	ORDER BY SUM(total_due) DESC

EXEC totalsales_each_product_by_MONTH

-------------------------------------(14) profit stored procedure 

ALTER PROC profit 
AS

	SELECT Product_name ,
		  SUM(quantity) AS total_product_sold_qty,
		  SUM(od.quantity*p.price - od.quantity*p.cost) AS total_profit_from_each_product
	FROM Products p inner join  order_details od 
	ON od.product_id=p.Product_ID
	group by Product_name 
	

EXEC profit