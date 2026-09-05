# Olist E-Commerce Delivery Experience Analysis

A full-lifecycle data analytics project investigating whether delivery speed causally affects customer satisfaction on Olist, a Brazilian e-commerce marketplace, using PostgreSQL, Python, Excel, and Tableau, with a quasi-experimental causal inference design at its core.

**[Interactive Tableau Dashboard](./Tableau%20Dashboard%20Olist.twb)** · **[Executive Summary (Excel)](./olist_executive_summary.xlsx)** · **[Detailed Phase Reports](./phase%20reports)**

---

## The Business Question

E-commerce platforms tend to assume faster delivery drives satisfaction, but naive comparisons confound delivery speed with product category, seller quality, distance, and order value. This project asks:

> **Does delivery speed have a genuine causal effect on customer satisfaction, or is the relationship fully explained by confounding factors?**

And a follow-up with direct business implications:

> **Which specific, actionable levers (seller performance, order complexity, expectation management) should the business prioritize?**

---

## Key Findings

| Finding | Detail |
|---|---|
| **Delivery speed is causal, not just correlated** | After controlling for 20+ confounders (category, region, distance, order value), each additional delivery day reduces the odds of a higher review score by **5.2%** |
| **Lateness matters more than raw speed** | A late order has **72.7% lower odds** of a higher review score than an on-time one (95% CI: 71.1-74.3%), independent of how many days delivery took. This is an expectation-management effect, not simply "faster is better" |
| **One top seller is a named business risk** | The platform's 5th-highest-revenue seller ($186.5K, 976 orders) scores a 3.35 average review, well below the ~4.1-4.2 norm |
| **Order complexity independently hurts satisfaction** | More items per order predicts lower satisfaction even controlling for order value, likely a partial-shipment/damage risk |
| **About 90% of customers are one-time buyers** | Traditional RFM loyalty segmentation is a weak lens here; first-purchase experience quality matters more than loyalty tiers |
| **Satisfaction dips track seasonal delivery strain** | Review scores dip in step with late-delivery spikes around September and December, consistent with holiday shipping strain |

### Statistical Rigor

A key methodological question in this project was whether `delivery_days` and `is_late` could safely coexist as independent predictors in the regression, given how correlated they are at the extremes. Rather than assuming, this was tested through a staged diagnostic pipeline:

1. **Correlation screening** (Phase 3): `delivery_days` and `is_late` correlated at 0.59, moderate but not severe on its own.
2. **Formal VIF testing** (Phase 4): Variance Inflation Factor computed for every continuous predictor. All scores fell between 1.2 and 1.9, well under the 5.0 caution threshold, confirming no meaningful multicollinearity.
3. **Likelihood ratio test** (Phase 5): compared the full regression model against a reduced model with `delivery_days` and `is_late` removed entirely. Removing them worsened the model's log-likelihood from -104,877.1 to -110,563.9, producing a likelihood ratio statistic of 11,373.6 (df=2, p<0.001), an unambiguous confirmation that these variables contribute real explanatory power beyond the confounders alone.
4. **Non-parametric confirmation**: Mann-Whitney U and Kruskal-Wallis tests, which make no assumption about the shape of the distribution (review scores are heavily left-skewed), independently corroborated the regression's findings.
5. **Multiple comparisons correction**: when testing whether delivery speed's effect varied by product category (15 simultaneous interaction tests), a Bonferroni-corrected threshold was applied rather than reading raw p-values at face value, avoiding a false-positive conclusion.

Full methodology and reasoning for every decision, including the ones that turned out to *not* be a problem, is documented in the **[phase reports](./phase%20reports)**.

---

## Methodology Overview

| Phase | What Was Done | Tools |
|---|---|---|
| **0-1: Data Setup & Validation** | Loaded 9 relational tables into PostgreSQL, enforced foreign key constraints, validated referential integrity (zero orphaned keys), handled real data quality issues (mislabeled statuses, duplicate reviews, missing categories) | PostgreSQL |
| **2: SQL Feature Engineering** | Built feature views using CTEs, window functions (`NTILE`, `RANK`), and self-joins for RFM segmentation, repeat-purchase cohort analysis, seller leaderboards, and category/region summaries | SQL |
| **3: Exploratory Data Analysis** | Diagnosed review score skew, identified MNAR missingness (non-delivered orders systematically excluded), built the confounder correlation matrix | Python (pandas, matplotlib, seaborn) |
| **4: Causal Analysis** | Engineered a geospatial distance confounder using the Haversine formula, fit an ordinal logistic regression, tested category-level effect variation with correct multiple-comparisons correction | Python (statsmodels) |
| **5: Statistical Inference** | 95% confidence intervals on all key coefficients, Mann-Whitney U and Kruskal-Wallis non-parametric tests, and a likelihood ratio test (comparing full vs. reduced model log-likelihood) to formally confirm the causal variables' significance | Python (scipy, statsmodels) |
| **6: Executive Summary** | Formula-driven KPI dashboard translating statistical findings into stakeholder-ready recommendations | Excel |
| **7: Interactive Dashboard** | Live-connected geographic map, category/region heatmap, seasonal trend analysis, and seller-risk scatter plot | Tableau |

---

## Repository Structure

```
├── phase0_data_import.sql                                          # Schema + data load
├── phase1_data_validation_checks.sql                               # Orphan/null/duplicate checks
├── phase1_naive_baseline_review_score_by_delivery_speed.sql        # Unadjusted baseline
├── phase2_views.sql                                                 # Core feature views
├── phase2_REPEAT-PURCHASE RATE BY FIRST-ORDER DELIVERY EXPERIENCE.sql
├── distance.sql / phase4_distance.sql                              # Haversine distance confounder
├── add order purchase timestamp.sql                                # Schema patch for time-trend analysis
├── phase3_eda.ipynb                                                # Exploratory data analysis
├── phase4_causal_analysis.ipynb                                    # Ordinal logistic regression
├── phase5_statistical_inference.ipynb                              # CIs, non-parametric tests, LR test
├── 12_tableau_export.sql                                           # Export queries for BI tools
├── olist_executive_summary.xlsx                                    # Excel stakeholder summary
├── excel summary 1.jpg, excel summary 2.jpg                        # Summary screenshots
├── Tableau Dashboard Olist.twb                                     # Interactive dashboard
├── tableau dashboard photo.jpg                                     # Dashboard screenshot
└── phase reports/                                                  # Detailed write-up per phase
```

---

## Dataset

[Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle), about 99K real orders from 2016 to 2018, across customers, orders, products, sellers, payments, and reviews.

## Tech Stack

**PostgreSQL** (CTEs, window functions, self-joins), **Python** (pandas, statsmodels, scipy), **Excel**, **Tableau**

---

## Author

**Surur Khan** 
