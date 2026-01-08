/*
	PURPOSE
		1.This creates the VIEWS used to access data in the Gold layer, which presents the final dimension
		  and fact tables using a Star Schema
		2.Each view performs transformations and combines data from different tables in the Silver layer to
		  produce cleaned,enriched, and business-ready datasets

	USAGE:
		1.The datasets can be used for analytics and reporting
*/

/************ Creating view for the CustomerInfo *************/
--NOTE: The CRM is the master for gender details
CREATE VIEW Gold.dim_CustomerInfo AS
SELECT ROW_NUMBER() OVER(ORDER BY ci.CustomerID) AS CustomerKey, ci.CustomerID, ci.CustomerKey AS CustomerNumber, ci.CustomerFirstName FirstName
	, ci.CustomerLastName AS LastName, l.Country, ci.CustomerMaritalStatus AS MaritalStatus
	,(CASE
		WHEN ci.CustomerGender != 'Unknown' THEN ci.CustomerGender
		ELSE COALESCE(c.Gender,'Unknown')
	END) Gender, c.BirthDate, ci.CustomerCreateDate AS CreateDate
FROM Silver.crm_CustomerInfo ci
LEFT JOIN Silver.erp_Customers c
ON ci.CustomerKey = c.ID
LEFT JOIN Silver.erp_Location l
ON ci.CustomerKey = l.CustomerID
WHERE ci.CustomerID IS NOT NULL;

/************ Creating view for the Products information *************/
CREATE VIEW Gold.dim_Products AS
SELECT ROW_NUMBER() OVER(ORDER BY  p.ProductStartDate,p.ProductKey) AS SurrKey, p.ProductID, p.ProductKey, p.ProductName, p.CategoryID,pc.Category, pc.SubCategory, pc.Maintenance
	, p.ProductCost, p.ProductLine, p.ProductStartDate, p.ProductEndDate
FROM Silver.crm_ProductInfo p
LEFT JOIN Silver.erp_ProductsCatalogue pc
ON p.CategoryID = pc.ID
WHERE ProductEndDate IS NULL;		--Filtering the historical data

/************ Creating view for the Sales information *************/
CREATE VIEW Gold.fact_Sales AS
SELECT OrderNumber, gp.SurrKey AS ProductKey, gc.CustomerKey, OrderDate, ShipDate, DueDate, Sales, Quantity, Price
FROM Silver.crm_SalesDetails s
LEFT JOIN Gold.dim_Products gp
ON s.ProductKey = gp.ProductKey
LEFT JOIN Gold.dim_CustomerInfo gc
ON s.CustomerID = gc.CustomerID

SELECT *
FROM Gold.fact_Sales