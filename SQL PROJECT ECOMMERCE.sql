-- 1.DATABASE SETUP   

USE ecommercedb;

-- 2.Preview first 5

SELECT*FROM customers;
SELECT*FROM order_items;
SELECT*FROM orders;
SELECT*FROM products;
SELECT*FROM returns;

-- 3.Show top 5 

SELECT*FROM customers LIMIT 5;
SELECT*FROM order_items LIMIT 5;
SELECT*FROM orders LIMIT 5;
SELECT*FROM products LIMIT 5;
SELECT*FROM returns LIMIT 5;

-- 4.DATA PREVIEW & INITIAL EXPLORATION

--   data count
SELECT 'customers' AS table_name, COUNT(*) AS myrows FROM customers UNION ALL
SELECT 'orders', COUNT(*) FROM orders UNION ALL
SELECT 'order_items',COUNT(*) FROM order_items UNION ALL
SELECT 'products',COUNT(*) FROM products UNION ALL
SELECT 'returms',COUNT(*) FROM returns;


-- counts NULLs in customers
SELECT
SUM(customer_id IS NULL) AS nulls_customer_id,
SUM(name IS NULL) AS nulls_name,
SUM(email IS NULL) AS nulls_email,
SUM(signup_date IS NULL) AS  nulls_signup_date,
SUM(region IS NULL) AS mulls_region
FROM customers;

-- count NULLs in orders
SELECT
SUM(order_id IS NULL) AS nulls_order_id,
SUM(customer_id IS NULL) AS nulls_customer_id,
SUM(order_date IS NULL) AS nulls_order_date,
SUM(total_amount IS NULL) AS  nulls_total_amount
FROM orders;

-- count NULLs in order_items
SELECT
SUM( order_item_id IS NULL) AS nulls_order_item_id,
SUM( order_id IS NULL) AS nulls_order_id,
SUM(product_id IS NULL) AS nulls_product_id,
SUM(quantity IS NULL) AS  nulls_quantity,
SUM(item_price IS NULL) AS nulls_item_price
FROM order_items;


-- count NULLs in products
SELECT
SUM( product_id IS NULL) AS nulls_product_id,
SUM( name IS NULL) AS nulls_name,
SUM(category IS NULL) AS nulls_category,
SUM(price IS NULL) AS  nulls_price
FROM products;


-- count NULLs in returns
SELECT
SUM( return_id IS NULL) AS nulls_return_id,
SUM(order_id IS NULL) AS nulls_order_id,
SUM(return_date IS NULL) AS nulls_return_date,
SUM(reason IS NULL) AS  nulls_reason
FROM returns;

-- percen NULLs by column in customers
SELECT 
100*SUM( name IS NULL)/COUNT(*)AS pct_nulls_name,
100*SUM( email IS NULL)/COUNT(*) AS pct_nulls_email,
100*SUM(signup_date IS NULL)/COUNT(*) AS pct_nulls_signup_date,
100*SUM(region IS NULL)/COUNT(*) AS  pct_nulls_region
FROM customers;

-- 5.BASIC STATISTICS & SUMMARY METRICS

-- Basic statistics for order amount
SELECT
MIN(total_amount) AS min_amt,
MAX(total_amount) AS max_amt,
AVG(total_amount) AS avg_amt,
SUM(total_amount) AS sum_amt
FROM orders;


-- basic statistics for order item prices and quantitis
SELECT
MIN(item_price) AS min_price,
MAX(item_price) AS max_price,
AVG(item_price) AS avg_price,
MIN(quantity) AS min_qty,
MAX(quantity) AS max_qty,
AVG(quantity) AS avg_qty
FROM order_items;

-- 6.DUPLICATE DATA HANDLING

-- Find customers with duplicate emails
SELECT email,COUNT(*) AS dup_count FROM customers
GROUP BY email HAVING COUNT(*) >1;

-- Find duplicate orders by customrs and date
SELECT customer_id,order_date,COUNT(*) AS dup_count FROM orders
GROUP BY customer_id,order_date HAVING COUNT(*) >1;

-- Find duplicate order_item for sdame products in same order
SELECT order_id,product_id,COUNT(*) AS dup_count FROM order_items
GROUP BY order_id,product_id HAVING COUNT(*) >1;

-- Disable safe mode for deletion operations
SET SQL_SAFE_UPDATES=0;


-- Delete duplicate customers by email (keep earlist signup)
WITH ranked AS(
SELECT*,ROW_NUMBER() OVER (PARTITION BY email ORDER BY signup_date) AS rn FROM customers)
DELETE FROM customers
WHERE customer_id IN(SELECT customer_id FROM ranked WHERE rn > 1); 

--   dalete duplicates order_items by order_products combination
WITH ranked AS(
SELECT order_item_id,ROW_NUMBER() OVER (PARTITION BY order_id,product_id ORDER BY order_item_id) AS rn FROM order_items)
DELETE FROM order_items
WHERE order_item_id IN(SELECT order_item_id FROM ranked WHERE rn > 1); 

-- 7.DATA VALIDATION & CLEANING PATTERNS

-- Find blank or invalid email addresses
SELECT * 
FROM customers
WHERE email IS NULL
OR TRIM(email) = ''
OR email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$';

-- Find product with missing names
SELECT*FROM products WHERE name IS NULL OR TRIM(name)='';

-- Replace missing region with 'unknow'
SELECT customer_id,name,email,signup_date,COALESCE(region,'Unknown') AS region_imputed FROM customers;

-- Drop rows with NULLs total_amount
SELECT*FROM orders WHERE total_amount IS NOT NULL; 

-- orders referencing non-existent customers
SELECT o.*FROM orders o LEFT JOIN customers c ON c.customer_id=o.customer_id WHERE c.customer_id IS NULL; 


--  Oeder items referencing missing products
SELECT oi.* FROM order_items oi LEFT JOIN products p ON p.product_id=oi.product_id 
WHERE p.product_id IS NULL;


--  Return referencing missing  orders
SELECT r.* FROM returns r LEFT JOIN orders o ON o.order_id=r.order_id  WHERE o.order_id IS NULL;

-- 8.SALES & REVENUE ANALYSIS

-- Revenue by product category
SELECT p.category, SUM(oi.quantity*oi.item_price) AS revenue FROM order_items oi JOIN products p ON p.product_id=oi.product_id GROUP BY p.category ORDER BY revenue DESC;   


-- Top 5 products by revenue
 SELECT p.product_id,p.name, SUM(oi.quantity*oi.item_price) AS revenue
 FROM order_items oi JOIN products p ON p.product_id=oi.product_id GROUP BY p.product_id,p.name ORDER BY revenue DESC LIMIT 5;   

-- orders per customer
SELECT c.customer_id,c.name,COUNT(o.order_id) AS order_count FROM customers c 
LEFT JOIN orders o ON o.customer_id=c.customer_id GROUP BY c.customer_id,c.name ORDER BY order_count DESC; 

-- Average order value (AOV)
SELECT AVG(total_amount) AS avg_order_value FROM orders;

--  Customer-Level total revenue
SELECT c.customer_id,c.name,SUM(oi.quantity*oi.item_price) AS total_revenue FROM customers c
JOIN orders o ON o.customer_id=c.customer_id
JOIN order_items oi ON oi.order_id=o.order_id
GROUP BY c.customer_id,c.name
ORDER BY total_revenue DESC;  

-- 9.TIME-BASED ANALYSIS

-- monthly revenue trend
SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS month,
SUM(oi.quantity*oi.item_price) AS revenue FROM orders o
JOIN order_items oi ON oi.order_id=o.order_id
GROUP BY month ORDER BY month; 

-- Daily order counts
SELECT DATE(order_date) AS order_day,COUNT(*) AS orders FROM orders
GROUP BY order_day
ORDER BY order_day;

-- 10.product & category analysis 

-- category mix by month
SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS month,p.category,
SUM(oi.quantity) AS units_sold FROM orders o 
JOIN order_items oi ON oi.order_id=o.order_id
JOIN products p ON p.product_id=oi.product_id
GROUP BY month,p.category
ORDER BY month,units_sold DESC;

-- first order date per customers
SELECT customer_id,MIN(order_date) AS first_order_date FROM orders GROUP BY customer_id;

-- 11.CUSTOMER BEHAVIOUR & COHORTS

-- chort:customers by signup month
SELECT DATE_FORMAT(signup_date,'%Y-%M') AS signup_month, COUNT(*) AS new_customers FROM customers
GROUP BY signup_month
ORDER BY signup_month;   

--  Orders placed within 30 days of signup(early activatiom)
SELECT c.customer_id,COUNT(o.order_id) AS orders_in_30d FROM customers c
LEFT JOIN orders o ON o.customer_id=c.customer_id AND o.order_date<= DATE_ADD(c.signup_date, INTERVAL 30 DAY) GROUP BY c.customer_id
ORDER BY orders_in_30d DESC;

-- 12. WINDOW FUCTIONS & ANALYTICS

-- Rank customeers by total revenue
SELECT customer_id,name,total_revenue,
DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS rank_position FROM(
SELECT c.customer_id,c.name,SUM(oi.quantity*oi.item_price) AS total_revenue FROM customers c
JOIN orders o ON o.customer_id=c.customer_id 
JOIN order_items oi ON oi.order_id=o.order_id
GROUP BY c.customer_id,c.name) AS t; 


-- runnin total revenue by day
WITH daily AS(
SELECT DATE(o.order_date) AS order_day,SUM(oi.quantity*oi.item_price) AS daily_revenue FROM orders o
JOIN order_items oi ON oi.order_id=o.order_id  GROUP BY order_day)
SELECT order_day,daily_revenue,
SUM(daily_revenue) OVER (ORDER BY order_day) AS running_revenue FROM daily;   


-- Detect order outliers using Z-score
WITH stats AS(
SELECT AVG(total_amount) AS mean_amt,STDDEV(total_amount) AS sd_amt FROM orders)
SELECT o.order_id,o.total_amount,
(o.total_amount-s.mean_amt)/s.sd_amt AS z_score FROM orders o CROSS JOIN stats s ORDER BY z_score  DESC;

-- 13. RETURNS & REFUND ANALYSIS

-- Return rate (% of total orders)
SELECT 100*COUNT(DISTINCT r.order_id)/COUNT(DISTINCT o.order_id)AS return_rate_pct FROM orders o 
LEFT JOIN returns r ON r.order_id = o.order_id; 

-- Return reason
SELECT reason,COUNT(*) AS reason_count FROM returns GROUP BY reason ORDER BY reason_count DESC;

-- Rrevenue lost to returns (assuming full refund)
SELECT SUM(o.total_amount) AS refund_value FROM orders o 
JOIN returns r ON r.order_id = o.order_id;

--  14. GEOGRAPHICAL INSIGHTS

-- Customers by region
SELECT region,COUNT(*) AS customer_count FROM customers GROUP BY region ORDER BY customer_count DESC;

-- Revenue by region
SELECT c.region,SUM(oi.quantity*oi.item_price) AS regional_revenue FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items  oi ON oi.order_id=o.order_id
GROUP BY c.region
ORDER BY regional_revenue DESC;  


-- 15. INTEGRITY CHECKS & FINAL VALIDATION

-- Compaire order header totals vs items totals
SELECT o.order_id,
o.total_amount AS header_total,
SUM(oi.quantity*oi.item_price) AS items_total,
o.total_amount - SUM(oi.quantity*oi.item_price) AS diffrence FROm orders o 
LEFT JOIN order_items  oi ON oi.order_id=o.order_id
GROUP BY o.order_id,o.total_amount
ORDER BY ABS(o.total_amount - SUM(oi.quantity*oi.item_price)) DESC;  