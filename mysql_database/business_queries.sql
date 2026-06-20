-- PROJECT  : India Digital Payments Fraud Intelligence Platform
-- MODULE   : Business SQL Queries
-- File     : business_queries.sql
-- Purpose  : 15+ analytical queries answering real business questions a bank's risk/fraud team would ask.
-- Run In   : MySQL Workbench (after schema_design.sql and after Python has loaded the data)


USE upi_fraud_db;


-- Q1. Overall Fraud Rate (the single most important KPI)

SELECT COUNT(*) AS total_transactions,
SUM(fraud_flag) AS fraud_transactions,
ROUND(SUM(fraud_flag) * 100.0 / COUNT(*), 4) AS fraud_rate_percent FROM upi_transactions;


-- Q2. Fraud Rate by Transaction Type
SELECT transaction_type,
COUNT(*) AS total_txns,
SUM(fraud_flag) AS fraud_txns, ROUND(SUM(fraud_flag) * 100.0 / COUNT(*), 4) AS fraud_rate_percent
FROM upi_transactions
GROUP BY transaction_type
ORDER BY fraud_rate_percent DESC;


-- Q3. Fraud Rate by Merchant Category
SELECT merchant_category,
COUNT(*) AS total_txns,
SUM(fraud_flag) AS fraud_txns,
ROUND(SUM(fraud_flag) * 100.0 / COUNT(*), 4) AS fraud_rate_percent,
ROUND(AVG(amount_inr), 2) AS avg_amount_inr
FROM upi_transactions
GROUP BY merchant_category
ORDER BY fraud_rate_percent DESC;


-- Q4. Fraud Rate by Sender State (Geographic Risk Mapping)
SELECT sender_state,
COUNT(*) AS total_txns,
SUM(fraud_flag) AS fraud_txns,
ROUND(SUM(fraud_flag) * 100.0 / COUNT(*), 4) AS fraud_rate_percent
FROM upi_transactions
GROUP BY sender_state
ORDER BY fraud_rate_percent DESC;


-- Q5. Fraud Rate by Bank (Sender Side)
SELECT sender_bank,
COUNT(*) AS total_txns,
SUM(fraud_flag)  AS fraud_txns,
ROUND(SUM(fraud_flag) * 100.0 / COUNT(*), 4)  AS fraud_rate_percent
FROM upi_transactions
GROUP BY sender_bank
ORDER BY fraud_rate_percent DESC;


-- Q6. Cross-Bank vs Same-Bank Transaction Fraud Comparison
SELECT
    CASE
        WHEN sender_bank = receiver_bank THEN 'Same Bank'
        ELSE 'Cross Bank'
    END AS bank_relationship,
    COUNT(*) AS total_txns,
    SUM(fraud_flag) AS fraud_txns,
    ROUND(SUM(fraud_flag) * 100.0 / COUNT(*), 4) AS fraud_rate_percent
FROM upi_transactions
GROUP BY bank_relationship
ORDER BY fraud_rate_percent DESC;


-- Q7. Fraud Rate by Hour of Day (Time-of-Day Risk Pattern)
SELECT
    hour_of_day,
    COUNT(*) AS total_txns,
    SUM(fraud_flag) AS fraud_txns,
    ROUND(SUM(fraud_flag) * 100.0 / COUNT(*), 4) AS fraud_rate_percent
FROM upi_transactions
GROUP BY hour_of_day
ORDER BY hour_of_day;


-- Q8. Weekday vs Weekend Fraud Comparison
SELECT
    CASE WHEN is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_type,
    COUNT(*) AS total_txns,
    SUM(fraud_flag) AS fraud_txns,
    ROUND(SUM(fraud_flag) * 100.0 / COUNT(*), 4) AS fraud_rate_percent
FROM upi_transactions
GROUP BY day_type;


-- Q9. Fraud Rate by Day of Week
SELECT day_of_week,
COUNT(*) AS total_txns,
SUM(fraud_flag) AS fraud_txns,
ROUND(SUM(fraud_flag) * 100.0 / COUNT(*), 4) AS fraud_rate_percent
FROM upi_transactions
GROUP BY day_of_week
ORDER BY FIELD(day_of_week, 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');


-- Q10. Fraud Rate by Device Type
SELECT device_type,
COUNT(*) AS total_txns,
SUM(fraud_flag) AS fraud_txns,
ROUND(SUM(fraud_flag) * 100.0 / COUNT(*), 4) AS fraud_rate_percent
FROM upi_transactions
GROUP BY device_type
ORDER BY fraud_rate_percent DESC;


-- Q11. Fraud Rate by Network Type
SELECT network_type,
    COUNT(*) AS total_txns,
    SUM(fraud_flag) AS fraud_txns,
    ROUND(SUM(fraud_flag) * 100.0 / COUNT(*), 4) AS fraud_rate_percent
FROM upi_transactions
GROUP BY network_type
ORDER BY fraud_rate_percent DESC;


-- Q12. Fraud Rate by Sender Age Group
SELECT sender_age_group,
    COUNT(*) AS total_txns,
    SUM(fraud_flag) AS fraud_txns,
    ROUND(SUM(fraud_flag) * 100.0 / COUNT(*), 4) AS fraud_rate_percent
FROM upi_transactions
GROUP BY sender_age_group
ORDER BY FIELD(sender_age_group, '18-25','26-35','36-45','46-55','56+');


-- Q13. High-Value Transaction Analysis (Above ₹10,000)
SELECT
    CASE WHEN amount_inr > 10000 THEN 'High Value (>10K)'
         ELSE 'Normal Value (<=10K)' END AS value_segment,
    COUNT(*) AS total_txns,
    SUM(fraud_flag) AS fraud_txns,
    ROUND(SUM(fraud_flag) * 100.0 / COUNT(*), 4) AS fraud_rate_percent,
    ROUND(AVG(amount_inr), 2)  AS avg_amount_inr
FROM upi_transactions
GROUP BY value_segment;


-- Q14. Amount Distribution Statistics for Fraud vs Legitimate
SELECT 'Legitimate' AS segment,
COUNT(*) AS txn_count,
MIN(amount_inr) AS min_amount,
ROUND(AVG(amount_inr), 2) AS avg_amount,
MAX(amount_inr) AS max_amount,
ROUND(STDDEV(amount_inr), 2) AS stddev_amount
FROM upi_transactions
WHERE fraud_flag = 0
UNION ALL
SELECT 'Fraud' AS segment,
COUNT(*),
MIN(amount_inr),
ROUND(AVG(amount_inr), 2),
MAX(amount_inr),
ROUND(STDDEV(amount_inr), 2)
FROM upi_transactions
WHERE fraud_flag = 1;


-- Q15. Monthly Fraud Trend (Time Series)
SELECT
    DATE_FORMAT(txn_timestamp, '%Y-%m') AS txn_month,
    COUNT(*) AS total_txns,
    SUM(fraud_flag) AS fraud_txns,
    ROUND(SUM(fraud_flag) * 100.0 / COUNT(*), 4) AS fraud_rate_percent,
    SUM(amount_inr) AS total_value_inr
FROM upi_transactions
GROUP BY txn_month
ORDER BY txn_month;


-- Q16. Top 10 Riskiest (Sender Bank → Receiver Bank) Pairs
SELECT sender_bank, receiver_bank,
    COUNT(*) AS total_txns,
    SUM(fraud_flag) AS fraud_txns,
    ROUND(SUM(fraud_flag) * 100.0 / COUNT(*), 4) AS fraud_rate_percent
FROM upi_transactions
GROUP BY sender_bank, receiver_bank
HAVING COUNT(*) >= 100          -- ignore statistically insignificant pairs
ORDER BY fraud_rate_percent DESC
LIMIT 10;


-- Q17. Failed Transaction Rate by Merchant Category
SELECT merchant_category,
    COUNT(*) AS total_txns,
    SUM(CASE WHEN transaction_status = 'FAILED' THEN 1 ELSE 0 END) AS failed_txns,
    ROUND(SUM(CASE WHEN transaction_status = 'FAILED' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS failure_rate_percent
FROM upi_transactions
GROUP BY merchant_category
ORDER BY failure_rate_percent DESC;


-- Q18. Top 5 States by Total Transaction Value (Business Volume View)
SELECT sender_state,
    COUNT(*) AS total_txns,
    SUM(amount_inr) AS total_value_inr,
    ROUND(AVG(amount_inr), 2) AS avg_txn_value_inr
FROM upi_transactions
GROUP BY sender_state
ORDER BY total_value_inr DESC
LIMIT 5;


-- Q19. Window Function — Rank Merchant Categories by Fraud Rate
SELECT
    merchant_category,
    fraud_txns,
    total_txns,
    fraud_rate_percent,
    RANK() OVER (ORDER BY fraud_rate_percent DESC) AS fraud_rank,
    ROUND(SUM(fraud_txns) OVER (ORDER BY fraud_rate_percent DESC
          ROWS UNBOUNDED PRECEDING), 0) AS running_fraud_total
FROM (
    SELECT
        merchant_category,
        COUNT(*) AS total_txns,
        SUM(fraud_flag) AS fraud_txns,
        ROUND(SUM(fraud_flag) * 100.0 / COUNT(*), 4) AS fraud_rate_percent
    FROM upi_transactions
    GROUP BY merchant_category
) AS category_stats
ORDER BY fraud_rank;


-- Q20. Risk Score Segmentation — Multi-Factor CASE Logic
SELECT
    CASE
        WHEN amount_inr > 10000
             AND (hour_of_day >= 22 OR hour_of_day <= 5)
             AND sender_bank != receiver_bank
            THEN 'High Risk'
        WHEN amount_inr > 10000
             OR (hour_of_day >= 22 OR hour_of_day <= 5)
            THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS rule_based_risk_tier,
    COUNT(*) AS total_txns,
    SUM(fraud_flag) AS actual_fraud_txns,
    ROUND(SUM(fraud_flag) * 100.0 / COUNT(*), 4) AS actual_fraud_rate_percent
FROM upi_transactions
GROUP BY rule_based_risk_tier
ORDER BY actual_fraud_rate_percent DESC;


-- Q21. Call the Stored Procedure (from Module 1 schema file)
CALL sp_fraud_summary();


-- Q22. Query Using the Views (demonstrates view reuse)
SELECT
    COUNT(*) AS night_txns,
    SUM(fraud_flag) AS night_fraud_txns,
    ROUND(SUM(fraud_flag) * 100.0 / COUNT(*), 4) AS night_fraud_rate_percent
FROM vw_night_transactions;

