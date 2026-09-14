-- =========================================================
-- Business Insight
-- =========================================================

-- =========================================================
-- 1.Regional Revenue Contribution %
-- =========================================================    
use ecommerce_analysis; 

with region_revenue as (
  select 
     c.region,
     sum(o.total_amount) as total_region_revenue
     from customers as c join orders as o
     on c.customer_id = o.customer_id 
     where o.order_status = 'completed'
     group by  c.region
    ),
total_company_revenue as (
select 
       sum(total_amount) as total_company_revenue 
       from orders 
       where order_status = 'completed')
  select 
      r.region,
      round(r.total_region_revenue,2) as total_region_revenue,
      round(t.total_company_revenue,2) as total_company_revenue ,
      round(r.total_region_revenue/t.total_company_revenue *100.0,2) as revenue_share_pct
      from  region_revenue  as r cross join total_company_revenue  as t
    order by total_region_revenue desc;
    
-- =========================================================
-- 2. . Channel Month-over-Month Revenue Growth
-- =========================================================      
                   
 with channel_current_revenue as (
 select 
	date_format(order_date , '%Y-%m-01') as month,
     channel,
     sum(total_amount) as current_month_revenue
     from orders 
     where order_status = 'completed'
     group by month , channel ),
  previous_channel_revenue as (
  select month,
         channel,
         current_month_revenue,
         lag(current_month_revenue) over (
             partition by channel 
             order by month )
             as previous_month_revenue 
       from     channel_current_revenue )
       
    select 
          month,
          channel,
           current_month_revenue,
           previous_month_revenue ,
           round(
                   (current_month_revenue -  previous_month_revenue)
                   / nullif(previous_month_revenue, 0) * 100.0 ,2) as MOM_pct
          from   previous_channel_revenue  
           order by month,channel;    
 
 -- =========================================================
-- 3A. Revenue concentration: Top 10 customer revenue share %?
-- =========================================================  

with top_10_customers as (
select 
       c.customer_id,
       c.customer_name,
       sum(o.total_amount) as total_customer_revenue 
       from customers as c join orders as o 
       on c.customer_id = o.customer_id 
       where o.order_status = 'completed'
       group by  c.customer_id,
                 c.customer_name
       order by   total_customer_revenue desc 
       limit 10 ),
total_company_revenue as (
 select 
        sum(total_amount) as total_company_revenue 
        from orders 
        where order_status = 'completed')
  select 
         t.customer_id,
         t.customer_name,
        round( t.total_customer_revenue,2) as lifetime_customer_revenue ,
		round(tc.total_company_revenue,2) as total_company_revenue ,
		round(t.total_customer_revenue/tc.total_company_revenue * 100.0 ,2) as customer_contribution
        from top_10_customers as t cross join total_company_revenue as tc 
        order by lifetime_customer_revenue desc;
         
-- =========================================================
-- 3B. Revenue concentration: Top 10 revenue concentration?
-- =========================================================                   
   with top_10_customers as (
select 
       c.customer_id,
       c.customer_name,
       sum(o.total_amount) as total_customer_revenue 
       from customers as c join orders as o 
       on c.customer_id = o.customer_id 
       where o.order_status = 'completed'
       group by  c.customer_id,
                 c.customer_name
       order by   total_customer_revenue desc 
       limit 10 ),
total_company_revenue as (
 select 
        sum(total_amount) as total_company_revenue 
        from orders 
        where order_status = 'completed')
  select 
        round(sum( t.total_customer_revenue),2) as  top_10_revenue ,
		round(max(tc.total_company_revenue),2) as total_company_revenue ,
		round(sum( t.total_customer_revenue)/
        max(tc.total_company_revenue) * 100.0 ,2) as customer_contribution_pct
        from top_10_customers as t cross join total_company_revenue as tc 
      ;  
      
-- =========================================================
-- 4. Why did revenue drop so sharply from July to August?
-- =========================================================  

  select 
        date_format(order_date , '%Y-%m') as month ,
        round(sum(total_amount) ,2) as total_revenue,
        round(count(distinct order_id),2) as total_orders,
        round(sum(total_amount)/count(distinct order_id),2) as AOV 
        from orders 
        where order_status = 'completed'
        and order_date >= '2026-07-01'
        and order_date < '2026-09-01'
        group by  date_format(order_date , '%Y-%m')
        order by month;
        
SELECT
    MIN(order_date) AS earliest_order,
    MAX(order_date) AS latest_order
FROM orders;

SELECT
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    COUNT(*) AS orders
FROM orders
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY
    year,
    month;
    
    SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(
        SUM(total_amount) / COUNT(DISTINCT order_id),
        2
    ) AS AOV
FROM orders
WHERE order_status = 'completed'
  AND order_date >= '2026-06-01'
  AND order_date < '2026-08-01'
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    ROUND(SUM(total_amount), 2) AS revenue
FROM orders
WHERE order_status = 'completed'
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

