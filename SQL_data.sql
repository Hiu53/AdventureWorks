-- Total_Sales by date (TimeSeries):
SELECT OrderDate AS SalesDate, SUM(TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader
GROUP BY OrderDate
ORDER BY SalesDate;

-- RFM (Phân cụm):
WITH recency as(
    SELECT CustomerID, max(maxdiff) recency
    FROM 
        (SELECT CustomerID, datediff(DAY, OrderDate ,
            (SELECT max(OrderDate)
            FROM [Sales].[SalesOrderHeader])) maxdiff
        FROM [Sales].[SalesOrderHeader]) r
    GROUP BY CustomerID
),
frequency AS (
    SELECT CustomerID, COUNT(SalesOrderID) AS frequency
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
),
monetary AS (
    SELECT CustomerID, SUM(TotalDue) AS monetary
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
)
SELECT
    rc.CustomerID,
    rc.recency,
    fr.frequency,
    mo.monetary
FROM recency rc
JOIN frequency fr ON rc.CustomerID = fr.CustomerID
JOIN monetary mo ON rc.CustomerID = mo.CustomerID
WHERE rc.recency > 0 AND fr.frequency > 0 AND mo.monetary > 0
;

-------------------
WITH recency as(
    SELECT CustomerID, max(maxdiff) recency
    FROM 
        (SELECT CustomerID, datediff(DAY, OrderDate ,
            (SELECT max(OrderDate)
            FROM [Sales].[SalesOrderHeader])) maxdiff
        FROM [Sales].[SalesOrderHeader]) r
    GROUP BY CustomerID
),
frequency AS (
    SELECT CustomerID, COUNT(SalesOrderID) AS frequency
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
),
monetary AS (
    SELECT CustomerID, SUM(TotalDue) AS monetary
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
)
SELECT
    rc.CustomerID,
    rc.recency,
    fr.frequency,
    mo.monetary
FROM recency rc
JOIN frequency fr ON rc.CustomerID = fr.CustomerID
JOIN monetary mo ON rc.CustomerID = mo.CustomerID
WHERE rc.recency > 0 AND fr.frequency > 0 AND mo.monetary > 0
;

-- Bảng phụ Customers:
SELECT soh.CustomerID,
       per.FirstName + ' ' + ISNULL(per.MiddleName + ' ', '') + per.LastName AS CustomerName,
       st.Name + ',' + st.CountryRegionCode AS Region,
       st.[Group] AS Continent,
       AVG(sod.OrderQty) AS avg_quantity,
       AVG(sod.UnitPrice) AS avg_unit_price,
       SUM(sod.UnitPrice * sod.OrderQty) AS TotalRevenue,
       SUM(pro.StandardCost * sod.OrderQty) AS TotalCost,
       SUM(sod.UnitPrice * sod.OrderQty - pro.StandardCost * sod.OrderQty) AS TotalProfit
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesTerritory st ON st.TerritoryID = soh.TerritoryID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pro ON sod.ProductID = pro.ProductID
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person per ON c.PersonID = per.BusinessEntityID
GROUP BY soh.CustomerID, per.FirstName, per.MiddleName, per.LastName, st.Name, st.CountryRegionCode, st.[Group]


-- Bảng phụ Order:
SELECT soh.SalesPersonID,
       soh.CustomerID,
       soh.SalesOrderID,
       soh.OrderDate AS SalesDate, 
       soh.TotalDue AS TotalSales, 
       sod.ProductID,
       p.Name,
       p.ListPrice,
       pc.Name AS ProductCategory, 
       psc.Name AS ProductSubcategory,
       sod.OrderQty AS Quantity,
       sod.UnitPrice AS Price
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID

SELECT COUNT(distinct a.SalesOrderID) FROM Sales.SalesOrderHeader a