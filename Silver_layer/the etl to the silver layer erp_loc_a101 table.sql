insert into silver_erp_loc_a101(
cid,cntry)
select replace(cid,'-','')as cid,
case 
when  upper(trim(cntry)) in('US','UNITED STATES','USA') then 'United States'
when  upper(trim(cntry)) in('DE','GERMANY') then 'Germany'
when    trim(cntry)= '' or cntry is null then 'n/a'
else trim(cntry)
end as cntry
from erp_loc_a101