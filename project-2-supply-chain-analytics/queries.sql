-- ============================================================
-- PROJECT 2: SUPPLY CHAIN ANALYTICS - SQL QUERIES
-- Author: Clinton Emengini
-- Industry: Dairy / Agri-Food / Logistics
-- ============================================================

-- 1. AVERAGE DELIVERY TIME BY CARRIER
SELECT 
    Carrier,
    COUNT(*) AS TotalShipments,
    ROUND(AVG(DaysDelayed), 2) AS AvgDaysDelayed,
    SUM(CASE WHEN DaysDelayed > 0 THEN 1 ELSE 0 END) AS DelayedShipments,
    ROUND(SUM(CASE WHEN DaysDelayed > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DelayRatePercent
FROM supplychain_cleaned
WHERE DeliveryStatus != 'Cancelled'
GROUP BY Carrier
ORDER BY AvgDaysDelayed ASC;

-- 2. PRODUCTS WITH STOCK LEVELS BELOW REORDER POINT (simulated)
-- Assuming reorder point = average monthly demand * 2
WITH MonthlyDemand AS (
    SELECT 
        ProductID,
        ProductName,
        AVG(QuantityOrdered) AS AvgMonthlyDemand,
        AVG(QuantityOrdered) * 2 AS ReorderPoint
    FROM supplychain_cleaned
    GROUP BY ProductID, ProductName
),
CurrentStock AS (
    SELECT 
        ProductID,
        SUM(QuantityOrdered) AS TotalReceived
    FROM supplychain_cleaned
    WHERE DeliveryStatus = 'Delivered'
    GROUP BY ProductID
)
SELECT 
    m.ProductID,
    m.ProductName,
    m.ReorderPoint,
    COALESCE(c.TotalReceived, 0) AS CurrentStock,
    CASE WHEN COALESCE(c.TotalReceived, 0) < m.ReorderPoint THEN 'REORDER NOW' ELSE 'OK' END AS StockStatus
FROM MonthlyDemand m
LEFT JOIN CurrentStock c ON m.ProductID = c.ProductID
ORDER BY CurrentStock ASC;

-- 3. ORDERS DELAYED BY MORE THAN 5 DAYS
SELECT 
    OrderID,
    OrderDate,
    ExpectedDeliveryDate,
    ActualDeliveryDate,
    DaysDelayed,
    SupplierName,
    ProductName,
    Carrier,
    OrderValue
FROM supplychain_cleaned
WHERE DaysDelayed > 5
ORDER BY DaysDelayed DESC;

-- 4. TOP SUPPLIERS BY ON-TIME DELIVERY RATE
SELECT 
    s.SupplierID,
    s.SupplierName,
    s.Location,
    s.Rating,
    COUNT(*) AS TotalOrders,
    SUM(CASE WHEN DaysDelayed <= 0 THEN 1 ELSE 0 END) AS OnTimeDeliveries,
    ROUND(SUM(CASE WHEN DaysDelayed <= 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS OnTimeRatePercent,
    ROUND(AVG(DaysDelayed), 2) AS AvgDelayDays
FROM supplychain_cleaned sc
JOIN suppliers s ON sc.SupplierID = s.SupplierID
WHERE sc.DeliveryStatus = 'Delivered'
GROUP BY s.SupplierID, s.SupplierName, s.Location, s.Rating
ORDER BY OnTimeRatePercent DESC, TotalOrders DESC;

-- 5. SHIPPING COST ANALYSIS BY REGION
SELECT 
    Location,
    COUNT(*) AS TotalOrders,
    SUM(ShippingCost) AS TotalShippingCost,
    ROUND(AVG(ShippingCost), 2) AS AvgShippingCost,
    SUM(OrderValue) AS TotalOrderValue,
    ROUND(SUM(ShippingCost) / SUM(OrderValue) * 100, 2) AS ShippingCostPercent
FROM supplychain_cleaned
GROUP BY Location
ORDER BY TotalShippingCost DESC;

-- 6. INVENTORY TURNOVER RATE BY PRODUCT CATEGORY
WITH ProductMetrics AS (
    SELECT 
        Category,
        ProductName,
        SUM(QuantityOrdered) AS TotalUnitsSold,
        AVG(QuantityOrdered) AS AvgOrderQty,
        COUNT(*) AS OrderFrequency,
        MAX(OrderDate) AS LastOrderDate
    FROM supplychain_cleaned
    WHERE DeliveryStatus = 'Delivered'
    GROUP BY Category, ProductName
)
SELECT 
    Category,
    COUNT(DISTINCT ProductName) AS ProductCount,
    SUM(TotalUnitsSold) AS TotalUnitsMoved,
    ROUND(AVG(TotalUnitsSold), 2) AS AvgInventoryTurnover,
    ROUND(AVG(OrderFrequency), 2) AS AvgOrderFrequency
FROM ProductMetrics
GROUP BY Category
ORDER BY TotalUnitsMoved DESC;

-- 7. SUPPLIER PERFORMANCE SCORECARD
SELECT 
    s.SupplierName,
    s.Rating,
    s.ContractType,
    COUNT(*) AS TotalOrders,
    SUM(sc.OrderValue) AS TotalOrderValue,
    SUM(sc.ShippingCost) AS TotalShippingCost,
    ROUND(AVG(sc.DaysDelayed), 2) AS AvgDelay,
    ROUND(SUM(CASE WHEN sc.DeliveryStatus = 'Delivered' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DeliverySuccessRate,
    CASE 
        WHEN AVG(sc.DaysDelayed) <= 0 AND s.Rating = 'A' THEN 'EXCELLENT'
        WHEN AVG(sc.DaysDelayed) <= 2 THEN 'GOOD'
        WHEN AVG(sc.DaysDelayed) <= 5 THEN 'FAIR'
        ELSE 'NEEDS IMPROVEMENT'
    END AS PerformanceGrade
FROM supplychain_cleaned sc
JOIN suppliers s ON sc.SupplierID = s.SupplierID
GROUP BY s.SupplierID, s.SupplierName, s.Rating, s.ContractType
ORDER BY TotalOrderValue DESC;
