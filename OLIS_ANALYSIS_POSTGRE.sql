--CREATE TABLES

--1)CREATE TABLE customers (
    customer_id              TEXT PRIMARY KEY,
    customer_unique_id       TEXT,
    customer_zip_code_prefix TEXT,
    customer_city            TEXT,
    customer_state           TEXT
);
--2)CREATE TABLE orders (
    order_id                       TEXT PRIMARY KEY,
    customer_id                    TEXT,
    order_status                   TEXT,
    order_purchase_timestamp       TIMESTAMP,
    order_approved_at              TIMESTAMP,
    order_delivered_carrier_date   TIMESTAMP,
    order_delivered_customer_date  TIMESTAMP,
    order_estimated_delivery_date  TIMESTAMP
);
--3)CREATE TABLE order_items (
    order_id            TEXT,
    order_item_id       INT,
    product_id          TEXT,
    seller_id           TEXT,
    shipping_limit_date TIMESTAMP,
    price               NUMERIC(10,2),
    freight_value       NUMERIC(10,2),
    PRIMARY KEY (order_id, order_item_id)
);

--4)CREATE TABLE order_payments (
    order_id             TEXT,
    payment_sequential   INT,
    payment_type         TEXT,
    payment_installments INT,
    payment_value        NUMERIC(10,2),
    PRIMARY KEY (order_id, payment_sequential)
);

--5)CREATE TABLE order_reviews (         
    review_id               TEXT,
    order_id                TEXT,
    review_score            INT,
    review_comment_title    TEXT,
    review_comment_message  TEXT,
    review_creation_date    TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

--6)CREATE TABLE products (
    product_id                 TEXT PRIMARY KEY,
    product_category_name      TEXT,
    product_name_length        INT,
    product_description_length INT,
    product_photos_qty         INT,
    product_weight_g           INT,
    product_length_cm          INT,
    product_height_cm          INT,
    product_width_cm           INT
);

--7)CREATE TABLE sellers (
    seller_id              TEXT PRIMARY KEY,
    seller_zip_code_prefix TEXT,
    seller_city            TEXT,
    seller_state           TEXT
);

--8)CREATE TABLE category_translation (
    product_category_name         TEXT PRIMARY KEY,
    product_category_name_english TEXT
);

--9)CREATE TABLE geolocation (        
    geolocation_zip_code_prefix TEXT,
    geolocation_lat             DOUBLE PRECISION,
    geolocation_lng             DOUBLE PRECISION,
    geolocation_city            TEXT,
    geolocation_state           TEXT
);

--DATA CHECKS

--1) ROW COUNTS OF EVERY TABLE 
SELECT 'customers' AS tbl, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'sellers', COUNT(*) FROM sellers;

--2)Order status breakdown 
SELECT
    order_status,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM orders), 2
    ) AS pct
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

--3)Join fan-out 
--Identify multiple reviews and payment types per order
--to avoid inflated counts when joining tables.

--Orders with multiple reviews
SELECT COUNT(*)
FROM (
    SELECT order_id
    FROM order_reviews
    GROUP BY order_id
    HAVING COUNT(*) > 1
) AS r;

--Orders with multiple payment types
SELECT COUNT(*)
FROM (
    SELECT order_id
    FROM order_payments
    GROUP BY order_id
    HAVING COUNT(DISTINCT payment_type) > 1
) AS p;

--Orders without delivery date
SELECT COUNT(*)
FROM orders
WHERE order_delivered_customer_date IS NULL;


--KPIS
--KPI1
--Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics
SELECT 
     CASE 
     WHEN EXTRACT (ISODOW FROM o.order_purchase_timestamp) IN (6,7)
   THEN 'Weekend'
   ELSE 'Weekday'
 END AS day_type,
 SUM(p.payment_value) AS total_payment,
CONCAT(ROUND((SUM(p.payment_value) * 100.0 / (SELECT SUM(payment_value) FROM order_payments))::numeric,2),'%')
as perct
FROM orders o
JOIN order_payments p
ON o.order_id = p.order_id
GROUP BY day_type;


--KPI2
--Number of Orders with review score 5 and payment type as credit card
SELECT
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN order_reviews r
    ON o.order_id = r.order_id
JOIN order_payments p
    ON o.order_id = p.order_id
WHERE r.review_score = 5
AND p.payment_type = 'credit_card';


--KPI3
--Average number of days taken for order_delivered_customer_date for pet_shop
SELECT 'pet_shop' AS product_category_name,
    ROUND(AVG(delivery_days), 0) AS avg_delivery_days
FROM (
    SELECT DISTINCT
        o.order_id,
        o.order_delivered_customer_date::DATE -
        o.order_purchase_timestamp::DATE AS delivery_days
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    WHERE p.product_category_name = 'pet_shop'
    AND o.order_delivered_customer_date IS NOT NULL
) AS pet_orders;


--KPI4
--Average price and payment values from customers of sao paulo city
SELECT
    (SELECT ROUND(AVG(oi.price)::numeric, 0)
     FROM orders o
     JOIN customers c ON o.customer_id = c.customer_id
     JOIN order_items oi ON o.order_id = oi.order_id
     WHERE c.customer_city = 'sao paulo'
    ) AS avg_item_price,

    (SELECT ROUND(AVG(p.payment_value)::numeric, 0)
     FROM orders o
     JOIN customers c ON o.customer_id = c.customer_id
     JOIN order_payments p ON o.order_id = p.order_id
     WHERE c.customer_city = 'sao paulo'
    ) AS avg_payment_value;


--KPI5
--Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) 
--Vs review scores
SELECT
    r.review_score,
    ROUND(AVG(o.order_delivered_customer_date::DATE -
     o.order_purchase_timestamp::DATE), 0) AS avg_shipping_days
FROM orders o
JOIN order_reviews r
    ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score;






















