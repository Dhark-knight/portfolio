# Sales Analytics

SQL-based analysis of 5,000 global sales orders, covering revenue performance, regional trends, product performance, and sales rep productivity.

## Business Questions Answered
- Which regions and products drive the most revenue and profit?
- How is revenue trending month-over-month and year-over-year?
- Which sales reps are top performers?
- Which products are declining in sales year-over-year and need attention?

## Key Insights
- **Total revenue: $18.7M** across 5,000 orders, at a **25% profit margin**
- **North America** led all regions at $6.84M in revenue, more than double Latin America and Middle East & Africa combined
- Top 5 products by revenue were led by **Graphics Card RTX ($1.44M)** and **Monitor 27" ($1.36M)**
- Sales rep performance was tightly clustered at the top — the difference between the #1 and #5 rep was under 5% of total sales, suggesting a well-balanced team rather than one standout performer

## Techniques Used
- Aggregation and grouping across region, product, and rep dimensions
- Window functions (`LAG`) for month-over-month growth calculations
- Self-joins for year-over-year product comparisons
- Profit margin calculations at the product level

## Sample Query — Month-over-Month Growth
```sql
WITH MonthlySales AS (
    SELECT OrderMonth, SUM(NetAmount) AS MonthlyRevenue
    FROM sales_cleaned
    GROUP BY OrderMonth
)
SELECT
    OrderMonth,
    MonthlyRevenue,
    LAG(MonthlyRevenue) OVER (ORDER BY OrderMonth) AS PrevMonthRevenue,
    ROUND((MonthlyRevenue - LAG(MonthlyRevenue) OVER (ORDER BY OrderMonth))
        / LAG(MonthlyRevenue) OVER (ORDER BY OrderMonth) * 100, 2) AS MoMGrowthPercent
FROM MonthlySales
ORDER BY OrderMonth;
```

See [`queries.sql`](./queries.sql) for the full set of 7 queries and [`insights.txt`](./insights.txt) for the raw output summary.

## Files
- `sales_raw.csv` — original uncleaned dataset
- `sales_cleaned.csv` — cleaned dataset used for analysis
- `queries.sql` — all analysis queries
- `insights.txt` — key findings
