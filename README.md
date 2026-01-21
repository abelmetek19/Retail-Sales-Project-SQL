# Retail Sales Analysis SQL Project

## Project Overview

**Project Title**: Retail Sales Analysis  
**Level**: Starter Project Practical  
**Database**: `practice_project`

Built a strong foundation in SQL by performing data cleaning, exploratory analysis, and basic business insights on retail sales data.

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `p1_retail_db`.
- **Table Creation**: A table named `retail_sales` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
-- creating the practice project practical database
drop database if exists `practice_project`;
create database `practice_project`;
use `practice_project`;

CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,	
    sale_time TIME,
    customer_id INT,	
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT
);
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.
- **Duplicate Check**: Check for any duplicated values in the dataset.
- **Data Consistency Checks**: Checking for any errors or bad data within columns.

```sql
-- Look at the whole table
select *
from retail_sales;

-- Let us see the number of total orders or transactions
select count(*)
from retail_sales;

-- checking for duplicates
select transactions_id, count(*)
from retail_sales
group by transactions_id
having count(*) > 1;

-- count categories
select count(distinct category)
from retail_sales;

-- seeing the number of unique customers in the table
select count(distinct customer_id) as no_of_customers
from retail_sales;

-- checking for null values
select *
from retail_sales
where transactions_id is null or sale_date is null or sale_time is null	
or customer_id is null	or gender is null	or age is null	or category	is null
or quantiy is null	or price_per_unit is null	or cogs is null	or total_sale is null;

-- deleting null values
delete
from retail_sales
where transactions_id is null or sale_date is null or sale_time is null	
or customer_id is null	or gender is null	or age is null	or category	is null
or quantiy is null	or price_per_unit is null	or cogs is null	or total_sale is null;

-- data consistency, legal age bounds
select min(age) as min_age, max(age) as max_age
from retail_sales;

-- data consistency check on category making sure there is no errors on this column
-- or that categories makes sense
select distinct category
from retail_sales;

-- data consistency, quantity should not be <= 0
select distinct quantiy
from retail_sales;

-- date consistency check
select min(sale_date), max(sale_date)
from retail_sales;

-- time consistency check
select min(sale_time), max(sale_time)
from retail_sales;

-- checking the price ranges per unit shouldn't be negative or 0
select min(price_per_unit), max(price_per_unit)
from retail_sales;
-- checking the cost of goods, this also shouldn't be negative or 0
select min(cogs), max(cogs)
from retail_sales;
-- checking the total_sale, this also shouldn't be negative or 0
select min(total_sale), max(total_sale)
from retail_sales;

-- check gender column for consistency and errors or formats
select distinct gender
from retail_sales;

-- checking correct total_sale value which should be quantity multiplied by the price of the unit
select *
from retail_sales
where total_sale <> quantiy * price_per_unit;

```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Checking transactions which had loss(where cost of goods was greater than total_sales)**:
```sql
-- Exploring the data
-- checking any loss because the cost is higher than total_sale made
select * 
from retail_sales
where cogs > total_sale;
-- In such situations, perhaps increasing the price per unit would be appropriate to avoid loss
```

2. **Total cost of goods and total sales over all transactions**:
```sql
-- seeing the total cost of goods and total sales over all transactions
select sum(cogs) as total_cogs, sum(total_sale) as total_sales
from retail_sales;
```

3. **Adding Profit column and calculating profit over all transactions**:
```sql
-- adding profit column for enhanced exploration of the data and create insights
create view retail_sales_profit_included as
select * , round((total_sale - cogs),2) as profit
from retail_sales;

-- total profit from all transactions combined
select round(sum(profit), 2) as total_profit
from retail_sales_profit_included;
```

4. **Which category had the most profit and sales?**:
```sql
-- To see which category had most profit and sales. 
select category, sum(total_sale) as t_s, round(sum(profit), 2) p
from retail_sales_profit_included
group by category
order by p desc;
-- The clothing category had most profit and sales compared to beauty or electronics. 
```

5. **Total Sales, Profit and number of orders per sale dates.**:
```sql
-- sales by date
select sale_date, sum(total_sale), sum(profit), count(*) as no_of_orders
from retail_sales_profit_included
group by sale_date
order by sale_date;
```

6. **Which dates made most sales?**:
```sql
-- which dates made most sales(useful for promotions or analyzing highest buying activity
-- Tends to be Q4 due to the major holidays.
select sale_date, sum(total_sale) t_s, sum(profit) as t_p
from retail_sales_profit_included
group by sale_date
order by t_p desc, t_s desc
limit 5;
```

7. **Write a SQL query to calculate the average sale for each month. Find out best selling month in each year**:
```sql
SELECT 
       year,
       month,
    avg_sale
FROM 
(    
SELECT 
    EXTRACT(YEAR FROM sale_date) as year,
    EXTRACT(MONTH FROM sale_date) as month,
    AVG(total_sale) as avg_sale,
    RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) as rank
FROM retail_sales
GROUP BY 1, 2
) as t1
WHERE rank = 1
```

8. **Which customers made highest total orders? **:
```sql
-- which customers made consistent orders
select customer_id, count(*) as orders
from retail_sales
group by customer_id
order by orders desc
limit 5;
```

9. **Which gender had more transactions and which gender had higher total sales overall and profit**:
```sql
select gender, count(*) as orders
from retail_sales
group by gender
order by orders;

select gender, avg(age) avg_age, sum(total_sale) t_s, sum(profit) t_p
from retail_sales_profit_included
group by gender;
```

10. **Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)**:
```sql
-- To see which timeframes had most sales and profit for strategic marketing times.
select shift, sum(total_sale) as t_s, sum(profit) as p
from (select *, 
case 
when extract(hour from sale_time) < 12 then 'Morning'
when extract(hour from sale_time) between 12 and 17 then 'Afternoon'
when extract(hour from sale_time) > 17 then 'Evening'
end as shift
from retail_sales_profit_included) time
group by shift;

-- Evening time had most sales and profit, perhaps because evening time people have more time to 
-- buy rather than other times which they may work.
```

## Findings

- **Customer Demographics**: The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing, Electronics and Beauty.
- **High-Value Transactions**: Several transactions had a total sale amount greater than 1000, indicating premium purchases.
- **Sales Trends**: Seeing that Q4 had highest orders and total_sales and profit
- **Customer Insights**: The analysis identifies the high-ordering customers and the most popular product categories.

## Reports

- **Marketing and Maximizing Profit**: By identifying customers who place high total orders and are likely to order again, analyzing which dates generated the highest sales, profit, and order volumes for promotional planning, understanding which times of day (morning, afternoon, or evening) see the most ordering activity, and determining which product categories generate the highest total sales and profit, businesses can make targeted, data-driven marketing and profitability decisions.
- **Minimizing Costs and Increasing Profitability**: By identifying non-profitable transactions at the category level, businesses can evaluate pricing strategies—such as adjusting the price per unit—to help reduce losses and improve overall profitability.

## Conclusion

Overall, this project helped strengthen SQL skills through hands-on practice in basic data cleaning, exploratory data analysis, and generating meaningful insights from retail sales data to support data-driven business decision-making.
