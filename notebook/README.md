# `notebook/` — Python Analysis & Modeling

### India Digital Payments Fraud Intelligence & Transaction Risk Scoring Platform

This folder contains all the Python/Jupyter work for the project, in the order they should be run:

```
notebook/
├── EDA_fraud_analysis.ipynb       ← Module 2: Exploratory Data Analysis (DONE)
├── Feature_engineering.ipynb      ← Module 3: Feature Engineering (next)
├── ML_model.ipynb                 ← Module 4: ML Modeling (after that)
└── README.md                      ← You are here
```

---

## 1. `EDA_fraud_analysis.ipynb` — Module 2 ✅

A fully executed notebook (charts already rendered — opens correctly on GitHub without re-running) covering:

1. Data loading & quality checks (nulls, duplicates, dtypes)
2. Target variable (`fraud_flag`) distribution — the class imbalance problem
3. Transaction type analysis
4. Merchant category analysis
5. Transaction amount analysis (distribution + high-value segment)
6. Time-based patterns (hour of day, day of week, weekend, monthly trend)
7. Geographic & banking patterns (state, bank, same-bank vs cross-bank)
8. Device, network, and age group patterns
9. Correlation heatmap
10. A summary table mapping every EDA finding → a Module 3 feature to engineer

**Strongest finding:** transactions above ₹10,000 have a fraud rate of 0.33% vs 0.19% baseline — about 1.7x higher risk. This is the clearest single signal in the entire dataset, and it directly feeds into the `is_high_amount` feature built in Module 3.

**How to run:** open in Jupyter/VS Code, point the CSV path in the first code cell to `../data/upi_transactions_2024.csv` (relative to this folder), then Kernel → Restart & Run All if you want to regenerate the charts yourself.

---

## 2. `Feature_engineering.ipynb` — Module 3 🔜

Will build the engineered features identified during EDA:

| Feature                      | Why (from EDA)                                             |
| ---------------------------- | ---------------------------------------------------------- |
| `is_high_amount`             | Amounts >₹10K are ~1.7x riskier — strongest EDA signal     |
| `amount_zscore`              | Fraud has higher variance/outliers than legitimate amounts |
| `is_night` / `is_late_night` | 3 AM hour spikes to 0.30% fraud rate                       |
| `is_same_bank`               | Cross-bank transfers showed slightly higher fraud rate     |
| Encoded categoricals         | `sender_state`, `sender_bank`, etc. prepared for ML input  |

---

## 3. `ML_model.ipynb` — Module 4 🔜

Will build: Logistic Regression baseline → Random Forest → XGBoost final model, with SMOTE for the 0.19% class imbalance, and SHAP for explainability.

---

## 🎯 Interview Talking Points (Module 2 — EDA)

1. **"Walk me through your EDA process."**
   Data quality first (nulls/duplicates/dtypes) → understand the target variable and its imbalance → univariate analysis on each feature → bivariate analysis (feature vs fraud_flag) → correlation check → summarize findings into a feature engineering plan.

2. **"What was the hardest part of EDA on this dataset?"**
   The extreme class imbalance (0.19% fraud) means every chart needs rate-based comparisons (percentages) instead of raw counts, plus log scales where raw counts must be shown — otherwise fraud is statistically invisible.

3. **"Did you find any surprising patterns?"**
   Cross-bank transfers showed a slightly _higher_ fraud rate than same-bank transfers — counter to the common assumption that cross-bank adds more verification friction and should be safer.

4. **"How does this EDA connect to your feature engineering?"**
   Directly — see the summary table at the end of `EDA_fraud_analysis.ipynb`. Every row maps an EDA finding to a specific engineered feature built in `Feature_engineering.ipynb`.

---

## ✅ Module 2 Completion Checklist

- [ ] Notebook opens and all 11 charts display correctly
- [ ] Read every business observation — able to restate each in your own words
- [ ] Understand why accuracy is the wrong metric here (class imbalance)
- [ ] Can explain the high-value transaction finding without looking at notes
- [ ] Reviewed the summary table — it's the roadmap for Module 3

**Next →** Open `Feature_engineering.ipynb` and start Module 3.
