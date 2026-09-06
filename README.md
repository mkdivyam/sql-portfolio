# Retail Sales Analysis SQL Project with Additional Business Problems

## Project Overview

**Project Title**: Retail Sales Analysis  
**Level**: Intermediate  
**Database**: `project_p1`  
**Publish On**: `04-Sep-2026`  
**References**: https://www.youtube.com/watch?v=ChIQjGBI3AM (Questions 1–10 based on this tutorial; Questions 11–13 are original extensions)


## Intent
This project is built primarily for personal familiarity with presenting the skills through the portfolio project(s). Although, this project demonstrates SQL skills and techniques typically used by data analysts, it's utility involves creating the git project, uploading and organising the work files, and documentation of the project. The project involves setting up a retail sales database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries.

## Objectives
1. **Set up a GIT Project**: Create the project and organise the work files in intuitive hierarchy.
2. **Document the Project**: Note down the objectives, structures, and problem statements. Format the script file to ensure readability.
3. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
4. **Data Cleaning**: Identify and remove any records with missing or null values.
5. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
6. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `project_p1`.
- **Table Creation**: A table named `retail_sales` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
CREATE DATABASE project_p1;
USE project_p1;

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

DESC retail_sales;
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.

```sql
SELECT COUNT(*) FROM retail_sales;
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
SELECT DISTINCT category FROM retail_sales;

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
```

### 3. Data Analysis & Findings (Question #1 - 10: from the reference tutorial)

The following SQL queries were developed to answer specific business questions:

1. **Write an SQL query to retrieve all columns for sales made on '2022-11-05.**
```sql
SELECT * FROM retail_sales
WHERE sale_date='2022-11-05';
```

2. **Write am SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022.**
```sql
SELECT * FROM retail_sales
WHERE 
	category='Clothing' 
    AND quantity>4
	AND sale_date BETWEEN '2022-11-01' AND '2022-11-30';
```

3. **Write an SQL query to calculate the total sales (total_sale) for each category.**
```sql
SELECT category, SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY category;
```

4. **Write an SQL query to find the average age of customers who purchased items from the 'Beauty' category.**
```sql
SELECT AVG(age) AS avg_age
FROM retail_sales
WHERE category='Beauty';
```

5. **Write an SQL query to find all transactions where the total_sale is greater than 1000.**
```sql
SELECT * FROM retail_sales
WHERE total_sale>1000;
```

6. **Write an SQL query to find the total number of transactions (transaction_id) made by each gender in each category.**
```sql
SELECT 
	category, 
    gender, 
    COUNT(transactions_id) AS no_of_transactions
FROM retail_sales
GROUP BY category, gender;
```

7. **Write an SQL query to calculate the average sale for each month. Find out best selling month in each year.**
```sql
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
```

8. **Write an SQL query to find the top 5 customers based on the highest total sales.**
```sql
SELECT customer_id, SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;
```

9. **Write an SQL query to find the number of unique customers who purchased items from each category.**
```sql
SELECT category, COUNT(DISTINCT customer_id) AS cust_count
FROM retail_sales
GROUP BY category;
```

10. **Write an SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17).**
```sql
WITH shift_sales AS (
SELECT *,
	CASE WHEN HOUR(sale_time)<12 THEN 'Morning'
    WHEN HOUR(sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
    WHEN HOUR(sale_time)>17 THEN 'Evening'
    END AS shift
FROM retail_sales)
SELECT shift, count(*) AS order_count
FROM shift_sales
GROUP BY shift;
```

### Original Extensions (Question #11-13)
*The following three questions extend beyond the reference tutorial, exploring profitability, customer retention, and trend analysis:*

11. **Which product category has the highest profit margin?**
```sql
SELECT 
	category,
	SUM(total_sale) AS total_sales,
	ROUND(SUM(quantity*1.0*(price_per_unit - cogs)),2) AS profit,
    ROUND(SUM(quantity*(price_per_unit - cogs))*100.0/SUM(total_sale),2) AS profit_perc
FROM retail_sales
GROUP BY category
ORDER BY profit_perc DESC;
```

12. **What percentage of customers made more than 10 purchase, and how does their average spend compare to less-frequent buyers?**
```sql
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
GROUP BY order_volume;
```

13. **What is the month-over-month percentage change in sales, and were there any months with a significant decline?**
```sql
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
```


## Findings

- **Customer Demographics**: The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing and Beauty.
- **High-Value Transactions**: Several transactions had a total sale amount greater than 1000, indicating premium purchases.
- **Sales Trends**: Monthly analysis shows variations in sales, helping identify peak seasons.
- **Customer Insights**: The analysis identifies the top-spending customers and the most popular product categories.
- **Category Profit Margins**: Category level profit margins are broadly consistent across the categories, with slight deviations.
- **Buyers' Frequency**: Over half of the customers have shopped less than 10 times. Little over 6% of the customers have more than 20 transactions. Nevertheless, the average order amount is broadly consistent across all the customer groups.
- **M-o-M Percentage Change**: There has been a significant decline (>20%) in sales during February each year. 

## Reports

- **Sales Summary**: A detailed report summarizing total sales, customer demographics, and category performance.
- **Trend Analysis**: Insights into sales trends across different months and shifts.
- **Customer Insights**: Reports on top customers and unique customer counts per category.

## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.

## How to Use

1. **Clone the Repository**: Clone this project repository from GitHub.
2. **Set Up the Database**: Run the SQL scripts provided in the `query_p1.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries provided in the `query_p1.sql` file to perform your analysis.
4. **Explore and Modify**: Feel free to modify the queries to explore different aspects of the dataset or answer additional business questions.

## Author - Divyanshu Medatwal

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!
