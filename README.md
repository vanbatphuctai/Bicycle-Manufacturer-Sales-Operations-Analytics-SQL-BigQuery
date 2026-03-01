# 🚲 Bicycle Manufacturer Sales & Operations Analytics Project | SQL & Google BigQuery

**Author:** Van Bat Phuc Tai  
**Tools:** **SQL**, **Google BigQuery**

---

## 📑 Table of Contents
- [📌 Background & Business Context](#-background--business-context)
- [🎯 Key Business Questions](#-key-business-questions)
- [👥 Target Audience](#-target-audience)
- [📂 Dataset Description](#-dataset-description)
- [📊 Dataset Overview](#-dataset-overview)
- [🔎 Final Conclusion & Recommendations](#-final-conclusion--recommendations)

---

## 📌 Background & Business Context

For manufacturing companies, balancing **Sales Performance**, **Inventory Control**, **Operational Efficiency**, and **Customer Retention** is essential to maintaining profitability and long-term growth.

This project analyzes transactional and operational data from a bicycle manufacturing company using **SQL in Google BigQuery**. By transforming raw sales, production, and purchasing data into structured performance metrics, the project delivers **actionable business insights** that support **data-driven decision-making** across Sales, Supply Chain, Finance, and Executive Strategy functions.

---

## 🎯 Key Business Questions

This project evaluates overall **Business Performance** by examining **Sales Growth Trends**, **Product Performance Dynamics**, and **Territory-Level Revenue Contribution**. It explores the financial impact of **Seasonal Discount Programs** and assesses **Customer Retention Behavior** through cohort analysis.

In addition, the analysis investigates **Operational Efficiency** by monitoring **Inventory Fluctuations**, measuring **Stock-to-Sales Ratios**, and reviewing **Pending Purchase Orders** to better understand supply chain performance and working capital exposure.

The ultimate objective is to integrate **Sales**, **Operations**, and **Customer Metrics** into a comprehensive, data-driven view of **Business Sustainability and Performance Health**.

---

## 👥 Target Audience

This analysis is designed for:

- **Sales & Operations Managers**
- **Supply Chain & Inventory Teams**
- **Business Analysts**
- **Finance & Strategy Departments**
- **Business Intelligence Teams**

---

## 📂 Dataset Description

### 📌 Data Source

This project uses the **AdventureWorks 2019** sample database hosted in **Google BigQuery**.

The dataset simulates a bicycle manufacturing company’s operations and includes:

- **Sales Transactions** (Order Headers & Order Details)
- **Product & Subcategory Information**
- **Territory-Level Sales Data**
- **Work Orders & Production Records**
- **Inventory Data**
- **Special Offers & Discount Programs**
- **Purchase Order Data**

---

## 📊 Dataset Overview

**Dataset Name:** `adventureworks2019`

**Core Tables Used:**

- `Sales.SalesOrderDetail`
- `Sales.SalesOrderHeader`
- `Production.Product`
- `Production.ProductSubcategory`
- `Production.WorkOrder`
- `Sales.SpecialOffer`
- `Purchasing.PurchaseOrderHeader`

**Estimated Data Volume:** ~300,000 rows across transactional and operational tables.

---

## 🔎 Project Scope & Analytical Approach

The analysis includes:

- **Last 12 Months (L12M) Sales Performance** by Product Subcategory  
- **Year-over-Year (YoY) Growth Analysis** & Top Performing Categories  
- **Territory Ranking** by Annual Order Volume  
- **Seasonal Discount Cost & Revenue Impact Analysis**  
- **Customer Retention Cohort Analysis**  
- **Monthly Inventory Trend & MoM Change**  
- **Stock-to-Sales Ratio Evaluation**  
- **Pending Purchase Order Volume & Total Value Assessment**

---

## 🛠 SQL Techniques Used

All transformations were implemented using **Google BigQuery Standard SQL**, including:

- **Common Table Expressions (CTEs)**
- **Window Functions** (LAG, LEAD, DENSE_RANK)
- **Time-Based Grouping** (EXTRACT, FORMAT_DATETIME)
- **Aggregations & Business Metric Calculations**
- **Ranking Logic**
- **Cohort Analysis Methodology**

---

## 📌 How to Access the Dataset

1. Log in to your **Google Cloud Platform** account  
2. Open the **BigQuery Console**  
3. Navigate to your project  
4. Locate the dataset: `adventureworks2019`
5. Explore the **Sales**, **Production**, and **Purchasing** schemas to execute analytical queries
   
---

## ⚒️ Main Process


### 🔍 Calculate Quantity of Items, Sales Value & Order Quantity by Each Subcategory in the Last 12 Months

This analysis evaluates **total quantity sold, total revenue, and total order volume** across subcategories within the **Last 12 Months (L12M)** to assess overall product performance. By aggregating results at the **subcategory level**, it highlights **sales volume distribution and revenue contribution patterns**, providing a concise view of recent product performance.

#### 🚀 **Queries**
```sql
SELECT
    FORMAT_DATETIME('%b %Y', a.ModifiedDate) AS period,
    c.Name AS name,
    SUM(a.OrderQty) AS qty_item,
    SUM(a.LineTotal) AS total_sales,
    COUNT(DISTINCT a.SalesOrderID) AS name_cnt
FROM `adventureworks2019.Sales.SalesOrderDetail` AS a
LEFT JOIN `adventureworks2019.Production.Product` AS b
    ON a.ProductID = b.ProductID
LEFT JOIN `adventureworks2019.Production.ProductSubcategory` AS c
    ON CAST(b.ProductSubcategoryID AS INT64) = c.ProductSubcategoryID
WHERE DATE(a.ModifiedDate) >= (
    SELECT
        DATE_SUB(
            CAST(MAX(ModifiedDate) AS DATE),
            INTERVAL 12 MONTH
        )
    FROM `adventureworks2019.Sales.SalesOrderDetail`
)
GROUP BY
    period,
    name
ORDER BY
    period DESC,
    name ASC;
```
#### 💡 Queries result
<img width="900" alt="image" src="https://github.com/user-attachments/assets/f559a4fe-54d0-4b02-8ebd-45368edf5bf8" />


## 🔍 Calculate the Year-over-Year (YoY) growth rate for each product subcategory using quantity_item as the performance metric. Return the Top 3 subcategories with the highest growth rate**, rounding results to 2 decimal places.

This analysis calculates the **Year-over-Year (YoY) growth rate** for each product subcategory using **quantity_item** from the AdventureWorks 2019 dataset in Google BigQuery. By comparing current-year quantity with the previous year, it identifies the **Top 3 fastest-growing subcategories**, highlighting recent demand growth trends.
Formula:
YoY Growth Rate = (qty_item / previous_year_qty) - 1

#### 🚀 **Queries**
```sql
WITH sale_info AS (
    SELECT
        EXTRACT(YEAR FROM a.ModifiedDate) AS year,
        c.Name AS subcategory_name,
        SUM(a.OrderQty) AS qty_item
    FROM `adventureworks2019.Sales.SalesOrderDetail` AS a
    LEFT JOIN `adventureworks2019.Production.Product` AS b
        ON a.ProductID = b.ProductID
    LEFT JOIN `adventureworks2019.Production.ProductSubcategory` AS c
        ON SAFE_CAST(b.ProductSubcategoryID AS INT64) = c.ProductSubcategoryID
    GROUP BY
        year,
        subcategory_name
),

sale_diff AS (
    SELECT
        year,
        subcategory_name,
        qty_item,
        LEAD(qty_item) OVER (
            PARTITION BY subcategory_name
            ORDER BY year DESC
        ) AS prev_qty
    FROM sale_info
),

ranked_qty_diff AS (
    SELECT
        year,
        subcategory_name,
        qty_item,
        prev_qty,
        ROUND(qty_item / prev_qty - 1, 2) AS qty_diff,
        DENSE_RANK() OVER (
            ORDER BY ROUND(qty_item / prev_qty - 1, 2) DESC
        ) AS diff_rank
    FROM sale_diff
    WHERE prev_qty IS NOT NULL
)

SELECT
    subcategory_name,
    qty_item,
    prev_qty,
    qty_diff
FROM ranked_qty_diff
WHERE diff_rank <= 3
ORDER BY diff_rank;
```
#### 💡 Queries result
<img width="900" alt="image" src="https://github.com/user-attachments/assets/0a69f785-51c0-439a-a013-fef89118a9aa" />


## 🔍 Calculate the Top 3 TerritoryID with the highest order quantity for each year without skipping rank numbers in case of ties.

This analysis identifies the **top 3 TerritoryID per year** based on **total order quantity**, ensuring the ranking remains **continuous when ties occur**.

#### 🚀 **Queries**
```sql
WITH order_count AS (
    SELECT
        EXTRACT(YEAR FROM a.ModifiedDate) AS year,
        b.TerritoryID AS territory_id,
        SUM(a.OrderQty) AS order_cnt
    FROM `adventureworks2019.Sales.SalesOrderDetail` AS a
    LEFT JOIN `adventureworks2019.Sales.SalesOrderHeader` AS b
        ON a.SalesOrderID = b.SalesOrderID
    GROUP BY
        year,
        territory_id
)

-- Top 3 TerritoryID with highest order quantity per year
SELECT
    year,
    territory_id,
    order_cnt,
    ranking
FROM (
    SELECT
        year,
        territory_id,
        order_cnt,
        DENSE_RANK() OVER (
            PARTITION BY year
            ORDER BY order_cnt DESC
        ) AS ranking
    FROM order_count
)
WHERE ranking <= 3
ORDER BY
    year DESC,
    ranking ASC;
```
#### 💡 Queries result
<img width="900" alt="image" src="https://github.com/user-attachments/assets/d8b62e51-05e1-4dcc-902b-436662975c89" />


## 🔍 Calculate the total discount cost under Seasonal Discount for each product SubCategory.

This analyzes the **total Seasonal Discount cost** aggregated at the **SubCategory level**, providing visibility into **promotion impact by product group**.

#### 🚀 **Queries**
```sql
SELECT
    EXTRACT(YEAR FROM a.ModifiedDate) AS year,
    c.Name AS subcategory_name,
    SUM(a.UnitPrice * a.OrderQty * d.DiscountPct) AS total_discount_cost
FROM `adventureworks2019.Sales.SalesOrderDetail` AS a
LEFT JOIN `adventureworks2019.Production.Product` AS b
    ON a.ProductID = b.ProductID
LEFT JOIN `adventureworks2019.Production.ProductSubcategory` AS c
    ON SAFE_CAST(b.ProductSubcategoryID AS INT64) = c.ProductSubcategoryID
LEFT JOIN `adventureworks2019.Sales.SpecialOffer` AS d
    ON a.SpecialOfferID = d.SpecialOfferID
WHERE LOWER(d.Type) LIKE '%seasonal discount%'
GROUP BY
    year,
    subcategory_name
ORDER BY
    total_discount_cost ASC;

```
#### 💡 Queries result
<img width="900" alt="image" src="https://github.com/user-attachments/assets/ddd06763-361f-4f62-aa51-90ead4512cdc" />


## 🔍 Calculate the customer retention rate in 2014 for orders with Successfully Shipped status using cohort analysis.

This analysis evaluates the **customer retention rate in 2014**, focusing only on **Successfully Shipped orders**, and tracks **repeat purchasing behavior within the cohort**.

#### 🚀 **Queries**
```sql
WITH info AS (
    SELECT
        EXTRACT(MONTH FROM ModifiedDate) AS month_no,
        EXTRACT(YEAR FROM ModifiedDate) AS year_no,
        CustomerID AS customer_id,
        COUNT(DISTINCT SalesOrderID) AS order_cnt
    FROM `adventureworks2019.Sales.SalesOrderHeader`
    WHERE EXTRACT(YEAR FROM ModifiedDate) = 2014
        AND Status = 5
    GROUP BY
        month_no,
        year_no,
        customer_id
),

first_order AS (
    SELECT
        customer_id,
        MIN(month_no) AS month_join
    FROM info
    GROUP BY customer_id
),

month_gap AS (
    SELECT
        i.customer_id,
        f.month_join,
        i.month_no AS month_order,
        i.order_cnt,
        CONCAT('M - ', CAST(i.month_no - f.month_join AS STRING)) AS month_diff
    FROM info AS i
    LEFT JOIN first_order AS f
        ON i.customer_id = f.customer_id
)

SELECT
    month_join,
    month_diff,
    COUNT(DISTINCT customer_id) AS customer_cnt
FROM month_gap
GROUP BY
    month_join,
    month_diff
ORDER BY
    month_join,
    month_diff;
```
#### 💡 Queries result
<img width="900" alt="image" src="https://github.com/user-attachments/assets/55c2abb2-49d9-483e-b7d6-f7c686917f94" />


## 🔍 Calculate the stock level trend and month-over-month percentage difference for all products in 2011, replacing null growth rates with 0 and rounding to 1 decimal place.

This task analyzes the **inventory trend in 2011** and measures the **month-over-month percentage change**, treating missing growth values as **0** and rounding results to **1 decimal place**.

#### 🚀 **Queries**
```sql
WITH total_stock AS (
SELECT
  a.Name AS Product,
  EXTRACT(MONTH FROM b.EndDate) AS mth,
  EXTRACT(YEAR FROM b.EndDate) AS yr,
  SUM(b.StockedQty) AS stock_qty
FROM `adventureworks2019.Production.Product` AS a
LEFT JOIN `adventureworks2019.Production.WorkOrder` AS b
ON a.ProductID = b.ProductID
WHERE EXTRACT(YEAR FROM b.EndDate) = 2011
GROUP BY 1,2,3
),

-- Find stock previous
stock_previous AS (
SELECT
  Product,
  mth,
  yr,
  stock_qty,
  LEAD(stock_qty) OVER (PARTITION BY Product ORDER BY mth DESC, yr) AS stock_prv
FROM total_stock
ORDER BY Product
)

-- Find stock diff
SELECT 
  Product,
  mth,
  yr,
  stock_qty,
  stock_prv,
  COALESCE(ROUND((stock_qty - stock_prv) / stock_prv * 100.0, 1), 0) AS diff
FROM stock_previous;
```
#### 💡 Queries result
<img width="900" alt="image" src="https://github.com/user-attachments/assets/5dbdc208-2c1d-42be-b60e-d93cd1df5076" />


## 🔍 Calculate the monthly ratio of Stock to Sales for each product in 2011 and compute MoM and YoY growth, ordering results by month descending and ratio descending, rounding the ratio to 1 decimal place.

This analysis evaluates the **Stock-to-Sales ratio by product and month in 2011**, along with **MoM and YoY growth trends**, to assess **inventory efficiency over time**.

#### 🚀 **Queries**
```sql
WITH sale_info AS (
    SELECT
        EXTRACT(MONTH FROM a.ModifiedDate) AS mth,
        EXTRACT(YEAR FROM a.ModifiedDate) AS yr,
        a.ProductID,
        b.Name AS Name,
        SUM(a.OrderQty) AS sales_qty
    FROM `adventureworks2019.Sales.SalesOrderDetail` AS a
    LEFT JOIN `adventureworks2019.Production.Product` AS b
        ON a.ProductID = b.ProductID
    WHERE EXTRACT(YEAR FROM a.ModifiedDate) = 2011
    GROUP BY
        1, 2, 3, 4
),

stock_info AS (
    SELECT 
        EXTRACT(MONTH FROM ModifiedDate) AS mth,
        EXTRACT(YEAR FROM ModifiedDate) AS yr,
        ProductID,
        SUM(StockedQty) AS stock_qty
    FROM `adventureworks2019.Production.WorkOrder`
    WHERE EXTRACT(YEAR FROM ModifiedDate) = 2011
    GROUP BY
        1, 2, 3
)

SELECT
    a.mth,
    a.yr,
    a.ProductID,
    a.Name,
    a.sales_qty,
    b.stock_qty,
    COALESCE(
        ROUND(b.stock_qty / a.sales_qty, 1),
        0
    ) AS ratio
FROM sale_info AS a
JOIN stock_info AS b
    ON a.ProductID = b.ProductID
    AND a.mth = b.mth
    AND a.yr = b.yr
ORDER BY
    a.mth DESC,
    ratio DESC;
```
#### 💡 Queries result
<img width="900" alt="image" src="https://github.com/user-attachments/assets/5d596839-1693-4783-8d90-0a90f3916613" />


## 🔍 Calculate the number of orders and total order value with Pending status in 2014.

This task measures the **total number of Pending orders in 2014** and their corresponding **total order value**, reflecting the volume and value of unprocessed transactions.

#### 🚀 **Queries**
```sql
SELECT
    EXTRACT(YEAR FROM ModifiedDate) AS yr,
    Status,
    COUNT(PurchaseOrderID) AS order_cnt,
    SUM(TotalDue) AS value
FROM `adventureworks2019.Purchasing.PurchaseOrderHeader`
WHERE EXTRACT(YEAR FROM ModifiedDate) = 2014
    AND Status = 1
GROUP BY
    1, 2;
```
#### 💡 Queries result
<img width="900" alt="image" src="https://github.com/user-attachments/assets/06d999b7-ec65-4c56-b353-e9b4cf74d393" />


## 🔎 Final Conclusion & Recommendations
