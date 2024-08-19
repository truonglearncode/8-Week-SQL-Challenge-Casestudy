-- Case Study Questions --

-- 1. What is the total amount each customer spent at the restaurant? -- 

SELECT customer_id, SUM(price) AS total_amount
FROM sales s 
JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id

-- 2. How many days has each customer visited the restaurant? --

SELECT customer_id, COUNT(DISTINCT order_date) AS day_visited
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer? --

WITH tempt
AS
(
    SELECT s.customer_id, s.order_date, m.product_name,
    DENSE_RANK() OVER(partition by s.customer_id order by s.order_date) as rank 
    FROM sales s
    JOIN menu m 
    ON s.product_id = m.product_id
)

SELECT DISTINCT customer_id, order_date, product_name
FROM tempt
WHERE rank = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers? -- 

WITH temp1
AS
(
    SELECT TOP 1 m.product_id,m.product_name, COUNT(*) AS most_item_purchase
    FROM sales s 
    JOIN menu m 
    ON s.product_id = m.product_id
    GROUP BY m.product_id ,m.product_name
    ORDER BY COUNT(*) DESC
)

    SELECT customer_id,t1.product_name, t1.most_item_purchase, COUNT(*) AS customer_purchase
    FROM sales s
    JOIN temp1 t1
    ON s.product_id = t1.product_id
    GROUP BY customer_id,t1.product_name, t1.most_item_purchase;

-- 5. Which item was the most popular for each customer?

WITH temp
AS
(
    SELECT s.customer_id, m.product_name, COUNT(*) purchase_quantity,
    DENSE_RANK() OVER(partition by customer_id ORDER BY COUNT(*) DESC) AS rank  
    FROM sales s
    JOIN menu m 
    ON s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name
)

SELECT customer_id, product_name, purchase_quantity
FROM temp
WHERE rank = 1

-- 6. Which item was purchased first by the customer after they became a member? --

WITH temp
AS
(
    SELECT s.customer_id, mb.join_date, s.order_date, product_name,
    DENSE_RANK() OVER(partition by s.customer_id ORDER BY order_date) as rank
    FROM sales s 
    JOIN menu mn 
    ON s.product_id = mn.product_id
    JOIN members mb
    ON s.customer_id = mb.customer_id
    WHERE join_date <= order_date 
)

SELECT customer_id,join_date,order_date product_name
FROM temp
WHERE rank = 1

-- 7. Which item was purchased just before the customer became a member? --

WITH tempt
AS
(
    SELECT s.customer_id,mb.join_date, s.order_date,mn.product_name,
    DENSE_RANK() OVER(partition by s.customer_id order by order_date DESC) AS rank 
    FROM sales s 
    JOIN menu mn 
    ON s.product_id = mn.product_id
    JOIN members mb
    ON s.customer_id = mb.customer_id
    WHERE order_date < join_date
)
SELECT customer_id, join_date, order_date, product_name
FROM tempt
WHERE rank = 1

-- 8. What is the total items and amount spent for each member before they became a member? --
 
SELECT s.customer_id, COUNT(*) as total_item, SUM(mn.price) amount_spent
FROM sales s 
JOIN menu mn 
ON s.product_id = mn.product_id
JOIN members mb 
ON mb.customer_id = s.customer_id
WHERE order_date < join_date
GROUP BY s.customer_id

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have? --

SELECT s.customer_id,
SUM(CASE 
        WHEN s.product_id = 1 THEN price*20
        ELSE price*10
    END) AS total_point
FROM sales s 
JOIN menu m 
ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
-- not just sushi how many points do customer A and B have at the end of January?
WITH tempt
AS
(
    SELECT s.customer_id,mb.join_date,s.order_date,mn.product_name, mn.price, DATEADD(WEEK,1,mb.join_date) AS in_week_program,
    CASE
        WHEN s.order_date <= DATEADD(WEEK,1,mb.join_date) AND s.order_date >= mb.join_date THEN price * 20
        WHEN product_name = 'sushi' THEN price * 20
        ELSE price * 10
    END AS customer_point
    FROM sales s
    JOIN members mb
    ON mb.customer_id = s.customer_id
    JOIN menu mn 
    ON s.product_id = mn.product_id
)

SELECT customer_id, SUM(customer_point)
FROM tempt
WHERE order_date < '2021-02-01'
GROUP BY customer_id
