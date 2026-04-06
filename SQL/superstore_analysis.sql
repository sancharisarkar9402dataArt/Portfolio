
-------------------------------------------------------
-- 1. DATA PREVIEW
-------------------------------------------------------
SELECT *
FROM superstore_sales
LIMIT 10;


-------------------------------------------------------
-- 2. DATA CLEANING & VALIDATION
-------------------------------------------------------

-- Check NULL values
SELECT 
    COUNT(*) AS total_rows,
    COUNT(order_id) AS order_id_count,
    COUNT(order_date) AS order_date_count,
    COUNT(sales) AS sales_count,
    COUNT(profit) AS profit_count
FROM superstore_sales;

-- Check duplicate records
SELECT order_id, COUNT(*)
FROM superstore_sales
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Check negative or abnormal values
SELECT *
FROM superstore_sales
WHERE sales < 0 OR quantity < 0;


-------------------------------------------------------
-- 3. KPI METRICS (MATCHING POWER BI)
-------------------------------------------------------

SELECT 
    ROUND(SUM(sales), 2) AS "Total Sales",
    ROUND(SUM(profit), 2) AS "Total Profit",
    SUM(quantity) AS "Total Quantity",
    ROUND(SUM(profit)/SUM(sales)*100, 2) AS "Profit-Margin (%)"
FROM superstore_sales;


-------------------------------------------------------
-- 4. SALES vs PROFIT BY CATEGORY
-------------------------------------------------------

SELECT 
    category AS "Category",
    ROUND(SUM(sales), 2) AS "Total Sales",
    ROUND(SUM(profit), 2) AS "Total Profit"
FROM superstore_sales
GROUP BY category
ORDER BY "Total Profit" DESC;


-------------------------------------------------------
-- 5. SALES vs PROFIT BY SUB-CATEGORY
-------------------------------------------------------

SELECT 
    sub_category AS "Sub-Category",
    ROUND(SUM(sales), 2) AS "Total Sales",
    ROUND(SUM(profit), 2) AS "Total Profit"
FROM superstore_sales
GROUP BY sub_category
ORDER BY "Total Profit" DESC;


-------------------------------------------------------
-- 6. PROFIT BY SUB-CATEGORY (LOSS ANALYSIS)
-------------------------------------------------------

SELECT 
    sub_category AS "Sub-Category",
    ROUND(SUM(profit), 2) AS "Total Profit"
FROM superstore_sales
GROUP BY sub_category
ORDER BY "Total Profit" ASC;


-------------------------------------------------------
-- 7. MONTHLY SALES TREND (MATCH "Month Year")
-------------------------------------------------------

SELECT 
    TO_CHAR(DATE_TRUNC('month', order_date), 'Mon YYYY') AS "Month Year",
    ROUND(SUM(sales), 2) AS "Total Sales"
FROM superstore_sales
GROUP BY "Month Year"
ORDER BY MIN(order_date);


-------------------------------------------------------
-- 8. TOP 5 PROFITABLE SUB-CATEGORIES
-------------------------------------------------------

SELECT 
    sub_category AS "Sub-Category",
    ROUND(SUM(profit), 2) AS "Total Profit"
FROM superstore_sales
GROUP BY sub_category
ORDER BY "Total Profit" DESC
LIMIT 5;


-------------------------------------------------------
-- 9. BOTTOM 5 LOSS-MAKING SUB-CATEGORIES
-------------------------------------------------------

SELECT 
    sub_category AS "Sub-Category",
    ROUND(SUM(profit), 2) AS "Total Profit"
FROM superstore_sales
GROUP BY sub_category
ORDER BY "Total Profit" ASC
LIMIT 5;


-------------------------------------------------------
-- 10. CATEGORY-WISE PROFIT CONTRIBUTION (%)
-------------------------------------------------------

SELECT 
    category AS "Category",
    ROUND(SUM(profit), 2) AS "Total Profit",
    ROUND(100 * SUM(profit) / SUM(SUM(profit)) OVER (), 2) 
        AS "Profit Contribution (%)"
FROM superstore_sales
GROUP BY category
ORDER BY "Total Profit" DESC;


-------------------------------------------------------
-- 11. REGION-WISE PERFORMANCE
-------------------------------------------------------

SELECT 
    region AS "Region",
    ROUND(SUM(sales), 2) AS "Total Sales",
    ROUND(SUM(profit), 2) AS "Total Profit"
FROM superstore_sales
GROUP BY region
ORDER BY "Total Sales" DESC;