insert into silver_cust (
cst_id,
cst_key ,
cst_firstname,
cst_lastname,
cst_gndr ,
 cst_marital_status ,
 cst_create_date
)
select 
cst_id,
cst_key ,
trim(cst_firstname) as cst_firstname ,
trim(cst_lastname) as cst_lastname,
case 
when upper(trim(cst_gndr)) ='F' then 'Female' 
when upper(trim(cst_gndr))= 'M' then 'Male'
else  'n/a' 
end cst_gndr ,
case 
when upper(trim(cst_marital_status)) ='S' then 'Singel' 
when upper(trim(cst_marital_status))= 'M' then 'Married'
else  'n/a' 
end cst_marital_status ,
cst_create_date
from(
select * ,
row_number() over( partition by cst_id order by cst_create_date desc) as flag
from crm_cust_info
)t where flag =1