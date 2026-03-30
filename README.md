# 📊 Customer Analytics SQL Project

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-336791?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![SQL](https://img.shields.io/badge/SQL-Advanced-blue?style=for-the-badge)](https://www.w3schools.com/sql/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

> A comprehensive SQL analytics project for customer behavior analysis with 650K+ realistic records and 20 advanced queries for customer segmentation, churn prediction, and lifetime value analysis.

---

## 🎯 Project Overview

This project demonstrates professional-grade SQL analytics focused entirely on **customer analytics**. It includes a realistic dataset with 650,000+ records modeling real-world customer behavior, with queries designed to answer critical business questions about customer value, retention, and growth.

### Key Metrics

| Metric | Value |
|--------|-------|
| **Total Records** | 655,000+ |
| **Database Tables** | 5 specialized tables |
| **Analysis Queries** | 20 advanced queries |
| **Customer Records** | 100,000 |
| **Transactions** | 400,000 |
| **Query Performance** | <5 seconds each |

---

## 🌟 Key Features

### 📊 Comprehensive Customer Data
- **100,000 customers** across 5 countries with full demographics
- **400,000 transactions** with realistic purchase patterns
- **50,000 churn signals** for risk assessment
- **100,000 interactions** tracking customer support and feedback

### 🔍 Advanced SQL Techniques
- **Window Functions**: RANK, ROW_NUMBER, NTILE, LAG, LEAD, PERCENT_RANK
- **CTEs (Common Table Expressions)**: For complex multi-step analysis
- **Complex Joins**: Multiple table relationships
- **Advanced Aggregations**: GROUP BY, HAVING, conditional aggregates
- **String Functions**: Concatenation, formatting
- **Date Arithmetic**: Time-based calculations

### 💼 Business-Focused Queries
1. **Top Customers by Lifetime Value** - Identify VIP accounts
2. **Customer Segmentation** - Distribution across segments
3. **Churn Risk Analysis** - At-risk customer identification
4. **Satisfaction & Retention** - Link satisfaction to retention
5. **Monthly Revenue Trends** - Revenue by segment
6. **Customer Acquisition Analysis** - Cohort performance
7. **Product Preferences** - Category preferences by segment
8. **Repeat Purchase Rates** - Loyalty measurement
9. **Geographic Distribution** - Location-based metrics
10. **Support Impact** - How support affects retention
11. **RFM Segmentation** - Recency/Frequency/Monetary analysis
12. **Payment Methods** - Payment preference and success rates
13. **Purchase Frequency** - Time between purchases
14. **AOV Growth** - Customers increasing spending
15. **CLV Prediction** - High-potential customer identification
16. **Refund Patterns** - Transaction status analysis
17. **Executive Dashboard** - Key KPIs
18. **Customer Journey** - Progression from acquisition
19. **Profitability by Segment** - Profit metrics
20. **Best Customers** - Characterizing top customers

---

## 🗂️ Project Structure

```
customer-analytics-sql/
├── README.md                          # This file
├── LICENSE                            # MIT License
├── .gitignore                         # Git ignore rules
│
├── sql/                               # SQL scripts
│   ├── 01_customer_analytics_schema.sql    # Database schema (5 tables, 15+ indexes)
│   ├── 02_customer_analytics_data.sql      # Data generation (655K records)
│   └── 03_customer_analytics_queries.sql   # 20 analysis queries
│
├── docs/                              # Documentation
│   ├── SETUP.md                       # Installation guide
│   ├── QUERIES.md                     # Query documentation
│   └── ANALYSIS_GUIDE.md              # How to use results
│
└── results/                           # Sample outputs
    └── sample_results.csv             # Example query results
```

---

## 🚀 Quick Start

### Prerequisites
- PostgreSQL 12+ ([Download](https://www.postgresql.org/download/))
- VS Code with SQLTools (optional but recommended)

### Installation (5 minutes)

```bash
# 1. Create database
psql -U postgres -h localhost
CREATE DATABASE customer_analytics;
\q

# 2. Load schema
psql -U postgres -h localhost -d customer_analytics < sql/01_customer_analytics_schema.sql

# 3. Generate data (15-20 minutes)
psql -U postgres -h localhost -d customer_analytics < sql/02_customer_analytics_data.sql

# 4. Run queries
psql -U postgres -h localhost -d customer_analytics < sql/03_customer_analytics_queries.sql
```

### Using VS Code (Recommended)
1. Install PostgreSQL extension
2. Create connection to your database
3. Open each SQL file and execute with keyboard shortcut

---

## 💡 Query Examples

### Example 1: Top Customers by Lifetime Value
```sql
SELECT 
    c.customer_id,
    c.customer_name,
    c.customer_segment,
    c.total_lifetime_value AS clv,
    c.total_purchases,
    c.last_purchase_date
FROM customers c
WHERE c.total_purchases > 0
ORDER BY c.total_lifetime_value DESC
LIMIT 50;
```

**Result**: Top 50 customers by spending
**Use**: Identify VIP accounts for retention focus

### Example 2: RFM Customer Segmentation
```sql
WITH rfm AS (
    SELECT 
        c.customer_id,
        NTILE(5) OVER (ORDER BY MAX(ct.transaction_date) DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY COUNT(*) DESC) AS frequency_score,
        NTILE(5) OVER (ORDER BY SUM(ct.final_amount) DESC) AS monetary_score
    FROM customers c
    LEFT JOIN customer_transactions ct ON c.customer_id = ct.customer_id
    GROUP BY c.customer_id
)
SELECT 
    customer_id,
    CONCAT(recency_score, frequency_score, monetary_score) AS rfm_score,
    CASE 
        WHEN recency_score >= 4 AND frequency_score >= 4 THEN 'Champions'
        WHEN recency_score = 1 AND frequency_score <= 2 THEN 'At Risk'
        ELSE 'Potential'
    END AS segment
FROM rfm;
```

**Result**: Customer segments based on behavior
**Use**: Personalized marketing campaigns

### Example 3: Churn Risk Analysis
```sql
SELECT 
    c.customer_id,
    c.customer_name,
    EXTRACT(DAY FROM CURRENT_DATE - c.last_purchase_date) AS days_inactive,
    CASE 
        WHEN EXTRACT(DAY FROM CURRENT_DATE - c.last_purchase_date) > 180 THEN 'Critical'
        WHEN EXTRACT(DAY FROM CURRENT_DATE - c.last_purchase_date) > 120 THEN 'High'
        ELSE 'Medium'
    END AS churn_risk
FROM customers c
WHERE c.total_purchases > 0
ORDER BY days_inactive DESC;
```

**Result**: Customers at risk of churning
**Use**: Retention campaigns

---

## 📊 Dataset Specifications

### Table Structure

**customers (100,000 rows)**
- Customer demographics (name, email, phone)
- Lifecycle data (signup date, last purchase, status)
- Segmentation (segment, tier, lifetime value)

**product_categories (5,000 rows)**
- Product catalog with pricing
- Cost and margin calculations
- Category and subcategory grouping

**customer_transactions (400,000 rows)**
- Individual purchases with amounts
- Product and payment details
- Transaction status tracking

**customer_churn_signals (50,000 rows)**
- Churn risk indicators
- Behavioral signals
- Risk scoring

**customer_interactions (100,000 rows)**
- Support tickets and surveys
- Satisfaction scores
- Resolution tracking

### Data Characteristics
- ✅ Realistic distributions (non-uniform)
- ✅ Geographic diversity (5 countries)
- ✅ Temporal patterns (3 years of data)
- ✅ Customer lifecycle patterns
- ✅ Proper relationships and referential integrity

---

## 📈 Key Insights You Can Generate

1. **Customer Segmentation** - Identify VIP, Standard, Budget segments
2. **Churn Prediction** - Flag at-risk customers early
3. **Lifetime Value Analysis** - Predict customer worth
4. **Retention Patterns** - Understand what keeps customers
5. **Revenue Forecasting** - Project future revenue
6. **Product Preferences** - Which products for which segments
7. **Support Impact** - How support affects retention
8. **Geographic Trends** - Regional performance
9. **Growth Opportunities** - Customers with growth potential
10. **Payment Preferences** - Methods and conversion rates

---

## 🎓 Learning Outcomes

After working with this project, you'll understand:

✅ Advanced SQL query writing
✅ Window functions for analytical queries
✅ Customer behavior analysis techniques
✅ Database performance optimization
✅ Churn prediction methods
✅ Customer lifetime value calculation
✅ RFM segmentation model
✅ Cohort analysis
✅ Business metrics and KPIs
✅ Data-driven decision making

---

## 🔧 Technical Stack

| Component | Technology |
|-----------|-----------|
| **Database** | PostgreSQL 12+ |
| **Language** | SQL |
| **IDE** | VS Code + SQLTools |
| **Dataset Size** | 655,000+ records |
| **Total Database** | ~300-400 MB |

---

## 📁 Detailed Documentation

See additional files for:
- **SETUP.md** - Detailed installation instructions
- **QUERIES.md** - Each query explained with business context
- **ANALYSIS_GUIDE.md** - How to interpret results

---

## 💾 Database Indexes

Optimized with 15+ indexes on frequently queried columns:
- Customer lookups (email, ID, segment)
- Transaction filtering (date, status, customer)
- Churn signal retrieval (risk level, date)
- Interaction searching (type, channel, satisfaction)

All queries run in <5 seconds even with 400K+ transactions.

---

## 🤝 Contributing

Contributions welcome! Consider:
- Adding more analysis queries
- Optimizing existing queries
- Adding visualization queries
- Improving documentation
- Creating sample reports

---

## 📄 License

MIT License - feel free to use this for learning and portfolio purposes.

---



