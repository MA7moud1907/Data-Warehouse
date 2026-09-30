create view gold.dim_product as (
select
row_number() over(order by pn.prd_id,date(pn.prd_start_dt)) as prdouct__key,
 pn.prd_id as product_id, 
pn.prd_key as product_number,
pn.prd_nm as product_name ,
pn.cat_id as  category_id,
pc.cat as category_name,
pc.subcat as sub_category_name,
pc.maintenance as manitenance,
pn.prd_cost as product_cost ,
pn.prd_line as  product_line,
date(pn.prd_start_dt) as start_date
from silver_crm_product_info pn
left join silver_erp_pax_cat_g1v2 as pc 
on pn.cat_id= pc.id
 )