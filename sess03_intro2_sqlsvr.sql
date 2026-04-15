-- This script introduces us to SQL server and T-SQL

-- Switch/choose the adventureworks2022
use AdventureWorks2022;

-- Fetch/get/retrieve the top 10 rows from the shift table in the HR schema
Select top 10 [name]
From HumanResources.Shift;