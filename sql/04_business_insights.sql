-- =========================================================
-- Business Insight
-- =========================================================

-- =========================================================
-- 1.Best-performing region
-- =========================================================    
use eccomerse_analysis; 

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
-- 2. Which sales channel is growing fastest?
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