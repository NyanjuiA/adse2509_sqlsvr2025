/* This session cover how to work with indexes/indeces in SQL server. */

-- Switch to the customer database
use Cust_db_adse2509;

-- ---------------------------------------------------------------------------
-- Demonstrate creating, modifying and deleting indexes
-- ---------------------------------------------------------------------------
-- 1. Create an Employee_details table
if OBJECT_ID('Cust_Details') is null
	Create table Cust_Details
	(
		EmpID int not null identity(1001,1) primary key,
		AccNo nvarchar(10) not null,
		AccName nvarchar(180) not null,
		Country nvarchar(70) not null
	);
else
	print('The ''Cust_Details'' table already exists and will not be recreated')

-- 2. Insert/add rows into the Cust_details table
Insert into dbo.Cust_Details
(AccNo,AccName,Country)
values
('CN001','John Keena','Spain'),
('CN020','Smith Jones','Russia'),
('CN011','Albert Walker','Germany'),
('CN021','Rosa Stines','Italy');

-- Get all the values store in the 'Cust_Details' table
select * from Cust_Details;

-- 3. Create a non-clustered index on the country field
create index ixCountry on Cust_Details(Country);

-- Create a clustered index on the ProductID field of the product_details table
Create clustered index ix_ProductID on dbo.product_details(ProductID);

-- Create a non-clustered index on the city field in the 'Customer_Details'
create nonclustered index ixCity on Customer_Details(City);

-- Add a primary key constraint to the 'CricketTeam' table
Alter table dbo.Cricketteam
add constraint PK_TeamID primary key clustered(TeamID);

-- Create a primary xml index on the 'CricketTeam' table on the teaminfo column/field.
Create primary xml index PXML_Teaminfo
on dbo.cricketTeam(teaminfo)

-- Create a secondary index for value => optimises value() method which is useful when extracting scalar values
Create XML Index SXML_TeamInfo_Value
on dbo.CricketTeam(Teaminfo)
Using XMl Index PXML_Teaminfo
for Value;

-- Create a secondary index for path => optimises exists() method and path based lookups
Create XML Index SXML_TeamInfo_Path
on dbo.CricketTeam(Teaminfo)
Using XMl Index PXML_Teaminfo
for Path;

-- Create a secondary index for Property => best used with typed xml columns (the teaminfor column is using the CricketSchemaCollection xsd)
Create XML Index SXML_TeamInfo_Property
on dbo.CricketTeam(Teaminfo)
Using XMl Index PXML_Teaminfo
for Property;

-- TODO: 1. Create a non-clustered index on the productname field in the 'Product_Details' table.
create index ixProdName on dbo.product_details(ProductName);

-- Modify/alter the name of the ixProdName non-clustered index to 'IX_ProductName'
exec sp_rename N'dbo.product_details.ixProdName', N'IX_ProductName', N'Index';

-- Modify/alter the 'IX_ProductName' non-clustered index to disable it
alter index IX_ProductName on dbo.product_details Disable;

-- Modify/alter the 'IX_ProductName' non-clustered index to enable it
alter index IX_ProductName on dbo.product_details rebuild;

-- Remove/delete the 'IX_ProductName'non-clustered index if it exists
drop index if exists IX_ProductName on dbo.Product_details;

-- Create a table with computed values then index the computed column field
if OBJECT_ID('tblCalcArea') is null
	create table tblCalcArea
	(
		Length Decimal(10,2),
		Breadth Decimal(10,2),
		Area as length * breadth -- => computed column given by multiplying the length * breadth to get the shape's area
	)
else
	print('The ''tblCalcArea'' table already exists and will not be recreated!')

-- Add records in to the 'tblCalcArea' table
insert into tblCalcArea(Length,Breadth)
values
(34, 10),
(20, 20),
(33.4, 12),
(12, 7);

-- Check whether the records were inserted successfully
Select * from tblCalcArea;

-- Create an index on the area computed column
create index ixArea on tblCalcArea(Area);

-- The above index will be used in a query to get shapes with an area less than 400
Select *
from tblCalcArea
where Area < 400;

-- Create a unique index on the 'Emp_Cellular' phone table for the personid column
create unique index ixPersonID on dbo.emp_cellularphone(PersonID);

-- Create a filtered index for products sold for 4000 or more on the product_details table
Create index ixExpensiveProduct on dbo.product_details(rate)
where rate >= 4000;

-- Use the above index to get products costing 4000 or more
Select ProductID, ProductName [Product Name], Rate, coalesce(Description,'') [Description] -- use coalesce function to remove nulls from the resultset
from Product_Details
where Rate >= 4000;

-- ---------------------------------------------------------------------------
-- Demonstrate working with cursors
-- ---------------------------------------------------------------------------
--1. Create an Employee's Table
Create Table Employee
(
	EmpID int not null primary key,
	EmpName nvarchar(100) not null,
	Salary int not null,
	Address nvarchar(200) not null
);

--2. Insert employee records
Insert into dbo.Employee
values
(1,'Derek', 12000, 'Houston'),
(2,'David', 25000, 'Texas'),
(3,'Alan', 22000, 'New York'),
(4,'Matthew', 22000, 'Las Vegas'),
(5,'Joseph', 28000, 'Chicago');

--3. Confirm entry of records into the Employee's Table
Select * from Employee;

--4. Declare a cursor on the Employee's Table
set nocount on
declare @id int, @name nvarchar(100), @salary int
--A cursor is declared by defining sql statements that return a resultset
declare curEmp Cursor
static for 
Select EmpID, EmpName, Salary from employee
--A cursor is opened and populated by executing the statement(s) 
--defined in the cursor
open curEmp
--Execute the statements below if the emp cursor contains rows
if @@CURSOR_ROWS > 0
	begin
		--Rows are fetched from the cursor one by one or in a block
		--for data manipulation
		Fetch next from curEmp into @id, @name, @salary
		while @@FETCH_STATUS = 0
		begin
			print 'ID: ' + convert(nvarchar(20),@id) + char(13) +
			'Name: ' + @name + char(13) +
			'Salary: ' + convert(nvarchar(20),@salary) + char(13)--> used for line break
			Fetch next from curEmp into @id, @name, @salary
		End
	End
--Close the cursor explicitly
Close curEmp
--Delete the cursor definition and release all the system resources associated
--with the cursor
deallocate curEmp
set nocount off