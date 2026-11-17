USE ecommerce;

-- Q10 | Business question: How many units and how much delivered item sales did each category generate?
-- Concepts: INNER JOIN, COUNT, SUM, GROUP BY, ORDER BY.
-- Logic: Join order lines to products and orders; aggregate only Delivered items.
-- Insight: Compares category volume and merchandise value without joining payments.
SELECT p.category,
       COUNT(DISTINCT o.order_id) AS delivered_orders,
       SUM(oi.quantity) AS units_sold,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS delivered_item_sales
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category
ORDER BY delivered_item_sales DESC;

-- Q11 | Business question: How did delivered item sales change by calendar month?
-- Concepts: INNER JOIN, SUM, GROUP BY, DATE_FORMAT.
-- Logic: Group purchase-time line values by year-month and keep delivered orders.
-- Insight: Reveals seasonality and growth/decline in delivered merchandise sales.
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
       COUNT(DISTINCT o.order_id) AS delivered_orders,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS delivered_item_sales
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY order_month;

-- Q12 | Business question: Which categories generated at least 100 delivered units?
-- Concepts: INNER JOIN, SUM, GROUP BY, HAVING.
-- Logic: Aggregate units by category, then HAVING filters grouped results.
-- Insight: Focuses category review on lines with material delivered volume.
SELECT p.category, SUM(oi.quantity) AS delivered_units
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category
HAVING SUM(oi.quantity) >= 100
ORDER BY delivered_units DESC;

-- Q13 | Business question: Which five customers generated the most delivered item sales?
-- Concepts: INNER JOIN, COUNT, SUM, GROUP BY, ORDER BY, LIMIT.
-- Logic: Aggregate delivered line values by customer; payments are intentionally not joined.
-- Insight: Identifies the highest-value customers by delivered merchandise value.
SELECT c.customer_id, c.first_name, c.last_name,
       COUNT(DISTINCT o.order_id) AS delivered_orders,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS delivered_item_sales
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY delivered_item_sales DESC, c.customer_id
LIMIT 5;

-- Q14 | Business question: Which customers have placed at least two delivered orders?
-- Concepts: COUNT, GROUP BY, HAVING, INNER JOIN.
-- Logic: Count Delivered orders per customer and keep customers with repeat activity.
-- Insight: Identifies repeat buyers for retention analysis.
SELECT c.customer_id, c.first_name, c.last_name,
       COUNT(*) AS delivered_order_count
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(*) >= 2
ORDER BY delivered_order_count DESC, c.customer_id;

-- Q15 | Business question: How do sellers compare on delivered sales and order reach?
-- Concepts: INNER JOIN, COUNT DISTINCT, SUM, GROUP BY.
-- Logic: Each product belongs to one seller; aggregate sold lines by that seller.
-- Insight: Compares seller merchandise sales, units, and distinct orders.
SELECT s.seller_id, s.seller_name,
       COUNT(DISTINCT o.order_id) AS delivered_orders,
       SUM(oi.quantity) AS units_sold,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS delivered_item_sales
FROM sellers s
JOIN products p ON p.seller_id = s.seller_id
JOIN order_items oi ON oi.product_id = p.product_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY s.seller_id, s.seller_name
ORDER BY delivered_item_sales DESC;

-- Q16 | Business question: Which customer cities contribute the most delivered item sales?
-- Concepts: INNER JOIN, SUM, COUNT DISTINCT, GROUP BY.
-- Logic: Attribute delivered order lines to the ordering customer's city.
-- Insight: Supports geographic marketing and fulfillment planning.
SELECT c.city, COUNT(DISTINCT o.order_id) AS delivered_orders,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS delivered_item_sales
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY c.city
ORDER BY delivered_item_sales DESC;

-- Q17 | Business question: What is the average successful payment amount by method?
-- Concepts: AVG, COUNT, GROUP BY, CASE.
-- Logic: Payments are one row per order, so aggregate payment_amount directly;
-- CASE labels cash-on-delivery separately as collected-success records in this dataset.
-- Insight: Compares average settled ticket size by tender method. Returned charges are included;
-- refunds are not modeled, so this is successful payment value before refunds.
SELECT payment_method,
       CASE WHEN payment_method = 'Cash on Delivery' THEN 'COD' ELSE 'Prepaid' END AS tender_group,
       COUNT(*) AS successful_payment_count,
       ROUND(AVG(payment_amount), 2) AS average_successful_payment
FROM payments
WHERE payment_status = 'Successful'
GROUP BY payment_method, tender_group
ORDER BY average_successful_payment DESC;

-- Q18 | Business question: How many payment attempts occurred for each method and outcome?
-- Concepts: COUNT, GROUP BY, CASE.
-- Logic: Count payment rows and label each as successful, pending, or failed.
-- Insight: Shows method-level usage and payment outcome mix without item joins.
SELECT payment_method,
       COUNT(*) AS attempts,
       SUM(CASE WHEN payment_status = 'Successful' THEN 1 ELSE 0 END) AS successful_count,
       SUM(CASE WHEN payment_status = 'Pending' THEN 1 ELSE 0 END) AS pending_count,
       SUM(CASE WHEN payment_status = 'Failed' THEN 1 ELSE 0 END) AS failed_count
FROM payments
GROUP BY payment_method
ORDER BY attempts DESC, payment_method;

-- Q19 | Business question: What are average, minimum, and maximum item totals by order status?
-- Concepts: subquery, AVG, MIN, MAX, GROUP BY.
-- Logic: First sum lines once per order; then summarize those order values by status.
-- Insight: Compares typical and extreme basket values by lifecycle outcome.
SELECT o.order_status, COUNT(*) AS order_count,
       ROUND(AVG(ov.order_value), 2) AS average_order_value,
       ROUND(MIN(ov.order_value), 2) AS minimum_order_value,
       ROUND(MAX(ov.order_value), 2) AS maximum_order_value
FROM orders o
JOIN (
    SELECT order_id, SUM(quantity * unit_price) AS order_value
    FROM order_items
    GROUP BY order_id
) ov ON ov.order_id = o.order_id
GROUP BY o.order_status
ORDER BY o.order_status;
