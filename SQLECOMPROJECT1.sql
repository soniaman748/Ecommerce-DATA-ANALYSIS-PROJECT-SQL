create database Ecommerceproject;

SET SQL_SAFE_UPDATES=0;

-- run below query to use project data base once the database is imported to sql

USE Ecommerceproject;

-- check table run below query

show tables;

-- check each tables columns in details run below query

select * from productsecom;
select * from orderdetailsecom;
select * from customerecom;
select * from ordersecom;

-- NO NEED TO RUN THESE BELOW QUERY SKIP TO TASK1 - THESE ALTER QUERIES ARE USED BY ME FOR FOR DATA CLEANING 

alter table  productsecom
rename column ï»¿product_id to product_id;

alter table  orderdetailsecom
rename column ï»¿order_id to order_id;

alter table  customerecom
rename column ï»¿customer_id to customer_id;

alter table  ordersecom
rename column ï»¿order_id to order_id;

-- TASK 1 - DESCRIBE TABLES FOR DATATYPE CHECK AND OTHER ANAMOLIES

desc productsecom;
desc orderdetailsecom;
desc customerecom;
desc ordersecom;

-- T2 query below - Market Segment- cities with most customers are delhi,cheenai and jaipur 

select location,count(*) as number_of_customers
from customerecom
group by location
order by number_of_customers desc
limit 3;

select * from productsecom;
select * from orderdetailsecom;
select * from customerecom;
select * from ordersecom;

-- T3 query below - Determining how many customers fall into each order frequency category based on the number of orders they have placed.
-- Using the Orders table, calculating the number of customers who placed 1 order, 2 orders, 3 orders, etc.
-- findings - as the number of orders increase the count of customers descrease also most customers are occasional shopper orerding 1 to 3 times

with cte1 as (
select customer_id,count(order_id) as numberoforders
from ordersecom
group by customer_id
order by numberoforders asc
)
select numberoforders,count(customer_id) as customercount
from cte1
group by numberoforders
order by numberoforders asc;

-- T4 query below-Identifing products where the average purchase quantity per order is 2 but with a high total revenue, 
-- suggesting premium product trends.
-- findings - productid 1 has highest total revenue

select * from orderdetailsecom;

select product_id,avg(quantity) as avgquantity ,sum(quantity*price_per_unit) as totalrevenue
from orderdetailsecom
group by product_id
having avgquantity =2
order by totalrevenue desc;

-- T5 Below - For each product category, calculating the unique number of customers purchasing from it. 
-- This will help understand which categories have wider appeal across the customer base.
-- findings -- electronic as a category has high demand between customers

select * from productsecom;
select * from orderdetailsecom;
select * from customerecom;
select * from ordersecom;

select p.category,count(distinct(o.customer_id)) as unique_customers
from productsecom p 
join orderdetailsecom od 
on p.product_id = od.product_id
join ordersecom o
on od.order_id = o.order_id 
group by p.category
order by unique_customers desc;

-- T6 Below - Analyzing the month-on-month percentage change in total sales to identify growth trends.
-- As per Sales Trend Analysis, During 2024 - in feb month the sales experience the largest decline
-- As per Sales Trend Analysis no clear sales trend from March to August

select * from ordersecom;

with cte1 as(
select date_format(order_date,"%Y-%m") as month,
sum(total_amount) as totalsales
from ordersecom
group by month
order by month asc
),
cte2 as (
select month,totalsales,lag(totalsales) over(
order by month
) as previousmonthsales
from cte1
)
select month,
totalsales,
round(((totalsales-previousmonthsales)/previousmonthsales)*100,2) as percentagechange
from cte2
order by month;

-- T7 Below- Examine how the average order value changes month-on-month. 
-- Insights can guide pricing and promotional strategies to enhance order value.
-- dec month has the highest change in avg order value representing customers spending more in december on products

select * from ordersecom;

with cte1 as (
select date_format(order_date,"%Y-%m") as Month,
round(avg(total_amount),2) as AvgOrderValue
from ordersecom
group by month
),
cte2 as (
select Month,AvgOrderValue,lag(AvgOrderValue) over(
order by Month
) as previousmonthsales
from cte1
)
select Month,
AvgOrderValue,
round((AvgOrderValue-previousmonthsales),2) as ChangeInValue
from cte2
order by ChangeInValue desc ;

-- T8 BELOW- Based on sales data, identifing products with the fastest turnover rates,suggesting high demand and the need for frequent restocking.
-- FINDINGS- Based on analysis productid 7 has highest turnover rate and need frequent restocking

select * from orderdetailsecom;

select product_id,count(order_id) as SalesFrequency
from orderdetailsecom
group by product_id
order by SalesFrequency desc
limit 5; 

-- T9 Below -finding products purchased by less than 40% of the customer base,
-- indicating potential mismatches between inventory and customer interest.
-- findings- product name smartphone6 and wireless earbuds have been purchased by <40% of the 
-- cx indicating less visibility of these products on platform,we can increase marketing and awareness of these products among customers

select * from productsecom;
select * from orderdetailsecom;
select * from customerecom;
select * from ordersecom;

select p.product_id,p.name,count(distinct(o.customer_id)) as UniqueCustomerCount
from productsecom p 
join orderdetailsecom od 
on p.product_id = od.product_id
join ordersecom o 
on od.order_id = o.order_id
join customerecom c 
on o.customer_id = c.customer_id
group by p.product_id,p.name
having UniqueCustomerCount < (
select count(distinct(customer_id))*0.40
from customerecom);

-- T10 Below - Evaluating the month-on-month growth rate in the customer base to
-- understand the effectiveness of marketing campaigns and market expansion efforts.
-- findings - the customer base is in downward trend representing  marketing campaigns are not much effective

select *  from ordersecom;

with cte1 as (
select customer_id,min(order_date) as FirstPurchase
from ordersecom
group by customer_id
)
select date_format(FirstPurchase,"%Y-%m") as FirstPurchaseMonth,
count(customer_id) as TotalNewCustomers
from cte1
group by FirstPurchaseMonth
order by FirstPurchaseMonth;

-- T11 Below - Identifing the months with the highest sales volume, aiding in planning for stock levels, 
-- marketing efforts, and staffing in anticipation of peak demand periods.
-- based on the analysis month of sept and dec will require heavy restocking and more staff as th sales will spike in these month

select * from ordersecom;

select date_format(order_date,"%Y-%M") as Month,
sum(total_amount) as TotalSales
from ordersecom
group by Month
order by TotalSales desc
limit 3;

--  CONCLUSION - The new customer are on a declining trend need better marketing campaingn for inviting new customers
-- Products like smartphone6 and wireless earbuds are require more visibility on platform
-- purchase value will increase in month of sept and dec need frequent restocking and more staff in these month
-- Productid  7 name Digital SLR Camera has highest turnover rate and need frequent restocking
-- During 2024 - in feb month the sales experience the largest decline , but no clear sales trend is seen 
-- electronic as a category has high demand between customers