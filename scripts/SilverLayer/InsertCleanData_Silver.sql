
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

