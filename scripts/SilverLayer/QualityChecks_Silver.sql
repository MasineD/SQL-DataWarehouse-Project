/*
    PURPOSE:
        1.This script performs various quality checks for data consistency, accuracy, 
            and standardization across the 'silver' layer. It includes checks for:
            - Null or duplicate primary keys.
            - Unwanted spaces in string fields.
            - Data standardization and consistency.
            - Invalid date ranges and orders.
            - Data consistency between related fields.

    USAGE:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
*/

/*************** Checking Silver.crm_CustomerInfo *************/
-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT CustomerKey 
FROM Silver.crm_CustomerInfo
WHERE CustomerKey != TRIM(CustomerKey);

-- Standadising and Normalising the data
SELECT DISTINCT CustomerMaritalStatus 
FROM Silver.crm_CustomerInfo;

/*********** Checking Silver.crm_ProductInfo **************/
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT ProductID, COUNT(*) 
FROM Silver.crm_ProductInfo
GROUP BY ProductID
HAVING COUNT(*) > 1 OR ProductID IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT ProductName 
FROM Silver.crm_ProductInfo
WHERE ProductName != TRIM(ProductName);

-- Check for NULLs or Negative Values in Cost
-- Expectation: No Results
SELECT ProductCost 
FROM Silver.crm_ProductInfo
WHERE ProductCost < 0 OR ProductCost IS NULL;

-- Normalising and standardising the data
SELECT DISTINCT ProductLine
FROM Silver.crm_ProductInfo;

-- Check for Invalid Date Orders (Start Date > End Date)
-- Expectation: No Results
SELECT * 
FROM Silver.crm_ProductInfo
WHERE ProductEndDate < ProductStartDate;

/************** Checking Bronze.crm_SalesDetails ***************/
-- Check for Invalid Dates
-- Expectation: No Invalid Dates
SELECT NULLIF(DueDate, 0) AS DueDate 
FROM Bronze.crm_SalesDetails
WHERE DueDate <= 0 
    OR LEN(DueDate) != 8 
    OR DueDate > 20500101 
    OR DueDate < 19000101;

/************** Checking Silver.crm_SalesDetails ***************/
-- Check for Invalid Date Orders (Order Date > Shipping/Due Dates)
-- Expectation: No Results
SELECT  * 
FROM Silver.crm_SalesDetails
WHERE OrderDate > ShipDate 
   OR OrderDate > ShipDate;

-- Check Data Consistency: Sales = Quantity * Price
-- Expectation: No Results
SELECT DISTINCT Sales, Quantity, Price 
FROM Silver.crm_SalesDetails
WHERE Sales != Quantity * Price
   OR Sales IS NULL 
   OR Quantity IS NULL 
   OR Price IS NULL
   OR Sales <= 0 
   OR Quantity <= 0 
   OR Price <= 0
ORDER BY Sales, Quantity, Price;

/*********** Checking Silver.erp_Customers ***************/
-- Identify Out-of-Range Dates
-- Expectation: Birthdates between 1924-01-01 and Today
SELECT DISTINCT BirthDate 
FROM Silver.erp_Customers
WHERE BirthDate < '1924-01-01' 
   OR BirthDate > GETDATE();

-- Data Standardization & Consistency
SELECT DISTINCT Gender 
FROM Silver.erp_Customers;

/*************** Checking Silver.erp_Location ******************/
-- Standadising and Normalising the data
SELECT DISTINCT Country 
FROM Silver.erp_Location
ORDER BY Country;

/************* Checking Silver.erp_ProductsCatalogue ***************/
-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT * 
FROM Silver.erp_ProductsCatalogue
WHERE Category != TRIM(Category) 
   OR SubCategory != TRIM(SubCategory) 
   OR Maintenance != TRIM(Maintenance);

-- Standadising and Normalising the data
SELECT DISTINCT Maintenance 
FROM Silver.erp_ProductsCatalogue;
