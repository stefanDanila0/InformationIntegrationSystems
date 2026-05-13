-- ============================================================
-- Oracle Abstraction & Consolidation Views
-- Run as: SYSTEM @ XEPDB1
--
-- Abstraction views encapsulate REST calls to PostgREST and
-- RestHeart, flattening JSON responses into relational rows
-- via JSON_TABLE. The consolidation view pre-joins local and
-- remote data for Layer 2 analytical queries.
-- ============================================================

-- ================== PostgREST Views ==================

CREATE OR REPLACE VIEW vw_ext_customers AS
SELECT customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state
FROM JSON_TABLE(
    get_rest_clob('http://postgrest-api:3000/customers'),
    '$[*]'
    COLUMNS(
        customer_id            VARCHAR2(50)  PATH '$.customer_id',
        customer_unique_id     VARCHAR2(50)  PATH '$.customer_unique_id',
        customer_zip_code_prefix NUMBER      PATH '$.customer_zip_code_prefix',
        customer_city          VARCHAR2(100) PATH '$.customer_city',
        customer_state         VARCHAR2(10)  PATH '$.customer_state'
    )
);

CREATE OR REPLACE VIEW vw_ext_sellers AS
SELECT seller_id, seller_zip_code_prefix, seller_city, seller_state
FROM JSON_TABLE(
    get_rest_clob('http://postgrest-api:3000/sellers'),
    '$[*]'
    COLUMNS(
        seller_id              VARCHAR2(50)  PATH '$.seller_id',
        seller_zip_code_prefix NUMBER        PATH '$.seller_zip_code_prefix',
        seller_city            VARCHAR2(100) PATH '$.seller_city',
        seller_state           VARCHAR2(10)  PATH '$.seller_state'
    )
);

-- ================== RestHeart Views ==================

CREATE OR REPLACE VIEW vw_ext_products AS
SELECT product_id, product_category_name_english AS category, product_weight_g AS weight
FROM JSON_TABLE(
    get_rest_clob('http://restheart-api:8080/olist_db/products'),
    '$[*]'
    COLUMNS(
        product_id                   VARCHAR2(50)  PATH '$.product_id',
        product_category_name_english VARCHAR2(100) PATH '$.product_category_name_english',
        product_weight_g             NUMBER        PATH '$.product_weight_g'
    )
);

CREATE OR REPLACE VIEW vw_ext_order_reviews AS
SELECT review_id, order_id, review_score, review_comment_title, review_comment_message
FROM JSON_TABLE(
    get_rest_clob('http://restheart-api:8080/olist_db/order_reviews'),
    '$[*]'
    COLUMNS(
        review_id               VARCHAR2(50)   PATH '$.review_id',
        order_id                VARCHAR2(50)   PATH '$.order_id',
        review_score            NUMBER         PATH '$.review_score',
        review_comment_title    VARCHAR2(200)  PATH '$.review_comment_title',
        review_comment_message  VARCHAR2(4000) PATH '$.review_comment_message'
    )
);

-- ================== Consolidation View ==================

CREATE OR REPLACE VIEW vw_consolidated_orders AS
SELECT 
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    c.customer_id,
    c.customer_city,
    c.customer_state,
    i.product_id,
    i.price,
    i.freight_value,
    p.category,
    p.weight,
    s.seller_id,
    s.seller_city,
    s.seller_state
FROM orders o
JOIN vw_ext_customers c ON o.customer_id = c.customer_id
JOIN order_items i      ON o.order_id    = i.order_id
JOIN vw_ext_products p  ON i.product_id  = p.product_id
JOIN vw_ext_sellers s   ON i.seller_id   = s.seller_id;

EXIT;
