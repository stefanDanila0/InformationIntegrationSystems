--------------------------------------------------------------------------------
-- DS_MongoDB_Products_SparkSQL_Views.sql
-- Creates JSON view for Olist MongoDB data (Product Categories)
--------------------------------------------------------------------------------

-- 1. Create JSON View for Product Categories
SELECT java_method(
               'org.spark.service.rest.RESTEnabledSQLService',
               'createJSONViewFromREST',
               'PRODUCT_CATEGORIES_JSON_VIEW',
               'http://localhost:8093/DSA-NoSQL-MongoDBService/rest/locations/ProductCategoryView');

-- 2. Create Remote View for Product Categories
-- DROP VIEW product_categories_view;
CREATE OR REPLACE VIEW product_categories_view AS
select v.*
FROM PRODUCT_CATEGORIES_JSON_VIEW as json_view LATERAL VIEW explode(json_view.array) AS v;

-- Verify
SELECT * FROM product_categories_view LIMIT 10;
