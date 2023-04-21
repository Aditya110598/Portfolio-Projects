

/*1. Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region*/


SELECT DISTINCT market
FROM gdb023.dim_customer
WHERE customer = 'Atliq Exclusive'
AND region = 'APAC';


/*2. What is the percentage of unique product increase in 2021 vs. 2020? 
The final output contains these fields, unique_products_2020, unique_products_2021, percentage_change*/ 


WITH up_2020_cte AS (
SELECT COUNT(DISTINCT product_code) AS unique_products_2020
FROM fact_sales_monthly
WHERE date >= '2020-01-01' AND date <= '2020-12-31'
),
up_2021_cte AS (
SELECT COUNT(DISTINCT product_code) AS unique_products_2021
FROM fact_sales_monthly
WHERE date >= '2021-01-01' AND date <= '2021-12-31'
)
SELECT
up_2020_cte.unique_products_2020,
up_2021_cte.unique_products_2021,
ROUND(((up_2021_cte.unique_products_2021 - up_2020_cte.unique_products_2020) / CAST(up_2020_cte.unique_products_2020 AS FLOAT)) * 100, 2) AS percentage_change
FROM up_2020_cte
CROSS JOIN up_2021_cte;


/*3. Provide a report with all the unique product counts for each segment and sort them in descending order of product counts. 
The final output contains 2 fields, segment, product_count*/


SELECT segment,
COUNT(DISTINCT product_code) AS product_count
FROM dim_product
GROUP BY segment
ORDER BY product_count DESC;
  
  
/*4. Which segment had the most increase in unique products in 2021 vs 2020? 
The final output contains these fields, segment, product_count_2020, product_count_2021, difference*/
  
  
WITH product_counts AS (
SELECT d.segment, YEAR(f.date) AS year,
COUNT(DISTINCT f.product_code) AS unique_products
FROM
fact_sales_monthly AS f
JOIN dim_product AS d ON f.product_code = d.product_code
GROUP BY
d.segment,
YEAR(f.date)
)
SELECT
pc_2020.segment,
pc_2020.unique_products AS product_count_2020,
pc_2021.unique_products AS product_count_2021,
pc_2021.unique_products - pc_2020.unique_products AS difference
FROM
product_counts AS pc_2020
JOIN product_counts AS pc_2021 ON pc_2020.segment = pc_2021.segment
WHERE
pc_2020.year = 2020 AND pc_2021.year = 2021
ORDER BY
difference DESC;
  
  
/*5. Get the products that have the highest and lowest manufacturing costs. 
The final output should contain these fields, product_code, product, manufacturing_cost*/
  
  
SELECT
d.product_code,
d.product,
f.manufacturing_cost
FROM
dim_product AS d
JOIN fact_manufacturing_cost AS f ON d.product_code = f.product_code
WHERE
f.manufacturing_cost = (
SELECT MAX(manufacturing_cost) FROM fact_manufacturing_cost) 
OR
f.manufacturing_cost = (
SELECT MIN(manufacturing_cost) FROM fact_manufacturing_cost);
   
   
/*6. Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market. 
The final output contains these fields, customer_code, customer, average_discount_percentage*/

    
SELECT
d.customer_code, d.customer,
ROUND(AVG(f.pre_invoice_discount_pct * 100), 2) AS average_discount_percentage
FROM
dim_customer AS d
JOIN fact_pre_invoice_deductions AS f ON d.customer_code = f.customer_code
WHERE
f.fiscal_year = 2021 AND
d.market = 'India'
GROUP BY
d.customer_code, d.customer
ORDER BY
average_discount_percentage DESC
LIMIT 5;


/*7. Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month. 
This analysis helps to get an idea of low and high-performing months and take strategic decisions. 
The final report contains these columns: Month, Year, Gross sales, Amount*/


SELECT
MONTH(fsm.date) AS Month,
YEAR(fsm.date) AS Year,
ROUND(SUM(fgs.gross_price * fsm.sold_quantity), 2) AS Gross_sales_amount
FROM
dim_customer AS d
JOIN fact_sales_monthly AS fsm ON d.customer_code = fsm.customer_code
JOIN fact_gross_price AS fgs ON fsm.product_code = fgs.product_code
WHERE d.customer = 'Atliq Exclusive'
GROUP BY
MONTH(fsm.date), YEAR(fsm.date)
ORDER BY
Year ASC, Month ASC;


/*8. In which quarter of 2020, got the maximum total_sold_quantity? 
The final output contains these fields sorted by the total_sold_quantity, Quarter, total_sold_quantity*/
  

WITH monthly_sales AS (
  SELECT 
    *,
    CASE 
      WHEN MONTH(date) BETWEEN 9 AND 11 THEN 'Q1'
      WHEN MONTH(date) BETWEEN 12 AND 2 THEN 'Q2'
      WHEN MONTH(date) BETWEEN 3 AND 5 THEN 'Q3'
      WHEN MONTH(date) BETWEEN 6 AND 8 THEN 'Q4'
    END AS quarter
  FROM fact_sales_monthly
  WHERE fiscal_year = '2020' AND customer_code = 'Atliq Hardware'
)
SELECT quarter, SUM(sold_quantity) AS total_sold_quantity
FROM monthly_sales
GROUP BY quarter
ORDER BY total_sold_quantity DESC
LIMIT 1;


/*9. Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution? 
The final output contains these fields, channel, gross_sales_mln, percentage*/


WITH sales_data AS (
  SELECT 
    f.customer_code,
    d.channel,
    MONTH(f.date) AS month,
    SUM(fg.gross_price * f.sold_quantity) AS gross_sales_mln,
    SUM(fg.gross_price * f.sold_quantity) OVER (PARTITION BY d.channel) AS channel_sales_mln
  FROM fact_sales_monthly AS f
  JOIN fact_gross_price AS fg ON f.product_code = fg.product_code
  JOIN dim_customer AS d ON f.customer_code = d.customer_code
  WHERE f.fiscal_year = '2021'
  GROUP BY f.customer_code, d.channel, MONTH(f.date)
)
SELECT 
channel, 
ROUND(SUM(gross_sales_mln), 2) AS gross_sales_mln, 
ROUND(SUM(gross_sales_mln) / SUM(channel_sales_mln) * 100, 2) AS percentage
FROM sales_data
GROUP BY channel
ORDER BY gross_sales_mln DESC
LIMIT 1;


/*10. Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021? 
The final output contains these fields, division, product_code*/


WITH sales_data AS (
  SELECT 
    d.segment,
    fs.product_code,
    SUM(fs.sold_quantity) AS total_sold_quantity,
    RANK() OVER (PARTITION BY d.segment ORDER BY SUM(fs.sold_quantity) DESC) AS rnk
  FROM 
    fact_sales_monthly fs
    JOIN dim_product d ON fs.product_code = d.product_code
  WHERE 
    fs.fiscal_year = 2021
  GROUP BY 
    d.segment,
    fs.product_code
)
SELECT 
  segment,
  product_code
FROM 
  sales_data
WHERE 
  rnk <= 3;



















