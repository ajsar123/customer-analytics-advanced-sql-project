-- ============================================================================
-- CUSTOMER ANALYTICS PROJECT - POSTGRESQL DATABASE SCHEMA
-- File: 01_customer_analytics_schema.sql
-- ============================================================================
-- This file creates the complete database schema for customer analytics
-- Focused on: Customer behavior, segmentation, lifetime value, churn
-- Run this FIRST
-- ============================================================================


-- ============================================================================
-- TABLE 1: CUSTOMERS (Master customer data)
-- ============================================================================
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(20),
    signup_date DATE NOT NULL,
    country VARCHAR(50) NOT NULL,
    state VARCHAR(50),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    customer_segment VARCHAR(50),
    customer_status VARCHAR(30),
    total_lifetime_value DECIMAL(12,2) DEFAULT 0,
    total_purchases INT DEFAULT 0,
    last_purchase_date DATE,
    first_purchase_date DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE customers IS 'Master customer table with demographics and status';
COMMENT ON COLUMN customers.customer_segment IS 'VIP, Premium, Standard, Budget';
COMMENT ON COLUMN customers.customer_status IS 'Active, Churned, Dormant, At-Risk';

-- ============================================================================
-- TABLE 2: PRODUCT_CATEGORIES (Product catalog for transactions)
-- ============================================================================
CREATE TABLE product_categories (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    subcategory VARCHAR(100),
    price DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    unit_margin DECIMAL(10,2) GENERATED ALWAYS AS (price - cost) STORED,
    margin_percent DECIMAL(5,2) GENERATED ALWAYS AS (ROUND(((price - cost) / price * 100)::NUMERIC, 2)) STORED,
    stock_quantity INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_date DATE DEFAULT CURRENT_DATE
);

COMMENT ON TABLE product_categories IS 'Product catalog with pricing and margins';
ALTER TABLE product_categories
ALTER COLUMN margin_percent TYPE DECIMAL(7,2);

ALTER TABLE product_categories
DROP COLUMN margin_percent;

ALTER TABLE product_categories
ADD COLUMN margin_percent DECIMAL(7,2)
GENERATED ALWAYS AS (
    ROUND(
        CASE 
            WHEN price = 0 THEN 0
            ELSE ((price - cost) / price * 100)
        END,
        2
    )
) STORED;
-- ============================================================================
-- TABLE 3: CUSTOMER_TRANSACTIONS (All customer purchases)
-- ============================================================================
CREATE TABLE customer_transactions (
    transaction_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES product_categories(product_id),
    transaction_date DATE NOT NULL,
    transaction_time TIME,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    line_total DECIMAL(12,2) NOT NULL,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    final_amount DECIMAL(12,2) NOT NULL,
    transaction_status VARCHAR(30) DEFAULT 'Completed',
    payment_method VARCHAR(50),
    shipping_country VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE customer_transactions IS 'Individual customer transactions';
COMMENT ON COLUMN customer_transactions.transaction_status IS 'Completed, Pending, Cancelled, Refunded';

-- ============================================================================
-- TABLE 4: CUSTOMER_CHURN_SIGNALS (Churn indicators and at-risk flags)
-- ============================================================================
CREATE TABLE customer_churn_signals (
    signal_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    signal_date DATE NOT NULL,
    days_since_last_purchase INT,
    purchase_frequency_trend VARCHAR(20),
    avg_order_value_change DECIMAL(5,2),
    customer_sentiment_score INT,
    support_ticket_count INT,
    refund_count INT,
    churn_risk_score DECIMAL(5,2),
    churn_risk_level VARCHAR(20),
    action_taken VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE customer_churn_signals IS 'Signals and indicators of customer churn risk';
COMMENT ON COLUMN customer_churn_signals.churn_risk_level IS 'Low, Medium, High, Critical';

-- ============================================================================
-- TABLE 5: CUSTOMER_INTERACTIONS (Support, feedback, engagement)
-- ============================================================================
CREATE TABLE customer_interactions (
    interaction_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    interaction_date DATE NOT NULL,
    interaction_type VARCHAR(50),
    interaction_channel VARCHAR(30),
    subject VARCHAR(255),
    message TEXT,
    satisfaction_score INT CHECK (satisfaction_score IS NULL OR (satisfaction_score >= 1 AND satisfaction_score <= 5)),
    resolution_status VARCHAR(30),
    resolution_time_hours INT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE customer_interactions IS 'Customer service interactions, feedback, surveys';
COMMENT ON COLUMN customer_interactions.interaction_type IS 'Support, Survey, Complaint, Feedback, Inquiry';
COMMENT ON COLUMN customer_interactions.interaction_channel IS 'Email, Phone, Chat, Social, SMS';

-- ============================================================================
-- CREATE INDEXES FOR PERFORMANCE
-- ============================================================================

-- Customer indexes
CREATE INDEX idx_customers_country ON customers(country);
CREATE INDEX idx_customers_segment ON customers(customer_segment);
CREATE INDEX idx_customers_status ON customers(customer_status);
CREATE INDEX idx_customers_signup_date ON customers(signup_date);
CREATE INDEX idx_customers_is_active ON customers(is_active);
CREATE INDEX idx_customers_email ON customers(email);

-- Product indexes
CREATE INDEX idx_products_category ON product_categories(category);
CREATE INDEX idx_products_is_active ON product_categories(is_active);
CREATE INDEX idx_products_price ON product_categories(price);

-- Transaction indexes
CREATE INDEX idx_transactions_customer_id ON customer_transactions(customer_id);
CREATE INDEX idx_transactions_date ON customer_transactions(transaction_date);
CREATE INDEX idx_transactions_status ON customer_transactions(transaction_status);
CREATE INDEX idx_transactions_payment ON customer_transactions(payment_method);
CREATE INDEX idx_transactions_customer_date ON customer_transactions(customer_id, transaction_date);

-- Churn signal indexes
CREATE INDEX idx_churn_customer_id ON customer_churn_signals(customer_id);
CREATE INDEX idx_churn_date ON customer_churn_signals(signal_date);
CREATE INDEX idx_churn_risk_level ON customer_churn_signals(churn_risk_level);

-- Interaction indexes
CREATE INDEX idx_interactions_customer_id ON customer_interactions(customer_id);
CREATE INDEX idx_interactions_date ON customer_interactions(interaction_date);
CREATE INDEX idx_interactions_type ON customer_interactions(interaction_type);
CREATE INDEX idx_interactions_channel ON customer_interactions(interaction_channel);
CREATE INDEX idx_interactions_satisfaction ON customer_interactions(satisfaction_score);

-- ============================================================================
-- SCHEMA VERIFICATION
-- ============================================================================

-- Verify all tables created
SELECT 
    schemaname,
    tablename,
    CASE 
        WHEN tablename = 'customers' THEN 1
        WHEN tablename = 'product_categories' THEN 2
        WHEN tablename = 'customer_transactions' THEN 3
        WHEN tablename = 'customer_churn_signals' THEN 4
        WHEN tablename = 'customer_interactions' THEN 5
        ELSE 99
    END AS table_order
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY table_order;

-- Expected output: 5 tables
-- ✓ customers
-- ✓ product_categories
-- ✓ customer_transactions
-- ✓ customer_churn_signals
-- ✓ customer_interactions
