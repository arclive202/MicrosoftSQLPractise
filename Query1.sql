--creating a new database
create database CUSTOMERSERVICE

--creating a table about customer details
create table CustomerDetails(
CustomerID char(4),
CustomerName varchar(100),
City varchar(100),
MobileNo char(100),
[Address] varchar(1000))

--creating a table about product details
create table ProductDetails(
ProductID int IDENTITY(1001,1),
ProductName varchar(100),
ProductImage varbinary(max),
Price money,
Quantity smallint,
ProductAddDate Date,
ProductModifiedDate Date,
AvailableStatus bit)

--adding email id column
alter table Customerdetails add EmailID varchar(200) not null

--adding Pin Code column
alter table Customerdetails add PinCode char(6) 
--adding the constraint to check pin
alter table Customerdetails add constraint checkpin
Check(PinCode LIKE('[0-9][0-9][0-9][0-9][0-9][0-9]'))

--altering customerID column to not null
alter table CustomerDetails alter column CustomerID char(4) not null

--adding the primary key for customerID in CustomerDetails
alter table CustomerDetails
add Constraint pkCustomerID Primary Key(CustomerID)

--adding the primary key for ProductID in ProductDetails
alter table ProductDetails add Constraint pkProductID Primary Key(ProductID)

--altering table to make CustomerID in ProductDetails table not null
alter table ProductDetails add CustomerID char(4) not null

--Defining a foreign key on CustomerID in Product Details and referencing it to CustomerDetails
alter table ProductDetails add Constraint fkCustomerID Foreign Key(CustomerID) references CustomerDetails(CustomerID)

--adding a constraint to check the mobile number
alter table CustomerDetails add constraint chkCustomerMobNo
Check(MobileNo LIKE('[6-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'))

--defining a default constraint for the productadddate date column
alter table ProductDetails add constraint dfProductDate Default Getdate() for ProductAddDate

--adding a column for registration date in customerDetails table and giving it a default constraint
alter table CustomerDetails add registrationdate date
alter table CustomerDetails add constraint dfregistrationdate Default Getdate() for registrationdate

select GETDATE()


--creating a table for OrderDetails with the constraints

create table OrderDetails(
OrderID int identity(10001,1) constraint pkOrderID Primary Key,
CustomerID char(4) constraint fkCustomerID1 Foreign key(CustomerID) references CustomerDetails(CustomerID),
ProductID int constraint fkProductID1 foreign key(ProductID) references ProductDetails(ProductID),
OrderDate Datetime constraint dfOrderDate Default Getdate(),
TotalQty int not null Constraint chkqty check(TotalQty Between 1 and 10),
ExpectedDeliveryDate Datetime,
TotalPrice money not null)


--Alter table CustomerDetails add CustomerJoinDate date constraint 

--Inserting in CustomerDetails
Insert into CustomerDetails(CustomerID,CustomerName,City,MobileNo,[Address],EmailID)
values ('C001','Aditya','Bangalore','7360563506','B-11','adi@gmail.com')

--Inserting in ProductDetails
Insert into ProductDetails(ProductName,Price,Quantity,AvailableStatus,CustomerID) values ('LG',10000.00,6,1,'C001')

select * from ProductDetails

--Inserting in OrderDetails
Insert into OrderDetails(CustomerID, ProductID,TotalQty,TotalPrice) values ('C001',1002,3,10000.00)

select * from CustomerDetails, ProductDetails, OrderDetails

--Updating Customer Details
update CustomerDetails set MobileNo='7000000000' where City = 'Bangalore'

-- deleting an entry from OrderDetails where the name of the customer is given.
delete from OrderDetails where CustomerID = (select CustomerID from CustomerDetails where CustomerName = 'Aditya')

--You can also define stored procedures and use them later on so that the code typing doesn't become redundant
create proc uspcustdet(@CustomerName varchar(100), @MobileNo char(10))
as
Select * from CustomerDetails where CustomerName = @CustomerName and MobileNo = @MobileNo

--executing the stored procedure.
exec uspcustdet 'Aditya','7000000000'


--creating a stored procedure for inserting values into the table
create proc uspinsemp(@CustomerID char(4),@CustomerName varchar(100),@City varchar(100),@MobileNo char(10),@address varchar(1000),@email varchar(200),@Pcode char(6))
as
if(exists(Select * from CustomerDetails where CustomerID = @CustomerID))
begin
print 'Customer ID already exists'
end
else
begin
insert into CustomerDetails(CustomerID,CustomerName,City,MobileNo,[Address],EmailID,PinCode) 
values (@CustomerID,@CustomerName,@City,@MobileNo,@address,@email,@Pcode)
print 'Customer ID :'+@CustomerID+' created successfully.'
end

--Executing the Stored Procedure for insert
exec uspinsemp 'C002','ARC','Bangalore','7123456890','36by1','arc@gmail.com','560008'


-- stored procedure for inserting product details
create proc uspinsprod(@ProductName varchar(100),@Price money,@quantity smallint,@avail bit,@custid char(4))
as
if(exists(Select * from ProductDetails where ProductName = @ProductName))
begin
print 'Product already exists'
end
else
begin
insert into ProductDetails(ProductName,Price,Quantity,AvailableStatus,CustomerID) 
values (@ProductName,@Price,@quantity,@avail,@custid)
print 'Product :'+@ProductName+' added successfully.'
end

--Executing procedure for inserting values into product details
exec uspinsprod 'Nivea',250.00,100,1,'C001'


--creating a procedure to insert values into the order details table
create proc uspinsord(@CustomerID char(4),@ProductID int,@totalqty int,@totalprc money)
as
insert into OrderDetails(CustomerID,ProductID,TotalQty,TotalPrice) 
values (@CustomerID,@ProductID,@totalqty,@totalprc)
print 'Order generated successfully.'


--Executing procedure for inserting values into order details
exec uspinsord 'C001',1005,7,1500.00

--Creating a Procedure for customer details to update the phone number and email id of the customer

create proc uspupcust(@CustomerID char(4),@MobNo char(10),@email varchar(200))
as
if(exists(Select * from CustomerDetails where CustomerID = @CustomerID))
begin
update CustomerDetails set MobileNo = @MobNo, EmailID = @email
where CustomerID = @CustomerID
print 'Customer ID: '+@CustomerID+', updated successfully'
end
else
print 'Customer ID doesnot exist'

--executing the procedure for updating customer table details
exec uspupcust 'c001','7360563506','arcl@gmail.com'

--creating a Procedure for customer details to delete a record given the customer ID
create proc uspdelcust(@CustomerID char(4))
as
if(exists(Select * from CustomerDetails where CustomerID = @CustomerID))
begin
delete from CustomerDetails where CustomerID = @CustomerID
print 'Customer ID: '+@CustomerID+' has been deleted.'
end
else
print 'Customer ID doesnot exist'

--executing a procedure for customer details to delete a record given the customer id
exec uspdelcust 'C002'

--Creating a Procedure for Order details to update the total price and total quantity of the product

create proc uspupord(@OrderID int,@qty int,@price money)
as
if(exists(Select * from OrderDetails where OrderID = @OrderID))
begin
update OrderDetails set TotalQty = @qty, TotalPrice = @price
where OrderID = @OrderID
print 'Order ID: '+@OrderID+', updated successfully'
end
else
print 'Order ID doesnot exist'

--executing the procedure for updating order details table
exec uspupord 10003,9,500

select * from OrderDetails

--creating a Procedure for order details to delete a record given the order ID
create proc uspdelord(@OrderID int)
as
if(exists(Select * from OrderDetails where OrderID = @OrderID))
begin
delete from OrderDetails where OrderID = @OrderID
print 'Order ID: '+@OrderID+' has been deleted.'
end
else
print 'Order ID doesnot exist'



sp_help productdetails
--executing a procedure for order details to delete a record given the order id
exec uspdelord '10003'

--creating VIEWS

create view vwCustOrd
as
Select C1.CustomerID,CustomerName, OrderID, [Address] from CustomerDetails C1 join OrderDetails O1 on C1.CustomerID = O1.CustomerID

-- displaying the table from the above defined view
select * from vwCustOrd

--updating a view. Update cannot be applied if the change affects the value of multiple tables
update vwCustOrd set [Address] = '36by1' where CustomerID = 'C001'

-- altering a view with SchemaBinding
alter view dbo.vwCustOrd
with schemabinding
as
Select C1.CustomerID,CustomerName, OrderID, [Address] from dbo.CustomerDetails C1 join dbo.OrderDetails O1 on C1.CustomerID = O1.CustomerID



--creating and calling a function just to display the output and also how to apply it in a query

create function fnCalculates(@Price float)
returns float
as
begin
return (@Price+((@Price*18)/100))
end

Declare @MRPrice float,@OriginalPrice float
SET @OriginalPrice = 25.50
SET @MRPrice = dbo.fnCalculates(@OriginalPrice)
print @MRPrice

select ProductID, ProductName, Price as OriginalPrice, dbo.fnCalculates(Price) as GSTPrice from ProductDetails

--Table Values Function returns the value in a tabular format rather than returning a singular value result in the function described above
--the advantage of using such functions is that they can be used as a subquery or within procedures as well.
create function fnProductDetails(@Name varchar(100))
returns table
as
return(Select * from ProductDetails where ProductName = @Name)

Select * from dbo.fnProductDetails('LG')

create proc uspProductName(@Name varchar(100))
as
select * from dbo.fnProductDetails(@Name)

exec uspProductName 'Dell'

--Temp Table and Temp table variables. 
--you can access these tables through the object explorer by looking under tempdb which is present under the System Database
--there are two ways a temporary table can be created: 
--1.) Creating a temporary table using '#'=This table will only be available to the current sql query file or the session it is running on.

create table #TempTable(ID int, Name varchar(100))

insert into #TempTable(ID,Name)values(3,'Sanjay')

select * from #TempTable

alter table #TempTable add city varchar(100)

update #TempTable set city = 'Bangalore' where ID = 1

--2.) Creating a temporary table using a temporary table variable. 
--Works in a batch, which means that all the collective statements should be executed together.
--gets immediately dropped after the batch has been executed.

Declare @TempTableVar table (ID int, Name varchar(100)) 
Insert into @TempTableVar(ID,Name) values (1, 'ABC')
Select * from @TempTableVar 

--2.1) When we try to insert values into the temporary table variable we must match the datatypes in insert correspondingly
Declare @TempTableVar table (ID char(4), Name varchar(100)) 
Insert into @TempTableVar
select CustomerID, CustomerName from CustomerDetails
Select * from @TempTableVar 


--Multistatement Function
create function fnCustomerMulti(@City varchar(100))
returns @TempCust table
(CustID char(4), Name varchar(100), City varchar(100))
as
begin
Insert @TempCust
Select CustomerID,CustomerName,City from CustomerDetails where City = @City
return
end

select * from dbo.fnCustomerMulti('Bangalore')


--Practise exercises

--1.Display all the orders placed on a particular city.(using subquery and table value function.)
 
create function fnGetCityOrders (@City varchar(50))
returns table
as
return(select * from orderdetails where OrderID in (select OrderID from orderdetails od join customerdetails cd on (od.CustomerID = cd.CustomerID) where cd.City=@City))


select * from fnGetCityOrders('Bangalore')


--2.a> Create a scalar function (name as fnTotalPrice) taking two arguments, price and quantity. Return type of the function is money. It returns Price * quantity (multiplies the value and returns the result). 

--  b> Use the function in a procedure where there is customer id, customer name, product name, product price and total quantity. Add the 6th column as the scalar function, from above.

create function fnTotalPrice(@Price float, @Quantity int)
returns money
as
begin
return (@Price*@Quantity)
end

create proc uspPriceCalculationProcedure
as
begin
select cd.CustomerID, customername, productname, price, totalqty, dbo.fnTotalPrice(price, totalqty) 
from CustomerDetails cd, OrderDetails od, PRODUCTDETAILS pd where cd.CustomerID = od.CustomerID and od.ProductID = pd.PRODUCTID  
end

exec uspPriceCalculationProcedure


--3.Display all the details of all the customers for a particular order date.
--This should be done using a procedure. When showing the order date, display only the date and year (e.g. Jan-2018).
--{Hint : where month(OrderDate) = 01 and year(OrderDate) = 2018.}

create proc uspDisplayCustDetailsOnDate(@month int, @year int)
as 
begin
select * from CustomerDetails cd join OrderDetails od on cd.CustomerID = od.CustomerID where year(od.OrderDate) = @year and month(od.OrderDate) = @month;
end


exec uspDisplayCustDetailsOnDate '01','2018'


--4. Display customerId, customer name, product name, price, orderdate and sort it by order date. Do it using stored procedures.

create proc displaySortedByOrderDate
as
begin 
        select customerdetails.CustomerID, customerName, ProductName, Price, Orderdate from CustomerDetails, OrderDetails, PRODUCTDETAILS where CustomerDetails.CustomerID = OrderDetails.CustomerID and OrderDetails.ProductID = PRODUCTDETAILS.PRODUCTID order by OrderDate; 
end



exec displaySortedByOrderDate

