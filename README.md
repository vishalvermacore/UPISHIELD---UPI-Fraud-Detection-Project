<div align="center">

# 🛡️ UPISHIELD
### UPI Fraud Detection & Risk Intelligence

*A complete data pipeline — from raw transaction logs to a tested, explainable fraud model — built on 250,000 real-world-style UPI transactions.*

![Python](https://img.shields.io/badge/Python-3.10-3776AB?style=flat-square&logo=python&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-Database-4479A1?style=flat-square&logo=mysql&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-Data%20Wrangling-150458?style=flat-square&logo=pandas&logoColor=white)
![Scikit-learn](https://img.shields.io/badge/Scikit--learn-ML-F7931E?style=flat-square&logo=scikitlearn&logoColor=white)
![XGBoost](https://img.shields.io/badge/XGBoost-Modeling-EB5E28?style=flat-square)
![SHAP](https://img.shields.io/badge/SHAP-Explainability-8A2BE2?style=flat-square)
![Status](https://img.shields.io/badge/Status-Complete-2E86AB?style=flat-square)

</div>

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [The Business Problem](#the-business-problem)
3. [Methodology](#methodology)
4. [Skills Demonstrated](#skills-demonstrated)
5. [Results & Recommendation](#results--recommendation)
6. [Next Steps](#next-steps)
7. [Project Structure](#project-structure)
8. [How to Run This Project](#how-to-run-this-project)

---

## Executive Summary

This project builds a full fraud-detection pipeline for UPI transactions — a relational database in MySQL, exploratory analysis, engineered risk features, and three machine learning models culminating in a tuned XGBoost classifier with SHAP-based explainability.

Along the way, the analysis took an unplanned but important turn. Before trusting any model output, the features were tested statistically against the fraud label — and none held up. Rather than reporting an inflated accuracy score (a model that simply predicts "not fraud" every time would already be 99.8% "accurate" on this data), the finding was reported honestly, and a second, controlled experiment was run to confirm the *pipeline itself* was sound — by testing it against a fraud pattern designed and labeled in advance. It worked exactly as expected.

That distinction — between a model that performs well and a model that's been properly *validated* — is the core contribution of this project. It's a small thing on the surface, and a significant one in practice: production fraud systems get shipped on the back of exactly this kind of due diligence, or fail because of its absence.

## The Business Problem

UPI now carries the majority of India's digital retail payment volume, and fraud on the network — while a small percentage of total transactions — represents a meaningful and growing cost to banks, payment processors, and customers. A fraud-detection system needs to do two things well: catch as much real fraud as possible, and avoid flagging so many genuine transactions that customers lose trust in the platform.

The dataset used here reflects the central difficulty of this problem in practice: out of 250,000 transactions, only 480 — roughly 0.19% — are labeled fraudulent. Any modeling approach that doesn't directly account for this imbalance will default to a model that's technically accurate and practically useless. The brief, then, wasn't just "predict fraud" — it was "build a process that would hold up to scrutiny by a risk team that has seen accuracy numbers be misleading before."

## Methodology

The project was built in four stages, each one feeding into the next.

**1. Database design (MySQL).** The raw transaction data was modeled into a relational schema with appropriate types, indexes for the query patterns expected later (fraud rate by state, by bank, by hour), and a set of 22 business-facing SQL queries — the kind a risk analyst would actually ask of this data, from cross-bank fraud comparisons to a rule-based risk-tier baseline.

**2. Exploratory analysis (Python).** Every categorical and numerical field was examined against the fraud label — transaction type, merchant category, amount, time of day, geography, device, and network — with the goal of identifying which factors, if any, separated fraudulent transactions from legitimate ones.

**3. Feature engineering.** The patterns observed in the EDA were translated into model-ready columns: a high-amount flag, a log-transformed and z-scored amount, night and late-night time windows, a same-bank/cross-bank flag, and a round-number flag (a known heuristic in real fraud detection, where automated transfers tend to use clean amounts).

**4. Modeling and validation.** Before any model was trained, a chi-square test and correlation analysis checked whether the engineered features actually related to the fraud label. They didn't, consistently, across every test. Three models — Logistic Regression, Random Forest, and a tuned XGBoost (via `RandomizedSearchCV` with `imblearn`-pipelined SMOTE inside Stratified K-Fold cross-validation) — were trained and evaluated regardless, all landing at the same near-random performance, which ruled out "unlucky split" or "wrong model choice" as explanations. To separate "bad data" from "bad pipeline," a synthetic fraud label was then constructed from a known, designed rule, and run through the identical pipeline — where it performed well, with SHAP confirming the model had learned exactly the rule it was given.

## Skills Demonstrated

**Database & SQL** — schema design, indexing strategy, views, a stored procedure, and 22 business queries covering aggregate analysis, window functions, and multi-table risk segmentation.

**Data analysis** — structured EDA workflow, data quality auditing, and a habit of validating visual patterns with formal statistical tests (chi-square, point-biserial correlation) rather than eyeballing percentage differences.

**Feature engineering** — translating exploratory findings into model inputs, with explicit attention to data leakage (recalculating distribution-based features like z-scores only on training data once a real model is being evaluated).

**Machine learning** — `ColumnTransformer` and `Pipeline`-based preprocessing, `imblearn`-integrated SMOTE for class imbalance, Stratified K-Fold cross-validation, hyperparameter tuning with `RandomizedSearchCV`, and evaluation built around Precision-Recall AUC rather than accuracy.

**Model explainability** — SHAP value analysis used both to interpret individual predictions and, in this case, as a diagnostic tool to confirm what a model had and hadn't actually learned.

**Applied judgment** — recognizing when a result needs to be questioned rather than reported, and designing a controlled experiment to isolate the cause.

## Results & Recommendation

| Check | Real fraud_flag | Synthetic fraud_flag (controlled test) |
|---|---|---|
| Statistical significance (chi-square / correlation) | Not significant on any feature | Significant by design |
| Cross-validation PR-AUC | ~0.002 (baseline) | 0.18 (≈10x baseline) |
| ROC-AUC | ~0.51 (random) | 0.74 |
| SHAP top features | No consistent leader | The 4 designed risk factors, in order |

**The finding:** with the transaction-level attributes available in this dataset, fraud cannot be reliably predicted — and that conclusion is now well-supported, not assumed. **The recommendation:** the modeling pipeline built here is ready to use; what's missing is data with real predictive signal. In a production setting, that would mean pushing for behavioral features (is this amount unusual for *this specific customer*, not the population average), device and session fingerprinting, and account-level relationship data — the categories of feature that real-world fraud systems lean on most heavily, and that static, per-transaction fields like the ones available here generally can't substitute for.

## Next Steps

- **Richer feature requests** — behavioral/historical features per customer, device and IP signals, and graph-based features describing relationships between accounts.
- **Deployment packaging** — the trained pipeline is already serialized with `joblib`; the next step would be wrapping it behind a lightweight API for real-time scoring.
- **Monitoring** — in production, a model like this would need ongoing drift monitoring, since fraud patterns shift over time in ways a static, one-time training run can't capture.
- **Threshold governance** — formalizing the precision/recall trade-off explored in this project into an actual business policy, owned jointly by risk and product teams rather than left as a default model setting.

## Project Structure

```
UPISHIELD/
├── data/
│   ├── upi_transactions_2024.csv          # raw dataset
│   └── upi_transactions_features.csv      # after feature engineering
├── mysql_database/
│   ├── schema_design.sql                  # database schema, indexes, views
│   ├── business_queries.sql               # 22 business-facing SQL queries
│   └── Data_loading.ipynb                 # CSV -> MySQL loader
├── notebook/
│   ├── EDA_fraud_analysis.ipynb           # exploratory analysis
│   ├── Feature_engineering.ipynb          # feature creation
│   ├── ML_model.ipynb                     # modeling, diagnosis, validation experiment
│   ├── fraud_model.pkl                    # saved model
│   └── fraud_preprocessor.pkl             # saved preprocessing pipeline
└── README.md
```

## How to Run This Project

1. **Database:** run `mysql_database/schema_design.sql` in MySQL Workbench, then run `Data_loading.ipynb` to load the dataset (update the credentials placeholder first), then explore with `business_queries.sql`.
2. **Analysis:** open the notebooks in `notebook/` in order — `EDA_fraud_analysis.ipynb` → `Feature_engineering.ipynb` → `ML_model.ipynb`. Each is self-contained and already shows its own output.
3. **Requirements:** `pandas`, `numpy`, `matplotlib`, `seaborn`, `scikit-learn`, `imbalanced-learn`, `xgboost`, `shap`, `joblib`, `mysql-connector-python`, `sqlalchemy`, `pymysql`.

---

<div align="center">

*Built as part of a data analytics & machine learning portfolio.*

</div>
