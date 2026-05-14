--------------------------------------------------------------------------------
-- DS_PG_Olist_SparkSQL_Views.sql
-- Creates JSON views for Olist PostgreSQL data (Customers and Sellers)
--------------------------------------------------------------------------------

-- 1. Create JSON View for Customers
SELECT java_method(
               'org.spark.service.rest.RESTEnabledSQLService',
               'createJSONViewFromREST',
               'CUSTOMERS_JSON_VIEW',
               'http://localhost:8091/DSA_SQL_JPAService/rest/customers/CustomerView');

-- 2. Create Remote View for Customers
-- DROP VIEW customers_view;
CREATE OR REPLACE VIEW customers_view AS
select v.*
FROM CUSTOMERS_JSON_VIEW as json_view LATERAL VIEW explode(json_view.array) AS v;

-- 3. Create JSON View for Sellers
SELECT java_method(
               'org.spark.service.rest.RESTEnabledSQLService',
               'createJSONViewFromREST',
               'SELLERS_JSON_VIEW',
               'http://localhost:8091/DSA_SQL_JPAService/rest/sellers/SellerView');

-- 4. Create Remote View for Sellers
-- DROP VIEW sellers_view;
CREATE OR REPLACE VIEW sellers_view AS
select v.*
FROM SELLERS_JSON_VIEW as json_view LATERAL VIEW explode(json_view.array) AS v;

-- Verify
SELECT * FROM customers_view LIMIT 10;
SELECT * FROM sellers_view LIMIT 10;
