# 🛒 Olist Store Data Analysis | PostgreSQL & Power BI

## Project Overview

An end-to-end analysis of Olist e-commerce data covering order patterns, payment behaviour, delivery performance, and customer satisfaction. Data was loaded and analysed in PostgreSQL and visualised in Power BI.

| | |
|---|---|
| **Dataset** | Olist E-Commerce Dataset (9 CSV files), provided by the ExcelR Bootcamp program |
| **Context** | Five business questions assigned in the ExcelR Project Bootcamp |
| **Tools** | PostgreSQL (loading, validation, queries) and Power BI (dashboard) |

---

## Business Questions & Results

| KPI | Business Question | Result |
|:---:|---|---|
| 1 | Share of orders on weekdays vs weekends | **77.26%** weekday, **22.74%** weekend |
| 2 | 5-star orders paid by credit card | **43,981** orders |
| 3 | Average delivery days for Pet Shop orders | **10.91** days |
| 4 | Average price vs payment value (São Paulo) | **108** vs **136** |
| 5 | Shipping days vs review score | **~21** days (1-star) to **~10** days (5-star) |

![Olist Dashboard](Olist%20dashboard.png)


---

## Key Insights

- **Weekdays dominate:** about 77% of orders are placed on weekdays.
- **Credit cards lead among happy customers:** among 5-star orders, credit card is the top payment type (~44K), followed by boleto (~11K).
- **Faster delivery means happier customers:** shipping days fall steadily as review scores rise. Late orders averaged a review score of **2.57** vs **4.29** for on-time orders (from SQL analysis).
- **São Paulo payments exceed item price:** average payment value (136) is higher than average item price (108), likely reflecting freight and other add-ons.

---

## Recommendations

- **Prioritise on-time delivery.** It is the clearest lever for improving review scores.
- **Keep credit card payments prominent,** since they are preferred by the most satisfied customers.

---

## Data Checks & Validation

- Verified row counts across loaded tables
- Reviewed order status distribution and percentages
- Handled multiple reviews and payment types per order to prevent join fan-out and inflated counts
- Checked for missing delivery dates before calculating delivery metrics

---

## My Contribution

- Loaded and managed all 9 CSV files in PostgreSQL
- Performed data quality checks and validation
- Wrote SQL queries to answer all five business questions
- Designed and built the interactive Power BI dashboard
- Turned results into business insights and recommendations

---

## Repository Structure

```text
├── sql/        # SQL queries for the five business questions
├── images/     # Dashboard screenshot
└── README.md
```
