USE ecommerce_analysis;


-- =========================================================
-- ECOMMERCE SALES & PRODUCT ANALYSIS
-- =========================================================


-- =========================================================
-- 1. OVERALL SALES PERFORMANCE
-- =========================================================

-- Overall revenue, completed orders and Average Order Value (AOV)

SELECT
    ROUND(SUM(total_amount), 2) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(
        SUM(total_amount) / COUNT(DISTINCT order_id),
        2
    ) AS AOV
FROM orders
WHERE order_status = 'completed';



-- =========================================================
-- 2. MONTHLY SALES PERFORMANCE
-- =========================================================

-- Monthly revenue, completed orders and AOV

SELECT
    DATE_FORMAT(order_date, '%Y-%m-01') AS month,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(
        SUM(total_amount) / COUNT(DISTINCT order_id),
        2
    ) AS AOV
FROM orders
WHERE order_status = 'completed'
GROUP BY DATE_FORMAT(order_date, '%Y-%m-01')
ORDER BY month;



-- =========================================================
-- 3. MONTH-OVER-MONTH REVENUE GROWTH
-- =========================================================

-- First calculate monthly revenue

WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m-01') AS month,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(total_amount) AS total_revenue
    FROM orders
    WHERE order_status = 'completed'
    GROUP BY DATE_FORMAT(order_date, '%Y-%m-01')
),

-- Add previous month's revenue using LAG()

monthly_comparison AS (
    SELECT
        month,
        total_orders,
        total_revenue,
        LAG(total_revenue) OVER (
            ORDER BY month
        ) AS previous_month_revenue
    FROM monthly_sales
)

-- Calculate MoM percentage change

SELECT
    month,
    total_orders,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,
    ROUND(
        (total_revenue - previous_month_revenue)
        / previous_month_revenue * 100,
        2
    ) AS mom_percentage
FROM monthly_comparison
ORDER BY month;



-- =========================================================
-- 4. SALES PERFORMANCE BY CHANNEL
-- =========================================================

SELECT
    channel,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(
        SUM(total_amount) / COUNT(DISTINCT order_id),
        2
    ) AS AOV
FROM orders
WHERE order_status = 'completed'
GROUP BY channel
ORDER BY total_revenue DESC;



-- =========================================================
-- 5. SALES PERFORMANCE BY REGION
-- =========================================================

SELECT
    c.region,
    ROUND(SUM(o.total_amount), 2) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(
        SUM(o.total_amount) / COUNT(DISTINCT o.order_id),
        2
    ) AS AOV
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'completed'
GROUP BY c.region
ORDER BY total_revenue DESC;



-- =========================================================
-- 6. PRODUCT PERFORMANCE
-- =========================================================

-- Product revenue is calculated from order_items rather than
-- orders.total_amount because one order can contain multiple products.

SELECT
    p.product_name,
    p.category,
    SUM(oi.quantity) AS units_sold,
    ROUND(
        SUM(oi.quantity * oi.unit_price),
        2
    ) AS total_revenue
FROM products AS p
JOIN order_items AS oi
    ON p.product_id = oi.product_id
JOIN orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'completed'
GROUP BY
    p.product_name,
    p.category
ORDER BY total_revenue DESC;
-- =========================================================
-- 7. TOP 5 PRODUCTS BY REVENUE WITHIN EACH CATEGORY
-- =========================================================

WITH SUMMARY AS ( 
SELECT
	p.category,
    p.product_name,
    SUM(oi.quantity) AS units_sold,
    ROUND(
        SUM(oi.quantity * oi.unit_price),
        2
    ) AS total_revenue
FROM products AS p
JOIN order_items AS oi
    ON p.product_id = oi.product_id
JOIN orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'completed'
GROUP BY
    p.product_name,
    p.category
),
TOP_PERFORMERS AS (
 SELECT 
      category,
      product_name,
      units_sold,
      total_revenue,
      dense_rank() over ( 
      partition by category 
      order by total_revenue desc
      )as revenue_rank 
      from summary )
select category,
      product_name,
       units_sold,
      total_revenue,
      revenue_rank
      from TOP_PERFORMERS
      where rn <= 5
      order by 
      category,
     revenue_rank;
-- =========================================================
-- 8. MONTH-OVER-MONTH CATEGORY PERFORMANCE
-- ========================================================= 

with summary as (
select 
     date_format(o.order_date, '%Y-%m-01') as Month,
     p.category ,
     sum(oi.quantity) as units_sold,
     sum(oi.quantity * oi.unit_price) as total_Revenue 
     from products as p join order_items as oi
     on p.product_id = oi.product_id
     join orders as o 
     on oi.order_id = o.order_id 
     where o.order_status = 'completed'
     group by 
     date_format(o.order_date, '%Y-%m-01') ,
     p.category ),
previous_month_summary as (
select month,
	   category,
       units_sold,
       total_Revenue,
       lag(total_Revenue) over (
       partition by category
       order by month ) as previous_month
       from summary )
select month,
	   category,
       units_sold,
       total_Revenue,
       previous_month,
       round((total_Revenue - previous_month)/nullif(previous_month,0) *100.0,2) as MOM_Perc
       from previous_month_summary;
