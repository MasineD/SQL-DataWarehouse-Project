/*
	PURPOSE:
		1.Creating the tables to store the data used in this project
	WARNING:
		1.Running this script will first drop(delete) any existing table with the same name and then
		  create a new one
*/

USE DataWarehouseDB;

--Creating the customers INFO table
IF OBJECT_ID('Bronze.crm_CustomerInfo', 'U') IS NOT NULL
	DROP TABLE Bronze.crm_CustomerInfo;
CREATE TABLE Bronze.crm_CustomerInfo(
	CustomerID INT,
	CustomerKey NVARCHAR(50),
	CustomerLastName NVARCHAR(50),
	CustomerFirstName NVARCHAR(50),
	CustomerMaritalStatus NVARCHAR(50),
	CustomerGender NVARCHAR(50),
	CustomerCreateDate DATE
);
--Creating the products table
IF OBJECT_ID('Bronze.crm_ProductInfo', 'U') IS NOT NULL
	DROP TABLE Bronze.crm_ProductInfo;
CREATE TABLE Bronze.crm_ProductInfo(
	ProductID INT,
	ProductKey NVARCHAR(50),
	ProductName NVARCHAR(50),
	ProductCost INT,
	ProductLine NVARCHAR(50),
	ProductStartDate DATETIME,
	ProductEndDate DATETIME
);
--Creating the sales table
IF OBJECT_ID('Bronze.crm_SalesDetails', 'U') IS NOT NULL
	DROP TABLE Bronze.crm_SalesDetails;
CREATE TABLE Bronze.crm_SalesDetails(
	OrderNumber NVARCHAR(50),
	ProductKey NVARCHAR(50),
	CustomerID INT,
	OrderDate INT,
	ShipDate INT,
	DueDate INT,
	Sales INT,
	Quantity INT,
	Price INT
);
--Creating the customers table
IF OBJECT_ID('Bronze.erp_Customers', 'U') IS NOT NULL
	DROP TABLE Bronze.erp_Customers;
CREATE TABLE Bronze.erp_Customers(
	ID NVARCHAR(50),
	BirthDate DATE,
	Gender NVARCHAR(50)
);
--Creating the locations table
IF OBJECT_ID('Bronze.erp_Location', 'U') IS NOT NULL
	DROP TABLE Bronze.erp_Location;
CREATE TABLE Bronze.erp_Location(
	CountryID NVARCHAR(50),
	Country NVARCHAR(50)
);
--Creating the products category table
IF OBJECT_ID('Bronze.erp_ProductsCategory', 'U') IS NOT NULL
	DROP TABLE Bronze.erp_ProductsCategory;
CREATE TABLE Bronze.erp_ProductsCategory(
	ID NVARCHAR(50),
	Category NVARCHAR(50),
	SubCategory NVARCHAR(50),
	Maintenance NVARCHAR(50)
);