🏦 Enterprise Data Warehouse: CRM & ERP IntegrationEnd-to-End Data Engineering & Analytics Pipeline using MySQL and the Medallion Architecture📌 Project OverviewThis project builds an end-to-end Data Warehousing solution designed to integrate and transform raw transactional data from two disparate source systems—CRM and ERP. Using a Medallion Architecture (Bronze → Silver → Gold), the raw CSV datasets are ingested, cleansed, standardized, enriched, and modeled into an analytical Star Schema optimized for Business Intelligence (BI) and reporting.🏗 System Architecture & Data Flow       Sources                   Bronze Layer               Silver Layer              Gold Layer
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
│       └───┘         │───>│   erp_px_cat_g1v2   │───>│   erp_px_cat_g1v2   │──┴───>│  dim_products  │
│        ERP          │    └─────────────────────┘    └─────────────────────┘       └────────────────┘
└─────────────────────┘
🛠 Medallion Architecture Layers1. Bronze Layer (Raw Staging)Goal: Store source data in its original format without making structural changes.Source Systems:CRM: crm_cust_info, crm_prd_info, crm_sales_detailsERP: erp_cust_az12, erp_loc_a101, erp_px_cat_g1v2Implementation: High-performance raw CSV loading using LOAD DATA LOCAL INFILE with standard table truncation for idempotent re-runs.2. Silver Layer (Cleansing, Standardization & Enrichment)Goal: Clean, standardize, and enrich data to build reliable intermediate models.Transformations Executed:Deduplication: Applied ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) to retain only the most recent customer records.Data Standardization: Cleaned whitespace (TRIM), standardized gender codes (M/F → Male/Female), marital status (S/M → Single/Married), and localized country strings (US/USA → United States, DE → Germany).Data Integrity & Imputation: Converted raw integer dates (YYYYMMDD) into native DATE types and enforced business math logic:
$$\text{Sales} = \text{Quantity} \times \vert{}\text{Price}\vert{}$$Key Extraction & Parsing: Extracted category IDs (cat_id) from composite string keys (prd_key) and cleaned legacy NAS prefixes from ERP customer identifiers.3. Gold Layer (Dimensional Modeling / Star Schema)Goal: Expose business-ready views structured as a Star Schema for analytical reporting.Data Objects:gold.dim_customers: Consolidated customer dimension unifying CRM demographic data with ERP birth dates and geography.gold.dim_product: Product hierarchy dimension combining CRM product lines with ERP category maintenance codes.gold.fact_sales: Central transactional fact view linking sales details with dimension surrogate keys (customer_key, product_key).📂 Repository Structure.
├── 1_bronze_layer.sql              # Raw staging tables DDL & LOAD DATA scripts
├── 2_silver_crm_cust.sql           # CRM Customer cleansing & deduplication
├── 3_silver_erp_cust.sql           # ERP Customer profile transformations
├── 4_silver_crm_product.sql        # Product parsing & line mapping
├── 5_silver_erp_loc.sql            # Country standardization
├── 6_silver_crm_sales.sql          # Sales calculation & date parsing
├── 7_gold_dim_customers.sql        # Customer Dimension View
├── 8_gold_dim_products.sql         # Product Dimension View
└── 9_gold_fact_sales.sql           # Sales Fact View
🚀 Key Technical FeaturesSQL Window Functions: Utilized ROW_NUMBER() for deduplication and surrogate key generation.Data Cleansing Logic: Employed CASE, COALESCE, NULLIF, ABS, TRIM, and regex string parsing (SUBSTRING, REPLACE).Star Schema Design: Implemented surrogate keys and isolated measures from dimensions for optimized BI ashboard queries.
---
