# Tibafya Healthcare Commercial Revenue & Regional Margins Dashboard

## Business Problem

Commercial sales directors could not monitor changing margins or active account metrics across facilities on demand. Raw records were locked in database tables, creating a heavy manual reporting burden and hiding where discounting was quietly eroding profit.

## Business Insight

From 483 total transactions, **430 passed data quality checks** (53 excluded). At first glance, performance looks healthy: **30.07% gross margin** and **KES 12,865,041.01 total revenue**. But a flat revenue view hides a real problem underneath.

**Discounting is eroding 6.92% of potential revenue (about KES 956,999)**, and it is not evenly spread:

| County | Revenue (KES) | Discount Leakage % | Gross Margin % |
|---|---|---|---|
| Nairobi | 2,265,423.62 | **9.04%** | 28.74% |
| Nakuru | 2,706,519.95 | 7.80% | 29.15% |
| Uasin Gishu | 2,891,181.13 | 6.44% | 30.30% |
| Kisumu | 2,753,903.28 | 6.40% | 30.56% |
| Mombasa | 2,248,013.03 | **4.88%** | 31.64% |

Nairobi has nearly double the discount rate of Mombasa, even though neither is the highest- or lowest-revenue county. A simple revenue-by-county chart would not show this.

**Segment view** confirms the same pattern from a different angle. Pharmacy has the lowest margin (28.82%) of the three client segments. Among clean transactions, **15 (3.5%) were sold at a genuine loss** (discounted below cost), concentrated in Kisumu, Nakuru, Private Hospital, and Pharmacy.

**Trend:** Q2 revenue fell **13.1%** compared to Q1 (KES 5.98M vs. 6.88M), driven by a sharp drop in April before partial recovery in May and June.

**Recommendation:** Review Nairobi's discount approval process before Q3 planning. It is the single largest source of margin leakage, not the highest-revenue county alone. Pharmacy segment discounting also needs closer review given its already thin baseline margin.

## Data Quality & Governance

An automated data quality (QC) layer flagged **53 of 483 transactions (11.0%)** across four defect types before any metric was calculated. Every excluded transaction is logged with its transaction ID and reason.

| Defect type | Count |
|---|---|
| Quantity outlier (>400 units — likely entry error) | 17 |
| Zero price (system glitch or free-sample miscode) | 13 |
| Price above list (data entry error) | 12 |
| Negative quantity (sign error) | 11 |

Full audit trail: `outputs/sales_audit_log.csv`.

Excessive discounting (>25% off list) was deliberately **not** treated as a QC defect. It is a real business signal, not a data error, and stays in the analysis to power the leakage metrics above.

## Data Governance Note

This dataset uses only numeric `client_key` values and no institution names. With small sample sizes per county and segment, a specific combination (for example, a single Pharmacy client in a low-volume county) could still be re-identifiable.

Any breakdown shared outside the immediate sales team should suppress cells representing fewer than 3 distinct clients, consistent with the Kenya Data Protection Act (2019) minimization principle.

## Repository Structure

```text
tibafya-revenue-margins-dashboard/
├── README.md
├── schema_sales.sql
├── load_sales_data.py
├── requirements.txt
├── .env            # gitignored
├── .gitignore
├── data/
│   ├── sales_products.csv
│   ├── sales_clients.csv
│   └── sales_raw.csv
├── notebooks/
│   └── revenue_margins_analysis.ipynb
├── outputs/
│   ├── clean_sales.csv
│   └── sales_audit_log.csv
└── dashboard/
    ├── revenue_margins_dashboard.pbix
    └── dashboard_screenshot.png
```

## How to Run

```bash
pip install -r requirements.txt

# 1. Run schema_sales.sql in your MySQL instance
# 2. Set your own credentials in .env
python load_sales_data.py

# 3. Open notebooks/revenue_margins_analysis.ipynb and Restart & Run All
#    -> produces outputs/clean_sales.csv and outputs/sales_audit_log.csv

# 4. Open dashboard/revenue_margins_dashboard.pbix in Power BI Desktop
#    Get Data -> dim_products, dim_clients (MySQL); clean_sales, sales_audit_log (CSV)
```

## Reproducibility

Every DAX measure in the Power BI model was independently verified against pandas output before being built. Total Revenue, Gross Margin %, Discount Leakage %, and all county and segment breakdowns matched to the cent between the two tools. This confirms the analysis logic rather than trusting either implementation alone.

## Stack

MySQL (dimension tables) -> SQLAlchemy + PyMySQL (load/extract) -> pandas (QC, metrics) -> CSV handoff -> Power BI + DAX (dashboard)

<img width="1582" height="882" alt="image" src="https://github.com/user-attachments/assets/7d051529-5f67-4b06-af34-1d156338104f" />
