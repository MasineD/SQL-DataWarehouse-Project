/*
	PURPOSE:
		1.Creating the tables to store the data used in this project
	WARNING:
		1.Running this script will first drop(delete) any existing table with the same name and then
		  create a new one
*/

USE DataWarehouseDB;

--Creating the customers INFO table
IF OBJECT_ID('Silver.crm_CustomerInfo', 'U') IS NOT NULL
	DROP TABLE Silver.crm_CustomerInfo;
CREATE TABLE Silver.crm_CustomerInfo(
	CustomerID INT,
	CustomerKey NVARCHAR(50),
	CustomerLastName NVARCHAR(50),
	CustomerFirstName NVARCHAR(50),
	CustomerMaritalStatus NVARCHAR(50),
	CustomerGender NVARCHAR(50),
	CustomerCreateDate DATE,
	dwh_CreateDate DATETIME2 DEFAULT GETDATE()
);
--Creating the products table
IF OBJECT_ID('Silver.crm_ProductInfo', 'U') IS NOT NULL
	DROP TABLE Silver.crm_ProductInfo;
CREATE TABLE Silver.crm_ProductInfo(
	ProductID INT,
	CategoryID NVARCHAR(50),
	ProductKey NVARCHAR(50),
	ProductName NVARCHAR(50),
	ProductCost INT,
	ProductLine NVARCHAR(50),
	ProductStartDate DATE,
	ProductEndDate DATE,
	dwh_CreateDate DATETIME2 DEFAULT GETDATE()
);
--Creating the sales table
IF OBJECT_ID('Silver.crm_SalesDetails', 'U') IS NOT NULL
	DROP TABLE Silver.crm_SalesDetails;
CREATE TABLE Silver.crm_SalesDetails(
	OrderNumber NVARCHAR(50),
	ProductKey NVARCHAR(50),
	CustomerID INT,
	OrderDate DATE,
	ShipDate DATE,
	DueDate DATE,
	Sales INT,
	Quantity INT,
	Price INT,
	dwh_CreateDate DATETIME2 DEFAULT GETDATE()
);
--Creating the customers table
IF OBJECT_ID('Silver.erp_Customers', 'U') IS NOT NULL
	DROP TABLE Silver.erp_Customers;
CREATE TABLE Silver.erp_Customers(
	ID NVARCHAR(50),
	BirthDate DATE,
	Gender NVARCHAR(50),
	dwh_CreateDate DATETIME2 DEFAULT GETDATE()
);
--Creating the locations table
IF OBJECT_ID('Silver.erp_Location', 'U') IS NOT NULL
	DROP TABLE Silver.erp_Location;
CREATE TABLE Silver.erp_Location(
	CustomerID NVARCHAR(50),
	Country NVARCHAR(50),
	dwh_CreateDate DATETIME2 DEFAULT GETDATE()
);
--Creating the products category table
IF OBJECT_ID('Silver.erp_ProductsCatalogue', 'U') IS NOT NULL
	DROP TABLE Silver.erp_ProductsCatalogue;
CREATE TABLE Silver.erp_ProductsCatalogue(
	ID NVARCHAR(50),
	Category NVARCHAR(50),
	SubCategory NVARCHAR(50),
	Maintenance NVARCHAR(50),
	dwh_CreateDate DATETIME2 DEFAULT GETDATE()
);