--1. What is the total amount each customer spent at the restaurant?

SELECT sales.customer_id, SUM(menu.price) AS total_spend FROM sales
LEFT JOIN menu
ON sales.product_id = menu.product_id
GROUP BY customer_id;

-- 2. How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(DISTINCT order_date) AS number_of_days
FROM sales
GROUP BY customer_id ;

-- 3. What was the first item from the menu purchased by each customer? (if a customer ordered multiple products you can just pick one)

SELECT customer_id, 
MIN(order_date) AS first_order_date, 
MIN(product_name) AS first_product
FROM sales
INNER JOIN menu ON sales.product_id = menu.product_id
GROUP BY customer_id  
ORDER BY customer_id;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT TOP 1 M.product_name, 
COUNT(S.product_id) AS number_of_orders 
FROM sales AS S
INNER JOIN menu AS M ON S.product_id = M.product_id
GROUP BY product_name
ORDER BY COUNT(S.product_id) DESC;

-- 5. Which item was the most popular for each customer?

WITH cust_orders AS (
SELECT customer_id, 
product_name, 
COUNT(product_name) AS number_of_orders,
RANK() OVER(PARTITION BY customer_id ORDER BY number_of_orders DESC) AS rank
FROM sales AS s
INNER JOIN menu AS m ON s.product_id = m.product_id
GROUP BY customer_id, product_name
)
SELECT * FROM cust_orders 
WHERE rank = 1;


-- 6. Which item was purchased first by the customer after they became a member (either return all or 1)

SELECT customer_id,
product_name FROM

    (SELECT s.customer_id, 
    order_date, 
    join_date, 
    product_name, 
    RANK()OVER(PARTITION BY s.customer_id ORDER BY order_date ASC) AS rnk
    FROM sales AS s
    INNER JOIN members AS mem ON s.customer_id = mem.customer_id
    INNER JOIN menu AS m ON s.product_id = m.product_id
    WHERE order_date >= join_date)

WHERE rnk = 1;

-- 7. Which item was purchased just before the customer became a member? (either return one or all items that meet this condition)

WITH cte AS (
SELECT s.customer_id, 
order_date, 
product_name, 
RANK()OVER(PARTITION BY s.customer_id ORDER BY order_date DESC) AS rnk 
FROM sales AS s
INNER JOIN menu AS m ON s.product_id = m.product_id
INNER JOIN members AS mem ON s.customer_id = mem.customer_id
WHERE order_date < join_date)

SELECT customer_id, 
product_name FROM cte 
WHERE rnk = 1;

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id, 
COUNT(product_name), 
SUM(price)
FROM sales AS s
INNER JOIN menu AS m ON s.product_id = m.product_id
INNER JOIN members AS mem ON s.customer_id = mem.customer_id
WHERE order_date < join_date
GROUP BY s.customer_id;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT s.customer_id, 
SUM(CASE WHEN product_name = 'sushi' THEN price*20
    ELSE price*10
    END) AS points
FROM sales AS s 
INNER JOIN menu AS m ON s.product_id = m.product_id
GROUP BY customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customers A and B have at the end of January?

WITH cte AS (
SELECT
s.customer_id, 
product_name, 
price, 
join_date, 
order_date
FROM sales AS s
INNER JOIN menu AS m ON s.product_id = m.product_id
INNER JOIN members AS mem ON s.customer_id = mem.customer_id 
WHERE order_date <= '2021-01-31')
SELECT customer_id, 
SUM(CASE WHEN DATEDIFF(week,join_date,order_date) <= 1 THEN price*20
WHEN product_name = 'sushi' THEN price*20 ELSE price*10 END) AS points
FROM cte GROUP BY customer_id;