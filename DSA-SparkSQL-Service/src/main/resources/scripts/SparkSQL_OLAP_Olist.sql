--------------------------------------------------------------------------------
--- SparkSQL_OLAP_Olist.sql
--- Olist Brazilian E-Commerce: Multidimensional Analytical Model
--- Prerequisites: Execute all 3 data source scripts first:
---   1. DS_CSV_Orders_SparkSQL_Views.sql       -> orders_view, order_items_view
---   2. DS_PG_Olist_SparkSQL_Views.sql         -> customers_view, sellers_view
---   3. DS_MongoDB_Products_SparkSQL_Views.sql -> product_categories_view
--------------------------------------------------------------------------------

--- Verify Data Sources ---
SELECT * FROM orders_view LIMIT 5;
SELECT * FROM order_items_view LIMIT 5;
SELECT * FROM customers_view LIMIT 5;
SELECT * FROM sellers_view LIMIT 5;
SELECT * FROM product_categories_view LIMIT 5;

--------------------------------------------------------------------------------
--- OLAP Fact Table
--- Joins orders + order_items + customers to produce fact records with amounts
--------------------------------------------------------------------------------
-- DROP VIEW OLAP_FACTS_ORDER_AMOUNTS;
CREATE OR REPLACE VIEW OLAP_FACTS_ORDER_AMOUNTS AS
SELECT 
    o.orderId,
    o.customerId,
    c.customerCity,
    c.customerState,
    oi.productId,
    oi.sellerId,
    o.orderPurchaseTimestamp,
    oi.price,
    oi.freightValue,
    (oi.price + oi.freightValue) AS totalAmount
FROM orders_view o
    INNER JOIN order_items_view oi ON o.orderId = oi.orderId
    INNER JOIN customers_view c ON o.customerId = c.customerId
WHERE o.orderStatus = 'delivered'
;
-- Test
SELECT * FROM OLAP_FACTS_ORDER_AMOUNTS LIMIT 10;

--------------------------------------------------------------------------------
--- Dimension: Customers by State (Geographic)
--------------------------------------------------------------------------------
-- DROP VIEW OLAP_DIM_CUSTOMERS_GEO;
CREATE OR REPLACE VIEW OLAP_DIM_CUSTOMERS_GEO AS
SELECT DISTINCT
    c.customerId,
    c.customerCity,
    c.customerState
FROM customers_view c
;
SELECT * FROM OLAP_DIM_CUSTOMERS_GEO LIMIT 10;

--------------------------------------------------------------------------------
--- Dimension: Sellers by State (Geographic)
--------------------------------------------------------------------------------
-- DROP VIEW OLAP_DIM_SELLERS_GEO;
CREATE OR REPLACE VIEW OLAP_DIM_SELLERS_GEO AS
SELECT DISTINCT
    s.sellerId,
    s.sellerCity,
    s.sellerState
FROM sellers_view s
;
SELECT * FROM OLAP_DIM_SELLERS_GEO LIMIT 10;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--- Analytical View 1: Sales by Customer State (ROLLUP)
--- Shows total sales amount per customer state with subtotals and grand total
--------------------------------------------------------------------------------
-- DROP VIEW OLAP_VIEW_SALES_BY_STATE;
CREATE OR REPLACE VIEW OLAP_VIEW_SALES_BY_STATE AS
SELECT 
    CASE 
        WHEN f.customerState IS NULL THEN '{Grand Total}'
        ELSE f.customerState 
    END AS customerState,
    COUNT(DISTINCT f.orderId) AS orderCount,
    ROUND(SUM(f.totalAmount), 2) AS totalSalesAmount,
    ROUND(AVG(f.totalAmount), 2) AS avgOrderAmount
FROM OLAP_FACTS_ORDER_AMOUNTS f
GROUP BY ROLLUP(f.customerState)
ORDER BY totalSalesAmount DESC
;
-- Test
SELECT * FROM OLAP_VIEW_SALES_BY_STATE;

--------------------------------------------------------------------------------
--- Analytical View 2: Sales by Product Category (CUBE)
--- Cross-tabulation of product category vs seller state
--------------------------------------------------------------------------------
-- DROP VIEW OLAP_VIEW_SALES_BY_CATEGORY;
CREATE OR REPLACE VIEW OLAP_VIEW_SALES_BY_CATEGORY AS
SELECT 
    CASE 
        WHEN pc.categoryNameEnglish IS NULL THEN '{All Categories}'
        ELSE pc.categoryNameEnglish 
    END AS categoryName,
    CASE 
        WHEN s.sellerState IS NULL THEN '{All States}'
        ELSE s.sellerState 
    END AS sellerState,
    COUNT(DISTINCT f.orderId) AS orderCount,
    ROUND(SUM(f.totalAmount), 2) AS totalSalesAmount
FROM OLAP_FACTS_ORDER_AMOUNTS f
    INNER JOIN OLAP_DIM_SELLERS_GEO s ON f.sellerId = s.sellerId
    LEFT JOIN product_categories_view pc ON 1=1
GROUP BY CUBE(pc.categoryNameEnglish, s.sellerState)
ORDER BY totalSalesAmount DESC
;
-- Test
SELECT * FROM OLAP_VIEW_SALES_BY_CATEGORY LIMIT 20;

--------------------------------------------------------------------------------
--- Analytical View 3: Top States Ranking (RANK)
--- Ranks customer states by total revenue using window functions
--------------------------------------------------------------------------------
-- DROP VIEW OLAP_VIEW_SALES_RANK;
CREATE OR REPLACE VIEW OLAP_VIEW_SALES_RANK AS
SELECT 
    customerState,
    totalSalesAmount,
    orderCount,
    RANK() OVER (ORDER BY totalSalesAmount DESC) AS salesRank,
    DENSE_RANK() OVER (ORDER BY totalSalesAmount DESC) AS salesDenseRank,
    PERCENT_RANK() OVER (ORDER BY totalSalesAmount DESC) AS salesPercentRank,
    ROW_NUMBER() OVER (ORDER BY totalSalesAmount DESC) AS salesRowNumber
FROM (
    SELECT 
        f.customerState,
        ROUND(SUM(f.totalAmount), 2) AS totalSalesAmount,
        COUNT(DISTINCT f.orderId) AS orderCount
    FROM OLAP_FACTS_ORDER_AMOUNTS f
    GROUP BY f.customerState
) state_sales
ORDER BY salesRank
;
-- Test
SELECT * FROM OLAP_VIEW_SALES_RANK;

--------------------------------------------------------------------------------
--- Summary: OLAP Views Available
--------------------------------------------------------------------------------
-- Verify all views
SELECT * FROM OLAP_FACTS_ORDER_AMOUNTS LIMIT 5;
SELECT * FROM OLAP_DIM_CUSTOMERS_GEO LIMIT 5;
SELECT * FROM OLAP_DIM_SELLERS_GEO LIMIT 5;
SELECT * FROM OLAP_VIEW_SALES_BY_STATE;
SELECT * FROM OLAP_VIEW_SALES_BY_CATEGORY LIMIT 20;
SELECT * FROM OLAP_VIEW_SALES_RANK;

SHOW VIEWS;
