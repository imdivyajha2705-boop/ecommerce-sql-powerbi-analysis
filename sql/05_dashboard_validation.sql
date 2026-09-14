-- =========================================================
-- 1. Total revenue , ordes , customers and AOV
-- =========================================================  


SELECT
    ROUND(SUM(total_amount), 2) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(
        SUM(total_amount) / COUNT(DISTINCT order_id),
        2
    ) AS aov
FROM orders
WHERE order_status = 'completed';

-- =========================================================
-- 2. Repeat customers percentage
-- =========================================================  

select customer_id, count(distinct order_id) as total_orders
from orders 
where order_status = 'completed'
group by customer_id
order by total_orders desc;

with customer_orders as ( 
     select  customer_id , 
             count(distinct order_id) as total_orders
             from orders
             where order_status = 'completed'
             group by customer_id)
             
  select count(*) as total_customers,
        sum( case when total_orders > 1 then 1 
                  else 0 
                  end ) as repeat_customers ,
         round(     sum( case when total_orders > 1 then 1 
                  else 0 
                  end ) / 
                  nullif( count(*),0) * 100.0,2) as repeat_customer_perc 
      from customer_orders ;
                  
-- =========================================================
-- 3. Monthly Performance 
-- =========================================================  		

select 
      date_format(order_date, '%Y-%m-01') as month ,
      round( sum(total_amount) ,2) as revenue,
      count(distinct order_id) as total_orders ,
      round( sum(total_amount )/ nullif( count(distinct order_id) ,0) ,2) as AOV 
      from orders 
      where order_status = 'completed'
      group by  date_format(order_date, '%Y-%m-01')
      order by month;

  -- =========================================================
-- 4. worst/best month
-- =========================================================  	    
  with monthly_performance as ( 
     select date_format(order_date , '%Y-%m') as month,
     round(sum(total_amount) ,2 )as revenue , 
     count(distinct order_id) as total_orders,
     round( sum(total_amount)/ nullif(count(distinct order_id),0),2) as aov 
     from orders 
     where order_status = 'completed'
     group  by date_format(order_date , '%Y-%m')
     )
     select * from monthly_performance 
     order by revenue desc;
      
-- =========================================================
-- 5. Channel Performance
-- =========================================================  	   
 
 select channel ,
 round(sum(total_amount) ,2) as revenue,
 count(distinct order_id) as total_orders,
 round(sum(total_amount)/ nullif(count(distinct order_id),0) ,2) as aov
 from orders 
 where order_status = 'completed'
 group by channel
 order by revenue desc;
 
-- =========================================================
-- 6. product/category performance
-- =========================================================  
 select p.category,
round( sum(oi.quantity * oi.unit_price) ,2) as revenue,
sum(oi.quantity) as total_units,
count(distinct o.order_id) as total_orders 
from products as p join order_items as oi 
on p.product_id = oi.product_id 
join orders as o 
on oi.order_id  = o.order_id 
where o.order_status = 'completed'
group by p.category
order by revenue desc;
        
 