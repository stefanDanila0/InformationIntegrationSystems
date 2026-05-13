-- ============================================================
-- Oracle Schema & Data Load
-- Run as: SYSTEM @ XEPDB1
-- ============================================================

ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS';
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';

CREATE OR REPLACE DIRECTORY csv_dir AS '/opt/oracle/csv';

-- ==================== ORDERS ====================
CREATE TABLE ext_orders (
    order_id VARCHAR2(50),
    customer_id VARCHAR2(50),
    order_status VARCHAR2(20),
    order_purchase_timestamp VARCHAR2(50),
    order_approved_at VARCHAR2(50),
    order_delivered_carrier_date VARCHAR2(50),
    order_delivered_customer_date VARCHAR2(50),
    order_estimated_delivery_date VARCHAR2(50)
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY csv_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('olist_orders_dataset.csv')
);

CREATE TABLE orders AS 
SELECT 
    order_id, 
    customer_id, 
    order_status, 
    CAST(TO_TIMESTAMP(order_purchase_timestamp, 'YYYY-MM-DD HH24:MI:SS') AS DATE) AS order_purchase_timestamp,
    CAST(TO_TIMESTAMP(order_approved_at, 'YYYY-MM-DD HH24:MI:SS') AS DATE) AS order_approved_at,
    CAST(TO_TIMESTAMP(order_delivered_carrier_date, 'YYYY-MM-DD HH24:MI:SS') AS DATE) AS order_delivered_carrier_date,
    CAST(TO_TIMESTAMP(order_delivered_customer_date, 'YYYY-MM-DD HH24:MI:SS') AS DATE) AS order_delivered_customer_date,
    CAST(TO_TIMESTAMP(order_estimated_delivery_date, 'YYYY-MM-DD HH24:MI:SS') AS DATE) AS order_estimated_delivery_date
FROM ext_orders;

ALTER TABLE orders ADD CONSTRAINT pk_orders PRIMARY KEY (order_id);

-- ==================== ORDER_ITEMS ====================
CREATE TABLE ext_order_items (
    order_id VARCHAR2(50),
    order_item_id NUMBER,
    product_id VARCHAR2(50),
    seller_id VARCHAR2(50),
    shipping_limit_date VARCHAR2(50),
    price NUMBER,
    freight_value NUMBER
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY csv_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('olist_order_items_dataset.csv')
);

CREATE TABLE order_items AS
SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    CAST(TO_TIMESTAMP(shipping_limit_date, 'YYYY-MM-DD HH24:MI:SS') AS DATE) AS shipping_limit_date,
    price,
    freight_value
FROM ext_order_items;

ALTER TABLE order_items ADD CONSTRAINT pk_order_items PRIMARY KEY (order_id, order_item_id);

-- ==================== ORDER_PAYMENTS ====================
CREATE TABLE ext_order_payments (
    order_id VARCHAR2(50),
    payment_sequential NUMBER,
    payment_type VARCHAR2(20),
    payment_installments NUMBER,
    payment_value NUMBER
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY csv_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('olist_order_payments_dataset.csv')
);

CREATE TABLE order_payments AS SELECT * FROM ext_order_payments;

-- ==================== CLEANUP EXTERNAL TABLES ====================
DROP TABLE ext_orders;
DROP TABLE ext_order_items;
DROP TABLE ext_order_payments;

EXIT;
