<#
.SYNOPSIS
    Validates the FDB infrastructure end-to-end.
.DESCRIPTION
    Tests PostgREST, RestHeart, and the Oracle consolidation view.
    Run after setup.ps1 or standalone to recheck.
.NOTES
    powershell -ExecutionPolicy Bypass -File .\validate.ps1
#>

$ErrorActionPreference = "Continue"

function Write-Step { param([string]$msg) Write-Host "`n--- $msg ---" -ForegroundColor Yellow }
function Write-Ok   { param([string]$msg) Write-Host "    [OK] $msg" -ForegroundColor Green }
function Write-Err  { param([string]$msg) Write-Host "    [FAIL] $msg" -ForegroundColor Red }

$rhAuth = @{
    "Authorization" = "Basic " + [System.Convert]::ToBase64String(
        [System.Text.Encoding]::UTF8.GetBytes("admin:secret")
    )
}

# -- PostgREST (PostgreSQL)
Write-Step "PostgREST (PostgreSQL)"
try {
    $pg = Invoke-RestMethod -Uri "http://localhost:3000/customers?limit=2"
    Write-Ok "Returned $($pg.Count) customer(s):"
    $pg | Format-Table customer_id, customer_city, customer_state -AutoSize
} catch {
    Write-Err $_.Exception.Message
}

# -- RestHeart (MongoDB)
Write-Step "RestHeart (MongoDB)"
try {
    $rh = Invoke-RestMethod -Uri "http://localhost:8081/olist_db/products?pagesize=2" -Headers $rhAuth
    Write-Ok "Returned $($rh.Count) product(s):"
    $rh | Format-Table product_id, product_category_name_english, product_weight_g -AutoSize
} catch {
    Write-Err $_.Exception.Message
}

# -- Oracle Local Tables
Write-Step "Oracle Local Tables"
docker exec oracle-db bash -c "sqlplus -s system/oracle@//localhost/XEPDB1 <<'EOF'
SET PAGESIZE 50
SET LINESIZE 200
COLUMN table_name FORMAT A20
COLUMN row_count  FORMAT 999999999
SELECT 'orders' AS table_name, COUNT(*) AS row_count FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'order_payments', COUNT(*) FROM order_payments;
EXIT;
EOF"

# -- Oracle Consolidation View (Cross-Database Query)
Write-Step "Oracle Consolidation View (Cross-Database Federation)"
docker exec oracle-db bash -c "sqlplus -s system/oracle@//localhost/XEPDB1 <<'EOF'
SET PAGESIZE 50
SET LINESIZE 200
COLUMN order_id       FORMAT A36
COLUMN customer_city  FORMAT A20
COLUMN category       FORMAT A30
COLUMN seller_city    FORMAT A20
SELECT order_id, customer_city, category, seller_city
FROM vw_consolidated_orders
FETCH FIRST 5 ROWS ONLY;
EXIT;
EOF"

Write-Host "`n--- Validation complete ---`n" -ForegroundColor Green
