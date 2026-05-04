/* Session 09 cover grouping, aggregating data, subqueries, joins, table expressions, and pivoting & unpivoting data. */

-- Switch to the Adventureworks2025 database
use AdventureWorks2025;

-- ---------------------------------------------------------------------------
-- Demonstrate the 'group by' clause in a select statement
-- ---------------------------------------------------------------------------
-- Get/retrieve the number of hours per work order from the workrouting table in the production schema
select workorderid, sum(ActualResourceHRS) 'Hours Per Order'
from production.workorderrouting
group by workorderid;

-- Get/retrieve the number of hours per work order from the workrouting table in the production schema for work
-- order ids that are less than 50
select workorderid, sum(ActualResourceHRS) 'Hours Per Order'
from production.workorderrouting
where WorkOrderID < 50
group by workorderid;

-- Get the average prices of products from the product table in the production schema and group them by class
Select class, AVG(ListPrice) as 'Average List Price'
from Production.Product
group by Class;

-- Get the sum of the salesYTD column from the salesterritory table in the sales schema and group them by
-- names that start with 'N' or 'E'  using the 'group by' with all
select [group], sum(salesytd) as 'Total Region Sales'
from Sales.SalesTerritory
where [group] like 'N%' or [group] like 'E%'
group by all [group];

-- Get/display the total sales in various regions from the salesterritory table in the sales schema for sales
-- less than 6M
select [group], convert(decimal(10,2),sum(salesytd)) as 'Total Region Sales'
from Sales.SalesTerritory
group by [group]
having sum(salesytd) < 6000000;

-- Get or display the total sales in countries other than 'Australia' or 'Canada' using the 'cube' operator
select [Name], CountryRegionCode, sum(salesytd) as 'Total Region Sales'
from sales.SalesTerritory
where [Name] <> 'Australia' and [Name] not like 'Canada'
group by [Name], CountryRegionCode with Cube;

-- Get or display the total sales in countries other than 'Australia' or 'Canada' using the 'rollup' operator (records in the resultset with be sorted/arranged in ascending order)
select [Name], CountryRegionCode, sum(salesytd) as 'Total Region Sales'
from sales.SalesTerritory
where [Name] <> 'Australia' and [Name] not like 'Canada'
group by [Name], CountryRegionCode with rollup;

-- ---------------------------------------------------------------------------
-- Demonstrate Various SQL Server aggregate functions
-- ---------------------------------------------------------------------------
-- Get the average/mean price, least order quantity and highest unit price from the salesorder table in the sales schema
select AVG(unitprice) as [Average Unit Price],
MIN(Orderqty) as 'Minimum Order Quantity',
MAX(unitPricediscount) as 'Maximum Discount'
from Sales.SalesOrderDetail;


-- Get the earliest and latest order dates from the salesorderheader table in the sales schema
select MIN(orderdate)  [Earliest Order],
MAX(orderdate) as 'Most recent Order'
from Sales.SalesOrderHeader

-- ---------------------------------------------------------------------------
-- Demonstrate Various SQL Spatial aggregate functions
-- ---------------------------------------------------------------------------
-- Link to lookup Spatial data in MS-SQL server
-- 1. https://docs.microsoft.com/en-gb/sql/relational-databases/spatial/spatial-data-types-overview
-- 2. https://www.red-gate.com/simple-talk/sql/t-sql-programming/introduction-to-sql-server-spatial-data/
-- Demonstrate the use of STUnion() function
select geometry::Point(251, 1, 4326).STUnion(geometry::Point(252, 2,4326));

-- Another example of STUnion()
-- 1. Declare 2 variables of the 'geography' type to represent spatial(geographic) areas
Declare @city1 geography, @city2 geography

-- 2. Set te values of '@city1' & '@city2' with different sets of geographic coodinates using latitude and longitude coordinates in Well-Known Text (WKT) format
set @city1 = geography::STPolyFromText('POLYGON((175.3 -41.5, 178.3 37.9, 172.8 -34.6, 175.3 -41.5))', 4326)
set @city2 = geography::STPolyFromText('POLYGON((169.3 -46.6, 174.3 41.6, 172.5 -40.7, 169.3 -46.6))', 4326)

-- 3. Create a new geography variable called '@combinedCity' using the STUnion() method to merge the shapes of '@city1' & '@city2'
declare @combinedCity geography = @city1.STUnion(@city2);

-- 4. Display the combined geography object (merged polygon) as the result of the query
select @combinedCity as 'Merged Poly of @city1 & @city2';

-- Example that merges all the living areas (geography values) for addresses in London from the Address table in the Person schemal uisn the UnionAggregate() function.
select Geography::UnionAggregate(SpatialLocation) as 'Average Location'
from Person.Address
where city like 'London';

-- Return the smallest/minimal bounding rectangle that contains all spatial instances in the spatiallocation column in the address table in the person schema
select Geography::EnvelopeAggregate(SpatialLocation) as 'London Area Bounds'
from Person.Address
where city like 'London';

-- Declare a table object/variable with two columns of type geometry and nvarchar
Declare @collectionDemo Table
(
	Shape geometry,
	ShapeType nvarchar(50)
);

-- Insert two records in the @collectionDemo variable table
insert into @collectionDemo
values
('CURVEPOLYGON(CIRCULARSTRING(2 3, 4 1, 6 3, 4 5, 2 3))','Circle'),
('POLYGON((1 1, 4 1, 4 5, 1 5, 1 1))','Rectangle');

-- Use the CollectionAggregate() function to aggregate the circle and rectangle intoa single geometry collection.
Select geometry::CollectionAggregate(Shape) as 'Combined Shape'
from @collectionDemo;

-- Use the ConvexHullAggregate() function to get the convex hull( smallest convex polygon) that contains all the geography points from the spatiallocaiton column in the address table in the Person schea
Select Geography::ConvexHullAggregate(SpatialLocation) as 'London Coverage Area'
from Person.Address
where city like 'London';

-- ---------------------------------------------------------------------------
-- Demonstrate Subqueries in SQL Server
-- ---------------------------------------------------------------------------
-- Use a subquery to get/obtain the shipping date of the latest/most recent order
select DueDate as 'Due Date', ShipDate 'Shipping Date'
from Sales.SalesOrderHeader
where OrderDate = 
(
	-- Subquery to get the latest/most recent order
	select MAX(OrderDate)
	from Sales.SalesOrderHeader
);

-- Get the first and last names of employees whose job title is R&D manager using the in clause and a subquery
select FirstName as 'First Name', LastName as 'Last Name'
from Person.Person
where Person.Person.BusinessEntityID in
(
	-- Subquery to get the employee's job title
	Select BusinessEntityID
	from HumanResources.Employee
	where JobTitle like 'Research and Development Manager'
);

-- Use a nested subquery to display the names of employees (salespersons) whose sales territory is canada
select Concat(P.FirstName, ' ', P.LastName) as 'Names'
from Person.Person as P -- Alias for the Person table
where P.BusinessEntityID in
(
	-- Outer subquery to fetch the Person's businessentityid
	select SP.BusinessEntityID
	from Sales.SalesPerson as SP -- Alias for the SalesPerson table
	where TerritoryID in
	(
		-- Inner subquerry to fetch the territoryId for the canada region
		Select ST.TerritoryID
		from Sales.SalesTerritory ST -- Alias for the SalesTerritory table
		where [Name] like 'Canada'
	)
);

-- Get the BusinessEntityID(s) of all individuals modified/changed before 2019 using a correlated query
Select BE.BusinessEntityID
from Person.BusinessEntityContact BE
where BE.ContactTypeID in
(
	-- Correlated subquery to get the contacttypeid modified b4 2019
	Select CT.ContactTypeID
	from Person.ContactType CT
	where YEAR(BE.ModifiedDate) < 2019
);

-- ---------------------------------------------------------------------------
-- Demonstrate Various SQL joins
-- ---------------------------------------------------------------------------
-- Retrieve the person's first and last name from  the person table in the person schema, and the jobtitle from the employee table in the HR schema by joining the on the the BusinessEntityID column which is common between the using an 'inner join'
select P.FirstName 'First Name', P.LastName 'Last Name', E.JobTitle 'Job Title'
from Person.Person P -- Person table alias
inner join HumanResources.Employee E -- Employee table alias
on P.BusinessEntityID = E.BusinessEntityID;

-- Get all the CustomerID(s) from the customer table in the sales schema and the shippingdate & duedate in the salesorderheader table in the sales schema even for customers that have not placed any orders using a 'left outer join'
Select C.CustomerID 'Customer''s ID', SO.DueDate 'Due Date', so.ShipDate as [Shipping Date]
from sales.Customer C
left outer join sales.SalesOrderHeader SO
on C.CustomerID = SO.CustomerID
and YEAR(SO.DueDate) < 2012;

-- Get all products from the production.product table with their associated salesorderid(s) using  a 'right-outer join' to include all products even when they've not been sold, i.e., they have no matching record(s) in the Sales.salesorderdetail table.
select p.name 'Product Name', s.SalesOrderDetailID 'Sales Order ID'
from sales.SalesOrderDetail S
right outer join production.product P
on S.Productid = p.productid;

-- Rewrite the above using a left outer join (More intuitive as it starts with the 'main' table in this case, production.product)
Select P.Name 'Product Name', S.SalesOrderID 'Sales Order ID'
from Production.Product P
left outer join Sales.SalesOrderDetail S 
on P.ProductID = S.ProductID;

-- Switch to the Customer database
use Cust_db_adse2509;

-- Create a SterlingEmployee table to store the details of employees
if OBJECT_ID('SterlingEmployee') is null
	create table SterlingEmployee
	(
		Emp_ID nvarchar(20) not null primary key,
		Fname nvarchar(20) not null,
		Middle_init nvarchar(1), 
		Lname nvarchar(20) not null,
		Job_ID int not null,
		Job_Level int not null,
		Pub_ID nvarchar(5) not null,
		Hire_Date datetime not null,
		Mngr_ID nvarchar(20)
	)
else
	print 'The ''SterlingEmployee'' table already exist!!';

-- Populate the SterlingEmployee table with employee details
Insert into dbo.SterlingEmployee values
('PMA42628M','Paolo','M','Accorti',13,35,'0877','1992-08-27','POK93028M'),
('PSA89086M','Pedro','S','Afonso',14,89,'1389','1990-12-24','POK93028M'),
('VPA30890F','Victoria','S','Ashworth',6,140,'0877','1990-09-13','ARD36733F'),
('H-B39728F','Helen','','Bennett',12,35,'0877','1989-09-21','POK93028M'),
('L-B31947F','Lesley','','Brown',7,120,'0877','1991-02-13','ARD36733F'),
('F-C16315M','Francisco','','Chang',4,227,'9952','1990-11-03','MAS70474F'),
('PTC11962M','Philip','T','Cramer',2,215,'9952','1989-11-11','MAS70474F'),
('A-C71970F','Aria','','Cruz',10,87,'1389','1991-10-26','POK93028M'),
('AMD15433F','Ann','M','Devon',3,200,'9952','1991-07-16','MAS70474F'),
('ARD36733F','Anabela','R','Domingues',8,100,'0877','1993-01-27',''),
('PHF38899M','Peter','H','Franken',10,75,'0877','1992-05-17','POK93028M'),
('PXH22250M','Paul','X','Henroit',5,159,'0877','1993-08-19','MAS70474F');

insert into 
SterlingEmployee values 
('POK93028M', 'Pirkko', 'O', 'Koskitalo', 10, 80, '9999', '1993-11-29','');

insert into 
SterlingEmployee values 
('MAS70474F', 'Margaret', 'A', 'Smith', 9, 78, '1389', '1988-09-29','');

-- records obtained from the pubs database sqlserver 2008
insert into SterlingEmployee values ('LAL21447M', 'Laurence', 'A', 'Lebihan', 5, 175, '0736', '06/03/90', 'ARD36733F')
insert into SterlingEmployee values ('SKO22412M', 'Sven', 'K', 'Ottlieb', 5, 150, '1389', '04/05/91', 'POK93028M')
insert into SterlingEmployee values ('RBM23061F', 'Rita', 'B', 'Muller', 5, 198, '1622', '10/09/93', 'ARD36733F')
insert into SterlingEmployee values ('MJP25939M', 'Maria', 'J', 'Pontes', 5, 246, '1756', '03/01/89', 'MAS70474F')
insert into SterlingEmployee values ('JYL26161F', 'Janine', 'Y', 'Labrune', 5, 172, '9901', '05/26/91', 'POK93028M')
insert into SterlingEmployee values ('CFH28514M', 'Carlos', 'F', 'Hernadez', 5, 211, '9999', '04/21/89', 'ARD36733F')
insert into SterlingEmployee values ('M-R38834F', 'Martine', '', 'Rance', 9, 75, '0877', '02/05/92', 'ARD36733F')
insert into SterlingEmployee values ('DBT39435M', 'Daniel', 'B', 'Tonini', 11, 75, '0877', '01/01/90', 'POK93028M')
insert into SterlingEmployee values ('ENL44273F', 'Elizabeth', 'N', 'Lincoln', 14, 35, '0877', '07/24/90', 'ARD36733F')

GO

insert into SterlingEmployee values ('MGK44605M', 'Matti', 'G', 'Karttunen', 6, 220, '0736', '05/01/94', 'MAS70474F')
insert into SterlingEmployee values ('PDI47470M', 'Palle', 'D', 'Ibsen', 7, 195, '0736', '05/09/93', 'POK93028M')
insert into SterlingEmployee values ('MMS49649F', 'Mary', 'M', 'Saveley', 8, 175, '0736', '06/29/93', 'ARD36733F')
insert into SterlingEmployee values ('GHT50241M', 'Gary', 'H', 'Thomas', 9, 170, '0736', '08/09/88', 'MAS70474F')
insert into SterlingEmployee values ('MFS52347M', 'Martin', 'F', 'Sommer', 10, 165, '0736', '04/13/90', 'POK93028M')
insert into SterlingEmployee values ('R-M53550M', 'Roland', '', 'Mendel', 11, 150, '0736', '09/05/91', 'ARD36733F')
insert into SterlingEmployee values ('HAS54740M', 'Howard', 'A', 'Snyder', 12, 100, '0736', '11/19/88', 'MAS70474F')
insert into SterlingEmployee values ('TPO55093M', 'Timothy', 'P', 'O''Rourke', 13, 100, '0736', '06/19/88', 'POK93028M')
insert into SterlingEmployee values ('KFJ64308F', 'Karin', 'F', 'Josephs', 14, 100, '0736', '10/17/92', 'ARD36733F')
insert into SterlingEmployee values ('DWR65030M', 'Diego', 'W', 'Roel', 6, 192, '1389', '12/16/91', 'MAS70474F')
insert into SterlingEmployee values ('M-L67958F', 'Maria', '', 'Larsson', 7, 135, '1389', '03/27/92', 'POK93028M')
insert into SterlingEmployee values ('PSP68661F', 'Paula', 'S', 'Parente', 8, 125, '1389', '01/19/94', 'ARD36733F')
insert into SterlingEmployee values ('MAP77183M', 'Miguel', 'A', 'Paolino', 11, 112, '1389', '12/07/92', 'POK93028M')
insert into SterlingEmployee values ('Y-L77953M', 'Yoshi', '', 'Latimer', 12, 32, '1389', '06/11/89', 'ARD36733F')
insert into SterlingEmployee values ('CGS88322F', 'Carine', 'G', 'Schmitt', 13, 64, '1389', '07/07/92', 'MAS70474F')
insert into SterlingEmployee values ('A-R89858F', 'Annette', '', 'Roulet', 6, 152, '9999', '02/21/90', 'POK93028M')
insert into SterlingEmployee values ('HAN90777M', 'Helvetius', 'A', 'Nagy', 7, 120, '9999', '03/19/93', 'ARD36733F')
insert into SterlingEmployee values ('M-P91209M', 'Manuel', '', 'Pereira', 8, 101, '9999', '01/09/89', 'MAS70474F')
insert into SterlingEmployee values ('KJJ92907F', 'Karla', 'J', 'Jablonski', 9, 170, '9999', '03/11/94', 'POK93028M')
insert into SterlingEmployee values ('PCM98509F', 'Patricia', 'C', 'McKenna', 11, 150, '9999', '08/01/89', 'ARD36733F')


-- Display/fetch all the records added/inserted from the dbo.SterlingEmployee table
select * from dbo.SterlingEmployee;