/* 
	PURPOSE:
	1.This scripts creates database and schemas used in this porject

	WARNING:
	1.Running the code in this script will first check if the database DataWarehouseDB exists, if
	  it does, it will be dropped(deleted) and a new one will be created.
*/
USE master;
GO

--Dropping an existing database and creating a new one
IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseDB')
	BEGIN
		ALTER DATABASE DataWarehouseDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE
		DROP DATABASE DataWarehouseDB
	END;
GO
CREATE DATABASE DataWarehouseDB;
GO
USE DataWarehouseDB;
GO
--Creating the schemas for each layer of the project
CREATE SCHEMA Bronze;
GO
CREATE SCHEMA Silver;
GO
CREATE SCHEMA Gold;