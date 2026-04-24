/* Session 08 covers retrieving/fetching/getting data from an SQl Server database, 
   working with typed and untyped XML and XML Schemas. */

-- Demonstrate the use of the 'SELECT' clause without a 'FROM'
-- Pick off/get the first 5 characters from the word 'International'
Select LEFT('International',5) as [First 5 Characters];

-- Pick off/get the last 7 characters from the word 'International'
Select Right('International',7) as [Last 7 Characters];

-- Do some basic math using the 'SELECT' clause
select (7 + 5) as [Sum of 7 and 5];

-- Switch to the AW2025 database
Use AdventureWorks2025;

-- Use the 'Asterisk *' with a select clause to display all columns in the employee table in the HR schema
select * from HumanResources.Employee;

-- When currently working with another database, use the fully qualified name as shown below
select * from AdventureWorks2025.HumanResources.Employee;

-- Display the 'locationid' and 'costrate' from the location table in the production schema
select locationid, costrate from Production.Location;

-- Display the 'name' and 'regioncode' from the salesterritory table in the sales schema
select [Name], countryregioncode from sales.SalesTerritory;

-- Format the above query using constants
select [Name] + ' :' + [countryregioncode] + ' -->' + [group] as [Country Region and Code]
from sales.SalesTerritory;

-- Rename a column name using the as clause
USE AdventureWorks2025
SELECT ModifiedDate as 'ChangedDate' FROM Person.Person
GO