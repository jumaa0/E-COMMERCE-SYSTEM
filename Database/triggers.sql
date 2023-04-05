
            --------->>>>>trigger to calculate the line total<<<<-------

CREATE TRIGGER line_total1 
ON [dbo].[order_details]
AFTER UPDATE,INSERT
AS 
	UPDATE order_details
	SET   line_total = quantity * price 
	FROM [dbo].[order_details] o inner join [dbo].[Products] p 
	ON o.product_id=p.Product_ID 

GO
            --------->>>>>trigger to calculate the Sub_total<<<<-------

CREATE TRIGGER sub_total
ON order_details
AFTER INSERT,UPDATE
AS
	UPDATE orders
	SET sub_total = (SELECT SUM(line_total) 
					 FROM order_details o 
					 WHERE o.order_id= inserted.order_id)
	FROM orders inner join inserted 
	ON orders.order_id=inserted.order_id

GO
            --------->>>>>trigger to calculate the order_data<<<<-------
CREATE TRIGGER order_data
ON orders
AFTER UPDATE
AS
	UPDATE Orders
	SET total_tax = .14*sub_total,
		total_freight=.07*sub_total,
		total_due=sub_total+total_tax+total_freight,
		Order_date= (SELECT GETDATE() 
				     FROM orders inner join inserted 
				     ON orders.order_id=inserted.order_id)

GO
            --------->>>>>trigger to update the order date<<<<-------
CREATE TRIGGER OrderDate
ON Orders
AFTER INSERT
AS
 
   UPDATE Orders
   SET Order_date= GETDATE()
   FROM orders inner join inserted 
   ON orders.order_id=inserted.order_id

GO
	            --------->>>>>trigger to insert the shiping_method <<<<-------
CREATE TRIGGER shiping_method 
ON orders
AFTER INSERT
AS 
    DECLARE @shiping_city VARCHAR(20)
	SELECT @shiping_city = shipping_city 
	FROM inserted 
	WHERE order_id = inserted.order_id
	IF @shiping_city in ('cairo' , 'Alexandria','Aswan','Ismailia','Qena')
	  BEGIN
		UPDATE orders 
		SET shipping_method = 'car' 
		WHERE orders.order_id= (SELECT order_id FROM inserted)
	  END
	ELSE
	  BEGIN
		UPDATE orders 
		SET shipping_method = 'train' 
		WHERE orders.order_id= (SELECT order_id FROM inserted)
	  END

