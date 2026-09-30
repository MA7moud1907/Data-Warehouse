# 🏦 Enterprise Data Warehouse: CRM & ERP Integration

![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?style=for-the-badge&logo=mysql&logoColor=white)
![Architecture](https://img.shields.io/badge/Architecture-Medallion_(Bronze_Silver_Gold)-green?style=for-the-badge)
![Data Modeling](https://img.shields.io/badge/Data_Model-Star_Schema-orange?style=for-the-badge)
![Analytics](https://img.shields.io/badge/Analytics-EDA_%26_Advanced_SQL-purple?style=for-the-badge)

> End-to-End Data Engineering, Exploratory Data Analysis (EDA), and Business Intelligence Suite using MySQL and Medallion Architecture

---

## 📌 Project Overview

This project builds an end-to-end Data Warehousing solution designed to integrate and transform raw transactional data from two disparate source systems—CRM and ERP. Using a **Medallion Architecture (Bronze → Silver → Gold)**, raw CSV datasets are ingested, cleansed, standardized, enriched, and modeled into an analytical **Star Schema** optimized for Business Intelligence (BI) and reporting.

On top of the core warehouse, this project includes an **Exploratory Data Analysis (EDA)** script and an **Advanced SQL Analytics** suite covering revenue trends, running performance metrics, Year-over-Year (YoY) growth, category share, product cost bucketing, and RFM-style customer segmentation.

---

## 🏗 System Architecture & Data Flow

```text
       Sources                   Bronze Layer               Silver Layer              Gold Layer
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐    ┌───────────────────┐
│                     │───>│   crm_sales_details │───>│  crm_sales_details  │───>│    fact_sales     │
│                     │    ├─────────────────────┤    ├─────────────────────┤    └───────────────────┘
│       ┌───┐         │───>│    crm_cust_info    │───>│    crm_cust_info    │────┐
│       │ 📁│         │    ├─────────────────────┤    ├─────────────────────┤    │
│       └───┘         │───>│    crm_prd_info     │───>│    crm_prd_info     │──┐ │  ┌────────────────┐
│        CRM          │    ├─────────────────────┤    ├─────────────────────┤  │ │  │ dim_customers  │
│                     │───>│    erp_cust_az12    │───>│    erp_cust_az12    │──┼─┼─>└────────────────┘
│                     │    ├─────────────────────┤    ├─────────────────────┤  │ │  └────────────────┘
│       ┌───┐         │───>│    erp_loc_a101     │───>│    erp_loc_a101     │──┼─┘
│       │ 📁│         │    ├─────────────────────┤    ├─────────────────────┤  │    ┌────────────────┐
│       └───┘         │───>│   erp_px_cat_g1v2   │───>│   erp_px_cat_g1v2   │──┴───>│  dim_products  │
│        ERP          │    └─────────────────────┘    └─────────────────────┘       └────────────────┘
└─────────────────────┘
