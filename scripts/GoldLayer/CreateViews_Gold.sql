--USE DataWarehouseDB

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

SELECT *
FROM Gold.dim_CustomerInfo
