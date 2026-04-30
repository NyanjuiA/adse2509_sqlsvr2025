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

