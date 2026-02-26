# 🚲 Bicycle Manufacturer Sales & Operations Analytics Project | SQL & Google BigQuery

**Author:** Van Bat Phuc Tai  
**Tools:** SQL, Google BigQuery  

---

## 📌 Background & Business Context

For manufacturing companies, balancing sales performance, inventory levels, and customer retention is essential to maintaining profitability and operational efficiency.

This project analyzes sales performance, inventory trends, discount impact, and customer retention for a bicycle manufacturing company using SQL in Google BigQuery.  

The objective is to transform transactional and operational data into actionable business insights that support data-driven decision making.

---

## 🎯 Key Business Questions

- How have sales quantity and revenue performed over the last 12 months (L12M)?
- Which product subcategories show the highest Year-over-Year (YoY) growth?
- Which territories generate the largest order volumes annually?
- What is the financial impact of seasonal discount programs?
- What is the customer retention rate based on cohort analysis?
- How do inventory levels fluctuate month-over-month?
- What is the stock-to-sales ratio across products?
- How many purchase orders remain in pending status, and what is their total value?

---

## 👥 Target Audience

This analysis is designed for:

- Sales & Operations Managers  
- Supply Chain & Inventory Teams  
- Business Analysts  
- Finance & Strategy Departments  
- Business Intelligence Teams  

---

## 📂 Dataset Description

### 📌 Data Source

This project uses the **AdventureWorks 2019** sample database hosted in Google BigQuery.

The dataset simulates a bicycle manufacturing company’s operations, including:

- Sales transactions (order details & headers)
- Product and subcategory information
- Territory-level sales data
- Work orders and inventory records
- Special offers and discount programs
- Purchase order data

---

## 📊 Dataset Overview

**Dataset name:** `adventureworks2019`

**Main tables used:**

- `Sales.SalesOrderDetail`
- `Sales.SalesOrderHeader`
- `Production.Product`
- `Production.ProductSubcategory`
- `Production.WorkOrder`
- `Sales.SpecialOffer`
- `Purchasing.PurchaseOrderHeader`

**Estimated data volume:** ~200,000–300,000 rows across core transactional and operational tables.

> Note: This is a sample dataset designed for analytics training and business case simulation.

---

## 🔎 Project Scope & Analytical Approach

The analysis includes:

✔️ Last 12 Months (L12M) Sales Performance by Product Subcategory  
✔️ Year-over-Year (YoY) Growth Rate & Top 3 Performing Categories  
✔️ Territory Ranking by Annual Order Volume  
✔️ Seasonal Discount Cost Analysis  
✔️ Customer Retention Cohort Analysis (2014)  
✔️ Monthly Inventory Trend & MoM Percentage Change  
✔️ Stock-to-Sales Ratio Analysis  
✔️ Pending Purchase Order Volume & Total Value Analysis  

### 🛠 SQL Techniques Used

- Common Table Expressions (CTEs)
- Window Functions (`LAG`, `LEAD`, `DENSE_RANK`)
- Time-based grouping (`EXTRACT`, `FORMAT_DATETIME`)
- Aggregations & business metric calculations
- Ranking & cohort analysis logic

All queries were executed using **Google BigQuery Standard SQL**.

---

## 📌 How to Access the Dataset

1. Log in to your Google Cloud Platform account.
2. Open **BigQuery Console**.
3. Navigate to your project.
4. Locate the dataset: adventureworks2019
5. Explore the Sales, Production, and Purchasing schemas to run analytical queries.

---

## 📈 Business Value

This project demonstrates the ability to:

- Analyze sales growth and product performance  
- Evaluate operational efficiency through inventory metrics  
- Measure discount impact on revenue  
- Conduct customer retention (cohort) analysis  
- Translate raw transactional data into business insights  
