/*
	PURPOSE:
		1. Creating a STORED PROCEDURE to insert data into the tables from .csv files
		2.The procedure does not take any parameters nor return any values
	USAGE EXAMPLE:
		EXEC Bronze.LoadBronze;
	WARNNING:
		1.Running the code below will first delete any available data in the tables, and then insert
		  new data
*/
CREATE OR ALTER PROCEDURE Bronze.LoadBronze AS
BEGIN
	DECLARE @StartTime DATETIME, @EndTime DATETIME, @BronzeStartTime DATETIME, @BronzeEndTime DATETIME;
	BEGIN TRY
		SET @BronzeStartTime = GETDATE();
		PRINT '===================================================';
		PRINT '					Laoding the CRM files			  ';
		PRINT '===================================================';
		PRINT '>> --------Truncating Bronze.crm_CustomerInfo---------';
		TRUNCATE TABLE Bronze.crm_CustomerInfo;
		PRINT '--------Inserting into Bronze.crm_CustomerInfo---------';
		SET @StartTime = GETDATE();
		BULK INSERT Bronze.crm_CustomerInfo 
		FROM 'C:\Users\Donald\OneDrive\Documents\Data Analysis\DWH Project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);	
		SET @EndTime = GETDATE();
		PRINT 'Loading time for Bronze.crm_CustomerInfo: ' + CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR) + ' seconds'
		
		PRINT '';
		PRINT '>> --------Truncating Bronze.crm_ProductInfo table---------';
		TRUNCATE TABLE Bronze.crm_ProductInfo;
		PRINT '--------Inserting into Bronze.crm_ProductInfo table---------';
		SET @StartTime = GETDATE();
		BULK INSERT Bronze.crm_ProductInfo 
		FROM 'C:\Users\Donald\OneDrive\Documents\Data Analysis\DWH Project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @EndTime = GETDATE();
		PRINT 'Loading time for Bronze.crm_ProductInfo: ' + CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR) + ' seconds'
		
		PRINT '';
		PRINT '>> --------Truncating Bronze.crm_SalesDetails table---------';
		TRUNCATE TABLE Bronze.crm_SalesDetails;
		PRINT '--------Inserting into Bronze.crm_ProductInfo table---------';
		SET @StartTime = GETDATE()
		BULK INSERT Bronze.crm_SalesDetails 
		FROM 'C:\Users\Donald\OneDrive\Documents\Data Analysis\DWH Project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @EndTime = GETDATE();
		PRINT 'Loading time for Bronze.crm_SalesDetails: ' + CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR) + ' seconds'
		PRINT '';
		PRINT '';
		
		PRINT '===================================================';
		PRINT '					Laoding the ERP files			  ';
		PRINT '===================================================';
		PRINT '>> --------Truncating Bronze.erp_Customers table---------';
		TRUNCATE TABLE Bronze.erp_Customers;
		PRINT '--------Inserting into Bronze.erp_Customers table---------';
		SET @StartTime = GETDATE();
		BULK INSERT Bronze.erp_Customers 
		FROM 'C:\Users\Donald\OneDrive\Documents\Data Analysis\DWH Project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @EndTime = GETDATE()
		PRINT 'Loading time for Bronze.erp_Customers: ' + CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR) + ' seconds'
		PRINT '';

		PRINT '>> --------Truncating Bronze.erp_Location table---------';
		TRUNCATE TABLE Bronze.erp_Location;
		PRINT '--------Inserting into Bronze.erp_Location table---------';
		SET @StartTime = GETDATE();
		BULK INSERT Bronze.erp_Location 
		FROM 'C:\Users\Donald\OneDrive\Documents\Data Analysis\DWH Project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @EndTime = GETDATE();
		PRINT 'Loading time for Bronze.erp_Location: ' + CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR) + ' seconds';
		PRINT '';

		PRINT '>> --------Truncating Bronze.erp_Location table---------';
		TRUNCATE TABLE Bronze.erp_ProductsCategory;
		PRINT '--------Inserting into Bronze.erp_Location table---------';
		SET @StartTime = GETDATE();
		BULK INSERT Bronze.erp_ProductsCategory 
		FROM 'C:\Users\Donald\OneDrive\Documents\Data Analysis\DWH Project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		SET @EndTime = GETDATE();
		PRINT 'Loading time for Bronze.erp_Location: ' + CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS VARCHAR) + ' seconds';
		SET @BronzeEndTime = GETDATE();
		PRINT '==================================================';
		PRINT 'Bronze loading time: ' + CAST(DATEDIFF(SECOND,@BronzeStartTime, @BronzeEndTime) AS VARCHAR) + ' seconds';
		PRINT '==================================================';
	END TRY
	BEGIN CATCH
		PRINT '========================================================';
		PRINT 'ERROR OCCURED WHEN LOADING THE BRONZE LAYER';
		PRINT 'Error Message :' + ERROR_MESSAGE();
		PRINT 'Error Number :' + CAST(ERROR_NUMBER() AS VARCHAR);
		PRINT 'Error State :' + CAST(ERROR_STATE() AS VARCHAR);
		PRINT '========================================================';
	END CATCH
END;

/* TODO:
	1.Change the file paths after done with everything
*/