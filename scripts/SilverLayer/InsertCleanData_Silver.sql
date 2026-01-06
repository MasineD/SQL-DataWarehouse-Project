
/********** Cleaninng the CustomerInfo table **********/
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

/********** Cleaninng the ProductInfo table **********/
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

/************* Cleaning the SalesDetails table *******************/
/*	Rules used for Sales, Quantity, and Price:
	1.If Sales is ZERO, NEGATIVE OR NULL, then calculate the value using Price and Quantity
	2.If Price is ZERO OR NULL,calculate it using Sales and Quantity
	3.If Price is NEGATIVE, convert it to POSITIVE
*/
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






