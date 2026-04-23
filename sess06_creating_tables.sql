/* Session 06 covers how to create, modify and delete (drop) tables and their columns in SQL Server. */

-- Switch or specify the database where the table(s) will be created
use Cust_db_adse2509;

-- Create a Customer table
Create table dbo.[Customer_1]
(
	Customer_ID_Number numeric(10,0) not null,
	[Customer_Name] varchar(55) not null
) on [Primary];

-- Make changes/modify and existing table
-- 01. Modify an existing column (change the column size of the customer id field)
alter table dbo.[Customer_1]
alter column Customer_ID_Number numeric(12,0) not null;

-- 02. Add a column (Add the customer contact to the customer table)
alter table customer_1
add Customer_contact varchar(10) not null;

-- 03. Remove or delete a column (delete the customer contact from the customer table)
alter table customer_1
drop column customer_contact;

-- Create and drop a dummy table
create table dummyTable(field1 nvarchar(10) not null);
drop table dummyTable;

-- NB: Once you drop a table you can't undo the command the only way to recover
-- is from a previous backup.

-- You can use the truncate table command to delete 
-- all the data in a table without deleting the table itself

-- Create a buddies table
Create table dbo.Buddies
(
	Buddy_Number numeric(12,0) not null primary key,
	Buddy_Name varchar(150) not null,
	Buddy_Nickname varchar(50)
)on [Primary];

-- Add records ( populate the table with data) to the buddies table
insert into Buddies
(Buddy_Number, Buddy_Name, Buddy_Nickname)
values
(101, 'Richard Parker', 'Richy'), -- Richie
(102, 'Mary Susan', 'Sue'),
(103, 'John Davidson', 'Davy');

-- Fetch/get/retrieve the above details from the buddies table
select * from buddies;

-- Modify/change (update) details in the buddies table
update Buddies
set Buddy_Nickname = 'Richie' -- Change Richard's nickname from 'Richy' to 'Richie'
where Buddy_Number = 101;  -- where buddy_name like 'Richard Parker'

-- Delete/remove a record/tuple/row from the buddies table
delete from buddies
where Buddy_Number = 103;

-- Truncate (delete all records from a table) the buddies table
truncate table buddies;

-- Create a table with a default column definition
create table StoreProduct
(
	ProductID int not null primary key,
	Name nvarchar(40) not null,
	Price money not null default(100)
) on [Primary];

-- Add/insert a record/row in the StoreProduct Table
insert into StoreProduct
(ProductID,Name)
values
(111,'Rivets');

-- Get all the records from the StoreProduct table
select * from StoreProduct;