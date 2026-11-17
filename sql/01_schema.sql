-- E-Commerce Sales & Customer Analytics
-- MySQL 8.0+ schema. Run this file once before loading the seed data.
CREATE DATABASE IF NOT EXISTS ecommerce
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE ecommerce;

CREATE TABLE customers (
    customer_id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
    first_name       VARCHAR(60) NOT NULL,
    last_name        VARCHAR(60) NOT NULL,
    email            VARCHAR(254) NOT NULL,
    phone            VARCHAR(25) NOT NULL,
    city             VARCHAR(80) NOT NULL,
    state            VARCHAR(80) NOT NULL,
    signup_date      DATE NOT NULL,
    PRIMARY KEY (customer_id),
    UNIQUE KEY uq_customers_email (email),
    UNIQUE KEY uq_customers_phone (phone),
    KEY idx_customers_city (city),
    KEY idx_customers_signup_date (signup_date),
    CONSTRAINT chk_customers_email CHECK (email LIKE '%_@_%._%')
) ENGINE=InnoDB;

CREATE TABLE sellers (
    seller_id        INT UNSIGNED NOT NULL AUTO_INCREMENT,
    seller_name      VARCHAR(120) NOT NULL,
    email            VARCHAR(254) NOT NULL,
    city             VARCHAR(80) NOT NULL,
    state            VARCHAR(80) NOT NULL,
    signup_date      DATE NOT NULL,
    PRIMARY KEY (seller_id),
    UNIQUE KEY uq_sellers_email (email),
    KEY idx_sellers_city (city),
    KEY idx_sellers_signup_date (signup_date),
    CONSTRAINT chk_sellers_email CHECK (email LIKE '%_@_%._%')
) ENGINE=InnoDB;

CREATE TABLE products (
    product_id       INT UNSIGNED NOT NULL AUTO_INCREMENT,
    seller_id        INT UNSIGNED NOT NULL,
    product_name     VARCHAR(160) NOT NULL,
    category         VARCHAR(60) NOT NULL,
    list_price       DECIMAL(10,2) NOT NULL,
    stock_quantity   INT UNSIGNED NOT NULL DEFAULT 0,
    created_at       DATE NOT NULL,
    PRIMARY KEY (product_id),
    KEY idx_products_seller (seller_id),
    KEY idx_products_category (category),
    CONSTRAINT fk_products_seller FOREIGN KEY (seller_id)
        REFERENCES sellers (seller_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_products_price CHECK (list_price > 0),
    CONSTRAINT chk_products_category CHECK (category IN
        ('Electronics', 'Home & Kitchen', 'Clothing', 'Books', 'Beauty', 'Sports', 'Toys', 'Grocery'))
) ENGINE=InnoDB;

CREATE TABLE orders (
    order_id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    customer_id      INT UNSIGNED NOT NULL,
    order_date       DATETIME NOT NULL,
    order_status     VARCHAR(20) NOT NULL,
    PRIMARY KEY (order_id),
    KEY idx_orders_customer_date (customer_id, order_date),
    KEY idx_orders_date_status (order_date, order_status),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_orders_status CHECK (order_status IN
        ('Delivered', 'Pending', 'Cancelled', 'Returned'))
) ENGINE=InnoDB;

CREATE TABLE order_items (
    order_item_id    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    order_id         INT UNSIGNED NOT NULL,
    product_id       INT UNSIGNED NOT NULL,
    quantity         SMALLINT UNSIGNED NOT NULL,
    unit_price       DECIMAL(10,2) NOT NULL COMMENT 'Price captured at purchase time; independent of current products.list_price',
    PRIMARY KEY (order_item_id),
    UNIQUE KEY uq_order_items_order_product (order_id, product_id),
    KEY idx_order_items_product (product_id),
    CONSTRAINT fk_order_items_order FOREIGN KEY (order_id)
        REFERENCES orders (order_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_order_items_product FOREIGN KEY (product_id)
        REFERENCES products (product_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_order_items_quantity CHECK (quantity > 0),
    CONSTRAINT chk_order_items_unit_price CHECK (unit_price > 0)
) ENGINE=InnoDB;

CREATE TABLE payments (
    payment_id       INT UNSIGNED NOT NULL AUTO_INCREMENT,
    order_id         INT UNSIGNED NOT NULL,
    payment_method   VARCHAR(30) NOT NULL,
    payment_amount   DECIMAL(12,2) NOT NULL,
    payment_date     DATETIME NULL,
    payment_status   VARCHAR(20) NOT NULL,
    PRIMARY KEY (payment_id),
    UNIQUE KEY uq_payments_order (order_id),
    KEY idx_payments_status_method (payment_status, payment_method),
    KEY idx_payments_date (payment_date),
    CONSTRAINT fk_payments_order FOREIGN KEY (order_id)
        REFERENCES orders (order_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_payments_method CHECK (payment_method IN
        ('Credit Card', 'Debit Card', 'UPI', 'Net Banking', 'Wallet', 'Cash on Delivery')),
    CONSTRAINT chk_payments_amount CHECK (payment_amount >= 0),
    CONSTRAINT chk_payments_status CHECK (payment_status IN ('Successful', 'Pending', 'Failed'))
) ENGINE=InnoDB;
