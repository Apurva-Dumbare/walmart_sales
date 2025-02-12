select * from walmart;

select count(*) from walmart;

select
distinct payment_method,
count(*)
from walmart
group by payment_method;

select 
	count(distinct branch)
	from walmart;

select min(quantity) from walmart;

-- 1. Analyze Payment Methods and Sales
-- ● Question: What are the different payment methods, and how many transactions and
-- items were sold with each method?
-- ● Purpose: This helps understand customer preferences for payment methods, aiding in
-- payment optimization strategies
select 
	payment_method, 
	count(*) as transcation_count,
	sum(quantity) as item_sold
	from walmart
	group by payment_method;

-- 2. Identify the Highest-Rated Category in Each Branch
-- ● Question: Which category received the highest average rating in each branch?
-- ● Purpose: This allows Walmart to recognize and promote popular categories in specific
-- branches, enhancing customer satisfaction and branch-specific marketing.
select * from
(select
	branch,
	category,
	avg(rating) as avg_rating,
	rank() over(partition by branch order by avg(rating) desc) as rank
	from walmart
	group by 1,2
	order by 1,3 desc
) where rank =1;

-- 3. Determine the Busiest Day for Each Branch
-- ● Question: What is the busiest day of the week for each branch based on transaction
-- volume?
-- ● Purpose: This insight helps in optimizing staffing and inventory management to
-- accommodate peak days.
select * from 
(select
	branch,
	to_char(to_date(date,'DD/MM/YY'),'Day') as day_name,
	count(*) as No_of_Transcations,
	rank() over(partition by branch order by count(*) desc ) as rank
from walmart
group by 1,2
) where rank =1;

	
-- 4. Calculate Total Quantity Sold by Payment Method
-- ● Question: How many items were sold through each payment method?
-- ● Purpose: This helps Walmart track sales volume by payment type, providing insights
-- into customer purchasing habits.
select
	payment_method,
	sum(quantity) as total_quantity_sold
from walmart
	group by payment_method
	order by 1,2;

-- 5. Analyze Category Ratings by City
-- ● Question: What are the average, minimum, and maximum ratings for each category in
-- each city?
-- ● Purpose: This data can guide city-level promotions, allowing Walmart to address
-- regional preferences and improve customer experiences.

select
	city,
	category,
	min(rating) as minimum_rating,
	max(rating) as maximum_rating,
	avg(rating) as Avg_rating
from walmart
	group by category,city
	order by city;

-- 6. Calculate Total Profit by Category
-- ● Question: What is the total profit for each category, ranked from highest to lowest?
-- ● Purpose: Identifying high-profit categories helps focus efforts on expanding these
-- products or managing pricing strategies effectively.
select 
	category,
	sum(total) as total_sales,
	rank() over(order by sum(total) desc) as rank
from walmart
	group by category
	order by total_sales desc;

-- 7. Determine the Most Common Payment Method per Branch
-- ● Question: What is the most frequently used payment method in each branch?
-- ● Purpose: This information aids in understanding branch-specific payment preferences,
-- potentially allowing branches to streamline their payment processing systems.

with payment_rank as(
	select 
		branch,
		payment_method,
		count(payment_method) as usage_count,
		rank() over(partition by branch order by count(payment_method)desc ) as rank
	from walmart
	group by 1,2
)
select branch,payment_method,usage_count 
from payment_rank
where rank =1 
order by branch;
	

-- 8. Analyze Sales Shifts Throughout the Day
-- ● Question: How many transactions occur in each shift (Morning, Afternoon, Evening)
-- across branches?
-- ● Purpose: This insight helps in managing staff shifts and stock replenishment schedules,
-- especially during high-sales periods.

select 
 branch,
	case
		when extract(hour from (time::Time)) < 12 then 'Morning'
		when extract(hour from (time::Time)) between 12 and 17 then 'Afternoon'
		else 'Evening'
	end as day_time,
	count(*) as total_transcations
from walmart
group by 1,2
order by 1,3 desc;


-- 9. Identify Branches with Highest Revenue Decline Year-Over-Year
-- ● Question: Which branches experienced the largest decrease in revenue compared to
-- the previous year?
-- ● Purpose: Detecting branches with declining revenue is crucial for understanding
-- possible local issues and creating strategies to boost sales or mitigate losses.10. Top Products by Quantity Sold
-- Purpose: Identifying the best-selling products helps with inventory management and demand forecasting.

-- rdr = last_rev-cr_rev /ls_rev *100
select *,
extract(year from to_date(date,'DD/MM/YY')) as formatted_date
from walmart

--2022 revenue
with revenue_2022
as
(
	select 
		branch,
		sum(total) as revenue
	from walmart
	where extract(year from to_date(date,'DD/MM/YY'))= 2022
	group by 1
),

revenue_2023
as
(
	select 
		branch,
		sum(total) as revenue
	from walmart
	where extract(year from to_date(date,'DD/MM/YY'))= 2023
	group by 1
)
select 
	ls.branch,
	ls.revenue as Last_year_revenue,
	cs.revenue as Current_year_revenue,
	round(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue :: numeric * 100,
		2) as revenue_decrease_ratio
from revenue_2022 as ls
join revenue_2023 as cs
on ls.branch = cs.branch
where ls.revenue > cs.revenue
order by 4 desc
limit 5

-- 10. Top Products by Quantity Sold
-- Question: Which products (based on category or invoice) are sold the most in terms of quantity?
-- Purpose: Identifying the best-selling products helps with inventory management and demand forecasting.
select 
	category,
	sum(quantity) as total_quantity_sold
from walmart
group by category
order by 2 desc;

-- 11. Sales Performance Comparison by Branch and Category
-- Question: How does sales performance compare across different branches for each category?
-- Purpose: This allows Walmart to identify branch-specific trends and tailor marketing or stock strategies for each branch.
select 
	branch,
	category,
	sum(total) as Total_sales
from walmart
 group by category,branch
 order by 1,3 desc;
 

-- 12. Product Rating vs. Quantity Sold
-- Question: Is there a correlation between the product ratings and the quantity sold?
-- Purpose: Understanding if higher-rated products lead to better sales can inform stock and promotional decisions.
select
	category,
	rating,
	sum(quantity) as quantity_sold
from walmart
group by 1,2
order by 2 desc
-- 13. Payment Method Popularity Over Time
-- Question: How does the popularity of different payment methods change over time?
-- Purpose: This helps Walmart track trends in payment preferences, guiding the company on where to focus payment system improvements.

SELECT
    TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'YYYY-MM') AS month,
    payment_method,
    COUNT(*) AS payment_count
FROM walmart
GROUP BY month, payment_method
ORDER BY month DESC, payment_count DESC;


-- 14. Revenue Breakdown by Time of Day and Payment Method
-- Question: How do revenue and payment methods vary by different times of the day?
-- Purpose: Understanding which payment methods are used more frequently during specific hours helps optimize staffing and payment processing.

SELECT
    CASE
        WHEN EXTRACT(HOUR FROM TO_TIMESTAMP(time, 'HH24:MI:SS')) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM TO_TIMESTAMP(time, 'HH24:MI:SS')) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day,
    payment_method,
    SUM(total) AS total_revenue
FROM walmart
GROUP BY time_of_day, payment_method
ORDER BY time_of_day, total_revenue DESC;


-- 15. Customer Rating Impact on Sales
-- Question: Do higher-rated products result in higher sales in specific branches?
-- Purpose: This helps Walmart decide which products to focus on, based on customer satisfaction and sales performance.

SELECT
    branch,
    rating,
    SUM(total) AS total_sales
FROM walmart
GROUP BY branch, rating
ORDER BY branch, rating DESC;
