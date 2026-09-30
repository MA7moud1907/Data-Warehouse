select  year(order_Date) as year,month(order_Date) as month_num ,sum(sls_sales) as total_sales ,
count( distinct customer_key) as total_Customer ,
sum(sls_quantity) as total_quantities
from gold.fact_sales
where year(order_Date)  is not null
group by   1  ,month(order_Date)
order by 1 ,2 desc;  -- Sales over time 
-- --------------------------------------------------------- -- 
with  running_total as(
select  year(order_date) as year_sales,  sum(sls_sales) as total_sales , round(avg(sls_sales),0) as average
from gold.fact_sales
where year(order_date) is not null
group by year(order_date)
order by year(order_date)
)
select  year_sales ,total_sales , sum(total_sales) over( order by year_sales) as running_total_sales , 
avg(average) over( order by year_sales) as running_average_sales 
from running_total ; -- running total sales and running average sales 
 -- -------------------------------------------------- ----------------------------------------------------------------------------- -- 
WITH cte AS (
    SELECT 
        (YEAR(s.order_date)) AS order_year,
        p.product_name, 
        p.category_name, 
        SUM(s.sls_sales) AS current_sales
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_product p
        ON s.prdouct__key = p.prdouct__key 
    WHERE s.order_date IS NOT NULL
    GROUP BY 
        YEAR(s.order_date), 
        p.product_name, 
        p.category_name
),
 cte2 as (
 select
 order_year,
    product_name,
    current_sales,
    round(AVG(current_sales) OVER (PARTITION BY product_name),0) AS avg_sales_by_product,
     current_sales - round(AVG(current_sales) OVER (PARTITION BY product_name),0) as diff_in_avg
     FROM cte
     )
     select  order_year,product_name,current_sales, avg_sales_by_product, diff_in_avg ,
     case 
     when  diff_in_avg <0 then "below the average" 
     when  diff_in_avg >0 then "above the average"
     else "average" 
     end as flag, -- year over year analysis
     lag(current_sales) over(partition by product_name   order by order_year) as previous_year_sales,
     current_sales -  lag(current_sales) over(partition by product_name   order by order_year) difference_previous_year,
     case 
     when  current_sales -  lag(current_sales) over(partition by product_name   order by order_year) >0 then "increase"
	when  current_sales -  lag(current_sales) over(partition by product_name   order by order_year) <0 then "decrease"
    else 'no_change' end as previous_year_change
from cte2
     order by product_name ,order_year;
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------- --
with cte as(
Select  
        p.category_name as category, 
        SUM(s.sls_sales) AS current_sales
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_product p
        ON s.prdouct__key = p.prdouct__key 
    WHERE s.order_date IS NOT NULL
    GROUP BY 
        p.category_name
)
	select category ,current_sales,
    sum(current_sales) over() as overall_sales,
    concat(round((current_sales/sum(current_sales) over())*100,2),'%') as percatage
from cte;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------- --
with product_segment as (
select prdouct__key ,product_name,product_cost ,
case 
when product_cost < 100 then "below 100"
when product_cost between 100 and 500 then "100-500"
when product_cost between 500 and 1000 then "500-1000"
else  'Above 1000'
end as cost_range
from
gold.dim_product
)
select  count(prdouct__key)  ,cost_range
from product_segment
group by cost_range
order by 1 desc;
-- ---------------------------------------------------------------------------------------------------------------------------------- --
with cte as
(select customer_key,sum(sls_sales) as total_sales , min((order_date)) as first_order, max((order_date)) as last_order,
TIMESTAMPDIFF( month,min((order_date)), max((order_date))) as life_span,
case 
when  sum(sls_sales) > 5000 and  TIMESTAMPDIFF( month,min((order_date)), max((order_date))) >=12
 then "vip"
when  sum(sls_sales) <=5000 and  TIMESTAMPDIFF( month,min((order_date)), max((order_date))) >=12
 then "regular"
 else "new"
end as customer_segment
from  gold.fact_sales 
group by customer_key 
)
select count(customer_key) as customer_segment ,customer_segment
from cte
group by customer_segment
order by  count(customer_key) desc