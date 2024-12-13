# let's get a sense for the data -- e.g., time range

SELECT MIN(purchase_date), MAX(purchase_date)
FROM orders o;

# the data is currently for the full calendar year 2021

SELECT DISTINCT state, COUNT(city) AS cities
FROM customers c
GROUP BY state
ORDER BY cities DESC ;

# we have 31 states and they range from 12-203 cities


#1. Which product has generated the top percentage of revenue in 2021?
SET @lifetime = (SELECT SUM(quantity*price_per_unit) FROM order_details od);

SELECT p.product_name, FORMAT(SUM(od.quantity*od.price_per_unit),0) AS revenue, 100*round(SUM(quantity*price)/@lifetime,2) AS pct_revenue
FROM order_details od 
LEFT JOIN products p 
ON od.product_id = p.product_id
GROUP BY p.product_name
ORDER BY pct_revenue DESC
LIMIT 1;

# smart home speaker has generated the greatest percentage of revenue in 2021.

# 2. By category, how has revenue changed quarter-over-quarter between the latest two quarters?
WITH 
	cte1 AS (SELECT product_id, SUM(total_amount) AS Q3 FROM orders o WHERE QUARTER(purchase_date) = 3 GROUP BY product_id),
	cte2 AS (SELECT product_id, SUM(total_amount) AS Q4 FROM orders o WHERE QUARTER(purchase_date) = 4 GROUP BY product_id)
SELECT p.category, sum(Q3) AS Q3, sum(Q4) AS Q4, SUM(Q4)-SUM(Q3) AS difference
FROM products p JOIN cte1 ON p.product_id = cte1.product_id
	JOIN cte2 ON p.product_id = cte2.product_id
GROUP BY p.category 
ORDER BY difference

# kitchen and electronics sales went down, home goods went up

# 3. Which customer segments (defined by total spending) contribute to the top 20% of cumulative customer lifetime value?
WITH 
	cte AS (SELECT c.gender, c.state,  AVG(age) AS avg_age, COUNT(c.customer_id) AS existing_customers, SUM(o.total_amount) AS segment_revenue FROM customers c JOIN orders o WHERE c.customer_id = o.customer_id GROUP BY gender, state ORDER BY gender, state)
SELECT gender, state, ROUND(avg_age,0) AS avg_age
	, ROUND(segment_revenue/existing_customers,2) AS avg_ltv
	, ROUND(100*segment_revenue/@lifetime,2) AS pct_total_revenue
	, ROUND(100*(SUM(segment_revenue) OVER(PARTITION BY gender))/@lifetime,2) AS gender_pct_revenue
	, ROUND(100*(SUM(segment_revenue) OVER(PARTITION BY state))/@lifetime,2) AS state_pct_revenue	
FROM  cte
GROUP BY gender, state
ORDER BY pct_total_revenue DESC 
LIMIT 10

#  Male Californians represent the largest percent of total cumulative revenue, with Female Californians close behind. 
# In doing this exercise; however, we can see that the average age of our customers is very high. As such, we would recommend
# taking a closer look at the age ranges of the customer base.

SELECT 
CASE
    WHEN age < 25 THEN '24 and under'
    WHEN age BETWEEN 25 and 34 THEN '25 - 34'
    WHEN age BETWEEN 35 and 44 THEN '35 - 44'
    WHEN age BETWEEN 45 and 54 THEN '45 - 54'
    WHEN age BETWEEN 55 and 74 THEN '55 - 74'
    WHEN age >= 75 THEN '75+'
    WHEN age IS NULL THEN NULL 
END as age_range,
ROUND(COUNT(*)/(COUNT(*) OVER ()),1) AS pct_customers,
ROUND(SUM(total_amount),2) AS total_revenue,
ROUND(100*SUM(total_amount)/@lifetime,1) AS pct_total_revenue 
FROM customers c JOIN orders o ON c.customer_id =o.customer_id 
GROUP BY age_range
ORDER BY age_range

# we have confirmed that the top age segment, both in percentage of customers and percentage of revenue, are individuals 75+

/* 4. What are the month-to-month sales variations for each product category, 
 identifying statistically significant seasonal peaks and troughs?*/ 

WITH 
	cte AS (SELECT MONTH(o.purchase_date) AS sales_month, o.product_id, SUM(od.total_amount) AS total_revenue
		FROM orders o LEFT JOIN order_details od ON o.order_id = od.order_id 
		GROUP BY MONTH(o.purchase_date), o.product_id 
		ORDER BY MONTH(o.purchase_date), o.product_id)
SELECT 
  c.sales_month,
  SUM(c.total_revenue) AS total_revenue,
  SUM(CASE WHEN p.category = 'Electronics' THEN c.total_revenue ELSE 0 END) AS 'electronics',
  SUM(CASE WHEN p.category = 'Home Goods' THEN total_revenue ELSE 0 END) AS 'home_goods',
  SUM(CASE WHEN p.category = 'Kitchen' THEN total_revenue ELSE 0 END) AS 'kitchen'
FROM cte c LEFT JOIN products p ON c.product_id = p.product_id 
GROUP BY c.sales_month
ORDER BY c.sales_month;

# We can see that Electronics had peaks in April and August, Home Goods is relatively flat, and Kitchen is more erratic. 

# Let's see what the pct change MoM by category looks like
WITH 
	cte AS (SELECT MONTH(o.purchase_date) AS sales_month, o.product_id, SUM(od.total_amount) AS total_revenue
		FROM orders o LEFT JOIN order_details od ON o.order_id = od.order_id 
		GROUP BY MONTH(o.purchase_date), o.product_id 
		ORDER BY MONTH(o.purchase_date), o.product_id),
	cte2 AS (SELECT c.sales_month, SUM(c.total_revenue) AS total_revenue, 
		SUM(CASE WHEN p.category = 'Electronics' THEN c.total_revenue ELSE 0 END) AS 'electronics', 
		SUM(CASE WHEN p.category = 'Home Goods' THEN total_revenue ELSE 0 END) AS 'home_goods', 
		SUM(CASE WHEN p.category = 'Kitchen' THEN total_revenue ELSE 0 END) AS 'kitchen'
		FROM cte c LEFT JOIN products p ON c.product_id = p.product_id 
		GROUP BY c.sales_month
		ORDER BY c.sales_month)
SELECT
 c2.sales_month,
  ROUND(100*((c2.total_revenue - LAG(c2.total_revenue) OVER (ORDER BY c2.sales_month))/c2.total_revenue),2) AS change_revenue, 
  ROUND(100*((c2.electronics - LAG(c2.electronics) OVER (ORDER BY c2.sales_month))/c2.electronics),2) AS change_electronics, 
  ROUND(100*((c2.home_goods - LAG(c2.home_goods) OVER (ORDER BY c2.sales_month))/c2.home_goods),2) AS change_home_goods, 
  ROUND(100*((c2.kitchen - LAG(c2.kitchen) OVER (ORDER BY c2.sales_month))/c2.kitchen),2) AS change_kitchen
FROM cte2 c2
ORDER BY c2.sales_month;

/* We can now see those shifts over each month a bit clearer. We can see a large drop in overall revenue from April to May.
 * August now really stands out for electronics with a dip preceeding and following.
 * Home Goods' peaks and valleys are the shallowest of the categories. Its best month was in February.
 * Kitchen had its extremes at the begining of the year and has been softening throughout the year. 
