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

-- Demonstrate calculations on table columns
-- Get a 15% discount of the standardcost from the productcosthistory table in the production schema
select ProductID, StandardCost, StandardCost * .15 as [Discount Amount]
from Production.ProductCostHistory;

/* Re-write the above query to display the same fields/columns plus Discount price. 
   For each of monetary column, results are displayed correct to 2 d.p. */
select ProductID, convert(decimal(10,2),StandardCost) as [Standard Cost],convert(decimal(10,2),(StandardCost * .15)) as [Discount Amount], convert(decimal(10,2),StandardCost) - convert(decimal(10,2),(StandardCost * .15)) as [Discounted Price]
from Production.ProductCostHistory;

-- Display all the standardcosts from the productcosthistory table in the production schema
select  StandardCost as [Standard Cost]
from Production.ProductCostHistory;

-- Display only the distinct standardcosts from the productcosthistory table in the production schema
select distinct  StandardCost as [Standard Cost]
from Production.ProductCostHistory;

-- Display only the 1st five distinct standardcosts from the productcosthistory table in the production schema
select distinct top 5 StandardCost as [Standard Cost]
from Production.ProductCostHistory;

-- Display the five highest distinct standardcosts from the productcosthistory table in the production schema
select distinct top 5 StandardCost as [Standard Cost]
from Production.ProductCostHistory
order by [Standard Cost] desc;

-- Display the five lowest distinct standardcosts from the productcosthistory table in the production schema
select distinct top 5 StandardCost as [Standard Cost]
from Production.ProductCostHistory
order by [Standard Cost] ;

-- Switch to the customer database
use Cust_db_adse2509;

-- Get/fetch records from one table in AD2025 and insert/add them in a new table in the customer database
select ProductModelID, Name -- Columns to get values from
into cust_db_adse2509.dbo.ProductName -- Destination table where rows/tuples wil[dbo].[StoreProduct]l be inserted
from AdventureWorks2025.Production.ProductModel; -- Source table of the records/tuples

-- Confirm whether the table above was created and the records inserted
Select *
from Cust_db_adse2509.dbo.ProductName;

-- Filtering records using the 'Where' clause
-- Fetch records whose end date (completion date) is 29th May
Select * 
from Production.ProductCostHistory
where enddate = '2023-05-29 12:00:00 AM'; -- same as 'where enddate = '5/29/2023 12:00:00 am'

-- Get all the details of the departments with an id less than 10
select * 
from HumanResources.Department
where departmentid < 10;

-- Display all the details of individuals whose suffix starts with 'jr' followed by a single character
select *
from Person.person
where suffix like 'Jr_';

-- Display the title, firstname, and lastname of people whose title is 'Mr.' or 'Ms.'
select title, firstname, lastname
from Person.person
where title like 'M_.'; -- can be written as "Where title like 'Mr.' or title like 'Ms.'"

-- Display the BusinessEntityID and names of individuals whose last name starts with letter 'B'
select BusinessEntityID, CONCAT(firstname, ' ', middlename) as [Firstname and Initial], lastname
from person.person
where lastname like 'B%';

-- Fetch/retrieve all details of transaction from usd to canadian dollars or chinese yuan
select * 
from sales.currencyrate
where tocurrencycode like 'c[an][dy]';

-- Fetch/retrieve all details of transaction from usd to currencies starting with 'A' and not followed by an 'r' or an 's'
select * 
from sales.currencyrate
where tocurrencycode like 'a[^r][^s]';


-- Demostrate the 'group by' clause in a select statement 
-- Get/retrieve the number of hours per work order from the workrouting table in the production schema
select workorderid, sum(ActualResourceHRS) 'Hours Per Order'
from production.workorderrouting
group by workorderid
order by 'Hours Per Order' desc;  -- Optionally arrange/sort the results in descending order

-- Demonstrate the use of the 'order by' clause to arrange/sort the results in 
-- a) ascending order (default)
-- b) descending order
-- Display all records from the salesterritory tabe in the sales schema arranged by the saleslastyear column from the least to the greatest (ascending order)
Select * 
from sales.salesterritory
order by salesLastyear;

-- Individual assignment
-- TODO : 01. Get all the details of individuals from Bothel city in the address table in the Person schema

-- TODO : 02. Get all the details where the addressid is more than 900 or the addresstype is 5 in the businessEntityaddress table in the Person schema

-- Switch to the customer database
use Cust_db_adse2509;

-- Create a Person schema in the Customer Database
Create schema Person;

-- Create the PhoneBilling table in the Person Schema
Create table Person.PhoneBilling
(
	Bill_ID int Primary Key,
	MobileNumber bigint unique,
	CallDetails XML
);

-- Add a record into the PhoneBilling table in the Person Schema
Insert into Person.PhoneBilling
values
(100, 9833276605, '<info><call>Local</call><duration>45 Minutes</duration><charges>200</charges></info>');

-- Display the call details from the PhoneBilling table in the Person schema
Select calldetails from Person.PhoneBilling;

-- Declare and display the contents of an xml variable
Declare @xmlVar xml
set @xmlVar = '<Employee name = "Ciku"/>';
select @xmlVar as 'Contents of xml variable "@xmlVar"';

-- Create and register an XML schema
CREATE XML SCHEMA COLLECTION CricketSchemaCollection
AS N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" >
<xsd:element name="MatchDetails">
<xsd:complexType>
<xsd:complexContent>
<xsd:restriction base="xsd:anyType">
<xsd:sequence>
<xsd:element name="Team" minOccurs="0" maxOccurs="unbounded">
<xsd:complexType>
<xsd:complexContent>
<xsd:restriction base="xsd:anyType">
<xsd:sequence />
<xsd:attribute name="country" type="xsd:string" />
<xsd:attribute name="score" type="xsd:string" />
</xsd:restriction>
</xsd:complexContent>
</xsd:complexType>
</xsd:element>
</xsd:sequence>
</xsd:restriction>
</xsd:complexContent>
</xsd:complexType>
</xsd:element>
</xsd:schema>';

-- Create a CricketTeam table with an XML type column and specify the above schema will be used to validate the column
Create table CricketTeam
(
	TeamID int identity not null,
	TeamInfo xml(CricketSchemaCollection)
);

-- Insert/add data to the CricketTeam table
insert into CricketTeam (TeamInfo)
values
(
	'<MatchDetails>
		<Team country="Australia" score="355"></Team>
		<Team country="Zimbambwe" score="475"></Team>
		<Team country="England" score="200"></Team>
	</MatchDetails>'
);

-- Create a typed xml variable using the 'CricketSchemaCollection' schema
Declare @team xml(CricketSchemaCollection)
Set @team = '<MatchDetails><Team country="Australia"></Team></MatchDetails>'
Select @team as 'Team';

-- Demonstrate the use of exist() method
Select TeamID
from CricketTeam
where TeamInfo.exist('(/MatchDetails/Team)') = 1;

-- Demonstrate the use of query() method
Select  TeamInfo.query('(/MatchDetails/Team)')As info
from CricketTeam;

-- Demonstrate the use of value() method
Select TeamInfo.value('(/MatchDetails/Team/@score)[1]','varchar(20)') as 'Score'
from CricketTeam
where TeamID = 1;



