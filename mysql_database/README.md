# Module 1 — MySQL Database Layer

### India Digital Payments Fraud Intelligence & Transaction Risk Scoring Platform

This module sets up the relational database foundation for the entire project. Power BI will connect directly to this MySQL database.

---

## 📁 Files in This Module

| File                   | Purpose                                                                    |
| ---------------------- | -------------------------------------------------------------------------- |
| `schema_design.sql`    | Creates the database, table, indexes, views, and a stored procedure        |
| `Data_loading.ipynb`   | Python script (Jupyter-cell format) that loads the 250K-row CSV into MySQL |
| `business_queries.sql` | 22 business-focused SQL queries answering real fraud-analytics questions   |

---

## 🚀 Setup Steps (Do These In Order)

### Step 1 — Install MySQL (if not already installed)

- Download MySQL Community Server: https://dev.mysql.com/downloads/mysql/
- During setup, set a root password and **remember it** — you'll need it in Step 3.

### Step 2 — Create the Schema

Open **MySQL Workbench** (or any MySQL client), connect to your local server, and run:

```sql
SOURCE schema_design.sql;
```

This creates:

- Database: `upi_fraud_db`
- Table: `upi_transactions` (17 columns, with `ENUM` types for data integrity)
- 7 indexes (for fast fraud/state/bank/time queries)
- 4 views (`vw_fraud_only`, `vw_success_only`, `vw_high_value`, `vw_night_transactions`)
- 1 stored procedure (`sp_fraud_summary`)

Verify it worked — you should see the table structure printed at the end.

### Step 3 — Load the Data (Python)

1. Open Jupyter Notebook.
2. Copy each `# ── CELL N ──` section from `Data_loading.ipynb` into its own notebook cell, in order.
3. **Edit Cell 2** — update `DB_CONFIG['password']` with your actual MySQL root password.
4. **Edit Cell 2** — make sure `CSV_PATH` points to your `..data/upi_transactions_2024.csv` location.
5. Run cells 1 → 7 in order. Cell 6 (the actual load) takes ~30–90 seconds for 250K rows.
6. Cell 7 verifies the row count in MySQL matches your CSV (250,000 rows) and shows the fraud distribution.

⚠️ **Important:** Only run Cell 6 once. If you re-run it, you'll get duplicate rows (the `transaction_id` PRIMARY KEY will actually reject duplicates and throw an error — which is a _good_ thing, it means your schema's constraint is working).

### Step 4 — Run the Business Queries

Back in MySQL Workbench:

```sql
SOURCE business_queries.sql;
```

Run each query one at a time (highlight + Ctrl+Enter in Workbench) and look at the results. Take screenshots of the most interesting outputs (Q1, Q6, Q7, Q19, Q20) for your GitHub README / portfolio writeup.

---

## 🎯 Interview Talking Points for This Module

Be ready to explain these out loud, in your own words:

1. **Why ENUM instead of VARCHAR for categorical columns?**
   ENUMs are stored as 1-byte integers internally, enforce data integrity at the database level (can't insert "Andhra" if the column only allows "Andhra Pradesh"), and self-document valid values.

2. **Why did you create indexes on `fraud_flag`, `sender_state`, etc.?**
   Without an index, MySQL does a full table scan (250K row reads) for every filtered query. An index creates a B-tree structure so the database can jump straight to matching rows — turning an O(n) scan into roughly O(log n) lookup.

3. **What's the difference between `WHERE` and `HAVING`?** (Q16 in business queries)
   `WHERE` filters individual rows _before_ grouping. `HAVING` filters _after_ `GROUP BY` aggregation — e.g., "only show bank pairs with 100+ transactions."

4. **Why use chunked inserts instead of loading all 250K rows at once?**
   Prevents memory overload and connection timeouts; if a failure happens mid-load, you know exactly which chunk failed instead of losing the whole batch.

5. **Why is the 0.19% fraud rate a big deal?**
   It's severe class imbalance. A naive model predicting "always legitimate" would be 99.8% accurate but catch zero fraud. This is why Module 4 uses SMOTE, class weighting, and judges the model on Precision/Recall/F1/AUC-PR — **never** plain accuracy.

6. **What's a window function and where did you use one?** (Q19)
   Window functions (`RANK() OVER (...)`) compute values across a set of rows related to the current row _without collapsing them into one row_, unlike `GROUP BY`. Used here to rank merchant categories by fraud rate while still keeping per-category detail.

7. **What did the rule-based risk score (Q20) teach you?**
   It's a baseline. By comparing this simple `CASE WHEN` rule's fraud-catch rate against the ML model's performance in Module 4, you can quantify exactly how much value the machine learning model adds over basic business rules — a number every interviewer loves hearing.

---

## Completion Checklist

- [ ] MySQL database `upi_fraud_db` created
- [ ] Table `upi_transactions` created with correct ENUM/data types
- [ ] All 7 indexes created
- [ ] All 4 views created
- [ ] Stored procedure `sp_fraud_summary` created
- [ ] 250,000 rows loaded and verified (row count matches CSV)
- [ ] fraud_flag distribution confirmed (~480 fraud / 250,000 total)
- [ ] All 22 business queries run successfully with results reviewed
- [ ] Screenshots saved for portfolio/README
