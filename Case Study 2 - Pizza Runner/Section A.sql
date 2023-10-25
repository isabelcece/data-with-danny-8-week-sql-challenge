--1. How many pizzas were ordered?

SELECT COUNT(pizza_id) AS number_of_pizzas
FROM customer_orders;

--2. How many unique customer orders were made?

SELECT COUNT(DISTINCT order_id) AS unique_customer_orders
FROM customer_orders;

--3. How many successful orders were delivered by each runner?

SELECT 
runner_id,
COUNT(order_id) AS successful_orders
FROM runner_orders
WHERE cancellation IS NULL
OR LOWER(cancellation) NOT LIKE '%cancel%'
GROUP BY runner_id;

--4. How many of each type of pizza was delivered?

SELECT 
    p.pizza_name,
    COUNT(o.order_id) AS number_delivered
FROM customer_orders AS o
    JOIN pizza_names AS p ON o.pizza_id = p.pizza_id
    JOIN runner_orders AS r ON o.order_id = r.order_id
WHERE cancellation IS NULL
    OR LOWER(cancellation) NOT LIKE '%cancel%'
GROUP BY p.pizza_name;

--5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT
    customer_id,
    pizza_name,
    COUNT(o.order_id) AS number_ordered
FROM customer_orders AS o
    INNER JOIN pizza_names AS p ON o.pizza_id = p.pizza_id
GROUP BY customer_id, pizza_name;

--6. What was the maximum number of pizzas delivered in a single order?

SELECT
    o.order_id,
    COUNT(pizza_id) AS number_pizzas
FROM customer_orders AS o
    INNER JOIN runner_orders AS r ON o.order_id = r.order_id
WHERE pickup_time <> 'null'
GROUP BY o.order_id
ORDER BY number_pizzas DESC 
LIMIT 1;

--7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
    
SELECT 
    customer_id,
    CASE
    WHEN (exclusions IS NULL OR exclusions = 'null' OR exclusions = '')
    AND (extras IS NULL OR extras = 'null' OR extras = '')THEN 'No changes'
    ELSE 'Changes'
    END AS changes,
    COUNT(pizza_id) AS number_pizzas
FROM customer_orders AS c
    INNER JOIN runner_orders AS r
    ON c.order_id = r.order_id
WHERE pickup_time <> 'null'
GROUP BY customer_id, changes
ORDER BY customer_id;

--8. How many pizzas were delivered that had both exclusions and extras?

SELECT 
    COUNT(pizza_id) AS pizzas_with_exclusions_and_extras
FROM customer_orders AS c
    INNER JOIN runner_orders AS r
    ON c.order_id = r.order_id
WHERE pickup_time <> 'null'
AND exclusions <> 'null' AND length(exclusions) >0
AND extras <> 'null' AND length(extras) >0;

--9. What was the total volume of pizzas ordered for each hour of the day?

SELECT 
    DATE_PART('hour',order_time) AS order_hour,
    COUNT(pizza_id) AS pizza_volume
FROM customer_orders
GROUP BY order_hour
ORDER BY order_hour;

--10. What was the volume of orders for each day of the week?


SELECT 
    DAYNAME(order_time) AS order_day,
    COUNT(pizza_id) AS pizza_volume
FROM customer_orders
GROUP BY order_day;