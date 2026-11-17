-- Reproducible sample-data generator for MySQL 8.0+.
-- Run after 01_schema.sql. Re-running replaces the sample rows and recreates
-- the same primary keys and values for the same seed.
USE ecommerce;

DROP PROCEDURE IF EXISTS generate_sample_data;
DELIMITER $$
CREATE PROCEDURE generate_sample_data(IN p_seed INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE j INT DEFAULT 1;
    DECLARE v_city VARCHAR(80);
    DECLARE v_state VARCHAR(80);
    DECLARE v_category VARCHAR(60);
    DECLARE v_product_name VARCHAR(160);
    DECLARE v_list_price DECIMAL(10,2);
    DECLARE v_order_status VARCHAR(20);
    DECLARE v_payment_status VARCHAR(20);
    DECLARE v_payment_method VARCHAR(30);
    DECLARE v_order_date DATETIME;
    DECLARE v_quantity SMALLINT UNSIGNED;
    DECLARE v_unit_price DECIMAL(10,2);
    DECLARE v_order_total DECIMAL(12,2);

    IF p_seed IS NULL OR p_seed < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Seed must be a non-negative integer';
    END IF;

    SET @saved_fk_checks = @@FOREIGN_KEY_CHECKS;
    SET FOREIGN_KEY_CHECKS = 1;
    START TRANSACTION;

    DELETE FROM payments;
    DELETE FROM order_items;
    DELETE FROM orders;
    DELETE FROM products;
    DELETE FROM sellers;
    DELETE FROM customers;

    -- 500 customers, with unique reserved example.com email addresses and
    -- unmistakably non-routable sample phone labels. The fixed vocabularies
    -- keep names varied without exposing real contact details.
    SET i = 1;
    WHILE i <= 500 DO
        SET v_city = CASE MOD(i + p_seed, 12)
            WHEN 0 THEN 'Mumbai' WHEN 1 THEN 'Delhi' WHEN 2 THEN 'Bengaluru'
            WHEN 3 THEN 'Hyderabad' WHEN 4 THEN 'Chennai' WHEN 5 THEN 'Kolkata'
            WHEN 6 THEN 'Pune' WHEN 7 THEN 'Ahmedabad' WHEN 8 THEN 'Jaipur'
            WHEN 9 THEN 'Lucknow' WHEN 10 THEN 'Kochi' ELSE 'Indore' END;
        SET v_state = CASE v_city
            WHEN 'Mumbai' THEN 'Maharashtra' WHEN 'Pune' THEN 'Maharashtra'
            WHEN 'Delhi' THEN 'Delhi' WHEN 'Bengaluru' THEN 'Karnataka'
            WHEN 'Hyderabad' THEN 'Telangana' WHEN 'Chennai' THEN 'Tamil Nadu'
            WHEN 'Kolkata' THEN 'West Bengal' WHEN 'Ahmedabad' THEN 'Gujarat'
            WHEN 'Jaipur' THEN 'Rajasthan' WHEN 'Lucknow' THEN 'Uttar Pradesh'
            WHEN 'Kochi' THEN 'Kerala' ELSE 'Madhya Pradesh' END;
        INSERT INTO customers (customer_id, first_name, last_name, email, phone, city, state, signup_date)
        VALUES (
            i,
            ELT(MOD(i * 7 + p_seed, 20) + 1, 'Aarav','Vivaan','Aditya','Vihaan','Arjun','Reyansh','Aanya','Diya','Anaya','Isha','Mira','Saanvi','Rohan','Kabir','Ira','Meera','Neel','Tara','Dev','Nisha'),
            ELT(MOD(i * 11 + p_seed, 20) + 1, 'Sharma','Patel','Reddy','Nair','Iyer','Mehta','Kapoor','Das','Rao','Singh','Joshi','Khan','Menon','Gupta','Pillai','Verma','Bose','Kulkarni','Mishra','Bhat'),
            CONCAT('customer', LPAD(i, 4, '0'), '@example.com'),
            CONCAT('SAMPLE-PHONE-', LPAD(i, 4, '0')),
            v_city, v_state,
            DATE_ADD('2023-01-01', INTERVAL MOD(i * 37 + p_seed, 900) DAY)
        );
        SET i = i + 1;
    END WHILE;

    -- 35 sellers across the same realistic Indian business locations.
    SET i = 1;
    WHILE i <= 35 DO
        SET v_city = CASE MOD(i + p_seed, 12)
            WHEN 0 THEN 'Mumbai' WHEN 1 THEN 'Delhi' WHEN 2 THEN 'Bengaluru'
            WHEN 3 THEN 'Hyderabad' WHEN 4 THEN 'Chennai' WHEN 5 THEN 'Kolkata'
            WHEN 6 THEN 'Pune' WHEN 7 THEN 'Ahmedabad' WHEN 8 THEN 'Jaipur'
            WHEN 9 THEN 'Lucknow' WHEN 10 THEN 'Kochi' ELSE 'Indore' END;
        SET v_state = CASE v_city
            WHEN 'Mumbai' THEN 'Maharashtra' WHEN 'Pune' THEN 'Maharashtra'
            WHEN 'Delhi' THEN 'Delhi' WHEN 'Bengaluru' THEN 'Karnataka'
            WHEN 'Hyderabad' THEN 'Telangana' WHEN 'Chennai' THEN 'Tamil Nadu'
            WHEN 'Kolkata' THEN 'West Bengal' WHEN 'Ahmedabad' THEN 'Gujarat'
            WHEN 'Jaipur' THEN 'Rajasthan' WHEN 'Lucknow' THEN 'Uttar Pradesh'
            WHEN 'Kochi' THEN 'Kerala' ELSE 'Madhya Pradesh' END;
        INSERT INTO sellers (seller_id, seller_name, email, city, state, signup_date)
        VALUES (i, CONCAT(ELT(MOD(i + p_seed, 12) + 1, 'Blue Peak','Maple & Main','Cedar House','Bright Basket','Urban Loom','Silver Fern','Golden Hour','Northstar','Willow Market','Cobalt Works','Saffron Lane','Harbor Goods'), ' Commerce'),
                CONCAT('seller', LPAD(i, 3, '0'), '@example.com'), v_city, v_state,
                DATE_ADD('2022-01-01', INTERVAL MOD(i * 53 + p_seed, 1200) DAY));
        SET i = i + 1;
    END WHILE;

    -- 120 products. Prices vary by category and model; seller ownership is explicit.
    SET i = 1;
    WHILE i <= 120 DO
        SET v_category = ELT(MOD(i - 1, 8) + 1, 'Electronics','Home & Kitchen','Clothing','Books','Beauty','Sports','Toys','Grocery');
        SET v_product_name = CONCAT(
            ELT(MOD(i - 1, 8) + 1, 'Wireless Headphones','Ceramic Cookware Set','Everyday Cotton Shirt','Contemporary Fiction','Hydrating Face Serum','Trail Running Bottle','Wooden Building Blocks','Organic Tea Selection'),
            ' Model ', LPAD(i, 3, '0'));
        SET v_list_price = CASE v_category
            WHEN 'Electronics' THEN 1499 + MOD(i * 97 + p_seed, 18000)
            WHEN 'Home & Kitchen' THEN 399 + MOD(i * 61 + p_seed, 8000)
            WHEN 'Clothing' THEN 499 + MOD(i * 43 + p_seed, 3500)
            WHEN 'Books' THEN 199 + MOD(i * 17 + p_seed, 900)
            WHEN 'Beauty' THEN 299 + MOD(i * 29 + p_seed, 2500)
            WHEN 'Sports' THEN 349 + MOD(i * 37 + p_seed, 5000)
            WHEN 'Toys' THEN 249 + MOD(i * 31 + p_seed, 4000)
            ELSE 149 + MOD(i * 13 + p_seed, 1200) END;
        INSERT INTO products (product_id, seller_id, product_name, category, list_price, stock_quantity, created_at)
        VALUES (i, MOD(i * 17 + p_seed, 35) + 1, v_product_name, v_category, v_list_price,
                MOD(i * 19 + p_seed, 250), DATE_ADD('2023-01-01', INTERVAL MOD(i * 23 + p_seed, 1000) DAY));
        SET i = i + 1;
    END WHILE;

    -- 1,500 orders spanning 18 months. Order/item/payment status patterns are
    -- deterministic and intentionally include delivered, pending, cancelled,
    -- returned plus successful, pending, failed payment scenarios.
    SET i = 1;
    WHILE i <= 1500 DO
        SET v_order_status = CASE MOD(i + p_seed, 20)
            WHEN 0 THEN 'Pending' WHEN 1 THEN 'Pending'
            WHEN 2 THEN 'Cancelled' WHEN 3 THEN 'Cancelled'
            WHEN 4 THEN 'Returned' ELSE 'Delivered' END;
        SET v_order_date = TIMESTAMP(DATE_ADD('2025-01-01', INTERVAL MOD(i * 19 + p_seed, 547) DAY), MAKETIME(MOD(i * 7 + 8, 24), MOD(i * 13, 60), 0));
        INSERT INTO orders (order_id, customer_id, order_date, order_status)
        VALUES (i, MOD(i * 67 + p_seed, 500) + 1, v_order_date, v_order_status);

        SET v_order_total = 0;
        SET j = 1;
        WHILE j <= 3 DO
            SET v_quantity = MOD(i * 11 + j * 7 + p_seed, 4) + 1;
            SET v_unit_price = ROUND((SELECT list_price FROM products WHERE product_id = MOD(i * 13 + j * 29 + p_seed, 120) + 1)
                                     * (100 - MOD(i * 3 + j * 5 + p_seed, 16)) / 100, 2);
            INSERT INTO order_items (order_id, product_id, quantity, unit_price)
            VALUES (i, MOD(i * 13 + j * 29 + p_seed, 120) + 1, v_quantity, v_unit_price);
            SET v_order_total = v_order_total + v_quantity * v_unit_price;
            SET j = j + 1;
        END WHILE;

        -- Match the lifecycle rule exactly: pending orders have pending
        -- attempts, cancellations fail before settlement, and delivered or
        -- returned orders have successful original payments. Refunds for
        -- returns are outside this one-payment-per-order sample model.
        SET v_payment_status = CASE
            WHEN v_order_status = 'Pending' THEN 'Pending'
            WHEN v_order_status = 'Cancelled' THEN 'Failed'
            ELSE 'Successful' END;
        SET v_payment_method = ELT(MOD(i * 5 + p_seed, 6) + 1,
            'Credit Card','Debit Card','UPI','Net Banking','Wallet','Cash on Delivery');
        INSERT INTO payments (order_id, payment_method, payment_amount, payment_date, payment_status)
        VALUES (i, v_payment_method, v_order_total,
                CASE WHEN v_payment_status = 'Pending' THEN NULL
                     ELSE DATE_ADD(v_order_date, INTERVAL MOD(i * 3 + p_seed, 48) HOUR) END,
                v_payment_status);
        SET i = i + 1;
    END WHILE;

    COMMIT;
    SET FOREIGN_KEY_CHECKS = @saved_fk_checks;
    SELECT p_seed AS seed_used,
           (SELECT COUNT(*) FROM customers) AS customers,
           (SELECT COUNT(*) FROM sellers) AS sellers,
           (SELECT COUNT(*) FROM products) AS products,
           (SELECT COUNT(*) FROM orders) AS orders,
           (SELECT COUNT(*) FROM order_items) AS order_items,
           (SELECT COUNT(*) FROM payments) AS payments;
END$$
DELIMITER ;

-- Change this integer to create a different repeatable arrangement.
-- Re-running this call clears and replaces rows in the six sample tables.
CALL generate_sample_data(20261117);
