# Supply Chain & Logistics Analytics

SQL-based analysis of a dairy/agri-food supply chain dataset — 3,000 orders, 25 suppliers, 30 products — focused on delivery performance, supplier reliability, and shipping cost efficiency.

## Business Questions Answered
- Which suppliers and carriers are causing the most delivery delays?
- What percentage of orders arrive on time, and where are the worst bottlenecks?
- Which products are at risk of stockouts based on demand vs. reorder points?
- How does shipping cost scale against order value by region?
- How would we build a supplier performance scorecard to flag underperformers?

## Key Insights
- **On-time delivery rate: 42.1%** — more than half of all orders arrived late, cancelled, or severely delayed
- **8.1% of orders (243)** were severely delayed (more than 5 days late)
- **77 orders cancelled outright**
- **Average delay: 1.57 days** across all orders
- Shipping cost represented **0.22% of total order value** ($4.59M shipping against $2.08B in order value)
- Top-performing suppliers (by on-time rate) were identified and ranked — none exceeded 61% on-time, pointing to a systemic carrier/logistics issue rather than a single bad supplier

## Techniques Used
- Multi-table joins (orders ↔ suppliers ↔ products)
- CTEs for demand forecasting and simulated reorder-point logic
- Conditional aggregation (`CASE WHEN`) for delivery-status scorecards
- Window-style ranking for supplier performance grading

## Sample Query — Supplier Performance Scorecard
```sql
SELECT
    s.SupplierName,
    s.Rating,
    COUNT(*) AS TotalOrders,
    ROUND(AVG(sc.DaysDelayed), 2) AS AvgDelay,
    ROUND(SUM(CASE WHEN sc.DeliveryStatus = 'Delivered' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2) AS DeliverySuccessRate,
    CASE
        WHEN AVG(sc.DaysDelayed) <= 0 AND s.Rating = 'A' THEN 'EXCELLENT'
        WHEN AVG(sc.DaysDelayed) <= 2 THEN 'GOOD'
        WHEN AVG(sc.DaysDelayed) <= 5 THEN 'FAIR'
        ELSE 'NEEDS IMPROVEMENT'
    END AS PerformanceGrade
FROM supplychain_cleaned sc
JOIN suppliers s ON sc.SupplierID = s.SupplierID
GROUP BY s.SupplierID, s.SupplierName, s.Rating
ORDER BY TotalOrderValue DESC;
```

See [`queries.sql`](./queries.sql) for the full set of 7 queries and [`insights.txt`](./insights.txt) for the raw output summary.

## Files
- `supplychain_cleaned.csv` — cleaned order-level dataset
- `suppliers.csv`, `products.csv` — supporting dimension tables
- `queries.sql` — all analysis queries
- `insights.txt` — key findings
