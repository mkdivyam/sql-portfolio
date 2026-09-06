/* 
SQL Retails Sales Analysis 
SQL Project Executed by Divyanshu Medatwal, Referecing - https://www.youtube.com/watch?v=ChIQjGBI3AM
Project Start Date - 3-Sept-2026
Project Completion Date - 4-Sept-2026
*/

-- Create DatabASe names project_p1
CREATE DATABASE project_p1;
USE project_p1;

-- Create table retail_sales
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales(
	transactions_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(10),
    age INT,
    category VARCHAR(20),
    quantity INT,
    price_per_unit FLOAT,
    cogs FLOAT,
    total_sale FLOAT
);

-- validate the table properties
DESC retail_sales;

DELETE FROM retail_sales;

-- import the data through the import wizard and validate
-- check if the columns are imported in the appropriate order
-- check the number of rows in source file, and validate with the table


-- Data exploaration
SELECT * FROM retail_sales;

SELECT * FROM retail_sales
ORDER BY sale_date, sale_time;

SELECT COUNT(*) AS transaction_cnt
FROM retail_sales;

SELECT COUNT(DISTINCT customer_id) AS cust_cnt
FROM retail_sales;

SELECT COUNT(DISTINCT category) AS category_cnt
FROM retail_sales;

SELECT DISTINCT category
FROM retail_sales;


-- Data cleaning - removing the rows with any null data
-- checking the data to be removed before execution
SELECT * FROM retail_sales
WHERE 
    sale_date IS NULL
    OR sale_time IS NULL
    OR customer_id IS NULL 
    OR gender IS NULL 
    OR age IS NULL 
    OR category IS NULL 
    OR quantity IS NULL 
    OR price_per_unit IS NULL 
    OR cogs IS NULL
    OR total_sale IS NULL;

DELETE FROM retail_sales
WHERE 
    sale_date IS NULL
    OR sale_time IS NULL
    OR customer_id IS NULL 
    OR gender IS NULL 
    OR age IS NULL 
    OR category IS NULL 
    OR quantity IS NULL 
    OR price_per_unit IS NULL 
    OR cogs IS NULL
    OR total_sale IS NULL;
    
SELECT * FROM retail_sales;

-- Solving Problem Statements

-- 1. Write an SQL query to retrieve all columns for sales made on '2022-11-05'.
SELECT * FROM retail_sales
WHERE sale_date='2022-11-05';

-- 2. Write an SQL query to retrieve all transactions WHERE the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022.
SELECT * FROM retail_sales
WHERE 
	category='Clothing' 
    AND quantity>4
	AND sale_date BETWEEN '2022-11-01' AND '2022-11-30';

-- 3. Write an SQL query to calculate the total sales (total_sale) for each category.
SELECT category, SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY category;

-- 4. Write an SQL query to find the average age of customers who purchASed items FROM the 'Beauty' category.
SELECT AVG(age) AS avg_age
FROM retail_sales
WHERE category='Beauty';

-- 5. Write an SQL query to find all transactions WHERE the total_sale is greater than 1000.
SELECT * FROM retail_sales
WHERE total_sale>1000;

-- 6. Write an SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
SELECT 
	category, 
    gender, 
    COUNT(transactions_id) AS no_of_transactions
FROM retail_sales
GROUP BY category, gender;

-- 7. Write an SQL query to calculate the average sale for each month. Find out best selling month in each year.
WITH cte AS(
SELECT
	YEAR(sale_date) AS sale_year, 
	MONTH(sale_date) AS sale_month, 
    AVG(total_sale) AS avg_sale,
    RANK() OVER(PARTITION BY YEAR(sale_date) ORDER BY AVG(total_sale) DESC) AS rn
FROM retail_sales
GROUP BY YEAR(sale_date), MONTH(sale_date))
SELECT 
	sale_year, 
	sale_month AS best_month, 
    avg_sale
FROM cte
WHERE rn=1;

-- 8. Write an SQL query to find the top 5 customers bASed on the highest total sales.
SELECT customer_id, SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

-- 9. Write an SQL query to find the number of unique customers who purchASed items FROM each category.
SELECT category, COUNT(DISTINCT customer_id) AS cust_count
FROM retail_sales
GROUP BY category;

-- 10. Write an SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17).
WITH shift_sales AS (
SELECT *,
	CASE WHEN HOUR(sale_time)<12 THEN 'Morning'
    WHEN HOUR(sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
    WHEN HOUR(sale_time)>17 THEN 'Evening'
    END AS shift
FROM retail_sales)
SELECT shift, COUNT(*) AS order_count
FROM shift_sales
GROUP BY shift;


-- Bonus problems with increased difficulty and complexity
-- 11. Which product category has the highest profit margin?
SELECT 
	category,
	SUM(total_sale) AS total_sales,
	ROUND(SUM(quantity*1.0*(price_per_unit - cogs)),2) AS profit,
    ROUND(SUM(quantity*(price_per_unit - cogs))*100.0/SUM(total_sale),2) AS profit_perc
FROM retail_sales
GROUP BY category
ORDER BY profit_perc DESC;

-- 12. What percentage of customers made more than 10 purchase, and how does their average spend compare to less-frequent buyers?
WITH cte AS(
SELECT
	customer_id, 
    COUNT(transactions_id) AS order_cnt,
    SUM(total_sale) AS cust_sales,
    CASE 
		WHEN COUNT(transactions_id)<=10 THEN 'Low order volume (<=10 orders)' 
		WHEN COUNT(transactions_id)<=20 THEN 'Medium order volume (10-20 orders)'
		ELSE 'High order volume (>20 orders)'
	END AS order_volume
FROM retail_sales
GROUP BY customer_id
ORDER BY order_cnt)
SELECT
	order_volume, 
	COUNT(customer_id) AS cust_cnt,
    ROUND(COUNT(customer_id)*100.00/(SELECT COUNT(DISTINCT customer_id) FROM retail_sales),2) AS cust_share_pct,
    ROUND(SUM(cust_sales)/SUM(order_cnt),2) AS avg_order
FROM cte
GROUP BY order_volume
;

-- 13. What is the month-over-month percentage change in sales, and were there any months with a significant decline?
WITH cte AS (
SELECT 
	YEAR(sale_date) AS sale_year,
    MONTH(sale_date) AS sale_month,
    COUNT(transactions_id) AS monthly_order_cnt,
    SUM(total_sale) AS monthly_sale
FROM retail_sales
GROUP BY YEAR(sale_date), MONTH(sale_date)
ORDER BY sale_year, sale_month),
cte2 AS (
	SELECT *,
	LAG(monthly_order_cnt,1,0) OVER(ORDER BY sale_year, sale_month) AS prev_order_cnt,
	LAG(monthly_sale,1,0) OVER(ORDER BY sale_year, sale_month) AS prev_month_sale
FROM cte)
SELECT *,
	ROUND(IFNULL((monthly_order_cnt - prev_order_cnt)*100.00/prev_order_cnt,100),2) AS mom_order_perc,
    ROUND(IFNULL((monthly_sale - prev_month_sale)*100.00/prev_month_sale,100),2) AS mom_sale_perc
FROM cte2;
