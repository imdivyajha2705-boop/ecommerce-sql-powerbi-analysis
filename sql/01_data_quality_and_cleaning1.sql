USE ecommerce_analysis;

-- =========================================================
-- 1. BASIC DATA QUALITY CHECKS
-- =========================================================

-- Check order date range
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM orders;


-- Check order status distribution
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status;


-- Check channel distribution
SELECT
    channel,
    COUNT(*) AS total_orders
FROM orders
GROUP BY channel
ORDER BY total_orders DESC;


-- Check NULL values in orders
SELECT
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS missing_order_date,
    SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS missing_order_status,
    SUM(CASE WHEN channel IS NULL THEN 1 ELSE 0 END) AS missing_channel,
    SUM(CASE WHEN total_amount IS NULL THEN 1 ELSE 0 END) AS missing_total_amount
FROM orders;


-- Check NULL values in customers
SELECT
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN customer_name IS NULL THEN 1 ELSE 0 END) AS missing_customer_name,
    SUM(CASE WHEN signup_date IS NULL THEN 1 ELSE 0 END) AS missing_signup_date,
    SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS missing_region
FROM customers;


-- =========================================================
-- 2. DUPLICATE ORDER ITEM CHECK
-- =========================================================

-- Identify duplicate order-item records
SELECT
    order_id,
    product_id,
    quantity,
    unit_price,
    COUNT(*) AS duplicate_count
FROM order_items
GROUP BY
    order_id,
    product_id,
    quantity,
    unit_price
HAVING COUNT(*) > 1;


-- Investigate one duplicate example
SELECT *
FROM order_items
WHERE order_id = 50149
  AND product_id = 1016;


-- Count duplicate rows that should be removed
SELECT COUNT(*) AS duplicate_rows_to_remove
FROM order_items AS oi1
WHERE EXISTS (
    SELECT 1
    FROM order_items AS oi2
    WHERE oi2.order_id = oi1.order_id
      AND oi2.product_id = oi1.product_id
      AND oi2.quantity = oi1.quantity
      AND oi2.unit_price = oi1.unit_price
      AND oi2.order_item_id < oi1.order_item_id
);


-- Remove duplicate rows while keeping the earliest order_item_id
DELETE FROM order_items
WHERE order_item_id IN (
    SELECT order_item_id
    FROM (
        SELECT
            order_item_id,
            ROW_NUMBER() OVER (
                PARTITION BY order_id, product_id, quantity, unit_price
                ORDER BY order_item_id
            ) AS rn
        FROM order_items
    ) AS duplicate_rows
    WHERE rn > 1
);


-- Verify final order-item row count
SELECT COUNT(*) AS total_order_items
FROM order_items;


-- Confirm no duplicates remain
SELECT
    order_id,
    product_id,
    quantity,
    unit_price,
    COUNT(*) AS duplicate_count
FROM order_items
GROUP BY
    order_id,
    product_id,
    quantity,
    unit_price
HAVING COUNT(*) > 1;


-- =========================================================
-- 3. BLANK CHANNEL CLEANING
-- =========================================================

-- Check blank channel values
SELECT
    channel,
    COUNT(*) AS total_orders
FROM orders
WHERE TRIM(channel) = ''
GROUP BY channel;


-- Replace blank channels with 'Unknown'
SET SQL_SAFE_UPDATES = 0;

UPDATE orders
SET channel = 'Unknown'
WHERE TRIM(channel) = '';

SET SQL_SAFE_UPDATES = 1;


-- Verify channel cleaning
SELECT
    channel,
    COUNT(*) AS total_orders
FROM orders
GROUP BY channel
ORDER BY total_orders DESC;


-- =========================================================
-- 4. BLANK REGION INVESTIGATION AND CLEANING
-- =========================================================

-- Count customers with blank region
SELECT
    region,
    COUNT(*) AS total_customers
FROM customers
WHERE TRIM(region) = ''
GROUP BY region;


-- Investigate business impact of customers with blank region
SELECT
    c.customer_id,
    c.customer_name,
    COALESCE(SUM(o.total_amount), 0) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
    AND o.order_status = 'completed'
WHERE TRIM(c.region) = ''
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_revenue DESC;


-- Replace blank regions with 'Unknown'
SET SQL_SAFE_UPDATES = 0;

UPDATE customers
SET region = 'Unknown'
WHERE TRIM(region) = '';

SET SQL_SAFE_UPDATES = 1;


-- Verify region cleaning
SELECT
    region,
    COUNT(*) AS total_customers
FROM customers
GROUP BY region
ORDER BY total_customers DESC;