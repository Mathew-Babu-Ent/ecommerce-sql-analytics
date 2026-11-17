USE ecommerce;

-- Q20 | Business question: What is delivered item sales by month with a cumulative running total?
-- Concepts: CTE, date functions, SUM window frame.
-- Logic: Aggregate delivered item sales to month first, then calculate a running sum
-- in chronological order. The running total spans the dataset; it does not reset per year.
-- Insight: Shows monthly sales and accumulated delivered sales over the observed period.
WITH monthly_sales AS (
    SELECT DATE_FORMAT(o.order_date, '%Y-%m-01') AS month_start,
           SUM(oi.quantity * oi.unit_price) AS item_sales
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m-01')
)
SELECT month_start, ROUND(item_sales, 2) AS delivered_item_sales,
       ROUND(SUM(item_sales) OVER (ORDER BY month_start
             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS running_item_sales
FROM monthly_sales
ORDER BY month_start;

-- Q21 | Business question: Which products rank highest by delivered sales within each category?
-- Concepts: CTE, RANK, PARTITION BY.
-- Logic: Aggregate product line sales, then rank products separately within each category.
-- Insight: Identifies leaders by category while preserving gaps after tied ranks.
WITH product_sales AS (
    SELECT p.product_id, p.product_name, p.category,
           SUM(oi.quantity) AS units_sold,
           SUM(oi.quantity * oi.unit_price) AS item_sales
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY p.product_id, p.product_name, p.category
), ranked_products AS (
    SELECT product_sales.*,
           RANK() OVER (PARTITION BY category ORDER BY item_sales DESC) AS category_rank
    FROM product_sales
)
SELECT product_id, product_name, category, units_sold,
       ROUND(item_sales, 2) AS delivered_item_sales, category_rank
FROM ranked_products
WHERE category_rank <= 3
ORDER BY category, category_rank, product_id;

-- Q22 | Business question: Which sellers lead by delivered item sales, and how do ties rank?
-- Concepts: CTE, DENSE_RANK, GROUP BY, window function.
-- Logic: Aggregate sales per seller first, then assign ranks without gaps between ties.
-- Insight: Compares seller performance with a tie-aware leaderboard.
WITH seller_sales AS (
    SELECT s.seller_id, s.seller_name,
           SUM(oi.quantity * oi.unit_price) AS item_sales
    FROM sellers s
    JOIN products p ON p.seller_id = s.seller_id
    JOIN order_items oi ON oi.product_id = p.product_id
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY s.seller_id, s.seller_name
)
SELECT seller_id, seller_name, ROUND(item_sales, 2) AS delivered_item_sales,
       DENSE_RANK() OVER (ORDER BY item_sales DESC) AS seller_dense_rank
FROM seller_sales
ORDER BY seller_dense_rank, seller_id;

-- Q23 | Business question: What is each customer's most recent order?
-- Concepts: CTE, ROW_NUMBER, PARTITION BY.
-- Logic: Number each customer's orders newest to oldest and keep row number one.
-- Insight: Supports customer service and recency-based retention analysis.
WITH customer_order_recency AS (
    SELECT o.customer_id, o.order_id, o.order_date, o.order_status,
           ROW_NUMBER() OVER (PARTITION BY o.customer_id
                              ORDER BY o.order_date DESC, o.order_id DESC) AS recency_number
    FROM orders o
)
SELECT customer_id, order_id, order_date, order_status
FROM customer_order_recency
WHERE recency_number = 1
ORDER BY order_date DESC, customer_id;

-- Q24 | Business question: Which customers' delivered item sales exceed the customer average?
-- Concepts: CTE, scalar subquery, AVG.
-- Logic: Build one sales total per customer (including zero-sales customers), then compare
-- each total with the average across all registered customers.
-- Insight: Identifies customers whose delivered item value is above the portfolio average.
WITH customer_sales AS (
    SELECT c.customer_id, c.first_name, c.last_name,
           COALESCE(SUM(CASE WHEN o.order_status = 'Delivered'
                             THEN oi.quantity * oi.unit_price ELSE 0 END), 0) AS item_sales
    FROM customers c
    LEFT JOIN orders o ON o.customer_id = c.customer_id
    LEFT JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT customer_id, first_name, last_name, ROUND(item_sales, 2) AS delivered_item_sales
FROM customer_sales
WHERE item_sales > (SELECT AVG(item_sales) FROM customer_sales)
ORDER BY item_sales DESC, customer_id;

-- Q25 | Business question: How did monthly delivered sales change versus the prior month?
-- Concepts: CTE, DATE_FORMAT, LAG, window function.
-- Logic: Aggregate by month, use LAG to bring in prior-month sales, then calculate
-- absolute change. First observed month has no prior-month comparison.
-- Insight: Highlights month-over-month movement in delivered merchandise sales.
WITH monthly_sales AS (
    SELECT DATE_FORMAT(o.order_date, '%Y-%m-01') AS month_start,
           SUM(oi.quantity * oi.unit_price) AS item_sales
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m-01')
), comparisons AS (
    SELECT month_start, item_sales,
           LAG(item_sales) OVER (ORDER BY month_start) AS prior_month_sales
    FROM monthly_sales
)
SELECT month_start, ROUND(item_sales, 2) AS delivered_item_sales,
       ROUND(prior_month_sales, 2) AS prior_month_sales,
       ROUND(item_sales - prior_month_sales, 2) AS month_over_month_change
FROM comparisons
ORDER BY month_start;

-- Q26 | Business question: What is the monthly delivered sales summary available to dashboards?
-- Concepts: VIEW, GROUP BY, date functions.
-- Logic: Create or replace a reusable view with one row per month, then query the view.
-- Insight: Provides a stable monthly metric for reporting and repeat analysis.
CREATE OR REPLACE VIEW vw_monthly_delivered_sales AS
SELECT DATE_FORMAT(o.order_date, '%Y-%m-01') AS month_start,
       COUNT(DISTINCT o.order_id) AS delivered_orders,
       SUM(oi.quantity) AS units_sold,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS delivered_item_sales
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m-01');

SELECT month_start, delivered_orders, units_sold, delivered_item_sales
FROM vw_monthly_delivered_sales
ORDER BY month_start;

-- Q27 | Business question: What are the top products in a chosen category?
-- Concepts: Stored procedure, input parameters, aggregation, ORDER BY, LIMIT.
-- Logic: A reusable procedure accepts a category and a safe result limit, aggregates
-- delivered line values, and returns the highest-sales products in that category.
-- Insight: Lets category managers run the same leaderboard for different categories.
DROP PROCEDURE IF EXISTS sp_top_products_by_category;
DELIMITER $$
CREATE PROCEDURE sp_top_products_by_category(IN p_category VARCHAR(60), IN p_limit INT)
BEGIN
    IF p_limit IS NULL OR p_limit < 1 OR p_limit > 50 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'p_limit must be between 1 and 50';
    END IF;

    SELECT p.product_id, p.product_name, p.category,
           SUM(oi.quantity) AS units_sold,
           ROUND(SUM(oi.quantity * oi.unit_price), 2) AS delivered_item_sales
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    JOIN orders o ON o.order_id = oi.order_id
    WHERE p.category = p_category
      AND o.order_status = 'Delivered'
    GROUP BY p.product_id, p.product_name, p.category
    ORDER BY delivered_item_sales DESC, p.product_id
    LIMIT p_limit;
END$$
DELIMITER ;

CALL sp_top_products_by_category('Electronics', 5);

-- Q28 | Business question: Do payment attempts equal their corresponding order item totals?
-- Concepts: CTE, joins at controlled grain, CASE.
-- Logic: Aggregate item rows to one value per order before joining one payment row;
-- CASE labels matching and mismatching records. This prevents item/payment fan-out.
-- Insight: Audits payment amount integrity; successful settlement is identified separately.
WITH item_totals AS (
    SELECT order_id, ROUND(SUM(quantity * unit_price), 2) AS order_value
    FROM order_items
    GROUP BY order_id
)
SELECT CASE WHEN it.order_value = p.payment_amount THEN 'Match' ELSE 'Mismatch' END AS amount_check,
       COUNT(*) AS order_count
FROM item_totals it
JOIN payments p ON p.order_id = it.order_id
GROUP BY amount_check
ORDER BY amount_check;

-- Q29 | Business question: How do customer cities rank by delivered item sales?
-- Concepts: CTE, RANK, GROUP BY.
-- Logic: Aggregate line sales by customer city, then rank cities by that total.
-- Insight: Prioritizes geographies for growth and fulfillment planning.
WITH city_sales AS (
    SELECT c.city, SUM(oi.quantity * oi.unit_price) AS item_sales
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.city
)
SELECT city, ROUND(item_sales, 2) AS delivered_item_sales,
       RANK() OVER (ORDER BY item_sales DESC) AS city_sales_rank
FROM city_sales
ORDER BY city_sales_rank, city;
