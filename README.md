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
│       GET /OLAP/SALES_BY_STATE    (ROLLUP)                             │
│       GET /OLAP/SALES_BY_CATEGORY (CUBE)                               │
│       GET /OLAP/SALES_RANK        (RANK)                               │
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
│       GET /olist/CustomerView                                          │
│       GET /olist/SellerView                                            │
│                                                                        │
│   DSA-NoSQL-MongoDBService (Port 8093)                                 │
│   └── Connects to MongoDB (product category translations)              │
│       GET /products/ProductCategoryView                                │
├─────────────────────────────────────────────────────────────────────────┤
│                     INFRASTRUCTURE (Docker)                            │
│                                                                        │
│   postgres-db (Port 5432)  │  mongo-db (Port 27017)                    │
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
- **MongoDB** (`mongo-db`) on port 27017.
- **mongo-seed** (one-shot container) — automatically seeds the `olist_mongo.ProductCategories` collection with all 71 Olist product categories (Portuguese + English names).

### Step 2: Start the Access Model Services
Start these three Spring Boot applications (via IntelliJ Run or `mvn spring-boot:run` from each project directory). They can be started in any order:

```
DSA-DOC-CSVService       → http://localhost:8097/DSA-DOC-CSVService/rest/orders/OrderView
DSA-SQL-JPAService       → http://localhost:8091/DSA_SQL_JPAService/rest/olist/CustomerView
DSA-NoSQL-MongoDBService → http://localhost:8093/DSA-NoSQL-MongoDBService/rest/products/ProductCategoryView
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

### Step 5: Start the Web Model
```
DSA-WEB-RESTService → http://localhost:8096/DSA-WEB-RESTService/rest/OLAP/SALES_BY_STATE
```
This service connects to Spark SQL via the Hive JDBC driver (`jdbc:hive2://localhost:10000`) and uses Spring Data JPA to map the analytical views to REST endpoints.

## 🔍 Data Flow (End-to-End)

The complete data journey for a single request to `/OLAP/SALES_BY_STATE`:

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

## 📊 Analytical Views (OLAP Model)

The OLAP model implements three analytical techniques from the course:

### 1. ROLLUP — Sales by Customer State
```sql
SELECT customerState, COUNT(DISTINCT orderId), SUM(totalAmount), AVG(totalAmount)
FROM OLAP_FACTS_ORDER_AMOUNTS
GROUP BY ROLLUP(customerState)
ORDER BY totalSalesAmount DESC;
```
Produces hierarchical subtotals: per-state totals → grand total. Exposed at `GET /OLAP/SALES_BY_STATE`.

### 2. CUBE — Sales by Category × Seller State
```sql
SELECT categoryNameEnglish, sellerState, COUNT(DISTINCT orderId), SUM(totalAmount)
FROM OLAP_FACTS_ORDER_AMOUNTS f
    JOIN OLAP_DIM_SELLERS_GEO s ON f.sellerId = s.sellerId
    LEFT JOIN product_categories_view pc ON ...
GROUP BY CUBE(categoryNameEnglish, sellerState);
```
Produces cross-tabulation with subtotals for every combination of category and state. Exposed at `GET /OLAP/SALES_BY_CATEGORY`.

### 3. RANK — Top States Ranking
```sql
SELECT customerState, SUM(totalAmount),
    RANK() OVER (ORDER BY totalSalesAmount DESC),
    DENSE_RANK() OVER (ORDER BY totalSalesAmount DESC),
    PERCENT_RANK() OVER (ORDER BY totalSalesAmount DESC)
FROM OLAP_FACTS_ORDER_AMOUNTS
GROUP BY customerState;
```
Ranks states by total revenue using window functions (RANK, DENSE_RANK, PERCENT_RANK, ROW_NUMBER). Exposed at `GET /OLAP/SALES_RANK`.

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
| MongoDB | — | 27017 |
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
│       ├── RESTViewServiceJPA.java             # REST controller
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
│           └── ProductCategoryViewBuilder.java  # MongoDB reader
│
├── DSA-SparkSQL-Service/                       # Integration Engine
│   └── src/main/resources/scripts/
│       ├── SparkSQL_OLAP_Olist.sql             # OLAP model (ROLLUP, CUBE, RANK)
│       └── SparkSQL_OLAP_Multidimensional_Analytical.sql  # (boilerplate reference)
│
└── DSA-WEB-RESTService/                        # Web Model / API Gateway
    └── src/main/java/org/j4di/
        ├── RESTViewService.java                # REST controller (OLAP endpoints)
        └── analytical/views/
            ├── OLAP_VIEW_SALES_BY_STATE.java          # JPA entity + Repository
            ├── OLAP_VIEW_SALES_BY_CATEGORY.java       # JPA entity + Repository
            └── OLAP_VIEW_SALES_RANK.java              # JPA entity + Repository
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
