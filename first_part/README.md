# Federated Database System (FDB) - Infrastructure Setup

This project simulates a real-world enterprise scenario where heterogeneous legacy systems are integrated into a unified analytical pipeline. It orchestrates a Federated Database System (FDB) using Docker, distributing the Olist Brazilian E-Commerce dataset across three different database engines. The dataset is found [here](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce/data).

## 🏗 Architecture Overview

The infrastructure relies on three distinct databases and two REST API wrappers, all communicating securely over a private Docker bridge network (`fdb-network`):

1. **Oracle Database 21c XE (`oracle-db`)**: 
   - Acts as the primary FDB hub (Relational Core).
   - Stores: `orders`, `order_items`, `order_payments`.
   - Contains abstraction views that federate data from the other systems and consolidation views for Layer 2 analytical queries.
2. **PostgreSQL 14 (`postgres-db`)**: 
   - Secondary relational source.
   - Stores: `customers`, `sellers`, `geolocation`.
   - Exposed to Oracle via PostgREST on port 3000.
3. **MongoDB 6 (`mongo-db`)**: 
   - Document store for semi-structured data.
   - Stores: `order_reviews`, `products` (which contain deeply nested JSON arrays combining product metadata and category translations).
   - Exposed to Oracle via RestHeart v8 on port 8081.

## 🚀 Quick Start

To provision the entire environment from scratch, navigate to the project root and run the setup script:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

This single command automates the entire 9-step deployment process, from container orchestration to cross-database validation.

## 🔍 Step-by-Step Explanation of `setup.ps1`

The setup script handles container orchestration, data loading, networking, and validation with zero manual intervention. Here is exactly what happens under the hood:

### Step 1: Container Orchestration
- Executes `docker-compose up -d` to spin up the Oracle, PostgreSQL, MongoDB, PostgREST, and RestHeart containers. RestHeart is uniquely configured via the `RHO` environment variable to expose all MongoDB databases natively rather than just its default internal database.

### Step 2: Health Checks
- Actively waits for all 5 services to become responsive before pushing data. Oracle specifically can take 2-5 minutes to initialize on its first run depending on host hardware.

### Step 3: PostgreSQL Initialization
- Mounts and executes `postgres-init/init.sql`.
- Creates local tables and bulk-loads the `customers`, `sellers`, and `geolocation` CSV files natively using `\copy`.
- Restarts the PostgREST container to ensure its schema cache registers the newly created tables.

### Step 4: MongoDB Initialization & Transformation
- Imports the raw CSV data into MongoDB using `mongoimport`.
- Executes `mongo-init/01_transform.js`. Because MongoDB is a document store, this script runs an aggregation pipeline to deeply nest the `category_translation` English metadata directly into the `products` documents, creating complex nested JSON structures.

### Step 5: Oracle Relational Initialization
- Mounts and executes `oracle-init/01_schema.sql`.
- Uses Oracle's `ORGANIZATION EXTERNAL` tables to parse the raw CSV data directly from the filesystem into memory, then builds the permanent local relational tables (`orders`, `order_items`, etc.) using `CREATE TABLE AS SELECT` (CTAS) to handle timestamp casting.

### Step 6: Oracle Network Security (ACLs)
- Modern Oracle databases block outbound HTTP requests by default.
- Executes `oracle-init/02_acl.sql` as `SYSDBA` (connecting directly to the CDB root (`XE`)) to create Access Control Lists (ACLs) that explicitly permit the Oracle container to perform `HTTP GET` operations against the Docker bridge network.

### Step 7: REST API Helper Functions
- Executes `oracle-init/03_functions.sql`.
- Creates a PL/SQL wrapper function (`get_rest_clob`) that utilizes `UTL_HTTP` to perform web requests. It automatically injects Base64-encoded `Basic Auth` HTTP headers when communicating with RestHeart to clear its default security layer.

### Step 8: Abstraction & Consolidation Views
- Executes `oracle-init/04_views.sql`.
- **Abstraction Views**: Creates views (`vw_ext_customers`, `vw_ext_products`, etc.) that dynamically fetch JSON payloads from PostgREST and RestHeart. These views utilize `JSON_TABLE` to recursively flatten the nested JSON responses into standard relational rows.
- **Consolidation View**: Combines the local Oracle tables with the abstracted REST views into a single, seamless entity (`vw_consolidated_orders`) ready for complex Layer 2 analytical queries.

### Step 9: Final Validation
- Automatically executes `validate.ps1` to test the architecture end-to-end.
- Asserts that PostgREST returns rows, RestHeart returns documents with nested category translations, and finally, queries the Oracle `vw_consolidated_orders` to prove the FDB successfully joins data across all three entirely disconnected database engines in real time.
