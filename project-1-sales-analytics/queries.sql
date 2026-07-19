-- ============================================================
-- PROJECT 1: SALES ANALYTICS - SQL QUERIES
-- Author: Clinton Emengini
-- Tools: SQL (MySQL/PostgreSQL compatible)
-- ============================================================

-- 1. TOTAL SALES BY REGION
SELECT 
    Region,
    COUNT(*) AS TotalOrders,
    SUM(NetAmount) AS TotalRevenue,
    SUM(Profit) AS TotalProfit,
    ROUND(AVG(NetAmount), 2) AS AvgOrderValue
FROM sales_cleaned
GROUP BY Region
ORDER BY TotalRevenue DESC;

-- 2. TOP 10 CUSTOMERS BY REVENUE
SELECT 
    CustomerID,
    COUNT(*) AS OrderCount,
    SUM(NetAmount) AS TotalSpent,
    SUM(Profit) AS CustomerProfit
FROM sales_cleaned
GROUP BY CustomerID
ORDER BY TotalSpent DESC
LIMIT 10;

-- 3. MONTH-OVER-MONTH SALES GROWTH
WITH MonthlySales AS (
    SELECT 
        OrderMonth,
        SUM(NetAmount) AS MonthlyRevenue
    FROM sales_cleaned
    GROUP BY OrderMonth
)
SELECT 
    OrderMonth,
    MonthlyRevenue,
    LAG(MonthlyRevenue) OVER (ORDER BY OrderMonth) AS PrevMonthRevenue,
    ROUND(
        (MonthlyRevenue - LAG(MonthlyRevenue) OVER (ORDER BY OrderMonth)) 
        / LAG(MonthlyRevenue) OVER (ORDER BY OrderMonth) * 100, 
        2
    ) AS MoMGrowthPercent
FROM MonthlySales
ORDER BY OrderMonth;

-- 4. PRODUCT PERFORMANCE ANALYSIS
SELECT 
    Product,
    ProductCategory,
    COUNT(*) AS UnitsSold,
    SUM(Quantity) AS TotalQuantity,
    SUM(NetAmount) AS TotalRevenue,
    SUM(Profit) AS TotalProfit,
    ROUND(SUM(Profit) / SUM(NetAmount) * 100, 2) AS ProfitMarginPercent
FROM sales_cleaned
GROUP BY Product, ProductCategory
ORDER BY TotalRevenue DESC;

-- 5. SALES REP PERFORMANCE
SELECT 
    SalesRep,
    COUNT(*) AS OrdersHandled,
    SUM(NetAmount) AS TotalSales,
    SUM(Profit) AS TotalProfit,
    ROUND(AVG(NetAmount), 2) AS AvgOrderValue
FROM sales_cleaned
GROUP BY SalesRep
ORDER BY TotalSales DESC;

-- 6. PRODUCTS WITH DECLINING SALES (YoY Comparison)
WITH YearlyProductSales AS (
    SELECT 
        Product,
        OrderYear,
        SUM(NetAmount) AS YearlyRevenue
    FROM sales_cleaned
    GROUP BY Product, OrderYear
)
SELECT 
    y2024.Product,
    y2024.YearlyRevenue AS Revenue_2024,
    y2025.YearlyRevenue AS Revenue_2025,
    ROUND((y2025.YearlyRevenue - y2024.YearlyRevenue) / y2024.YearlyRevenue * 100, 2) AS YoY_ChangePercent
FROM YearlyProductSales y2024
JOIN YearlyProductSales y2025 ON y2024.Product = y2025.Product
WHERE y2024.OrderYear = 2024 AND y2025.OrderYear = 2025
ORDER BY YoY_ChangePercent ASC;

-- 7. QUARTERLY TRENDS
SELECT 
    OrderQuarter,
    SUM(NetAmount) AS QuarterlyRevenue,
    SUM(Profit) AS QuarterlyProfit,
    COUNT(*) AS OrderCount
FROM sales_cleaned
GROUP BY OrderQuarter
ORDER BY OrderQuarter;
