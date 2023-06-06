SELECT * FROM customer_cb.customer;
INSERT INTO `customer_cb`.`customer` 
(`IdCustomer`,`FirstName`, `LastName`, `Age`, `City`,`State`,`Country`) 
VALUES ('1','Bryan', 'Wasiu', '4', 'Ibadan','Oyo','Nigeria');
INSERT INTO `customer_cb`.`customer` 
(`IdCustomer`,`FirstName`, `LastName`, `Age`, `City`,`State`,`Country`) 
VALUES ('2','Kiki', 'Wasiu', '2', 'Lagos','Lagos','Nigeria');
INSERT INTO `customer_cb`.`customer` 
(`IdCustomer`,`FirstName`, `LastName`, `Age`, `City`,`State`,`Country`) 
VALUES ('3','Yomi', 'Wasiu', '20', 'Ijebu','Ogun','Nigeria');
INSERT INTO `customer_cb`.`customer` 
(`IdCustomer`,`FirstName`, `LastName`, `Age`, `City`,`State`,`Country`) 
VALUES ('4','Olamide', 'Ogunsola', '16', 'ijako','Ogun','Nigeria');
INSERT INTO `customer_cb`.`customer` 
(`IdCustomer`,`FirstName`, `LastName`, `Age`, `City`,`State`,`Country`) 
VALUES ('5','Aduragbemi', 'Ogunsola', '22', 'Sango','Ogun','Nigeria');
INSERT INTO `customer_cb`.`customer` 
(`IdCustomer`,`FirstName`, `LastName`, `Age`, `City`,`State`,`Country`) 
VALUES ('6','Busayo', 'Ishola', '28', 'Oluyole','Oyo','Nigeria');

Update `customer_cb`.`customer`
set`Age` = 31
where `firstname` = 'Busayo'

Delete from `customer_cb`.`customer`
where `age` = Null

alter table customer_cb.customer
add Country Varchar(60)
add State Varchar(60)

UPDATE `customer_cb`.`customer` 
SET `State` = 'Oyo', `Country` = 'Nigeria' 
WHERE (`idCustomer` = '1');
UPDATE `customer_cb`.`customer` 
SET `State` = 'Lagos', `Country` = 'Nigeria' 
WHERE (`idCustomer` = '2');
UPDATE `customer_cb`.`customer` 
SET `State` = 'Ogun', `Country` = 'Nigeria' 
WHERE (`idCustomer` = '3');
UPDATE `customer_cb`.`customer` 
SET `State` = 'Ogun', `Country` = 'Nigeria' 
WHERE (`idCustomer` = '4');
UPDATE `customer_cb`.`customer` 
SET `State` = 'Ogun', `Country` = 'Nigeria' 
WHERE (`idCustomer` = '5');
UPDATE `customer_cb`.`customer` 
SET `State` = 'Oyo', `Country` = 'Nigeria' 
WHERE (`idCustomer` = '6');

CREATE TABLE `customer_cb`.`product` (
  `idProduct` INT NULL,
  `ProductName` VARCHAR(60) NULL DEFAULT 'Null',
  `Price` FLOAT NULL,
  PRIMARY KEY (`idProduct`));
  
Select * from customer_cb.product;
INSERT INTO `customer_cb`.`Product` 
(`idProduct`,`ProductName`, `Price`) 
VALUES ('1','Chipbox', '100.99');
INSERT INTO `customer_cb`.`Product` 
(`idProduct`,`ProductName`, `Price`) 
VALUES ('2','Crackerbuscuit', '50.99');
INSERT INTO `customer_cb`.`Product` 
(`idProduct`,`ProductName`, `Price`) 
VALUES ('3','Shawama', '150.99');
INSERT INTO `customer_cb`.`Product` 
(`idProduct`,`ProductName`, `Price`) 
VALUES ('4','Caprison', '60.99');
INSERT INTO `customer_cb`.`Product` 
(`idProduct`,`ProductName`, `Price`) 
VALUES ('5','Apple', '190.99');
INSERT INTO `customer_cb`.`Product` 
(`idProduct`,`ProductName`, `Price`) 
VALUES ('6','coffee', '70.99');

CREATE TABLE `customer_cb`.`Orders` (
`OrderDate` Datetime, 
  `Orderid` INT primary key Null,
  `Customerid` int null);
  
  Alter table `customer_cb`.`Orders` 
  Add `Productid` int null
  
 select * from customer_cb.Orders;
 select * from customer_cb.Customer;
 Select * from customer_cb.product;
 
INSERT INTO customer_cb.Orders 
(OrderDate,Orderid, Customerid) 
VALUES (now()-1,5,4)

alter table `customer_cb.Orders`
add foreign key (`Customerid`) references (`Customer`.`idCustomer`);

Select customer_cb.Customer.LastName,customer_cb.Customer.City,
sum(customer_cb.product.Price) Total,AVG(customer_cb.product.Price) Average 
from customer_cb.Orders
inner join customer_cb.product on customer_cb.Orders.Productid=idProduct
inner Join customer_cb.Customer on customer_cb.Orders.Customerid=idCustomer
group by customer_cb.Customer.LastName,customer_cb.Customer.City

Select customer_cb.Customer.FirstName,customer_cb.Customer.City,customer_cb.product.ProductName, 
count(customer_cb.Orders.Productid) Product_Count,
sum(customer_cb.product.Price) Total,AVG(customer_cb.product.Price) Average, 
((sum(customer_cb.product.Price)) / (Select sum(customer_cb.product.Price) from customer_cb.product)) '% Contribution'
from customer_cb.Orders
inner join customer_cb.product on customer_cb.Orders.Productid=idProduct
inner Join customer_cb.Customer on customer_cb.Orders.Customerid=idCustomer
group by customer_cb.Customer.FirstName,customer_cb.product.ProductName,customer_cb.Customer.City

Select
sum(customer_cb.product.Price) Total
from customer_cb.product




