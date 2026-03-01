-- Query 1
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
    SELECT DATE_SUB(CAST(MAX(ModifiedDate) AS DATE), INTERVAL 12 MONTH)
    FROM `adventureworks2019.Sales.SalesOrderDetail`
)
GROUP BY period, name
ORDER BY period DESC, name ASC;

-- Query 2
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
    GROUP BY year, subcategory_name
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
SELECT subcategory_name, qty_item, prev_qty, qty_diff
FROM ranked_qty_diff
WHERE diff_rank <= 3
ORDER BY diff_rank;

-- Query 3
WITH order_count AS (
    SELECT
        EXTRACT(YEAR FROM a.ModifiedDate) AS year,
        b.TerritoryID AS territory_id,
        SUM(a.OrderQty) AS order_cnt
    FROM `adventureworks2019.Sales.SalesOrderDetail` AS a
    LEFT JOIN `adventureworks2019.Sales.SalesOrderHeader` AS b
        ON a.SalesOrderID = b.SalesOrderID
    GROUP BY year, territory_id
)
SELECT year, territory_id, order_cnt, ranking
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
ORDER BY year DESC, ranking ASC;

-- Query 4
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
GROUP BY year, subcategory_name
ORDER BY total_discount_cost ASC;

-- Query 5
WITH info AS (
    SELECT
        EXTRACT(MONTH FROM ModifiedDate) AS month_no,
        CustomerID AS customer_id,
        COUNT(DISTINCT SalesOrderID) AS order_cnt
    FROM `adventureworks2019.Sales.SalesOrderHeader`
    WHERE EXTRACT(YEAR FROM ModifiedDate) = 2014
        AND Status = 5
    GROUP BY month_no, customer_id
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
        CONCAT('M-', CAST(i.month_no - f.month_join AS STRING)) AS month_diff
    FROM info AS i
    LEFT JOIN first_order AS f
        ON i.customer_id = f.customer_id
)
SELECT
    month_join,
    month_diff,
    COUNT(DISTINCT customer_id) AS customer_cnt
FROM month_gap
GROUP BY month_join, month_diff
ORDER BY month_join, month_diff;

-- Query 6
WITH total_stock AS (
    SELECT
        a.Name AS product,
        EXTRACT(MONTH FROM b.EndDate) AS mth,
        EXTRACT(YEAR FROM b.EndDate) AS yr,
        SUM(b.StockedQty) AS stock_qty
    FROM `adventureworks2019.Production.Product` AS a
    LEFT JOIN `adventureworks2019.Production.WorkOrder` AS b
        ON a.ProductID = b.ProductID
    WHERE EXTRACT(YEAR FROM b.EndDate) = 2011
    GROUP BY product, mth, yr
),
stock_previous AS (
    SELECT
        product,
        mth,
        yr,
        stock_qty,
        LEAD(stock_qty) OVER (
            PARTITION BY product
            ORDER BY mth DESC
        ) AS stock_prv
    FROM total_stock
)
SELECT
    product,
    mth,
    yr,
    stock_qty,
    stock_prv,
    COALESCE(ROUND((stock_qty - stock_prv) / stock_prv * 100, 1), 0) AS diff_pct
FROM stock_previous;

-- Query 7
WITH sale_info AS (
    SELECT
        EXTRACT(MONTH FROM a.ModifiedDate) AS mth,
        EXTRACT(YEAR FROM a.ModifiedDate) AS yr,
        a.ProductID,
        b.Name,
        SUM(a.OrderQty) AS sales_qty
    FROM `adventureworks2019.Sales.SalesOrderDetail` AS a
    LEFT JOIN `adventureworks2019.Production.Product` AS b
        ON a.ProductID = b.ProductID
    WHERE EXTRACT(YEAR FROM a.ModifiedDate) = 2011
    GROUP BY mth, yr, a.ProductID, b.Name
),
stock_info AS (
    SELECT
        EXTRACT(MONTH FROM ModifiedDate) AS mth,
        EXTRACT(YEAR FROM ModifiedDate) AS yr,
        ProductID,
        SUM(StockedQty) AS stock_qty
    FROM `adventureworks2019.Production.WorkOrder`
    WHERE EXTRACT(YEAR FROM ModifiedDate) = 2011
    GROUP BY mth, yr, ProductID
)
SELECT
    a.mth,
    a.yr,
    a.ProductID,
    a.Name,
    a.sales_qty,
    b.stock_qty,
    COALESCE(ROUND(b.stock_qty / a.sales_qty, 1), 0) AS ratio
FROM sale_info AS a
JOIN stock_info AS b
    ON a.ProductID = b.ProductID
    AND a.mth = b.mth
    AND a.yr = b.yr
ORDER BY a.mth DESC, ratio DESC;

-- Query 8
SELECT
    EXTRACT(YEAR FROM ModifiedDate) AS yr,
    Status,
    COUNT(PurchaseOrderID) AS order_cnt,
    SUM(TotalDue) AS value
FROM `adventureworks2019.Purchasing.PurchaseOrderHeader`
WHERE EXTRACT(YEAR FROM ModifiedDate) = 2014
    AND Status = 1
GROUP BY yr, Status;
