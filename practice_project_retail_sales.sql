
-- creating the practice project practical database
drop database if exists `practice_project`;
create database `practice_project`;
use `practice_project`;

-- creating the table schema
create table retail_sales(
	transactions_id	 int primary key,
    sale_date	 date,
    sale_time	 time,
    customer_id	 int,
    gender	 varchar(15),
    age	 int,
    category  varchar(15),
    quantiy	 int,
    price_per_unit	 float,
    cogs	 float,
    total_sale  float
);

-- Look at the whole table
select *
from retail_sales;

-- Let us see the number of total orders or transactions
select count(*)
from retail_sales;

-- data consistency check
select customer_id, count(distinct gender)
from retail_sales
group by customer_id
order by customer_id;

-- checking for null values
select *
from retail_sales
where transactions_id is null or sale_date is null or sale_time is null	
or customer_id is null	or gender is null	or age is null	or category	is null
or quantiy is null	or price_per_unit is null	or cogs is null	or total_sale is null;

-- checking for duplicates
select transactions_id, count(*)
from retail_sales
group by transactions_id
having count(*) > 1;

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


-- Exploring the data
-- checking any loss because the cost is higher than total_sale made
select * 
from retail_sales
where cogs > total_sale;
-- In such situations perhaps increasing the price per unit would be appropraite to avoid loss

-- seeing the total cost of goods and total sales over all transactions
select sum(cogs) as total_cogs, sum(total_sale) as total_sales
from retail_sales;

-- adding profit column for enhanced exploration of the data and create insights
create view retail_sales_profit_included as
select * , round((total_sale - cogs),2) as profit
from retail_sales;

-- we can see the top profits seen
select *
from retail_sales_profit_included
order by profit desc;

-- total profit from all transactions combined
select round(sum(profit), 2) as total_profit
from retail_sales_profit_included;

-- seeing the number of unique customers in the table
select count(distinct customer_id) as no_of_customers
from retail_sales;

-- To see which category had most profit and sales. 
select category, sum(total_sale) as t_s, round(sum(profit), 2) p
from retail_sales_profit_included
group by category
order by p desc;

-- sales by date and then which date made most sales

select sale_date, sum(total_sale), sum(profit), count(*) as no_of_orders
from retail_sales_profit_included
group by sale_date
order by sale_date;

-- which dates made most sales(useful for promotions or analyzing highest buying activity
-- Tends to be Q4 and early Q1
select sale_date, sum(total_sale) t_s, sum(profit) as t_p
from retail_sales_profit_included
group by sale_date
order by t_p desc, t_s desc
limit 5;

-- which date and category made most profit and sales
select sale_date, category, sum(total_sale) m_t_s, sum(profit) as m_p
from retail_sales_profit_included
group by sale_date, category
order by m_p desc, m_t_s desc
limit 5;

-- Insights: Seems like electronics had highest max total sale and profit. 

-- to see the quantity amount for each category.
select avg(quantiy), max(quantiy), min(quantiy), category 
from retail_sales
group by category;

-- to see the price per unit per category
select avg(price_per_unit), max(price_per_unit), min(price_per_unit), category
from retail_sales
group by category;

-- Beauty category tends to have highest average price per unit

select avg(age), category
from retail_sales
group by category;

select sale_date, count(*) as orders
from retail_sales
group by sale_date
order by orders desc
limit 5;

-- which customers made consistent orders
select customer_id, count(*) as orders
from retail_sales
group by customer_id
order by orders desc;

select customer_id, count(*) as orders, sum(total_sale) as t_s, sum(total_sale)/ count(*) as average_sale_per_order
, sum(profit), sum(profit)/ count(*) as average_profit_per_order
from retail_sales_profit_included
group by customer_id
order by average_sale_per_order desc;

-- seeing how many transactions had loss(no profit).
select count(*) 
from retail_sales_profit_included
where profit < 0;

-- which category is causing less profit, maybe increase price
select category, count(*)
from retail_sales_profit_included
where profit < 0
group by category;

-- Clothing seems to have higher orders with loss. 

-- Which gender made more transactions
select gender, count(*) as orders
from retail_sales
group by gender
order by orders;

-- Females had slightly more orders than men. 

-- which gender had higher total sales over all and profit
select gender, avg(age), sum(total_sale) t_s, sum(profit) p
from retail_sales_profit_included
group by gender;

-- category and gender

select category, gender, count(*) as orders
from retail_sales_profit_included
group by category, gender
order by category;

-- Electronics had higher males ordering than females and Beauty had higher females ordering than males.

-- find the best selling months for each year(ones with most profit and most sales).
select year, month, a_t_s, a_p from
(select extract(year from sale_date) year, extract(month from sale_date) month, avg(total_sale) as a_t_s, 
avg(profit) a_p, row_number() 
over(partition by extract(year from sale_date) order by avg(total_sale) desc, avg(profit) desc) as row_num
from retail_sales_profit_included
group by year, month
order by 3 desc, 4 desc) as finding_month
where row_num = 1;
--

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





