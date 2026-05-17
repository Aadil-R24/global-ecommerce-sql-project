/* =========================================================
   GLOBAL E-COMMERCE SQL PROJECT
   End-to-End Data Cleaning, Modeling & Analytics Project
   =========================================================

   PROJECT FLOW:
   1. Database Creation
   2. Raw Tables Creation
   3. Sample Data Insertion
   4. Data Profiling
   5. Data Cleaning
   6. Normalization & Data Modeling
   7. Analytical Queries
   8. Power BI Preparation

   TECHNOLOGIES:
   - Microsoft SQL Server
   - SQL (DDL, DML, JOINS, AGGREGATIONS)
   - Data Cleaning
   - Normalization (1NF, 2NF, 3NF)
   - Relational Data Modeling
   - Power BI Preparation

========================================================= */


-- =========================================================
-- PHASE 1: DATABASE CREATION
-- =========================================================

-- Create project database
CREATE DATABASE COMPLETE_SQL_PROJECT;
GO

-- Select database
USE COMPLETE_SQL_PROJECT;
GO



-- =========================================================
-- PHASE 2: RAW TABLES CREATION
-- =========================================================

/*
Purpose:
These are the original/raw business tables.

customers:
Stores customer-level information.

orders:
Stores transactional order information.
*/


-- =========================================================
-- CUSTOMERS TABLE
-- =========================================================

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(50),
    country VARCHAR(100),
    signup_date DATE,
    is_active BIT,
    loyalty_tier VARCHAR(50),
    marketing_opt_in BIT
);



-- =========================================================
-- ORDERS TABLE
-- =========================================================

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    product_name VARCHAR(255),
    category VARCHAR(100),
    unit_price DECIMAL(10,2),
    quantity INT,
    discount_pct DECIMAL(5,2),
    status VARCHAR(50),
    shipping_country VARCHAR(100)
);



-- =========================================================
-- PHASE 3: SAMPLE DATA INSERTION
-- =========================================================

/*
Purpose:
Insert sample business data for analysis,
cleaning, modeling, and dashboard creation.
*/


-- =========================================================
-- INSERT DATA INTO CUSTOMERS
-- =========================================================

INSERT INTO customers VALUES
(1,'Aadil','Rashid','aadil@gmail.com','9876543210','India','2022-01-10',1,'Gold',1),

(2,'John','Doe','john@gmail.com','1234567890','USA','2023-02-11',1,'Silver',0),

(3,'Marie','Claire','marie@gmail.com','7777777777','France','2024-03-05',1,'Gold',1),

(4,'Luis','Garcia','luis@gmail.com','8888888888','Spain','2024-01-20',1,'Bronze',1),

(5,'Akira','Tanaka','akira@gmail.com','9999999999','Japan','2024-05-15',1,'Silver',0);



-- =========================================================
-- INSERT DATA INTO ORDERS
-- =========================================================

INSERT INTO orders VALUES

(101,1,'2024-01-01','Laptop','Electronics',1200,1,10,'COMPLETED','India'),

(102,2,'2024-01-03','Phone','Electronics',800,1,5,'COMPLETED','USA'),

(103,3,'2024-02-01','Shoes','Fashion',150,2,0,'COMPLETED','France'),

(104,4,'2024-02-11','Watch','Accessories',300,1,15,'PENDING','Spain'),

(105,5,'2024-03-01','Headphones','Electronics',200,1,0,'COMPLETED','Japan');



-- =========================================================
-- PHASE 4: DATA PROFILING
-- =========================================================

/*
Purpose:
Understand the quality of data before cleaning.

Checks performed:
1. Total rows
2. Missing values
3. Duplicate records
4. Invalid email formats
5. Country inconsistencies
6. Foreign key integrity
*/


-- =========================================================
-- CHECK TOTAL ROWS
-- =========================================================

SELECT COUNT(*) AS total_customers
FROM customers;

SELECT COUNT(*) AS total_orders
FROM orders;



-- =========================================================
-- CHECK MISSING VALUES
-- =========================================================

/*
Logic:
CASE returns:
1 = missing value found
0 = valid value

SUM counts total missing rows.
*/

SELECT
    SUM(
        CASE
            WHEN first_name IS NULL
                 OR first_name = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_first_name,

    SUM(
        CASE
            WHEN email IS NULL
                 OR email = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_email,

    SUM(
        CASE
            WHEN phone IS NULL
                 OR phone = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_phone

FROM customers;



-- =========================================================
-- CHECK DUPLICATE EMAILS
-- =========================================================

/*
Purpose:
Identify duplicate customer emails.
Useful for CRM cleaning.
*/

SELECT
    email,
    COUNT(*) AS occurrences

FROM customers

GROUP BY email

HAVING COUNT(*) > 1;



-- =========================================================
-- CHECK DUPLICATE PHONE NUMBERS
-- =========================================================

SELECT
    phone,
    COUNT(*) AS occurrences

FROM customers

WHERE phone IS NOT NULL

GROUP BY phone

HAVING COUNT(*) > 1;



-- =========================================================
-- CHECK COUNTRY INCONSISTENCIES
-- =========================================================

/*
Purpose:
Detect inconsistent spellings such as:
USA
U.S.A.
United States
france
France
*/

SELECT DISTINCT country
FROM customers
ORDER BY country;



-- =========================================================
-- CHECK INVALID EMAIL FORMATS
-- =========================================================

/*
LIKE Pattern:
%@%.%

%   = wildcard
@   = must contain @
.   = must contain domain extension
*/

SELECT
    customer_id,
    email

FROM customers

WHERE email NOT LIKE '%@%.%';



-- =========================================================
-- CHECK FOREIGN KEY INTEGRITY
-- =========================================================

/*
Purpose:
Find orders without valid customers.
*/

SELECT
    o.order_id,
    o.customer_id

FROM orders AS o

LEFT JOIN customers AS c
    ON o.customer_id = c.customer_id

WHERE c.customer_id IS NULL;



-- =========================================================
-- PHASE 5: DATA CLEANING
-- =========================================================

/*
Purpose:
Standardize and improve data quality.
*/


-- =========================================================
-- STANDARDIZE COUNTRY NAMES
-- =========================================================

UPDATE customers

SET country = 'USA'

WHERE country IN
(
    'U.S.A.',
    'United States',
    'USA'
);



-- =========================================================
-- FIX INVALID EMAILS
-- =========================================================

UPDATE customers

SET email = NULL

WHERE email NOT LIKE '%@%.%';



-- =========================================================
-- CREATE CLEAN TABLES
-- =========================================================

/*
Purpose:
Preserve raw tables and create clean copies
for modeling and analytics.
*/

SELECT *
INTO customers_clean
FROM customers;

SELECT *
INTO orders_clean
FROM orders;



-- =========================================================
-- PHASE 6: NORMALIZATION & DATA MODELING
-- =========================================================

/*
Goal:
Convert raw transactional data into a
normalized relational model.

Final Tables:
1. loyalty_tiers
2. customers_model
3. products
4. orders_model
5. order_items

Benefits:
- Reduces redundancy
- Improves scalability
- Supports BI & ML
- Improves JOIN efficiency
*/


-- =========================================================
-- LOYALTY TIERS TABLE
-- =========================================================

CREATE TABLE loyalty_tiers (

    loyalty_tier_id INT PRIMARY KEY,

    tier_name VARCHAR(50),

    discount_rate DECIMAL(5,2),

    description VARCHAR(255)
);



-- =========================================================
-- CUSTOMERS MODEL TABLE
-- =========================================================

/*
One row per customer.
*/

CREATE TABLE customers_model (

    customer_id INT PRIMARY KEY,

    first_name VARCHAR(100),

    last_name VARCHAR(100),

    email VARCHAR(255),

    phone VARCHAR(20),

    country VARCHAR(100),

    signup_date DATE,

    is_active BIT,

    loyalty_tier_id INT,

    marketing_opt_in BIT,

    FOREIGN KEY (loyalty_tier_id)
        REFERENCES loyalty_tiers(loyalty_tier_id)
);



-- =========================================================
-- PRODUCTS TABLE
-- =========================================================

/*
Stores unique products.
Removes repeated product names from orders.
*/

CREATE TABLE products (

    product_id INT PRIMARY KEY,

    product_name VARCHAR(255),

    category VARCHAR(100),

    base_price DECIMAL(10,2)
);



-- =========================================================
-- ORDERS MODEL TABLE
-- =========================================================

/*
Stores one row per order.
*/

CREATE TABLE orders_model (

    order_id INT PRIMARY KEY,

    customer_id INT,

    order_date DATE,

    status VARCHAR(50),

    shipping_country VARCHAR(100),

    FOREIGN KEY (customer_id)
        REFERENCES customers_model(customer_id)
);



-- =========================================================
-- ORDER ITEMS TABLE
-- =========================================================

/*
Stores line-level order details.

This becomes the FACT TABLE
for analytics and Power BI.
*/

CREATE TABLE order_items (

    order_item_id INT PRIMARY KEY,

    order_id INT,

    product_id INT,

    unit_price DECIMAL(10,2),

    quantity INT,

    discount_pct DECIMAL(5,2),

    FOREIGN KEY (order_id)
        REFERENCES orders_model(order_id),

    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);



-- =========================================================
-- PHASE 7: ANALYTICAL QUERIES
-- =========================================================

/*
Purpose:
Business intelligence and reporting.
*/


-- =========================================================
-- NET REVENUE BY COUNTRY
-- =========================================================

/*
Formula:
Net Revenue =
unit_price * quantity * (1 - discount_pct/100)
*/

SELECT

    c.country,

    SUM(
        o.unit_price
        * o.quantity
        * (1 - o.discount_pct / 100.0)
    ) AS total_revenue

FROM customers AS c

JOIN orders AS o
    ON c.customer_id = o.customer_id

WHERE LOWER(o.status) = 'completed'

GROUP BY c.country

ORDER BY total_revenue DESC;



-- =========================================================
-- REVENUE BY COUNTRY AND YEAR
-- =========================================================

SELECT

    c.country,

    YEAR(o.order_date) AS order_year,

    SUM(
        o.unit_price
        * o.quantity
        * (1 - o.discount_pct / 100.0)
    ) AS total_revenue

FROM customers AS c

JOIN orders AS o
    ON c.customer_id = o.customer_id

WHERE o.status = 'COMPLETED'

GROUP BY
    c.country,
    YEAR(o.order_date)

HAVING
    SUM(
        o.unit_price
        * o.quantity
        * (1 - o.discount_pct / 100.0)
    ) > 50

ORDER BY total_revenue DESC;



-- =========================================================
-- PHASE 8: POWER BI PREPARATION
-- =========================================================

/*
Purpose:
Create a business-ready analytical view
for Power BI dashboards.

This view combines:
- Customers
- Orders
- Products
- Loyalty tiers
- Revenue metrics
*/


-- =========================================================
-- CREATE ANALYTICAL VIEW
-- =========================================================

CREATE VIEW v_order_items_enriched AS

SELECT

    oi.order_item_id,

    oi.order_id,

    o.order_date,

    o.status,

    o.shipping_country,

    c.customer_id,

    c.first_name,

    c.last_name,

    c.country AS customer_country,

    lt.tier_name AS loyalty_tier,

    p.product_id,

    p.product_name,

    p.category,

    oi.unit_price,

    oi.quantity,

    oi.discount_pct,

    (
        oi.unit_price * oi.quantity
    ) AS gross_value,

    (
        oi.unit_price
        * oi.quantity
        * (1 - oi.discount_pct / 100.0)
    ) AS net_value

FROM order_items AS oi

JOIN orders_model AS o
    ON oi.order_id = o.order_id

JOIN customers_model AS c
    ON o.customer_id = c.customer_id

LEFT JOIN loyalty_tiers AS lt
    ON c.loyalty_tier_id = lt.loyalty_tier_id

JOIN products AS p
    ON oi.product_id = p.product_id;



-- =========================================================
-- ER DIAGRAM (TEXT REPRESENTATION)
-- =========================================================

/*

loyalty_tiers
        |
        | 1-to-many
        ▼
customers_model
        |
        | 1-to-many
        ▼
orders_model
        |
        | 1-to-many
        ▼
order_items
        |
        | many-to-1
        ▼
products

*/



-- =========================================================
-- STAR SCHEMA (POWER BI PERSPECTIVE)
-- =========================================================

/*

                 loyalty_tiers
                       ▲
                       │
         products    customers_model
               ▲            ▲
               └──────┬─────┘
                      │
                      ▼
                  order_items

Fact Table:
- order_items

Dimension Tables:
- customers_model
- products
- loyalty_tiers

*/



-- =========================================================
-- FINAL BUSINESS VALUE
-- =========================================================

/*

This project demonstrates:

✔ SQL data cleaning
✔ Data profiling
✔ Normalization
✔ Relational modeling
✔ Aggregation logic
✔ Revenue analytics
✔ Referential integrity
✔ Power BI preparation
✔ Real-world BI workflow

Suitable for:
- Data Analyst portfolios
- Power BI projects
- SQL interview preparation
- BI engineering demonstrations
- ML data preparation

*/
