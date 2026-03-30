
-- ============================================================================
-- Generates 500K+ records for customer analytics
-- Expected time: 15-20 minutes
--===========================================================================


-- ============================================================================
-- STEP 1: INSERT CUSTOMERS (100,000 records)
-- ============================================================================
-- Real customer profiles with realistic segments and lifecycle

INSERT INTO customers (customer_name, email, phone, signup_date, country, state, city, postal_code, customer_segment, customer_status, is_active)
SELECT
    CONCAT('Customer_', series) AS customer_name,
    CONCAT('customer', series, '@email.com') AS email,
    CONCAT('+1-', LPAD((RANDOM()*9999999999)::TEXT, 10, '0')) AS phone,
    CURRENT_DATE - (RANDOM() * 1095 || ' days')::INTERVAL AS signup_date,
    CASE (RANDOM() * 4)::INT
        WHEN 0 THEN 'USA'
        WHEN 1 THEN 'Canada'
        WHEN 2 THEN 'UK'
        WHEN 3 THEN 'Germany'
        ELSE 'Australia'
    END AS country,
    CASE (RANDOM() * 4)::INT
        WHEN 0 THEN 'California'
        WHEN 1 THEN 'Texas'
        WHEN 2 THEN 'New York'
        WHEN 3 THEN 'Florida'
        ELSE 'Illinois'
    END AS state,
    CASE (RANDOM() * 5)::INT
        WHEN 0 THEN 'New York'
        WHEN 1 THEN 'Los Angeles'
        WHEN 2 THEN 'Chicago'
        WHEN 3 THEN 'Houston'
        ELSE 'Phoenix'
    END AS city,
    LPAD((RANDOM()*99999)::TEXT, 5, '0') AS postal_code,
    CASE (RANDOM() * 4)::INT
        WHEN 0 THEN 'VIP'
        WHEN 1 THEN 'Premium'
        WHEN 2 THEN 'Standard'
        ELSE 'Budget'
    END AS customer_segment,
    CASE WHEN (RANDOM() * 100) > 20 THEN 'Active' ELSE 'Dormant' END AS customer_status,
    CASE WHEN (RANDOM() * 100) > 15 THEN TRUE ELSE FALSE END AS is_active
FROM GENERATE_SERIES(1, 100000) AS series;

SELECT COUNT(*) as total_customers FROM customers;
-- Expected: 100,000

-- ============================================================================
-- STEP 2: INSERT PRODUCTS (5,000 products)
-- ============================================================================
-- Diverse product catalog across multiple categories

INSERT INTO product_categories (product_name, category, subcategory, price, cost, stock_quantity)
SELECT
    CONCAT('Product_', series) AS product_name,
    CASE (RANDOM() * 9)::INT
        WHEN 0 THEN 'Electronics'
        WHEN 1 THEN 'Clothing'
        WHEN 2 THEN 'Home & Garden'
        WHEN 3 THEN 'Books'
        WHEN 4 THEN 'Sports'
        WHEN 5 THEN 'Toys'
        WHEN 6 THEN 'Beauty'
        WHEN 7 THEN 'Food'
        ELSE 'Accessories'
    END AS category,
    CASE (RANDOM() * 3)::INT
        WHEN 0 THEN 'Premium'
        WHEN 1 THEN 'Standard'
        ELSE 'Budget'
    END AS subcategory,
    ROUND((10 + RANDOM() * 2990)::NUMERIC, 2) AS price,
    ROUND((5 + RANDOM() * 1500)::NUMERIC, 2) AS cost,
    (RANDOM() * 10000)::INT AS stock_quantity
FROM GENERATE_SERIES(1, 5000) AS series;

SELECT COUNT(*) as total_products FROM product_categories;
-- Expected: 5,000

-- ============================================================================
-- STEP 3: INSERT CUSTOMER TRANSACTIONS (400,000 purchases)
-- ============================================================================
-- Realistic purchase patterns with repeat customers

INSERT INTO customer_transactions (
    customer_id, product_id, transaction_date, transaction_time, quantity, unit_price, 
    line_total, discount_amount, tax_amount, final_amount, transaction_status, 
    payment_method, shipping_country
)
SELECT
    -- pick a random existing customer
    (SELECT customer_id FROM customers ORDER BY RANDOM() LIMIT 1) AS customer_id,
    
    -- pick a random existing product
    (SELECT product_id FROM product_categories ORDER BY RANDOM() LIMIT 1) AS product_id,
    
    -- random date in the last 3 years
    CURRENT_DATE - (RANDOM() * 1095 || ' days')::INTERVAL AS transaction_date,
    
    -- random time (fixed)
    (LPAD(FLOOR(RANDOM()*24)::TEXT, 2, '0') || ':' ||
     LPAD(FLOOR(RANDOM()*60)::TEXT, 2, '0') || ':' ||
     LPAD(FLOOR(RANDOM()*60)::TEXT, 2, '0'))::TIME AS transaction_time,
    
    -- quantity
    (RANDOM() * 10 + 1)::INT AS quantity,
    
    -- prices and amounts
    ROUND((10 + RANDOM() * 500)::NUMERIC, 2) AS unit_price,
    ROUND((50 + RANDOM() * 5000)::NUMERIC, 2) AS line_total,
    ROUND((RANDOM() * 500)::NUMERIC, 2) AS discount_amount,
    ROUND((RANDOM() * 500)::NUMERIC, 2) AS tax_amount,
    ROUND((50 + RANDOM() * 5000)::NUMERIC, 2) AS final_amount,
    
    -- status
    CASE (RANDOM() * 5)::INT
        WHEN 0 THEN 'Completed'
        WHEN 1 THEN 'Pending'
        WHEN 2 THEN 'Refunded'
        WHEN 3 THEN 'Cancelled'
        ELSE 'Completed'
    END AS transaction_status,
    
    -- payment method
    CASE (RANDOM() * 4)::INT
        WHEN 0 THEN 'Credit Card'
        WHEN 1 THEN 'PayPal'
        WHEN 2 THEN 'Debit Card'
        ELSE 'Bank Transfer'
    END AS payment_method,
    
    -- shipping country
    CASE (RANDOM() * 4)::INT
        WHEN 0 THEN 'USA'
        WHEN 1 THEN 'Canada'
        WHEN 2 THEN 'UK'
        ELSE 'Germany'
    END AS shipping_country

FROM GENERATE_SERIES(1, 400000) AS series;

SELECT COUNT(*) as total_transactions FROM customer_transactions;
-- Expected: 400,000

-- ============================================================================
-- STEP 4: INSERT CHURN SIGNALS (50,000 records)
-- ============================================================================
-- Churn indicators and risk assessment

INSERT INTO customer_churn_signals (customer_id, signal_date, days_since_last_purchase, purchase_frequency_trend, avg_order_value_change, customer_sentiment_score, support_ticket_count, refund_count, churn_risk_score, churn_risk_level)
SELECT
    (RANDOM() * 99999 + 1)::INT AS customer_id,
    CURRENT_DATE - (RANDOM() * 365 || ' days')::INTERVAL AS signal_date,
    (RANDOM() * 365)::INT AS days_since_last_purchase,
    CASE (RANDOM() * 3)::INT
        WHEN 0 THEN 'Declining'
        WHEN 1 THEN 'Stable'
        ELSE 'Increasing'
    END AS purchase_frequency_trend,
    ROUND((RANDOM() * 100 - 50)::NUMERIC, 2) AS avg_order_value_change,
    (RANDOM() * 5 + 1)::INT AS customer_sentiment_score,
    (RANDOM() * 10)::INT AS support_ticket_count,
    (RANDOM() * 5)::INT AS refund_count,
    ROUND((RANDOM() * 100)::NUMERIC, 2) AS churn_risk_score,
    CASE 
        WHEN (RANDOM() * 100) < 20 THEN 'Critical'
        WHEN (RANDOM() * 100) < 40 THEN 'High'
        WHEN (RANDOM() * 100) < 70 THEN 'Medium'
        ELSE 'Low'
    END AS churn_risk_level
FROM GENERATE_SERIES(1, 50000) AS series;

SELECT COUNT(*) as total_churn_signals FROM customer_churn_signals;
-- Expected: 50,000

-- ============================================================================
-- STEP 5: INSERT CUSTOMER INTERACTIONS (100,000 records)
-- ============================================================================
-- Support tickets, surveys, feedback, engagement

INSERT INTO customer_interactions (
    customer_id, interaction_date, interaction_type, interaction_channel,
    subject, satisfaction_score, resolution_status, resolution_time_hours
)
SELECT
    -- pick random existing customer
    (SELECT customer_id FROM customers ORDER BY RANDOM() LIMIT 1) AS customer_id,
    
    -- random date in last 900 days
    CURRENT_DATE - (RANDOM() * 900 || ' days')::INTERVAL AS interaction_date,
    
    -- interaction type
    CASE (RANDOM() * 4)::INT
        WHEN 0 THEN 'Support'
        WHEN 1 THEN 'Survey'
        WHEN 2 THEN 'Complaint'
        ELSE 'Feedback'
    END AS interaction_type,
    
    -- interaction channel
    CASE (RANDOM() * 3)::INT
        WHEN 0 THEN 'Email'
        WHEN 1 THEN 'Chat'
        ELSE 'Phone'
    END AS interaction_channel,
    
    -- subject
    CASE (RANDOM() * 5)::INT
        WHEN 0 THEN 'Order Issue'
        WHEN 1 THEN 'Shipping Inquiry'
        WHEN 2 THEN 'Product Question'
        WHEN 3 THEN 'Return Request'
        ELSE 'General Inquiry'
    END AS subject,
    
    -- satisfaction score 1-5
    (FLOOR(RANDOM() * 5) + 1)::INT AS satisfaction_score,
    
    -- resolution status
    CASE (RANDOM() * 2)::INT
        WHEN 0 THEN 'Resolved'
        ELSE 'Pending'
    END AS resolution_status,
    
    -- resolution time in hours
    (RANDOM() * 72 + 1)::INT AS resolution_time_hours

FROM GENERATE_SERIES(1, 100000) AS series;
SELECT COUNT(*) as total_interactions FROM customer_interactions;
-- Expected: 100,000

-- ============================================================================
-- STEP 6: UPDATE CUSTOMER METRICS
-- ============================================================================
-- Calculate customer lifetime value and purchase stats

UPDATE customers c
SET 
    total_purchases = (
        SELECT COUNT(*)
        FROM customer_transactions ct
        WHERE ct.customer_id = c.customer_id
        AND ct.transaction_status IN ('Completed', 'Refunded')
    ),
    first_purchase_date = (
        SELECT MIN(transaction_date)
        FROM customer_transactions ct
        WHERE ct.customer_id = c.customer_id
        AND ct.transaction_status = 'Completed'
    ),
    last_purchase_date = (
        SELECT MAX(transaction_date)
        FROM customer_transactions ct
        WHERE ct.customer_id = c.customer_id
        AND ct.transaction_status = 'Completed'
    ),
    total_lifetime_value = (
        SELECT COALESCE(SUM(final_amount), 0)
        FROM customer_transactions ct
        WHERE ct.customer_id = c.customer_id
        AND ct.transaction_status = 'Completed'
    )
WHERE customer_id <= 100000;

-- Update customer status based on activity
UPDATE customers c
SET customer_status = 
    CASE 
        WHEN last_purchase_date IS NULL THEN 'Never Purchased'
        WHEN EXTRACT(DAY FROM CURRENT_DATE - last_purchase_date) <= 30 THEN 'Active'
        WHEN EXTRACT(DAY FROM CURRENT_DATE - last_purchase_date) <= 90 THEN 'At-Risk'
        WHEN EXTRACT(DAY FROM CURRENT_DATE - last_purchase_date) <= 180 THEN 'Dormant'
        ELSE 'Churned'
    END
WHERE customer_id <= 100000;

-- ============================================================================
-- FINAL VERIFICATION
-- ============================================================================

SELECT 
    'Customers' AS table_name,
    COUNT(*) AS record_count,
    pg_size_pretty(pg_total_relation_size('customers')) AS table_size
FROM customers
UNION ALL
SELECT 
    'Products' AS table_name,
    COUNT(*) AS record_count,
    pg_size_pretty(pg_total_relation_size('product_categories')) AS table_size
FROM product_categories
UNION ALL
SELECT 
    'Transactions' AS table_name,
    COUNT(*) AS record_count,
    pg_size_pretty(pg_total_relation_size('customer_transactions')) AS table_size
FROM customer_transactions
UNION ALL
SELECT 
    'Churn Signals' AS table_name,
    COUNT(*) AS record_count,
    pg_size_pretty(pg_total_relation_size('customer_churn_signals')) AS table_size
FROM customer_churn_signals
UNION ALL
SELECT 
    'Interactions' AS table_name,
    COUNT(*) AS record_count,
    pg_size_pretty(pg_total_relation_size('customer_interactions')) AS table_size
FROM customer_interactions;

-- Expected final dataset:
-- Customers:          100,000 records
-- Products:             5,000 records
-- Transactions:       400,000 records
-- Churn Signals:       50,000 records
-- Interactions:       100,000 records
-- TOTAL:              655,000+ records

-- ============================================================================
-- NEXT STEP: Run 03_customer_analytics_queries.sql
-- ============================================================================