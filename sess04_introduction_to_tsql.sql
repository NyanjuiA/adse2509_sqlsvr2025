/* This session introduces us to Microsoft's SQL Dialect - Transact SQL (T-SQL and its features) */

-- Switch to the Adventureworks2025 database
use adventureworks2025;

-- Get the login id of employees whose job title is design engineer from the employee table in the HR schema
Select LoginID as [Login ID]
from HumanResources.Employee
where jobTitle like 'Design Engineer';

-- Demonstrate the 'in' operator
-- Retrieve the persontype, title, firstname, and lastname of individuals with specific
-- person type values i.e. (either 'em' or 'sc')

Select PersonType, Title, FirstName, LastName
from AdventureWorks2025.Person.Person
where PersonType in ('em', 'sc');

-- Demonstrate the 'between' operator
-- Fetch/retrieve the employee details for employees hired between 2010 and 2013
Select BusinessEntityID, NationalIDNumber, LoginID, JobTitle, HireDate
from HumanResources.Employee
where HireDate between '01-01-2010' and '01-01-2013';

 -- Demonstrate the 'like' operator
 -- Get/fetch the department details for departments starting with letter 'p'
 SELECT DepartmentID, Name, GroupName, ModifiedDate
 FROM HumanResources.Department
 WHERE name like 'P%';

 -- Demonstrate the 'contains' operator
 select * from Person.Address
 where contains(AddressLine1,'Street'); -- will not work as the field/column is not full-text indexed. (sess11)

 -- ---------------------------------------------------------------
 -- Demonstrate Variables and Operators in T-SQL
 -- ---------------------------------------------------------------
 Declare @number int; -- Declare a variable of type int
 Set @number = 2 + 2 * ( 4  + (5 - 3)) -- Assign a value to a variable using expression
 select @number as [Answer];

 -- ---------------------------------------------------------------
 -- Demonstrate inbuilt T-SQL functions
 -- ---------------------------------------------------------------
 -- Get and display a) current date, b) current year, from the current sqlserver instance using in-built functions. 
 select GETDATE() as 'Current Date';
 select Year(getdate()) as 'Current Year';


 -- Use in-built functions in a query
 -- Get the sales details for the order date year and subsequent year from the salesorderheader table in the sales schema
 select SalesOrderID, CustomerID, SalesPersonID, TerritoryID, Year(orderdate) as 'Order Year', year(orderdate) + 1 as 'Subsequent Year'
 from Sales.SalesOrderHeader;

 -- ---------------------------------------------------------------
 -- Demonstrate the logical flow of how an SQL statement is executed in T-SQL
 -- ---------------------------------------------------------------
 Select SalesPersonID, YEAR(orderdate) as [Order Year] -- 5th
 from Sales.SalesOrderHeader   -- 1st
 where CustomerID = 30084      -- 2nd
 group by SalesPersonID, year(OrderDate)  -- 3rd
 having count(*) > 1 -- 4th
 order by salesPersonid, [Order Year]; -- 6th