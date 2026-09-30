create view gold.fact_sales as(
select  
sd.sls_ord_num as order_number,
pr.prdouct__key ,
c.customer_key,
sd.sls_order_dt as order_date,
sd.sls_ship_dt as shipping_date,
sd.sls_due_dt as due_date ,
sd.sls_price ,
sd.sls_quantity ,
sd.sls_sales 
from silver_crm_sales_details sd
left join gold.dim_product pr
on sd.sls_prd_key = pr.product_number
left join gold.dim_customers c
on sd.sls_cust_id= c.customer_id
)