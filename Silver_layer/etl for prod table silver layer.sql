INSERT INTO silver_crm_product_info (
    prd_id, 
    cat_id, 
    prd_key, 
    prd_cost, 
    prd_line, 
    prd_nm, 
    prd_start_dt
)
SELECT 
    prd_id, 
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
    COALESCE(prd_cost, 0) AS prd_cost,
    CASE 
        WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
        WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other sales'
        WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
        ELSE 'N/A'
    END AS prd_line,
    prd_nm, 
    CAST(prd_start_dt AS DATE) AS prd_start_dt
FROM crm_prd_info;