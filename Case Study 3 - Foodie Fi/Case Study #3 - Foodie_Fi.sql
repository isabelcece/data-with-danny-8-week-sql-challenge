--SECTION A: Customer Journey
--Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

SELECT customer_id,
start_date,
plan_name,
price
FROM subscriptions AS s
JOIN plans AS p ON s.plan_id = p.plan_id
WHERE customer_id <= 8
ORDER BY customer_id, start_date ASC;

--SECTION B: Data Analysis Questions

--1. How many customers has Foodie-Fi ever had?

SELECT COUNT(DISTINCT customer_id) FROM subscriptions;

--2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

SELECT
DATE_TRUNC(MONTH,start_date) AS month_of_start_date,
COUNT(DISTINCT customer_id) AS number_of_customers
FROM subscriptions AS s
JOIN plans AS p ON s.plan_id = p.plan_id
WHERE plan_name = 'trial'
GROUP BY month_of_start_date
ORDER BY month_of_start_date ASC;

--3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

SELECT plan_name,
COUNT(customer_id) AS events
FROM subscriptions AS s
JOIN plans AS p ON s.plan_id = p.plan_id
WHERE YEAR(start_date) > 2020
GROUP BY plan_name;

--4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

SELECT 
(SELECT COUNT(DISTINCT customer_id) FROM subscriptions) AS customers,
ROUND((COUNT(DISTINCT customer_id) / customers)*100, 1) AS percentage_churn
FROM subscriptions AS s
JOIN plans AS p ON s.plan_id = p.plan_id
WHERE plan_name = 'churn';

--5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

WITH cte AS(

SELECT customer_id,
MIN(plan_id) AS minimum,
MAX(plan_id) AS maximum,
COUNT(plan_id) AS number_plans
FROM subscriptions
GROUP BY customer_id)

SELECT 
COUNT(customer_id) AS churned_after_trial,
ROUND(COUNT(customer_id)/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions)*100) AS percentage
FROM cte
WHERE minimum = 0 AND maximum = 4 AND number_plans = 2;

--6. What is the number and percentage of customer plans after their initial free trial?
--If not every customer has a free trial:

WITH cte AS (
SELECT customer_id,
start_date,
plan_name,
ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY start_date) AS rn
FROM subscriptions AS s
LEFT JOIN plans AS p ON s.plan_id = p.plan_id
WHERE plan_name != 'trial')
SELECT plan_name,
COUNT(DISTINCT customer_id) AS customer_number,
ROUND(COUNT(DISTINCT customer_id)/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions)*100,1) AS customer_percent
FROM cte 
WHERE rn = 1
GROUP BY plan_name;

--If every customer has a free trial:
WITH cte AS (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY start_date) AS rn
FROM subscriptions
ORDER BY customer_id, start_date)
SELECT * FROM cte
LEFT JOIN plans on cte.plan_id = plans.plan_id
WHERE rn = 2 AND cte.plan_id = 1;

--7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

WITH cte AS(
SELECT customer_id,
MAX(start_date) AS max_date
FROM subscriptions 
WHERE start_date <= '2020-12-31'
GROUP BY customer_id)

SELECT
plan_name,
COUNT(DISTINCT(cte.customer_id)) AS customer_count,
ROUND((COUNT(DISTINCT(cte.customer_id))/(SELECT COUNT(DISTINCT(CUSTOMER_ID)) FROM subscriptions))*100,1) AS percentage
FROM cte

INNER JOIN subscriptions AS s ON cte.customer_id = s.customer_id AND start_date = max_date 
INNER JOIN plans AS p ON p.plan_id = s.plan_id

GROUP BY plan_name;

--8. How many customers have upgraded to an annual plan in 2020?

SELECT
COUNT(DISTINCT customer_id) AS customers
FROM subscriptions AS s
LEFT JOIN plans AS p ON s.plan_id = p.plan_id
WHERE YEAR(start_date) = 2020 AND CONTAINS(plan_name, 'annual');

--9. How many days on average does it take for a customer to start an annual plan from the day they join Foodie-Fi?

WITH cte AS 
(SELECT s.customer_id, DATEDIFF(day, MIN(start_date), MAX(start_date)) AS day_diff
FROM subscriptions AS s 
INNER JOIN plans AS p on s.plan_id = p.plan_id
WHERE plan_name = 'trial' OR plan_name = 'pro annual'
GROUP BY s.customer_id)
SELECT ROUND(AVG(day_diff)) AS avg_days_to_annual
FROM cte
WHERE day_diff != 0;

--10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

WITH cte AS (
SELECT s.customer_id, DATEDIFF(day, MIN(start_date), MAX(start_date)) AS day_diff,
CASE 
WHEN DATEDIFF(day, MIN(start_date), MAX(start_date)) <= 30 THEN '0-30 days'
WHEN DATEDIFF(day, MIN(start_date), MAX(start_date)) <= 60 AND DATEDIFF(day, MIN(start_date), MAX(start_date)) > 30 THEN '31-60 days'
WHEN DATEDIFF(day, MIN(start_date), MAX(start_date)) <= 90 AND DATEDIFF(day, MIN(start_date), MAX(start_date)) > 60 THEN '61-90 days'
WHEN DATEDIFF(day, MIN(start_date), MAX(start_date)) <= 120 AND DATEDIFF(day, MIN(start_date), MAX(start_date)) > 90 THEN '91-120 days'
WHEN DATEDIFF(day, MIN(start_date), MAX(start_date)) <= 150 AND DATEDIFF(day, MIN(start_date), MAX(start_date)) > 120 THEN '121-150 days'
WHEN DATEDIFF(day, MIN(start_date), MAX(start_date)) <= 180 AND DATEDIFF(day, MIN(start_date), MAX(start_date)) > 150 THEN '151-180 days'
WHEN DATEDIFF(day, MIN(start_date), MAX(start_date)) <= 210 AND DATEDIFF(day, MIN(start_date), MAX(start_date)) > 180 THEN '181-210 days'
WHEN DATEDIFF(day, MIN(start_date), MAX(start_date)) <= 240 AND DATEDIFF(day, MIN(start_date), MAX(start_date)) > 210 THEN '211-240 days'
WHEN DATEDIFF(day, MIN(start_date), MAX(start_date)) <= 270 AND DATEDIFF(day, MIN(start_date), MAX(start_date)) > 240 THEN '241-270 days'
WHEN DATEDIFF(day, MIN(start_date), MAX(start_date))<= 300 AND DATEDIFF(day, MIN(start_date), MAX(start_date)) > 270 THEN '271-300 days'
WHEN DATEDIFF(day, MIN(start_date), MAX(start_date)) <= 330 AND DATEDIFF(day, MIN(start_date), MAX(start_date)) > 300 THEN '301-330 days'
WHEN DATEDIFF(day, MIN(start_date), MAX(start_date)) <= 360 AND DATEDIFF(day, MIN(start_date), MAX(start_date)) > 330 THEN '331-360 days'
END AS bin
FROM subscriptions AS s 
INNER JOIN plans AS p on s.plan_id = p.plan_id
WHERE plan_name = 'trial' OR plan_name = 'pro annual'
GROUP BY s.customer_id)
SELECT bin,
COUNT(DISTINCT customer_id) AS customers
FROM cte
WHERE day_diff != 0
GROUP BY bin;

--11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

WITH pro_monthly AS
(SELECT customer_id,
start_date AS pro_start_date
FROM subscriptions
WHERE plan_id = 2),

basic_monthly AS 
(SELECT customer_id,
start_date AS basic_start_date
FROM subscriptions
WHERE plan_id = 1)

SELECT p.customer_id,
pro_start_date,
basic_start_date
FROM pro_monthly AS p
INNER JOIN basic_monthly AS b ON p.customer_id = b.customer_id
WHERE YEAR(basic_start_date) = 2020 
AND pro_start_date < basic_start_date;