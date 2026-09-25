insert into silver_crm_sales_details(
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
select 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    case 
        when sls_order_dt = 0 or length(sls_order_dt) != 8 then null 
        else cast(cast(sls_order_dt as char) as date)
    end as sls_order_dt,
    case 
        when sls_due_dt = 0 or length(sls_due_dt) != 8 then null 
        else cast(cast(sls_due_dt as char) as date)
    end as sls_due_dt,
    case 
        when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * ABS(sls_price)
        then sls_quantity * ABS(sls_price)
        else sls_sales
    end as sls_sales,
    sls_quantity,
    case 
        when sls_price is null or sls_price <= 0
        then sls_sales / NULLIF(sls_quantity, 0) 
        else sls_price 
    end as sls_price
from crm_sales_details;