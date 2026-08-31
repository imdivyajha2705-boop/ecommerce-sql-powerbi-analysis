-- =========================================================
-- CUSTOMER ANALYSIS
-- =========================================================
use ecommerce_analysis;
-- =========================================================
-- 1. New vs Returning Orders
-- =========================================================
with customer_first_order as (
SELECT
  customer_id,
  min(order_date) as first_order_date
  from orders 
  where order_status = 'completed'
  group by customer_id )
select 
      o.order_id,
      o.customer_id,
      o.order_date,
      case when  o.order_date = f.first_order_date then 'New' else 
      'Returning' end as customer_type
      from orders as o 
      join customer_first_order as f 
      on o.customer_id = f.customer_id
      where o.order_status = 'completed';
      
-- =========================================================
--  MOM New vs Returning Customers
-- =========================================================    
    with customer_first_order as (
    select customer_id,
		min(order_date) as first_order
     from orders 
	group by customer_id
     ) ,
	customer_summary as (
      select 
            o.order_id,
            o.customer_id,
            o.order_date,
            case when o.order_date = f.first_order then 'NEW' 
            else 'Returning' end as customer_type 
            from orders as o join customer_first_order as f 
            on o.customer_id = f.customer_id 
            where o.order_status = 'completed'
            )
	select 
         date_format(order_date , '%Y-%m-01' ) as Month,
         customer_type ,
         count(distinct order_id) as total_orders from customer_summary
         group by 
          date_format(order_date , '%Y-%m-01' ) ,
         customer_type
         order by Month;
-- =========================================================
-- 2. REPEAT CUSTOMER RATE
-- =========================================================         
 
 with customer_repeat_orders as (
 select 
        customer_id ,
        count(distinct order_id) as total_orders 
        from orders 
        where order_status = 'completed'
        group by customer_id
         )
select 
      count(*) as total_customers,
      sum(case when total_orders > 1 then 1
      else 0 end ) as repeat_customers ,
      round(
      sum(
      case when total_orders > 1 then 1
      else 0 end )
      / count(*) *100.0 ,2)
      as repeat_customer_pct
      from customer_repeat_orders;
-- =========================================================
-- 3. TOP CUSTOMERS BY LIFETIME REVENUE
-- =========================================================         
	
  select 
         c.customer_name,
         count(distinct o.order_id ) as total_orders,
         round(sum( o.total_amount),2) as lifetime_revenue,
         round(sum( o.total_amount) /   count(distinct o.order_id ),2) as AOV 
         from customers as c join orders as o 
         on c.customer_id = o.customer_id 
         where o.order_status = 'completed'
         group by 
         c.customer_id,
         c.customer_name
         order by lifetime_revenue desc ;
         
-- =========================================================
-- 4.CUSTOMERS INACTIVE FOR MORE THAN 90 DAYS
-- =========================================================   
 
 select 
 c.customer_id,
 c.customer_name ,
 max(o.order_date) as last_order_date
 from customers as c join orders as o 
 on c.customer_id = o.customer_id 
 where o.order_status = 'completed'
 group by 
 c.customer_id,
 c.customer_name
 order by last_order_date ;
 
 SELECT MAX(order_date)
FROM orders;

select 
   c.customer_id,
   c.customer_name,
   max(order_date) as last_order_date 
   from customers as c join orders as o 
   on c.customer_id = o.customer_id 
   where o.order_status = 'completed'
   group by   
   c.customer_id,
   c.customer_name
   having 
   last_order_date < date_sub(
   (Select max(order_date) from orders)
   , interval 90 day ) 
   order by last_order_date  asc;
-- =========================================================
-- 5.CHURN-RISK CUSTOMER RATE
-- =========================================================      
 with customer_last_order as (
 select 
       c.customer_id,
       c.customer_name,
	   max(o.order_date) as last_order_date
       from customers as c join orders as o
       on c.customer_id = o.customer_id 
       where o.order_status = 'completed'
       group by 
         c.customer_id,
         c.customer_name )
select 
       count(*) as total_customers,
       sum(case when last_order_date < date_sub( 
                (select max(order_date) from orders) , interval 90 day ) then 1 else 0 end)
                as total_churn_customers,
             round(
             sum(case when last_order_date < date_sub( 
                (select max(order_date) from orders) , interval 90 day ) then 1 else 0 end)
                /   nullif(count(*),0) * 100.0 ,2) as churn_customers_pct
        from     customer_last_order ;   
        
-- =========================================================
-- 6.Customer Value Segmentation
-- =========================================================            
                
  with customer_revenue as (
  select 
         c.customer_id,
         c.customer_name,
         sum(o.total_amount) as lifetime_revenue 
         from customers as c join orders as o 
         on c.customer_id = o.customer_id 
         where o.order_status = 'completed'
         group by 
                 c.customer_id,
                 c.customer_name
         order by lifetime_revenue   desc ),
  customer_segmentation as (
  select 
          customer_id,
          customer_name,
          lifetime_revenue ,
          case 
          when lifetime_revenue  >= 1000 then 'High value' 
		  when lifetime_revenue  >= 500 then 'Medium value'
          else 'Low value' end  as customer_segment 
          from customer_revenue )
	
    select 
           customer_segment ,
           count(*) as no_of__customers,
           sum( lifetime_revenue) as total_revenue,
           round(
                  sum( lifetime_revenue) / nullif(count(*) ,0) ,2) as avg_customer_value
     from customer_segmentation 
     group by customer_segment
     order by total_revenue desc;      
                  
           
        
