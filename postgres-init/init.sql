CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INTEGER,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

CREATE TABLE sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INTEGER,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);

CREATE TABLE geolocation (
    geolocation_zip_code_prefix INTEGER,
    geolocation_lat NUMERIC(15,7),
    geolocation_lng NUMERIC(15,7),
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(10)
);

\copy customers FROM '/data/olist_customers_dataset.csv' WITH CSV HEADER;
\copy sellers FROM '/data/olist_sellers_dataset.csv' WITH CSV HEADER;
\copy geolocation FROM '/data/olist_geolocation_dataset.csv' WITH CSV HEADER;
