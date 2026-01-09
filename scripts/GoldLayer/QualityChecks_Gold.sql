/*
    PURPOSE:
    1.This script performs quality checks to validate the integrity, consistency, 
        and accuracy of the Gold Layer. These checks ensure:
        - Uniqueness of surrogate keys in dimension tables.
        - Referential integrity between fact and dimension tables.
        - Validation of relationships in the data model for analytical purposes.

    USAGE:
    - Investigate and resolve any discrepancies found during the checks.
*/

/*************** Checking Gold.dim_CustomerInfo *******************/
-- Check for Uniqueness of CustomerKey in Gold.dim_CustomerInfo
-- Expectation: No results 
SELECT CustomerKey, COUNT(*) AS duplicate_count
FROM Gold.dim_CustomerInfo
GROUP BY CustomerKey
HAVING COUNT(*) > 1;

/*************** Checking Gold.dim_Products *****************/
-- Check for Uniqueness of Product Key(SurrKey) in Gold.dim_Products
-- Expectation: No results 
SELECT SurrKey, COUNT(*) AS duplicate_count
FROM Gold.dim_Products
GROUP BY SurrKey
HAVING COUNT(*) > 1;

/*************** Checking Gold.fact_Sales **************/
-- Checking the quality of the data model connectivity between fact and dimension tables
SELECT * 
FROM Gold.fact_Sales f
LEFT JOIN Gold.dim_CustomerInfo c
ON c.CustomerKey = f.CustomerKey
LEFT JOIN Gold.dim_Products p
ON p.SurrKey = f.ProductKey
WHERE p.SurrKey IS NULL OR c.CustomerKey IS NULL  
