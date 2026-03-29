# FDB Infrastructure — Walkthrough

## Quick Start

```powershell
# Prerequisites: Docker Desktop running, CSV datasets in project root
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

The script handles everything — container orchestration, data loading, Oracle ACL configuration, REST wrapper setup, view creation, and validation.

---

## Project Structure

```
InformationIntegrationSystems/
├── docker-compose.yml          # 5 services on fdb-network
├── setup.ps1                   # One-shot orchestration (9 steps)
├── validate.ps1                # Standalone validation
├── postgres-init/
│   └── init.sql                # Schema + CSV load
├── mongo-init/
│   └── 01_transform.js         # Merge products + category translations
├── oracle-init/
│   ├── 01_schema.sql           # Tables via External Tables → CTAS
│   ├── 02_acl.sql              # CDB-level ACL (run as SYSDBA)
│   ├── 03_functions.sql        # get_rest_clob() UTL_HTTP wrapper
│   └── 04_views.sql            # Abstraction + consolidation views
└── *.csv                       # 9 Olist dataset files
```

---

## Architecture

| Container | Image | Port | Role |
|---|---|---|---|
| `oracle-db` | gvenzl/oracle-xe:21-slim | 1521 | FDB Hub — orders, items, payments |
| `postgres-db` | postgres:14 | 5432 | Customers, sellers, geolocation |
| `postgrest-api` | postgrest/postgrest | 3000 | REST wrapper for PostgreSQL |
| `mongo-db` | mongo:6 | 27017 | Products, order reviews |
| `restheart-api` | softinstigate/restheart:8 | 8081 | REST wrapper for MongoDB |

### Oracle Views

| View | Source | Method |
|---|---|---|
| `vw_ext_customers` | PostgreSQL | PostgREST → JSON_TABLE |
| `vw_ext_sellers` | PostgreSQL | PostgREST → JSON_TABLE |
| `vw_ext_products` | MongoDB | RestHeart + Basic Auth → JSON_TABLE |
| `vw_ext_order_reviews` | MongoDB | RestHeart + Basic Auth → JSON_TABLE |
| `vw_consolidated_orders` | All above JOINed | Consolidation |

---

## Key Issues Resolved

1. **Oracle ACL (`ORA-24247`)** — Must be created at **CDB root** via SYSDBA, not PDB level
2. **RestHeart 404** — Default `mongo-mount` maps to `restheart` DB; overridden via `RHO` env var to `{"what":"*","where":"/"}`
3. **RestHeart unreachable** — `RHO` override reset `http-listener/host` to `localhost`; added `"0.0.0.0"` binding
4. **RestHeart 401 from Oracle** — `UTL_HTTP.SET_AUTHENTICATION` uses proxy headers; switched to manual `SET_HEADER` with Base64
5. **PostgREST 404** — Schema cache stale after table creation; added `docker restart postgrest-api` after data load

---

## Clean-Slate Run

```
==> Step 0: [OK] All 9 CSV datasets found / Docker running
==> Step 1: [OK] Containers started
==> Step 2: [OK] PostgreSQL / MongoDB / Oracle / PostgREST / RestHeart ready
==> Step 3: [OK]  COPY 99441 / COPY 3095 / COPY 1000163
==> Step 4: [OK]  99224 + 32951 + 71 docs imported
==> Step 5-8: [OK] All Oracle objects created
==> Step 9: Validation
```

```
--- PostgREST ---  [OK] 2 customers returned
--- RestHeart ---  [OK] 2 products returned
--- Oracle ---     orders: 99441 | items: 112650 | payments: 103886
--- Consolidation View ---
ORDER_ID                             CUSTOMER_CITY        CATEGORY                SELLER_CITY
00f2c876aa08fbba04199823952e96c1     rio de janeiro       housewares              pedreira
0176d7e16d1bd14cde42d9d3a24e525b     cruzeiro             computers_accessories   itajai
0261eac8b7b097ab1e28579b69e6ea90     sao paulo            furniture_living_room   mesquita
```
