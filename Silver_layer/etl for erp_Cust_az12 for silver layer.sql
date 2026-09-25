insert into silver_erp_cust_az12(
cid,
bdate,
gen)

select case
when cid like 'NAS%' then substring(cid,4,length(cid))  
else cid
end as cid,
case 
when  cast(bdate as char ) ='0000-00-00'  or bdate >'2024-01-01' then null
else bdate
end as bdate,
case 
when upper(trim(gen)) in ('F','FEMALE') then 'Female' 
when upper(trim(gen)) in ('M','MALE') then 'Male'
else 'n/a'
end as  gen 
from erp_cust_az12
