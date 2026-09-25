/* =====================================================================
   BRONZE LAYER - raw tables + CSV load
   Purpose : Store source data exactly as received (no cleaning).
   Sources : CRM (3 files) and ERP (3 files)
   NOTE    : Column names/types are inferred from the silver ETL scripts.
             Check them against your real tables before publishing.
   ===================================================================== */

-- Needed once per session/server for LOAD DATA LOCAL INFILE
-- SET GLOBAL local_infile = 1;
-- Also enable it in the Workbench connection: Advanced > "OPT_LOCAL_INFILE=1"


/* ---------------------------- CRM tables --------------------------- */

DROP TABLE IF EXISTS crm_cust_info;
CREATE TABLE crm_cust_info (
    cst_id             INT,
    cst_key            VARCHAR(50),
    cst_firstname      VARCHAR(50),
    cst_lastname       VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr           VARCHAR(50),
    cst_create_date    DATE
);

DROP TABLE IF EXISTS crm_prd_info;
CREATE TABLE crm_prd_info (
    prd_id       INT,
    prd_key      VARCHAR(50),
    prd_nm       VARCHAR(255),
    prd_cost     INT,
    prd_line     VARCHAR(50),
    prd_start_dt DATETIME
    -- prd_end_dt DATETIME   -- add back if your source file has it
);

DROP TABLE IF EXISTS crm_sales_details;
CREATE TABLE crm_sales_details (
    sls_ord_num  VARCHAR(50),
    sls_prd_key  VARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,          -- raw YYYYMMDD integer
    sls_ship_dt  INT,          -- raw YYYYMMDD integer
    sls_due_dt   INT,          -- raw YYYYMMDD integer
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT
);


/* ---------------------------- ERP tables --------------------------- */

DROP TABLE IF EXISTS erp_cust_az12;
CREATE TABLE erp_cust_az12 (
    cid   VARCHAR(50),
    bdate DATE,
    gen   VARCHAR(50)
);

DROP TABLE IF EXISTS erp_loc_a101;
CREATE TABLE erp_loc_a101 (
    cid   VARCHAR(50),
    cntry VARCHAR(50)
);

DROP TABLE IF EXISTS erp_px_cat_g1v2;
CREATE TABLE erp_px_cat_g1v2 (
    id          VARCHAR(50),
    cat         VARCHAR(50),
    subcat      VARCHAR(50),
    maintenance VARCHAR(50)
);


/* ----------------------------- Load data --------------------------- */
-- Full reload pattern: TRUNCATE first so re-running never duplicates rows.
-- File names other than cust_info.csv are assumed; adjust to your files.
-- If rows load with a trailing \r, change '\n' to '\r\n' (Windows files).

TRUNCATE TABLE crm_cust_info;
LOAD DATA LOCAL INFILE "D:/Downloads/cust_info.csv"
INTO TABLE crm_cust_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

TRUNCATE TABLE crm_prd_info;
LOAD DATA LOCAL INFILE "D:/Downloads/prd_info.csv"
INTO TABLE crm_prd_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

TRUNCATE TABLE crm_sales_details;
LOAD DATA LOCAL INFILE "D:/Downloads/sales_details.csv"
INTO TABLE crm_sales_details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

TRUNCATE TABLE erp_cust_az12;
LOAD DATA LOCAL INFILE "D:/Downloads/CUST_AZ12.csv"
INTO TABLE erp_cust_az12
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

TRUNCATE TABLE erp_loc_a101;
LOAD DATA LOCAL INFILE "D:/Downloads/LOC_A101.csv"
INTO TABLE erp_loc_a101
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

TRUNCATE TABLE erp_px_cat_g1v2;
LOAD DATA LOCAL INFILE "D:/Downloads/PX_CAT_G1V2.csv"
INTO TABLE erp_px_cat_g1v2
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


/* ------------------------ Row-count sanity check ------------------- */
SELECT 'crm_cust_info'     AS table_name, COUNT(*) AS row_count FROM crm_cust_info
UNION ALL SELECT 'crm_prd_info',      COUNT(*) FROM crm_prd_info
UNION ALL SELECT 'crm_sales_details', COUNT(*) FROM crm_sales_details
UNION ALL SELECT 'erp_cust_az12',     COUNT(*) FROM erp_cust_az12
UNION ALL SELECT 'erp_loc_a101',      COUNT(*) FROM erp_loc_a101
UNION ALL SELECT 'erp_px_cat_g1v2',   COUNT(*) FROM erp_px_cat_g1v2;
