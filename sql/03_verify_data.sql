-- Basic row-count, coverage, and referential-integrity checks.
USE ecommerce;

SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'payments', COUNT(*) FROM payments;

SELECT MIN(order_date) AS first_order, MAX(order_date) AS last_order,
       COUNT(DISTINCT DATE_FORMAT(order_date, '%Y-%m')) AS calendar_months
FROM orders;

SELECT order_status, COUNT(*) AS order_count FROM orders GROUP BY order_status ORDER BY order_status;
SELECT payment_status, COUNT(*) AS payment_count FROM payments GROUP BY payment_status ORDER BY payment_status;
SELECT payment_method, COUNT(*) AS payment_count FROM payments GROUP BY payment_method ORDER BY payment_count DESC;

SELECT
    (SELECT COUNT(*) FROM orders o LEFT JOIN customers c ON c.customer_id = o.customer_id WHERE c.customer_id IS NULL) AS orphan_orders,
    (SELECT COUNT(*) FROM order_items oi LEFT JOIN orders o ON o.order_id = oi.order_id WHERE o.order_id IS NULL) AS orphan_order_items_orders,
    (SELECT COUNT(*) FROM order_items oi LEFT JOIN products p ON p.product_id = oi.product_id WHERE p.product_id IS NULL) AS orphan_order_items_products,
    (SELECT COUNT(*) FROM products p LEFT JOIN sellers s ON s.seller_id = p.seller_id WHERE s.seller_id IS NULL) AS orphan_products,
    (SELECT COUNT(*) FROM payments p LEFT JOIN orders o ON o.order_id = p.order_id WHERE o.order_id IS NULL) AS orphan_payments;

-- Compare sales and successful payment amounts at one row per order.
-- Aggregating order_items first avoids repeating a single payment for every item row.
WITH order_values AS (
    SELECT order_id, ROUND(SUM(quantity * unit_price), 2) AS order_value
    FROM order_items
    GROUP BY order_id
), settled_orders AS (
    SELECT o.order_id, ov.order_value, p.payment_amount
    FROM orders o
    JOIN order_values ov ON ov.order_id = o.order_id
    JOIN payments p ON p.order_id = o.order_id
    WHERE p.payment_status = 'Successful'
      AND o.order_status IN ('Delivered', 'Returned')
), all_order_payments AS (
    SELECT o.order_id, o.order_status, p.payment_status,
           ov.order_value, p.payment_amount
    FROM orders o
    JOIN order_values ov ON ov.order_id = o.order_id
    JOIN payments p ON p.order_id = o.order_id
)
SELECT (SELECT COUNT(*) FROM all_order_payments) AS orders_with_payment,
       (SELECT SUM(order_value <> payment_amount) FROM all_order_payments) AS all_payment_amount_mismatches,
       (SELECT ROUND(SUM(order_value), 2) FROM settled_orders) AS settled_item_sales_total,
       (SELECT ROUND(SUM(payment_amount), 2) FROM settled_orders) AS settled_payment_total;

-- A cancellation is represented as an unsuccessful payment attempt. Refunds
-- for returned orders are outside this sample's payment lifecycle scope.
SELECT COUNT(*) AS cancelled_orders_with_successful_payment
FROM orders o
JOIN payments p ON p.order_id = o.order_id
WHERE o.order_status = 'Cancelled' AND p.payment_status = 'Successful';

-- Expected status mapping: Pending -> Pending, Cancelled -> Failed,
-- Delivered/Returned -> Successful. A zero count confirms every pair matches.
SELECT COUNT(*) AS order_payment_status_mismatches
FROM orders o
JOIN payments p ON p.order_id = o.order_id
WHERE NOT (
       (o.order_status = 'Pending' AND p.payment_status = 'Pending')
    OR (o.order_status = 'Cancelled' AND p.payment_status = 'Failed')
    OR (o.order_status IN ('Delivered', 'Returned') AND p.payment_status = 'Successful')
);

SELECT o.order_status, p.payment_status, COUNT(*) AS order_payment_count
FROM orders o JOIN payments p ON p.order_id = o.order_id
GROUP BY o.order_status, p.payment_status
ORDER BY o.order_status, p.payment_status;

-- Smoke tests: customer orders, sales by category, and the highest-value items.
SELECT c.city, COUNT(DISTINCT o.order_id) AS orders_placed
FROM customers c JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.city ORDER BY orders_placed DESC LIMIT 5;

SELECT pr.category, SUM(oi.quantity) AS units_sold,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS item_sales
FROM order_items oi JOIN products pr ON pr.product_id = oi.product_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY pr.category ORDER BY item_sales DESC;

SELECT o.order_id, o.order_status, p.payment_status,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS order_value
FROM orders o JOIN payments p ON p.order_id = o.order_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.order_status, p.payment_status
ORDER BY order_value DESC LIMIT 5;
