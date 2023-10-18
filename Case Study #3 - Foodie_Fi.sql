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