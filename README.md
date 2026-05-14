# P2: Data Service Architecture (DSA) — Java4DI Microservices

This project implements a **Data Service Architecture** using the **Java4DI** framework — a microservices-based approach built on Spring Boot and Apache Spark SQL. It takes the Olist Brazilian E-Commerce dataset (previously distributed across Oracle, PostgreSQL, and MongoDB in Part 1) and re-integrates it through a layered microservices architecture where **Spark SQL acts as the virtual integration engine**.

The dataset is found [here](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce/data).

## 🏗 Architecture Overview

The architecture follows a **three-layer stratified strategy**, as prescribed by the Java4DI pattern:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     LAYER 3: WEB Model (Port 8096)                     │
│                                                                        │
│   DSA-WEB-RESTService                                                  │
│   └── Exposes OLAP views as REST endpoints via Hive JDBC               │
│       GET /analytics/salesByState    (ROLLUP)                          │
│       GET /analytics/salesByCategory (CUBE)                            │
│       GET /analytics/salesRank       (RANK)                            │
├─────────────────────────────────────────────────────────────────────────┤
│                  LAYER 2: Integration Model (Port 10000)               │
│                                                                        │
│   DSA-SparkSQL-Service                                                 │
│   └── Hive Thrift Server: virtual database engine                      │
│       ├── Mounts REST endpoints as SQL tables via java_method()        │
│       ├── Creates OLAP dimensions & fact views                         │
│       └── Runs analytical queries (ROLLUP, CUBE, RANK)                 │
│                                                                        │
│   4 SQL Scripts (executed in DBeaver via jdbc:hive2://localhost:10000)  │
│       ├── DS_CSV_Orders_SparkSQL_Views.sql                             │
│       ├── DS_PG_Olist_SparkSQL_Views.sql                               │
│       ├── DS_MongoDB_Products_SparkSQL_Views.sql                       │
│       └── SparkSQL_OLAP_Olist.sql                                      │
├─────────────────────────────────────────────────────────────────────────┤
│                    LAYER 1: Access Model (Data Sources)                │
│                                                                        │
│   DSA-DOC-CSVService (Port 8097)                                       │
│   └── Reads olist_orders_dataset.csv + olist_order_items_dataset.csv   │
│       GET /orders/OrderView                                            │
│       GET /orders/OrderItemView                                        │
│                                                                        │
│   DSA-SQL-JPAService (Port 8091)                                       │
│   └── Connects to PostgreSQL (customers, sellers, geolocation)         │
│       GET /customers/CustomerView                                      │
│       GET /sellers/SellerView                                          │
│                                                                        │
│   DSA-NoSQL-MongoDBService (Port 8093)                                 │
│   └── Connects to MongoDB (product category translations)              │
│       GET /locations/ProductCategoryView                               │
├─────────────────────────────────────────────────────────────────────────┤
│                     INFRASTRUCTURE (Docker)                            │
│                                                                        │
│   postgres-db (Port 5432)  │  mongo-db (Port 27018)                    │
│   └── olist_db: customers, │  └── olist_mongo: ProductCategories       │
│       sellers, geolocation │      (seeded via mongo-seed container)     │
└─────────────────────────────────────────────────────────────────────────┘
```

## 📦 Project Structure

The project consists of **5 Spring Boot microservices** and **4 SQL scripts**:

| # | Project | Port | Role | Data Source |
|---|---------|------|------|-------------|
| 1 | `DSA-DOC-CSVService` | 8097 | Access Model | CSV files (orders, order items) |
| 2 | `DSA-SQL-JPAService` | 8091 | Access Model | PostgreSQL (customers, sellers) |
| 3 | `DSA-NoSQL-MongoDBService` | 8093 | Access Model | MongoDB (product categories) |
| 4 | `DSA-SparkSQL-Service` | 9990 / 10000 | Integration Engine | Virtual (Spark SQL + Hive Thrift) |
| 5 | `DSA-WEB-RESTService` | 8096 | Web Model | Spark SQL via Hive JDBC |

| # | SQL Script | Purpose |
|---|-----------|---------| 
| 1 | `DS_CSV_Orders_SparkSQL_Views.sql` | Mounts CSV REST endpoints as Spark tables |
| 2 | `DS_PG_Olist_SparkSQL_Views.sql` | Mounts PostgreSQL REST endpoints as Spark tables |
| 3 | `DS_MongoDB_Products_SparkSQL_Views.sql` | Mounts MongoDB REST endpoint as a Spark table |
| 4 | `SparkSQL_OLAP_Olist.sql` | Creates the OLAP analytical model (ROLLUP, CUBE, RANK) |

## 🚀 Startup Procedure

The services must be started **in a specific order** due to their dependencies:

### Step 1: Infrastructure (Docker)
```powershell
docker-compose up -d
```
This starts:
- **PostgreSQL** (`postgres-db`) on port 5432 with the `olist_db` database (customers, sellers, geolocation tables from Part 1).
- **MongoDB** (`mongo-db`) on port 27018 (host) → 27017 (container).
- **mongo-seed** (one-shot container) — automatically seeds the `olist_mongo.ProductCategories` collection with all 71 Olist product categories (Portuguese + English names).

> **Note:** MongoDB is mapped to **port 27018** on the host to avoid conflicts with any native MongoDB installation on the development machine. The internal container port remains 27017.

### Step 2: Start the Access Model Services
Start these three Spring Boot applications (via IntelliJ Run or `mvn spring-boot:run` from each project directory). They can be started in any order:

```
DSA-DOC-CSVService       → http://localhost:8097/DSA-DOC-CSVService/rest/orders/OrderView
DSA-SQL-JPAService       → http://localhost:8091/DSA_SQL_JPAService/rest/customers/CustomerView
DSA-NoSQL-MongoDBService → http://localhost:8093/DSA-NoSQL-MongoDBService/rest/locations/ProductCategoryView
```

Each service wraps its raw data source (CSV file, PostgreSQL table, or MongoDB collection) and exposes it as a JSON REST API. At this point, you can verify each service by hitting its URL in a browser and confirming that JSON data is returned.

### Step 3: Start the Integration Engine
```
DSA-SparkSQL-Service → Spark Web UI at http://localhost:8081
                     → Hive Thrift Server at jdbc:hive2://localhost:10000
```
This service starts an embedded Apache Spark instance with a Hive Thrift Server. It acts as the **virtual database** — it doesn't store any data itself, but can query data from the Access Model services via REST.

### Step 4: Create Virtual Tables (DBeaver)
Connect DBeaver (or DataGrip) to `jdbc:hive2://localhost:10000` and execute the SQL scripts **in this order**:

1. **`DS_CSV_Orders_SparkSQL_Views.sql`** — Creates `orders_view` and `order_items_view` from the CSV service.
2. **`DS_PG_Olist_SparkSQL_Views.sql`** — Creates `customers_view` and `sellers_view` from the JPA service.
3. **`DS_MongoDB_Products_SparkSQL_Views.sql`** — Creates `product_categories_view` from the MongoDB service.
4. **`SparkSQL_OLAP_Olist.sql`** — Creates the OLAP analytical model:
   - **Fact table:** `OLAP_FACTS_ORDER_AMOUNTS` (orders + items + customers joined)
   - **Dimensions:** `OLAP_DIM_CUSTOMERS_GEO`, `OLAP_DIM_SELLERS_GEO`
   - **Analytical views:** `OLAP_VIEW_SALES_BY_STATE` (ROLLUP), `OLAP_VIEW_SALES_BY_CATEGORY` (CUBE), `OLAP_VIEW_SALES_RANK` (RANK)

These scripts use Spark's `java_method()` UDF to call a helper class (`RESTEnabledSQLService`) that fetches JSON from the Access Model REST endpoints and registers them as queryable SQL views.

> **Important:** These views exist only in the Spark session's memory. If the `DSA-SparkSQL-Service` is restarted, all four scripts must be re-executed in order.

### Step 5: Start the Web Model
```
DSA-WEB-RESTService → http://localhost:8096/DSA-WEB-RESTService/rest/analytics/salesByState
```
This service connects to Spark SQL via the Hive JDBC driver (`jdbc:hive2://localhost:10000`) and uses Spring's `JdbcTemplate` to query the analytical views and expose them as REST endpoints.

> **Note:** The Web Model uses `JdbcTemplate` (not JPA Repositories) because the Hive JDBC driver does not support transactional operations (`commit`/`rollback`). Hibernate's default transaction management would cause `SQLFeatureNotSupportedException` errors.

## 🔍 Data Flow (End-to-End)

The complete data journey for a single request to `/analytics/salesByState`:

```
Browser/Client
    │
    ▼
DSA-WEB-RESTService (Port 8096)
    │  Hive JDBC → jdbc:hive2://localhost:10000
    ▼
DSA-SparkSQL-Service (Spark Engine)
    │  Resolves OLAP_VIEW_SALES_BY_STATE → needs OLAP_FACTS_ORDER_AMOUNTS
    │  → needs orders_view, order_items_view, customers_view
    │
    ├──── REST GET → http://localhost:8097/.../OrderView      → CSV file
    ├──── REST GET → http://localhost:8097/.../OrderItemView   → CSV file
    └──── REST GET → http://localhost:8091/.../CustomerView    → PostgreSQL
    │
    ▼
Spark SQL joins all data in-memory, applies ROLLUP aggregation
    │
    ▼
JSON result returned to browser
```

## 🔌 View Creation Flow (How REST → SQL Works)

Each data source script follows the same two-step pattern to transform REST API responses into queryable SQL views:

### Step 1: Mount REST as JSON View (`java_method`)
```sql
SELECT java_method(
    'org.spark.service.rest.RESTEnabledSQLService',
    'createJSONViewFromREST',
    'ORDERS_JSON_VIEW',                                          -- View name in Spark
    'http://localhost:8097/DSA-DOC-CSVService/rest/orders/OrderView'  -- REST endpoint
);
```
This calls a Java helper class at runtime that:
1. Makes an HTTP GET to the REST endpoint
2. Receives JSON array response
3. Infers the schema using Spark's `schema_of_json()`
4. Registers a temporary Spark SQL view wrapping the parsed JSON

### Step 2: Explode JSON Array into Rows
```sql
CREATE OR REPLACE VIEW orders_view AS
SELECT v.*
FROM ORDERS_JSON_VIEW AS json_view
LATERAL VIEW explode(json_view.array) AS v;
```
The JSON view contains a single row with a nested array. `LATERAL VIEW explode()` unpacks each array element into its own row, creating a flat, table-like view with one row per record.

### Column Naming Convention
- **CSV Service** (Orders, Items): Uses `snake_case` field names (`order_id`, `customer_id`, `freight_value`)
- **JPA Service** (Customers, Sellers): Uses `camelCase` field names (`customerId`, `customerState`)
- **MongoDB Service** (Categories): Uses `camelCase` field names (`categoryName`, `categoryNameEnglish`)

The OLAP script handles this mixed naming by referencing each column in its native format.

## 📊 Analytical Views (OLAP Model)

The OLAP model implements three analytical techniques:

### 1. ROLLUP — Sales by Customer State
```sql
SELECT customerState, COUNT(DISTINCT order_id), SUM(totalAmount), AVG(totalAmount)
FROM OLAP_FACTS_ORDER_AMOUNTS
GROUP BY ROLLUP(customerState)
ORDER BY totalSalesAmount DESC;
```
Produces **hierarchical subtotals**: per-state totals → grand total. The `{Grand Total}` row aggregates across all states.

### 2. CUBE — Sales by Category × Seller State
```sql
SELECT categoryNameEnglish, sellerState, COUNT(DISTINCT order_id), SUM(totalAmount)
FROM OLAP_FACTS_ORDER_AMOUNTS f
    JOIN OLAP_DIM_SELLERS_GEO s ON f.seller_id = s.sellerId
    LEFT JOIN product_categories_view pc ON ...
GROUP BY CUBE(categoryNameEnglish, sellerState);
```
Produces **cross-tabulation** with subtotals for every combination of category and state, including `{All Categories}` and `{All States}` rollup rows.

### 3. RANK — Top States Ranking
```sql
SELECT customerState, SUM(totalAmount),
    RANK() OVER (ORDER BY totalSalesAmount DESC),
    DENSE_RANK() OVER (ORDER BY totalSalesAmount DESC),
    PERCENT_RANK() OVER (ORDER BY totalSalesAmount DESC)
FROM OLAP_FACTS_ORDER_AMOUNTS
GROUP BY customerState;
```
Ranks states by total revenue using **window functions** (RANK, DENSE_RANK, PERCENT_RANK, ROW_NUMBER).

## 🌐 REST API Endpoints

### Layer 1: Access Model (Raw Data)

| Service | Endpoint | Full URL | Description |
|---------|----------|----------|-------------|
| CSV | `GET /orders/OrderView` | `http://localhost:8097/DSA-DOC-CSVService/rest/orders/OrderView` | All Olist orders (order_id, customer_id, status, timestamps) |
| CSV | `GET /orders/OrderItemView` | `http://localhost:8097/DSA-DOC-CSVService/rest/orders/OrderItemView` | All order line items (order_id, product_id, seller_id, price, freight) |
| JPA | `GET /customers/CustomerView` | `http://localhost:8091/DSA_SQL_JPAService/rest/customers/CustomerView` | All customers (customerId, city, state, zip code) |
| JPA | `GET /sellers/SellerView` | `http://localhost:8091/DSA_SQL_JPAService/rest/sellers/SellerView` | All sellers (sellerId, city, state, zip code) |
| MongoDB | `GET /locations/ProductCategoryView` | `http://localhost:8093/DSA-NoSQL-MongoDBService/rest/locations/ProductCategoryView` | Product categories (Portuguese + English names) |

### Layer 3: Web Model (Analytical Reports)

| Endpoint | Full URL | OLAP Technique | What It Shows |
|----------|----------|----------------|---------------|
| `GET /analytics/salesByState` | `http://localhost:8096/DSA-WEB-RESTService/rest/analytics/salesByState` | **ROLLUP** | Total revenue, order count, and average order value per Brazilian state, with a grand total row. Answers: *"Which states generate the most e-commerce revenue?"* |
| `GET /analytics/salesByCategory` | `http://localhost:8096/DSA-WEB-RESTService/rest/analytics/salesByCategory` | **CUBE** | Cross-tabulation of product categories vs. seller states, with subtotals in both dimensions. Answers: *"Which product categories sell best in which seller regions?"* |
| `GET /analytics/salesRank` | `http://localhost:8096/DSA-WEB-RESTService/rest/analytics/salesRank` | **RANK** | All states ranked by total sales revenue using RANK, DENSE_RANK, PERCENT_RANK, and ROW_NUMBER window functions. Answers: *"How do states compare relative to each other in sales performance?"* |

## 🔧 Configuration Reference

### Service Ports
| Service | HTTP Port | Other Ports |
|---------|-----------|-------------|
| DSA-DOC-CSVService | 8097 | — |
| DSA-SQL-JPAService | 8091 | — |
| DSA-NoSQL-MongoDBService | 8093 | — |
| DSA-SparkSQL-Service | 9990 | 10000 (Hive Thrift), 8081 (Spark UI) |
| DSA-WEB-RESTService | 8096 | — |
| PostgreSQL | — | 5432 |
| MongoDB | — | 27018 (host) → 27017 (container) |
| RestHeart | 8082 | — |

### Security
All Spring Boot services use basic authentication (disabled by default via `SecurityAutoConfiguration` exclusion). Default credentials where applicable: `developer` / `iis`.

## 📁 Key Files

```
InformationIntegrationSystems/
├── docker-compose.yml                          # Infrastructure (Postgres, MongoDB, seed)
├── mongo-seed/
│   └── seed_product_categories.js              # MongoDB init: 71 product categories
│
├── DSA-DOC-CSVService/                         # CSV Access Layer
│   └── src/main/java/org/datasource/
│       ├── RESTViewServiceCSV.java             # REST controller
│       └── csv/olist/
│           ├── OrderView.java                  # POJO
│           ├── OrderCSVViewBuilder.java         # CSV parser
│           ├── OrderItemView.java              # POJO
│           └── OrderItemCSVViewBuilder.java     # CSV parser
│
├── DSA-SQL-JPAService/                         # PostgreSQL Access Layer
│   └── src/main/java/org/datasource/
│       ├── RESTCustomerViewService.java        # REST controller (customers)
│       ├── RESTSellerViewService.java          # REST controller (sellers)
│       └── springdata/views/
│           ├── CustomerView.java               # JPA entity
│           ├── CustomerViewRepository.java
│           ├── SellerView.java                 # JPA entity
│           └── SellerViewRepository.java
│
├── DSA-NoSQL-MongoDBService/                   # MongoDB Access Layer
│   └── src/main/java/org/datasource/
│       ├── RESTViewServiceMongoDB.java          # REST controller
│       └── mongodb/views/productcategories/
│           ├── ProductCategoryView.java         # POJO
│           ├── ProductCategoriesListView.java   # Document wrapper
│           └── ProductCategoryViewBuilder.java  # MongoDB reader (manual Document mapping)
│
├── DSA-SparkSQL-Service/                       # Integration Engine
│   └── src/main/resources/scripts/
│       ├── DS_CSV_Orders_SparkSQL_Views.sql     # Script 1: CSV views
│       ├── DS_PG_Olist_SparkSQL_Views.sql       # Script 2: PostgreSQL views
│       ├── DS_MongoDB_Products_SparkSQL_Views.sql # Script 3: MongoDB views
│       └── SparkSQL_OLAP_Olist.sql             # Script 4: OLAP model
│
└── DSA-WEB-RESTService/                        # Web Model / API Gateway
    └── src/main/java/org/j4di/
        ├── RESTViewService.java                # REST controller (JdbcTemplate-based)
        └── analytical/views/
            ├── OLAP_VIEW_SALES_BY_STATE.java          # Entity (reference only)
            ├── OLAP_VIEW_SALES_BY_CATEGORY.java       # Entity (reference only)
            └── OLAP_VIEW_SALES_RANK.java              # Entity (reference only)
```

## ✅ Deliverables Checklist (per specs)

| Requirement | Status | Details |
|-------------|--------|---------|
| ~3 Access Model microservices | ✅ | CSV, JPA/PostgreSQL, MongoDB |
| DSA-SparkSQL-Service running | ✅ | Hive Thrift on port 10000 |
| SQL scripts for data source views | ✅ | 3 scripts (CSV, PG, MongoDB) |
| SQL script for OLAP analytical model | ✅ | `SparkSQL_OLAP_Olist.sql` |
| WEB REST service exposing OLAP views | ✅ | 3 endpoints via Hive JDBC |
| Java4DI architecture | ✅ | Stratified: Access → Integration → Web |
| Spring Boot + Spark SQL platform | ✅ | 5 Spring Boot projects |
| Total: ~5 Spring Boot projects | ✅ | 5 projects |
| Total: ~4 SQL scripts | ✅ | 4 scripts |
