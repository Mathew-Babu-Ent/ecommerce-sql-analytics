USE ecommerce;

-- Q01 | Business question: Which pending orders have the oldest order dates?
-- Concepts: SELECT, WHERE, ORDER BY, LIMIT.
-- Logic: Keep pending orders and sort the oldest order dates first. The schema has
-- no status-change timestamp, so order age is only a triage proxy for time pending.
-- Insight: Gives operations a short queue of older pending orders to investigate.
SELECT order_id, customer_id, order_date, order_status
FROM orders
WHERE order_status = 'Pending'
ORDER BY order_date ASC, order_id ASC
LIMIT 10;

-- Q02 | Business question: Which product categories are in the catalog?
-- Concepts: DISTINCT, ORDER BY.
-- Logic: DISTINCT removes repeated category values so each category appears once.
-- Insight: Shows the breadth of the current product assortment.
SELECT DISTINCT category
FROM products
ORDER BY category;

-- Q03 | Business question: Which ten catalog products have the highest current list prices?
-- Concepts: SELECT, ORDER BY, LIMIT.
-- Logic: Sort current product prices descending and keep the first ten.
-- Insight: Helps merchandising review premium-priced products. This is not historical sales.
SELECT product_id, product_name, category, list_price
FROM products
ORDER BY list_price DESC, product_id
LIMIT 10;

-- Q04 | Business question: Which products are running low on stock?
-- Concepts: WHERE, ORDER BY, LIMIT.
-- Logic: Filter to stock at or below 25 units and show the lowest stock first.
-- Insight: Highlights products that may need replenishment soon.
SELECT product_id, product_name, category, stock_quantity
FROM products
WHERE stock_quantity <= 25
ORDER BY stock_quantity, product_id
LIMIT 15;

-- Q05 | Business question: Which customers in Mumbai signed up most recently?
-- Concepts: WHERE, ORDER BY, LIMIT.
-- Logic: Filter customers by city and sort newest registration dates first.
-- Insight: Helps local marketing review recent customer acquisition.
SELECT customer_id, first_name, last_name, signup_date
FROM customers
WHERE city = 'Mumbai'
ORDER BY signup_date DESC, customer_id DESC
LIMIT 10;

-- Q06 | Business question: Which orders were placed in January 2026?
-- Concepts: WHERE, date range filtering, ORDER BY.
-- Logic: Use a half-open date range so every time on Jan 31 is included.
-- Insight: Provides order-level records for a monthly operations review.
SELECT order_id, customer_id, order_date, order_status
FROM orders
WHERE order_date >= '2026-01-01'
  AND order_date <  '2026-02-01'
ORDER BY order_date, order_id;

-- Q07 | Business question: What payment methods appear in payment records?
-- Concepts: DISTINCT, ORDER BY.
-- Logic: Return each method once, regardless of how often it was used.
-- Insight: Shows the available payment-method mix before measuring its volume.
SELECT DISTINCT payment_method
FROM payments
ORDER BY payment_method;

-- Q08 | Business question: Which orders have failed payment attempts?
-- Concepts: WHERE, ORDER BY, LIMIT.
-- Logic: Filter payment records to Failed and show the most recent attempts.
-- Insight: Gives finance or support a review queue for unsuccessful transactions.
SELECT payment_id, order_id, payment_method, payment_amount, payment_date
FROM payments
WHERE payment_status = 'Failed'
ORDER BY payment_date DESC, payment_id DESC
LIMIT 15;

-- Q09 | Business question: Which products were added to the catalog most recently?
-- Concepts: WHERE, ORDER BY, LIMIT.
-- Logic: Sort product creation dates newest first.
-- Insight: Helps merchandising check the newest catalog additions.
SELECT product_id, product_name, category, created_at
FROM products
WHERE created_at IS NOT NULL
ORDER BY created_at DESC, product_id DESC
LIMIT 10;
