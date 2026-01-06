/*
	PURPOSE:
		1. Creating a STORED PROCEDURE to clean and insert data into silver layer  tables from from corresponding tables in the bronze layer
		2.The procedure does not take any parameters nor return any values
	
	WARNING:
		1.Running this code will first delete any records from the existing tables the load or insert the new data

	USAGE EXAMPLE:
		EXEC Silver.LoadSilver;
*/

CREATE OR ALTER PROCEDURE Silver.LoadSilver AS
BEGIN
	BEGIN TRY
		PRINT '========================================================='
		PRINT '				Loading the SILVER layer					'
		PRINT '========================================================='
		DECLARE @ProcedureStartTime DATETIME, @ProcedureEndTime DATETIME, @StartTime DATETIME, @EndTime DATETIME
		SET @ProcedureStartTime = GETDATE();
		PRINT '----------------------------------------------------------'
		PRINT '			Cleaning and inserting data into CRM tables		 '
		PRINT '----------------------------------------------------------'
		PRINT''
		/********** Cleaninng the CustomerInfo table **********/
		PRINT '>>Truncating the Silver.crm_CustomerInfo table'
		TRUNCATE TABLE Silver.crm_CustomerInfo		--Truncating the table before inserting data, to avoid duplicate data
		PRINT '>>Inserting data into the Silver.crm_CustomerInfo table'
		SET @StartTime = GETDATE();
		INSERT INTO Silver.crm_CustomerInfo (CustomerID, CustomerKey, CustomerFirstName, CustomerLastName, CustomerGender,  CustomerMaritalStatus,CustomerCreateDate)
		--2.Removing unwanted spaces with a TRIM() function
		SELECT CustomerID, CustomerKey, TRIM(CustomerFirstName) AS CustomerFirstName, TRIM(CustomerLastName) AS CustomerLastName, 
		(CASE UPPER(TRIM(CustomerGender))	--3.Standardizing and normalizing the CustomerGender column using a CASE-WHEN statement	
			WHEN 'M' THEN 'Male'
			WHEN 'F' THEN 'Female'
			ELSE 'Unknown'
		END) AS CustomerGender,
			(CASE UPPER(TRIM(CustomerMaritalStatus))		--4.Standardizing and normalizing the CustomerMaritalStatus column using a CASE-WHEN statement	
				WHEN 'M' THEN 'Married'
				WHEN 'S' THEN 'Single'
				ELSE 'Unknown'
			END) AS CustomerMaritalStatus, CustomerCreateDate
		FROM (
			SELECT *, ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY CustomerCreateDate DESC) AS LatestDate
			FROM Bronze.crm_CustomerInfo
		) RankingSubQuery
		WHERE LatestDate = 1;	--1.Removing duplicates
		SET @EndTime = GETDATE();
		PRINT 'Time elapsed: '+ CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR) + ' seconds'

		/********** Cleaninng the ProductInfo table **********/
		PRINT '>>Truncating the Silver.crm_ProductInfo table'
		TRUNCATE TABLE Silver.crm_ProductInfo
		PRINT '>>Inserting the Silver.crm_ProductInfo table'
		SET @StartTime = GETDATE();
		INSERT INTO Silver.crm_ProductInfo (ProductID, ProductKey, CategoryID, ProductName, ProductCost, ProductLine, ProductStartDate, ProductEndDate)
		SELECT ProductID,SUBSTRING(ProductKey,7,LEN(ProductKey)) AS ProductKey, REPLACE(SUBSTRING(ProductKey,1,5),'-','_') AS CategoryID,	--Extracting the CategoryID from the ProductKey( Deriving new columns)
		TRIM(ProductName), ISNULL(ProductCost,0) AS ProductCost,	--Removing unwanted spaces and handling missing values
		(CASE UPPER(TRIM(ProductLine))		--Standardizing the ProductLine column
			WHEN 'M' THEN 'Mountain'
			WHEN 'R' THEN 'Road'
			WHEN 'S' THEN 'Other Sales'
			WHEN 'T' THEN 'Touring'
			ELSE 'Unknown'
		END) AS ProductLine, CAST(ProductStartDate AS DATE) ProductStartDate
		, CAST(LEAD(ProductStartDate) OVER(PARTITION BY ProductKey ORDER BY ProductStartDate)-1 AS DATE) AS ProductEndDate
		FROM Bronze.crm_ProductInfo;
		SET @EndTime = GETDATE();
		PRINT 'Time elapsed: '+ CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR) + ' seconds'

		/************* Cleaning the SalesDetails table *******************/
		/*	Rules used for Sales, Quantity, and Price:
			1.If Sales is ZERO, NEGATIVE OR NULL, then calculate the value using Price and Quantity
			2.If Price is ZERO OR NULL,calculate it using Sales and Quantity
			3.If Price is NEGATIVE, convert it to POSITIVE
		*/
		PRINT '>>Truncating the Silver.crm_SalesDetails table'
		TRUNCATE TABLE Silver.crm_SalesDetails
		PRINT '>>Inserting data into the Silver.crm_SalesDetails table'
		SET @StartTime = GETDATE();
		INSERT INTO Silver.crm_SalesDetails ( OrderNumber, ProductKey, CustomerID, OrderDate, ShipDate, DueDate, Sales, Quantity, Price)
		SELECT OrderNumber, ProductKey, CustomerID, --Removing invalid date variables
			(CASE
				WHEN OrderDate = 0 OR LEN(OrderDate) != 8 OR CAST(CAST(OrderDate AS VARCHAR) AS DATE) >= DATEADD(DAY,1,GETDATE()) OR OrderDate > DueDate
				THEN NULL
				ELSE  CAST(CAST(OrderDate AS VARCHAR) AS DATE)
			END) AS OrderDate,
			(CASE
				WHEN ShipDate = 0 OR LEN(ShipDate)  != 8 OR ShipDate < OrderDate THEN NULL
				ELSE  CAST(CAST(ShipDate AS VARCHAR) AS DATE)
			END) AS ShipDate,
			(CASE
				WHEN DueDate = 0 OR LEN(DueDate) != 8 OR OrderDate > DueDate THEN NULL
				ELSE  CAST(CAST(DueDate AS VARCHAR) AS DATE)
			END) AS DueDate,
			(CASE
				WHEN Sales IS NULL OR Sales <=0 OR Sales != Quantity * ABS(Price) THEN Quantity * ABS(Price)
				ELSE Sales
			END) AS Sales, Quantity,
			(CASE
				WHEN Price IS NULL OR Price <= 0 THEN Sales/NULLIF(Quantity,0)
				ELSE Price
			END) AS Price
		FROM Bronze.crm_SalesDetails
		SET @EndTime = GETDATE();
		PRINT 'Time elapsed: '+ CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR) + ' seconds'

		PRINT''
		PRINT '----------------------------------------------------------'
		PRINT '			Cleaning and inserting data into ERP tables		 '
		PRINT '----------------------------------------------------------'
		PRINT''
		/************* Cleaning the Customers table *******************/
		PRINT 'Truncating the Silver.erp_Customers table'
		TRUNCATE TABLE Silver.erp_Customers
		PRINT 'Inserting the Silver.erp_Customers table'
		SET @StartTime = GETDATE();
		INSERT INTO Silver.erp_Customers (ID, BirthDate, Gender)
		SELECT
			(CASE	--Extracting the CustomerID from the provided ID column
				WHEN ID LIKE 'NAS%' THEN SUBSTRING(ID,4,LEN(ID))
				ELSE ID
			END) CustomerID,
			(CASE	--Nullifying invalid dates
				WHEN BirthDate > GETDATE() THEN NULL
				ELSE BirthDate
			END )  AS BirthDate,
			(CASE	--Standardizing and normalizing the Gender column
				WHEN UPPER(TRIM(Gender)) IN('F','FEMALE') THEN 'Female'
				WHEN UPPER(TRIM(Gender)) IN('M','MALE') THEN 'Male'
				ELSE 'Unknown'
			END) AS Gender
		FROM Bronze.erp_Customers;
		SET @EndTime = GETDATE();
		PRINT 'Time elapsed: '+ CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR) + ' seconds'

		/************* Cleaning the Location table ******************/
		PRINT '>>Truncating the Silver.erp_Location table'
		TRUNCATE TABLE Silver.erp_Location
		PRINT '>>Inserting into the Silver.erp_Location table'
		SET @StartTime = GETDATE();
		INSERT INTO Silver.erp_Location (CustomerID, Country)
		SELECT REPLACE(CountryID,'-','') CustomerID,	--Remove the dash(-) in CustomerID to allow JOINs with Customers table
			(CASE	--Standardizing and normalising the Country column
				WHEN UPPER(TRIM(Country)) = 'DE' THEN 'Germany'
				WHEN UPPER(TRIM(Country)) IN ('US','USA') THEN 'United States'
				WHEN UPPER(TRIM(Country)) = '' OR UPPER(TRIM(Country)) IS NULL THEN 'Unknown'
				ELSE TRIM(Country)
			END)  Country
		FROM Bronze.erp_Location;
		SET @EndTime = GETDATE();
		PRINT 'Time elapsed: '+ CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR) + ' seconds'

		/************* Cleaning the ProductCatalogue table ******************/
		PRINT '>>Truncating the Silver.erp_ProductsCatalogue'
		TRUNCATE TABLE Silver.erp_ProductsCatalogue
		PRINT '>>Inserting into the Silver.erp_ProductsCatalogue'
		SET @StartTime = GETDATE();
		INSERT INTO Silver.erp_ProductsCatalogue (ID,Category, SubCategory, Maintenance)
		SELECT ID, Category, SubCategory, Maintenance
		FROM Bronze.erp_ProductsCategory
		SET @EndTime = GETDATE();
		PRINT 'Time elapsed: '+ CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR) + ' seconds'
		PRINT ''
		SET @ProcedureEndTime = GETDATE();
		PRINT 'Time elapsed to run STORED PROCEDURE: '+ CAST(DATEDIFF(SECOND, @ProcedureStartTime, @ProcedureEndTime) AS VARCHAR) + ' seconds'
	END TRY
	BEGIN CATCH
		PRINT '========================================================';
		PRINT 'ERROR OCCURED WHEN LOADING THE SILVER LAYER';
		PRINT 'Error Message :' + ERROR_MESSAGE();
		PRINT 'Error Number :' + CAST(ERROR_NUMBER() AS VARCHAR);
		PRINT 'Error State :' + CAST(ERROR_STATE() AS VARCHAR);
		PRINT '========================================================';
	END CATCH
END






