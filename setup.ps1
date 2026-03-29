<#
.SYNOPSIS
    Federated Database System — Full Setup Script
.DESCRIPTION
    Orchestrates the complete FDB infrastructure from scratch.
    Assumes Docker Desktop is running and CSV datasets are in the
    same directory as this script.
.NOTES
    Run from the project root:
    powershell -ExecutionPolicy Bypass -File .\setup.ps1
#>

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

function Write-Step { param([string]$msg) Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Write-Ok   { param([string]$msg) Write-Host "    [OK] $msg" -ForegroundColor Green }
function Write-Err  { param([string]$msg) Write-Host "    [FAIL] $msg" -ForegroundColor Red }

# ============================================================
# STEP 0: Preflight Checks
# ============================================================
Write-Step "Step 0: Preflight checks"

$requiredCsvs = @(
    "olist_customers_dataset.csv",
    "olist_sellers_dataset.csv",
    "olist_geolocation_dataset.csv",
    "olist_orders_dataset.csv",
    "olist_order_items_dataset.csv",
    "olist_order_payments_dataset.csv",
    "olist_order_reviews_dataset.csv",
    "olist_products_dataset.csv",
    "product_category_name_translation.csv"
)
foreach ($csv in $requiredCsvs) {
    if (-not (Test-Path "$root\$csv")) {
        Write-Err "Missing dataset: $csv"
        exit 1
    }
}
Write-Ok "All 9 CSV datasets found"

docker info *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Err "Docker is not running. Please start Docker Desktop."
    exit 1
}
Write-Ok "Docker is running"

# ============================================================
# STEP 1: Start Containers
# ============================================================
Write-Step "Step 1: Starting Docker containers"
docker-compose -f "$root\docker-compose.yml" up -d
Write-Ok "Containers started"

# ============================================================
# STEP 2: Wait for Databases to be Ready
# ============================================================
Write-Step "Step 2: Waiting for databases to initialise"

# -- PostgreSQL
Write-Host "    Waiting for PostgreSQL..." -NoNewline
for ($i = 0; $i -lt 30; $i++) {
    $pg = docker exec postgres-db pg_isready -U postgres 2>&1
    if ($pg -match "accepting connections") { break }
    Start-Sleep -Seconds 2
}
Write-Ok "PostgreSQL ready"

# -- MongoDB
Write-Host "    Waiting for MongoDB..." -NoNewline
for ($i = 0; $i -lt 30; $i++) {
    $mg = docker exec mongo-db mongosh --quiet --eval "db.runCommand({ping:1}).ok" 2>&1
    if ($mg -match "1") { break }
    Start-Sleep -Seconds 2
}
Write-Ok "MongoDB ready"

# -- Oracle (takes the longest on first run, ~2‒5 min)
Write-Host "    Waiting for Oracle (this may take a few minutes on first run)..." -NoNewline
for ($i = 0; $i -lt 90; $i++) {
    $ora = docker exec oracle-db bash -c "echo 'SELECT 1 FROM DUAL;' | sqlplus -s system/oracle@//localhost/XEPDB1" 2>&1
    if ($ora -match "^\s*1\s*$") { break }
    Start-Sleep -Seconds 5
}
Write-Ok "Oracle ready"

# -- PostgREST
Write-Host "    Waiting for PostgREST..." -NoNewline
for ($i = 0; $i -lt 20; $i++) {
    try {
        Invoke-RestMethod -Uri "http://localhost:3000/" -TimeoutSec 2 *> $null
        break
    } catch { Start-Sleep -Seconds 2 }
}
Write-Ok "PostgREST ready"

# -- RestHeart
Write-Host "    Waiting for RestHeart..." -NoNewline
$rhAuth = @{"Authorization" = "Basic " + [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("admin:secret"))}
for ($i = 0; $i -lt 20; $i++) {
    try {
        Invoke-RestMethod -Uri "http://localhost:8081/ping" -TimeoutSec 2 *> $null
        break
    } catch { Start-Sleep -Seconds 2 }
}
Write-Ok "RestHeart ready"

# ============================================================
# STEP 3: Load PostgreSQL Data
# ============================================================
Write-Step "Step 3: Loading PostgreSQL data (customers, sellers, geolocation)"

docker exec postgres-db mkdir -p /data
docker cp "$root\olist_customers_dataset.csv"   postgres-db:/data/
docker cp "$root\olist_sellers_dataset.csv"      postgres-db:/data/
docker cp "$root\olist_geolocation_dataset.csv"  postgres-db:/data/
docker cp "$root\postgres-init\init.sql"         postgres-db:/data/
docker exec postgres-db psql -U postgres -d olist_db -f /data/init.sql

# PostgREST caches the schema at startup. Restart it so it
# discovers the tables we just created.
docker restart postgrest-api *> $null
Start-Sleep -Seconds 3
Write-Ok "PostgreSQL data loaded (PostgREST schema cache refreshed)"

# ============================================================
# STEP 4: Load MongoDB Data
# ============================================================
Write-Step "Step 4: Loading MongoDB data (order_reviews, products)"

docker exec mongo-db mkdir -p /data/import
docker cp "$root\olist_order_reviews_dataset.csv"           mongo-db:/data/import/
docker cp "$root\olist_products_dataset.csv"                mongo-db:/data/import/
docker cp "$root\product_category_name_translation.csv"     mongo-db:/data/import/
docker cp "$root\mongo-init\01_transform.js"                mongo-db:/data/import/

docker exec mongo-db mongoimport --db olist_db --collection order_reviews      --type csv --headerline --file /data/import/olist_order_reviews_dataset.csv
docker exec mongo-db mongoimport --db olist_db --collection products_raw       --type csv --headerline --file /data/import/olist_products_dataset.csv
docker exec mongo-db mongoimport --db olist_db --collection category_translation --type csv --headerline --file /data/import/product_category_name_translation.csv

docker exec mongo-db mongosh --quiet /data/import/01_transform.js
Write-Ok "MongoDB data loaded and products merged with category translations"

# ============================================================
# STEP 5: Load Oracle Data
# ============================================================
Write-Step "Step 5: Loading Oracle data (orders, order_items, payments)"

docker exec -u root oracle-db bash -c "mkdir -p /opt/oracle/csv && chown oracle:oinstall /opt/oracle/csv"
docker cp "$root\olist_orders_dataset.csv"         oracle-db:/opt/oracle/csv/
docker cp "$root\olist_order_items_dataset.csv"     oracle-db:/opt/oracle/csv/
docker cp "$root\olist_order_payments_dataset.csv"  oracle-db:/opt/oracle/csv/
docker cp "$root\oracle-init\01_schema.sql"         oracle-db:/opt/oracle/csv/

docker exec oracle-db bash -c "sqlplus system/oracle@//localhost/XEPDB1 @/opt/oracle/csv/01_schema.sql"
Write-Ok "Oracle data loaded"

# ============================================================
# STEP 6: Configure Oracle Network ACLs (CDB root level)
# ============================================================
Write-Step "Step 6: Configuring Oracle network ACLs for outbound HTTP"

docker cp "$root\oracle-init\02_acl.sql" oracle-db:/opt/oracle/csv/
docker exec oracle-db bash -c "sqlplus sys/oracle@//localhost/XE as sysdba @/opt/oracle/csv/02_acl.sql"
Write-Ok "ACLs configured at CDB root"

# ============================================================
# STEP 7: Create Oracle Helper Functions
# ============================================================
Write-Step "Step 7: Creating Oracle helper functions (get_rest_clob)"

docker cp "$root\oracle-init\03_functions.sql" oracle-db:/opt/oracle/csv/
docker exec oracle-db bash -c "sqlplus system/oracle@//localhost/XEPDB1 @/opt/oracle/csv/03_functions.sql"
Write-Ok "Helper functions created"

# ============================================================
# STEP 8: Create Oracle Views (Abstraction + Consolidation)
# ============================================================
Write-Step "Step 8: Creating Oracle abstraction & consolidation views"

docker cp "$root\oracle-init\04_views.sql" oracle-db:/opt/oracle/csv/
docker exec oracle-db bash -c "sqlplus system/oracle@//localhost/XEPDB1 @/opt/oracle/csv/04_views.sql"
Write-Ok "All views created"

# ============================================================
# STEP 9: Validation
# ============================================================
Write-Step "Step 9: Running validation"
& "$root\validate.ps1"

Write-Host "`n============================================================" -ForegroundColor Green
Write-Host " FDB SETUP COMPLETE" -ForegroundColor Green
Write-Host "============================================================`n" -ForegroundColor Green
