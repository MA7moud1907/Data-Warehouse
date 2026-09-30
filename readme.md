TRUNCATE TABLE crm_cust_info;
LOAD DATA LOCAL INFILE "D:/Downloads/cust_info.csv"
INTO TABLE crm_cust_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
```[cite: 4]

* **Idempotent Ingestion:** Tables are truncated prior to reloading so scripts can be re-run safely without causing duplicate records[cite: 4].
* **Raw Preservation:** No transformations or data scrubbing occur at this stage[cite: 4].

---

## Silver Layer (Data Cleaning & Quality)

The Silver layer transforms raw text strings and integers into normalized, reliable fields[cite: 5, 6, 7, 8, 9, 10]:

| Table | Cleaning Transformations Applied |
| :--- | :--- |
| `silver_cust` | Cleaned leading/trailing whitespace (`TRIM`)[cite: 5]. Standardized coded flags (`F`/`M` $\rightarrow$ `Female`/`Male`; `S`/`M` $\rightarrow$ `Single`/`Married`)[cite: 5]. Deduplicated customer profiles using `ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC)`[cite: 5]. |
| `silver_erp_cust_az12` | Stripped `NAS` prefixes from customer IDs to match CRM primary keys[cite: 6]. Set invalid dates (`0000-00-00` or future dates $> 2024$) to `NULL`[cite: 6]. Normalized gender entries (`FEMALE`, `female`, `F` $\rightarrow$ `Female`)[cite: 6]. |
| `silver_erp_loc_a101` | Removed hyphens (`-`) from customer IDs[cite: 10]. Standardized country codes (`US`/`USA` $\rightarrow$ `United States`, `DE` $\rightarrow$ `Germany`)[cite: 10]. Replaced blank/null fields with `'n/a'`[cite: 10]. |
| `silver_crm_product_info` | Parsed composite `prd_key` strings to separate `cat_id` from the main product key[cite: 7]. Standardized product line codes (`M`/`R`/`S`/`T` $\rightarrow$ `Mountain`, `Road`, etc.)[cite: 7]. Replaced `NULL` costs with `0` and cast start dates to `DATE`[cite: 7]. |
| `silver_erp_pax_cat_g1v2` | Standardized category attributes directly into silver storage[cite: 8]. |
| `silver_crm_sales_details` | Converted integer dates (`YYYYMMDD`) to SQL `DATE` types[cite: 9]. Corrected invalid sales figures by enforcing logical math ($Sales = Quantity \times \vert{}Price\vert{}$)[cite: 9]. Derived missing prices ($Price = Sales \div Quantity$)[cite: 9]. |

---

## Gold Layer (Data Enrichment & Modeling)

The Gold layer models the cleansed data into a **Star Schema** using database views[cite: 1, 2, 3]:

* **`gold.dim_customers`**: Integrates CRM customer data with ERP demographics (birth date, country)[cite: 1]. Uses `COALESCE` logic so ERP gender acts as a fallback when CRM gender is `'n/a'`[cite: 1].
* **`gold.dim_product`**: Integrates product details with category, subcategory, and maintenance attributes from ERP lookup tables[cite: 2].
* **`gold.fact_sales`**: Isolates core sales transactions (`sls_sales`, `sls_quantity`, `sls_price`) and joins them to dimension surrogate keys (`customer_key`, `prdouct__key`)[cite: 1, 2, 3].

*Surrogate keys are generated dynamically using `ROW_NUMBER()`[cite: 1, 2], ensuring views automatically reflect the latest Silver layer updates.*

---

## Exploratory Data Analysis (EDA)

The `EDA_project.sql` script audits the warehouse and provides baseline insights[cite: 13]:

1. **Schema Auditing:** Queries `information_schema` to verify objects and column types[cite: 13].
2. **Dimension Profiling:** Explores distinct values across customer countries, age ranges, and product categories[cite: 13].
3. **Headline Metrics:** Computes overall Total Revenue, Quantity Sold, Average Price, Total Orders, Active Customers, and Catalog Item counts[cite: 13].
4. **Magnitude & Breakdown Analysis:** Measures customer distribution across countries/genders and calculates average product cost per category[cite: 13].
5. **Ranking & Extremes:** Ranks product revenue performance (Top 5 / Bottom 5 items using `DENSE_RANK()`) and highlights lowest-ordering customers[cite: 13].

---

## Advanced Analytics

The `analysis_project.sql` script implements common business intelligence metrics:

| Analysis Focus | Business Question Addressed | SQL Technique Used |
| :--- | :--- | :--- |
| **Sales Performance Trends** | Are sales growing month-over-month and year-over-year? | Date truncation & `GROUP BY` aggregations[cite: 13]. |
| **Cumulative Revenue** | What is the cumulative revenue trend and moving average? | Window functions (`SUM() OVER`, `AVG() OVER`)[cite: 13]. |
| **Year-over-Year (YoY) Growth** | Which products are over/underperforming prior year benchmarks? | `LAG()` window function, partition-based moving comparisons[cite: 13]. |
| **Part-to-Whole Share** | What percentage of total sales does each product category contribute? | Window `SUM() OVER ()` percentage calculations[cite: 13]. |
| **Catalog Price Tiers** | How are items distributed across price brackets? | Conditional `CASE WHEN` bucketing[cite: 13]. |
| **Customer RFM Segmentation** | How many customers qualify as VIP, Regular, or New based on spend/tenure? | `CASE WHEN` spend thresholds combined with `TIMESTAMPDIFF` tenure logic[cite: 13]. |

---

## How to Run

1. **Database Setup:** Open MySQL Workbench and enable bulk load permissions:
   ```sql
   SET GLOBAL local_infile = 1;
   ```[cite: 4]
   *(Also enable `OPT_LOCAL_INFILE=1` in the Workbench Connection Advanced options).*
2. **Execute Layer Scripts:**
   * Run `bronze_layer.sql` to initialize staging tables and import source CSVs[cite: 4].
   * Run Silver scripts to execute cleaning, type casting, and deduplication routines[cite: 5, 6, 7, 8, 9, 10].
   * Run Gold scripts to build the analytical Star Schema views (`dim_customers`[cite: 1], `dim_product`[cite: 2], `fact_sales`[cite: 3]).
3. **Execute Analytics Scripts:**
   * Run `EDA_project.sql` to perform baseline data profiling[cite: 13].
   * Run `analysis_project.sql` to execute advanced business metrics and customer segmentation[cite: 13].

---

## Skills Demonstrated

* **Data Warehousing & Modeling:** Medallion Architecture (Bronze/Silver/Gold)[cite: 1, 2, 3, 4], Star Schema design[cite: 1, 2, 3], Surrogate Key generation[cite: 1, 2], View abstraction[cite: 1, 2, 3].
* **ETL & Data Quality Engineering:** Multi-source integration (CRM + ERP)[cite: 1, 2, 4], Window-based deduplication[cite: 5], string parsing[cite: 7], numeric recalculation logic[cite: 9], invalid date handling[cite: 6, 9].
* **Advanced Analytics SQL:** CTEs, Window Functions (`ROW_NUMBER`[cite: 1, 2, 5], `DENSE_RANK`[cite: 13], `LAG`), cumulative aggregates, conditional segmentation (`CASE` statements)[cite: 5, 6, 7, 9, 10, 13].
* **Business Analytics:** YoY trend performance, revenue distribution modeling, RFM-style customer segmentation[cite: 13].

---

## Known Limitations & Next Steps

* **Automated Data Quality Tests:** Add automated assertions to check for orphaned foreign keys or unexpected `NULL` values.
* **SCD Type 2 History:** Incorporate end-date filtering (`prd_end_dt`) to track historical product price changes cleanly without duplicating fact records.
* **Naming Conventions:** Standardize minor legacy naming inconsistencies in source schemas (`prdouct__key` $\rightarrow$ `product_key`)[cite: 1, 2, 3].

---

## Repo Structure

```text
.
├── bronze/
│   └── bronze_layer.sql           # Table creation & LOAD DATA scripts
├── silver/
│   ├── silver_customers.sql       # Customer deduplication & cleaning
│   ├── silver_products.sql        # Product parsing & transformation
│   ├── silver_sales.sql           # Date casting & sales metric validation
│   └── silver_erp_tables.sql      # ERP location & category normalization
├── gold/
│   ├── gold_dim_customers.sql     # Customer dimension view
│   ├── gold_dim_products.sql      # Product dimension view
│   └── gold_fact_sales.sql        # Sales fact view
├── eda/
│   └── EDA_project.sql            # Exploratory analysis & data profiling
├── analysis/
│   └── analysis_project.sql       # Advanced analytics & customer segmentation
└── README.md                      # Project documentation
