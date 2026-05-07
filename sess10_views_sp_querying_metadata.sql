/* This session covers working with views, stored procedures and querying database metadata. */

-- Switch to the customer database
use Cust_db_adse2509;

-- ---------------------------------------------------------------------------
-- Demonstrate creating, modifying and deleting views
-- ---------------------------------------------------------------------------
-- Create a view to display the details from the Production.Product table in the AD2025 DB
create view vwProductInfo as
Select ProductID [Product ID], ProductNumber [Product Number], [name] [Product Name],
SafetyStockLevel as [Safety Stock Level]
from AdventureWorks2025.Production.Product;

-- Display the records returned by the ProductInfo view
Select * from vwProductInfo;

-- Get all products with lock from the ProductInfo view
select [Product Name]
from vwProductInfo
where [Product Name] like '%Lock%';

-- Create a view using a join to get data from multiple tables
-- Create a view to display the personal detials of employees using data from the HR.Employee table and Person.Person table in the AD2025 DB
Create view vwPersonDetails as
Select P.Title, P.FirstName [First Name], P.MiddleName [Middle Name], P.LastName [Last Name],
E.JobTitle [Job Title], YEAR(GetDate()) - YEAR(E.Birthdate) as [Employee Age], e.Gender
From AdventureWorks2025.Person.Person P -- Person table alias
join AdventureWorks2025.HumanResources.Employee E -- Employee table alias
on P.BusinessEntityID = E.BusinessEntityID;

-- Display all the employee's personal details from the PersonDetails view
Select * from vwPersonDetails;

-- Recreate the above view but replace all null values in the title and middlename columns with an empty string using coalesce function.
Create view vwEmpDetails1 as
Select Coalesce(P.Title,'') [Title], P.FirstName [First Name], Coalesce(P.MiddleName,'') [Middle Name], P.LastName [Last Name],
E.JobTitle [Job Title], YEAR(GetDate()) - YEAR(E.Birthdate) as [Employee Age], e.Gender
From AdventureWorks2025.Person.Person P -- Person table alias
join AdventureWorks2025.HumanResources.Employee E -- Employee table alias
on P.BusinessEntityID = E.BusinessEntityID;

-- Display all the employee's personal details from the EmpDetails view
Select * from vwEmpDetails1;

-- Create tables to be used as the base tables for the employee details view
create table Employee_Personal_Details
(
	EmpID int not null primary key,
	FirstName nvarchar(30) not null,
	LastName nvarchar(30) not null,
	Address nvarchar(30)
);

Create table Employee_Salary_Details
(
	EmpID int not null Primary Key,
	Designation nvarchar(30) not null,
	Salary int not null
	Foreign key (EmpID) references Employee_Personal_Details(EmpID)
);

-- Insert records in the employee personal detials table and salary details table
insert into dbo.Employee_Personal_Details
values
(1, 'Jack', 'Wilson', '24, Park Ave.'),
(2, 'Susan', 'Andrews', '12, Hill Road'),
(3, 'Jack', 'Wilson', '24, Park Ave.');

insert into dbo.Employee_Salary_Details
values
(1, 'Accountant', 8000),
(2, 'Reviewer', 12000),
(3, 'Admin', 12500);

-- confirm above record insertions
select * from dbo.Employee_Personal_Details;
select * from dbo.Employee_Salary_Details;

-- Create a view to display the employee's personal and salary details
create view vwEmpDetails as
Select PD.EmpID [Employee ID], PD.FirstName, PD.LastName, SD.Designation, SD.Salary
from Employee_Personal_Details PD
join Employee_Salary_Details SD
on PD.EmpID = SD.EmpID;

-- Display the data returned by the employee details view
Select * from vwEmpDetails;

-- Try to insert the details of a new employee using the Employee details view
insert into vwEmpDetails
values
(2,'Jack','Wilson','Software Developer',160000); -- will not work as it gets its data from multiple base tables.

-- Create a view that will allow us to enter rows/records/tuples in the employee salary details table
create view vwEmp_Details as
Select EmpID, FirstName, LastName, Address
from Employee_Personal_Details;

-- Get/Display the records returned by the above view
Select * from vwEmp_Details;

-- Add/insert Jack Wilson's details using the 'vwEmp_details' view
insert into vwEmp_Details
values
(4,'Jack','Wilson','New York');

-- Create a product details table and its corresponding view that will be used to modify/update records in the table
Create table Product_Details  
(
	ProductID int not null,
	ProductName nvarchar(35) not null,
	Rate money not null
);

-- Insert/add records into the above table
insert into Product_Details
values
(5,'DVD Writer',2250.00),
(4,'DVD Writer',1250.00),
(6,'DVD Writer',1250.00),
(2,'External Hard Drive',4250.00),
(3,'External Hard Drive',4250.00);

-- Confirm table creation and record insertion
select * from Product_Details;