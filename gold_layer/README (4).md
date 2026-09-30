# 🏦 Enterprise Data Warehouse: CRM & ERP Integration

![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?style=for-the-badge&logo=mysql&logoColor=white)
![Architecture](https://img.shields.io/badge/Architecture-Medallion_(Bronze_Silver_Gold)-green?style=for-the-badge)
![Data Modeling](https://img.shields.io/badge/Data_Model-Star_Schema-orange?style=for-the-badge)
![Analytics](https://img.shields.io/badge/Analytics-EDA_%26_Advanced_SQL-purple?style=for-the-badge)

> **End-to-End Data Engineering, Exploratory Data Analysis (EDA) and Business Intelligence Suite using MySQL and the Medallion Architecture**

---

## 📌 Project Overview

This project builds an end-to-end Data Warehousing solution designed to integrate and transform raw transactional data from two disparate source systems: **CRM** and **ERP**. Using a **Medallion Architecture (Bronze → Silver → Gold)**, the raw CSV datasets are ingested, cleansed, standardized, enriched, and modeled into an analytical **Star Schema** optimized for Business Intelligence (BI) and reporting.

On top of the warehouse, the project includes:

* an **Exploratory Data Analysis (EDA)** script that profiles the database, dimensions, dates, and key measures;
* an **Advanced SQL Analytics** suite covering sales trends, running totals, year-over-year (YoY) performance, part-to-whole analysis, product cost bucketing, and customer segmentation.

---

## 🏗 System Architecture & Data Flow

```text
       Sources                   Bronze Layer               Silver Layer              Gold Layer
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐    ┌───────────────────┐
│                     │───>│   crm_sales_details │───>│  crm_sales_details  │───>│    fact_sales     │
│                     │    ├─────────────────────┤    ├─────────────────────┤    └───────────────────┘
│       ┌───┐         │───>│    crm_cust_info    │───>│    crm_cust_info    │────┐
│       │ 📁│         │    ├─────────────────────┤    ├─────────────────────┤    │
│       └───┘         │───>│    crm_prd_info     │───>│    crm_prd_info     │──┐ │
│        CRM          │    ├─────────────────────┤    ├─────────────────────┤  │ │  ┌────────────────┐
│                     │───>│    erp_cust_az12    │───>│    erp_cust_az12    │──┼─┼─>│ dim_customers  │
│                     │    ├─────────────────────┤    ├─────────────────────┤  │ │  └────────────────┘
│       ┌───┐         │───>│    erp_loc_a101     │───>│    erp_loc_a101     │──┼─┘
│       │ 📁│         │    ├─────────────────────┤    ├─────────────────────┤  │    ┌────────────────┐
│       └───┘         │───>│   erp_px_cat_g1v2   │───>│   erp_px_cat_g1v2   │──┴───>│  dim_product   │
│        ERP          │    └─────────────────────┘    └─────────────────────┘       └────────────────┘
└─────────────────────┘
```

---

## 🛠 Medallion Architecture Layers

### 1. Bronze Layer (Raw Staging)
* **Goal:** Store source data in its original format without making structural changes.
* **Source Systems:**
  * **CRM:** `crm_cust_info`, `crm_prd_info`, `crm_sales_details`
  * **ERP:** `erp_cust_az12`, `erp_loc_a101`, `erp_px_cat_g1v2`
* **Implementation:** High-performance raw CSV loading using `LOAD DATA LOCAL INFILE`, with table truncation for idempotent re-runs.

### 2. Silver Layer (Cleansing, Standardization & Enrichment)
* **Goal:** Clean, standardize, and enrich data to build reliable intermediate models.
* **Transformations Executed:**
  * **Deduplication:** Applied `ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC)` to retain only the most recent customer records.
  * **Data Standardization:** Cleaned whitespace (`TRIM`), standardized gender codes (`M`/`F` → `Male`/`Female`), marital status (`S`/`M` → `Single`/`Married`), and country values (`US`/`USA` → `United States`, `DE` → `Germany`).
  * **Data Integrity & Derivation:** Converted raw integer dates (`YYYYMMDD`) into native `DATE` types and enforced business logic: `Sales = Quantity × ABS(Price)`.
  * **Key Extraction & Parsing:** Extracted category IDs (`cat_id`) from composite product keys (`prd_key`) and removed legacy `NAS` prefixes from ERP customer identifiers.

### 3. Gold Layer (Dimensional Modeling / Star Schema)
* **Goal:** Expose business-ready views structured as a Star Schema for analytical reporting.
* **Data Objects:**
  * **`gold.dim_customers`**: Consolidated customer dimension unifying CRM demographic data with ERP birth dates and geography.
  * **`gold.dim_product`**: Product hierarchy dimension combining CRM product lines with ERP category maintenance codes.
  * **`gold.fact_sales`**: Central transactional fact view linking sales details to the dimensions through surrogate keys (`customer_key` and the product key).

---

## 🔎 Exploratory Data Analysis (`EDA_project.sql`)

A structured walkthrough of the warehouse, moving from metadata to business measures:

| Step | What it explores | Techniques |
|------|------------------|------------|
| **Database exploration** | All objects and columns in the `bronze` schema | `information_schema.tables`, `information_schema.columns` |
| **Dimensions exploration** | Customer countries; categories → subcategories → products | `DISTINCT`, multi-column `ORDER BY` |
| **Date exploration** | First/last order date, time span in months and years; customer age range | `MIN`, `MAX`, `TIMESTAMPDIFF` |
| **Measures exploration** | Total sales, quantity, average price, orders, customers, products | `SUM`, `AVG`, `COUNT(DISTINCT …)` |
| **Magnitude analysis** | Customers by country and gender; products by category; average cost per category; revenue by category and by customer; items sold by country | `GROUP BY`, `LEFT JOIN` across fact and dimensions |
| **Ranking analysis** | Top 5 and bottom 5 products by revenue; customers with the fewest orders | `DENSE_RANK()`, `LIMIT` |

---

## 📈 Advanced SQL Analytics (`analysis_project.sql`)

| Analysis | Business question | Techniques |
|----------|-------------------|------------|
| **Sales over time** | How do sales, customers, and quantities evolve by year and month? | `YEAR()`, `MONTH()`, aggregation |
| **Cumulative analysis** | What are the running total sales and running average price by year? | CTE, `SUM() OVER`, `AVG() OVER` |
| **Performance analysis** | How does each product perform against its own average and against the previous year? | CTEs, `AVG() OVER (PARTITION BY …)`, `LAG()`, `CASE` flags (above/below average, increase/decrease) |
| **Part-to-whole** | Which categories contribute most to overall sales? | `SUM() OVER ()`, percentage calculation |
| **Product segmentation** | How many products fall in each cost range (`below 100`, `100-500`, `500-1000`, `Above 1000`)? | `CASE`, `GROUP BY` |
| **Customer segmentation** | Who are the VIP, Regular, and New customers? | `TIMESTAMPDIFF`, `CASE` |

**Customer segmentation rules**

* **VIP:** customer history of at least 12 months **and** total spend above 5,000
* **Regular:** customer history of at least 12 months **and** total spend of 5,000 or less
* **New:** customer history shorter than 12 months

---

## 📂 Repository Structure

```text
.
├── 1_bronze_layer.sql              # Raw staging tables DDL & LOAD DATA scripts
├── 2_silver_crm_cust.sql           # CRM Customer cleansing & deduplication
├── 3_silver_erp_cust.sql           # ERP Customer profile transformations
├── 4_silver_crm_product.sql        # Product parsing & line mapping
├── 5_silver_erp_loc.sql            # Country standardization
├── 6_silver_crm_sales.sql          # Sales calculation & date parsing
├── 7_gold_dim_customers.sql        # Customer Dimension View
├── 8_gold_dim_products.sql         # Product Dimension View
├── 9_gold_fact_sales.sql           # Sales Fact View
├── EDA_project.sql                 # Exploratory Data Analysis
└── analysis_project.sql            # Advanced SQL analytics & segmentation
```

---

## 🚀 How to Run

1. Enable local file loading in MySQL (required for `LOAD DATA LOCAL INFILE`):
   ```sql
   SET GLOBAL local_infile = 1;
   ```
   Also start your client with local infile enabled (for the CLI: `mysql --local-infile=1 -u <user> -p`).
2. Update the CSV file paths in `1_bronze_layer.sql` to match your machine.
3. Execute the scripts in numeric order, `1_` through `9_`, to build the Bronze, Silver, and Gold layers.
4. Run `EDA_project.sql` to profile the data.
5. Run `analysis_project.sql` to reproduce the analytics.

---

## 🧰 Key Technical Features

* **SQL Window Functions:** `ROW_NUMBER()` for deduplication and surrogate keys; `DENSE_RANK()`, `LAG()`, and running `SUM() / AVG() OVER` for ranking, YoY, and cumulative metrics.
* **CTEs:** Layered Common Table Expressions for readable multi-step analytics.
* **Data Cleansing Logic:** `CASE`, `COALESCE`, `NULLIF`, `ABS`, `TRIM`, and string parsing (`SUBSTRING`, `REPLACE`).
* **Date Analytics:** `TIMESTAMPDIFF`, `YEAR`, `MONTH` for time spans, age ranges, and customer lifespan.
* **Star Schema Design:** Surrogate keys and isolated measures for optimized BI dashboard queries.
* **Customer & Product Segmentation:** Rule-based VIP/Regular/New customer tiers and product cost bands.
