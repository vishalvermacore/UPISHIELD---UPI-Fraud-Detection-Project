-- PROJECT  : India Digital Payments Fraud Intelligence Platform
-- MODULE   : MySQL Schema Design
-- Author   : [Vishal Verma]
-- Dataset  : upi_transactions_2024.csv (250,000 rows, 17 columns)
-- Purpose  : Define the database structure to store and query UPI transaction data for fraud analysis

-- STEP 1: Create & select the database

DROP DATABASE IF EXISTS upi_fraud_db;
CREATE DATABASE upi_fraud_db
    CHARACTER SET utf8mb4          -- supports all Unicode (emojis, ₹ symbol etc.)
    COLLATE utf8mb4_unicode_ci;    -- case-insensitive string comparisons

USE upi_fraud_db;


-- STEP 2: Main Transactions Table

CREATE TABLE upi_transactions (
transaction_id      VARCHAR(15)     NOT NULL,
txn_timestamp       DATETIME        NOT NULL,
hour_of_day         TINYINT UNSIGNED NOT NULL,
day_of_week         ENUM('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday') NOT NULL,
is_weekend          TINYINT(1)      NOT NULL DEFAULT 0,
transaction_type    ENUM('P2P','P2M','Bill Payment','Recharge') NOT NULL,
merchant_category   ENUM('Grocery','Food','Shopping','Fuel','Transport','Entertainment','Utilities','Healthcare','Education','Other') NOT NULL,
amount_inr          MEDIUMINT UNSIGNED NOT NULL,
transaction_status  ENUM('SUCCESS','FAILED') NOT NULL,
sender_age_group    ENUM('18-25','26-35','36-45','46-55','56+') NOT NULL,
receiver_age_group  ENUM('18-25','26-35','36-45','46-55','56+') NOT NULL,
sender_state        ENUM('Maharashtra','Uttar Pradesh','Karnataka','Tamil Nadu','Delhi','Telangana','Gujarat','Andhra Pradesh','Rajasthan','West Bengal') NOT NULL,
sender_bank         ENUM('SBI','HDFC','ICICI','Axis','PNB','Kotak','IndusInd','Yes Bank') NOT NULL,
receiver_bank       ENUM('SBI','HDFC','ICICI','Axis','PNB','Kotak','IndusInd','Yes Bank') NOT NULL,
device_type         ENUM('Android','iOS','Web') NOT NULL,
network_type        ENUM('3G','4G','5G','WiFi') NOT NULL,
fraud_flag          TINYINT(1)      NOT NULL DEFAULT 0,
CONSTRAINT pk_transaction PRIMARY KEY (transaction_id)

) 
ENGINE=InnoDB                    -- supports transactions, FK, row-level locking
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci
ROW_FORMAT=COMPRESSED;           -- compresses row data — useful for 250K rows


-- Index 1: fraud_flag — most queried column
CREATE INDEX idx_fraud_flag ON upi_transactions (fraud_flag);

-- Index 2: timestamp — used for date range filters & monthly trends
CREATE INDEX idx_timestamp ON upi_transactions (txn_timestamp);

-- Index 3: sender_state — frequent GROUP BY for geographic analysis
CREATE INDEX idx_sender_state ON upi_transactions (sender_state);

-- Index 4: transaction_type — used in many business queries
CREATE INDEX idx_txn_type ON upi_transactions (transaction_type);

-- Index 5: composite (fraud_flag + sender_bank) — supports fraud-by-bank queries
CREATE INDEX idx_fraud_bank ON upi_transactions (fraud_flag, sender_bank);

-- Index 6: composite (fraud_flag + merchant_category) — fraud-by-category queries
CREATE INDEX idx_fraud_category ON upi_transactions (fraud_flag, merchant_category);

-- Index 7: hour_of_day — used in time-of-day fraud analysis
CREATE INDEX idx_hour ON upi_transactions (hour_of_day);



-- STEP 4: Useful Views (Pre-built Query Layers)


-- View 1: Only fraud transactions (used repeatedly)
CREATE OR REPLACE VIEW vw_fraud_only AS
SELECT * FROM upi_transactions WHERE fraud_flag = 1;

-- View 2: Only successful transactions (remove noise of FAILED txns)
CREATE OR REPLACE VIEW vw_success_only AS SELECT * FROM upi_transactions WHERE transaction_status = 'SUCCESS';

-- View 3: High-value transactions (above ₹10,000 — risk segment)
CREATE OR REPLACE VIEW vw_high_value AS SELECT * FROM upi_transactions WHERE amount_inr > 10000;

-- View 4: Night-time transactions (10 PM to 5 AM — high risk window)
CREATE OR REPLACE VIEW vw_night_transactions AS SELECT * FROM upi_transactions WHERE hour_of_day >= 22 OR hour_of_day <= 5;


-- STEP 5: Stored Procedure — Fraud Summary Report
-- ─────────────────────────────────────────────

DELIMITER $$

CREATE PROCEDURE sp_fraud_summary()
BEGIN
    -- Overall KPIs
    SELECT
        COUNT(*)                                        AS total_transactions,
        SUM(fraud_flag)                                 AS total_fraud_cases,
        ROUND(SUM(fraud_flag) * 100.0 / COUNT(*), 4)   AS fraud_rate_pct,
        SUM(amount_inr)                                 AS total_txn_value_inr,
        SUM(CASE WHEN fraud_flag = 1 THEN amount_inr ELSE 0 END) AS fraud_amount_inr,
        ROUND(AVG(amount_inr), 2)                       AS avg_txn_amount_inr,
        ROUND(AVG(CASE WHEN fraud_flag = 1 THEN amount_inr END), 2) AS avg_fraud_amount_inr
    FROM upi_transactions;
END$$

DELIMITER ;


-- STEP 6: Verify Schema Was Created Correctly

SHOW TABLES;
DESCRIBE upi_transactions;
SHOW INDEX FROM upi_transactions;
