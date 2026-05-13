----------------------------------------------------------------------------------
--- DS_CSV_Orders_SparkSQL_Views.sql
--- Creates Spark SQL virtual views from DSA-DOC-CSVService REST endpoints
----------------------------------------------------------------------------------

-- 1. Create JSON View for Orders
SELECT java_method(
               'org.spark.service.rest.RESTEnabledSQLService',
               'createJSONViewFromREST',
               'ORDERS_JSON_VIEW',
               'http://localhost:8097/DSA-DOC-CSVService/rest/orders/OrderView');

SELECT * FROM ORDERS_JSON_VIEW;

-- 2. Create Remote View
-- DROP VIEW orders_view;
CREATE OR REPLACE VIEW orders_view AS
select v.*
FROM ORDERS_JSON_VIEW as json_view LATERAL VIEW explode(json_view.array) AS v;

-- 3. Test Remote View
SELECT * FROM orders_view LIMIT 10;

----------------------------------------------------------------------------------
-- 1. Create JSON View for Order Items
SELECT java_method(
               'org.spark.service.rest.RESTEnabledSQLService',
               'createJSONViewFromREST',
               'ORDER_ITEMS_JSON_VIEW',
               'http://localhost:8097/DSA-DOC-CSVService/rest/orders/OrderItemView');

SELECT * FROM ORDER_ITEMS_JSON_VIEW;

-- 2. Create Remote View
-- DROP VIEW order_items_view;
CREATE OR REPLACE VIEW order_items_view AS
select v.*
FROM ORDER_ITEMS_JSON_VIEW as json_view LATERAL VIEW explode(json_view.array) AS v;

-- 3. Test Remote View
SELECT * FROM order_items_view LIMIT 10;
