CREATE DATABASE Chalenge

CREATE TABLE sales (
    customer_id VARCHAR(1),
    order_date DATE,
    product_id INTEGER
);

INSERT INTO sales
    (customer_id,order_date,product_id)
VALUES
    ('A', '2021-01-01', '1'),
    ('A', '2021-01-01', '2'),
    ('A', '2021-01-07', '2'),
    ('A', '2021-01-10', '3'),
    ('A', '2021-01-11', '3'),
    ('A', '2021-01-11', '3'),
    ('B', '2021-01-01', '2'),
    ('B', '2021-01-02', '2'),
    ('B', '2021-01-04', '1'),
    ('B', '2021-01-11', '1'),
    ('B', '2021-01-16', '3'),
    ('B', '2021-02-01', '3'),
    ('C', '2021-01-01', '3'),
    ('C', '2021-01-01', '3'),
    ('C', '2021-01-07', '3');
 

CREATE TABLE menu(
    product_id INTEGER,
    product_name VARCHAR(5),
    price INTEGER
);

INSERT INTO menu
    (product_id,product_name,price)
VALUES
    ('1', 'sushi', '10'),
    ('2', 'curry', '15'),
    ('3', 'ramen', '12');

CREATE TABLE members(
    customer_id VARCHAR(1),
    join_date DATE
);

INSERT INTO members
    (customer_id,join_date)
VALUES
    ('A', '2021-01-07'),
    ('B', '2021-01-09');

-- Case Study Questions --

SELECT * FROM menu
SELECT * FROM members
SELECT * FROM sales

-- 1. What is the total amount each customer spent at the restaurant? -- 

SELECT s.customer_id, SUM(m.price) AS total_amount FROM sales AS s
JOIN menu as m on s.product_id = m.product_id
GROUP BY s.customer_id

-- 2. How many days has each customer visited the restaurant? --

SELECT customer_id ,COUNT(distinct(order_date))
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer? --

WITH tempt 
AS
(
    SELECT s.customer_id, s.order_date, m.product_name,
        Dense_rank() OVER(partition BY s.customer_id order by s.order_date asc) as rank 
    FROM sales s
    JOIN menu m ON s.product_id = m.product_id
)

SELECT customer_id, product_name, order_date,rank
FROM tempt
WHERE rank = 1
GROUP by customer_id, product_name, order_date,rank

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers? -- 

SELECT TOP 1  m.product_name, COUNT(m.product_id) as most_purchased
FROM sales s
JOIN menu m on s.product_id = m.product_id
GROUP by s.product_id, m.product_name
ORDER BY most_purchased DESC

SELECT s.customer_id, COUNT(m.product_id) as times_purchased
FROM sales s
JOIN menu m on s.product_id = m.product_id
WHERE m.product_name = 'ramen'
Group BY customer_id;

-- 5. Which item was the most popular for each customer?

WITH temp0
AS
(
SELECT s.customer_id, m.product_name, COUNT(m.product_id) as quantity_purchased,
dense_rank() OVER(partition by customer_id order by COUNT(m.product_id) DESC) as rank
FROM sales s
JOIN menu m on s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name
)

SELECT customer_id, product_name, quantity_purchased
FROM temp0
WHERE rank = 1

-- 6. Which item was purchased first by the customer after they became a member? --

WITH TEMP1
AS
(
    SELECT s.customer_id, s.order_date,mb.join_date,mn.product_name,
    DENSE_RANK() OVER(partition by s.customer_id order by s.order_date) as rank
    FROM sales s
    JOIN menu mn on s.product_id = mn.product_id
    JOIN members mb on s.customer_id = mb.customer_id
    WHERE mb.join_date <= s.order_date
)

 SELECT customer_id, product_name
 FROM TEMP1
 WHERE rank = 1

-- 7. Which item was purchased just before the customer became a member? --

WITH TEMP
AS
(
    SELECT s.customer_id,s.order_date,mb.join_date,mn.product_name,
    DENSE_RANK() OVER(partition by s.customer_id order by s.order_date DESC) as rank
    FROM sales s
    JOIN menu mn on s.product_id = mn.product_id
    JOIN members mb on mb.customer_id = s.customer_id
    WHERE mb.join_date > s.order_date
)

SELECT customer_id, product_name
FROM TEMP
WHERE rank = 1

-- 8. What is the total items and amount spent for each member before they became a member? --
 
SELECT s.customer_id, COUNT(mn.product_name) total_items, SUM(mn.price) total_amt
FROM sales s
JOIN menu mn on s.product_id = mn.product_id
JOIN members mb on s.customer_id = mb.customer_id
WHERE mb.join_date > s.order_date
GROUP BY s.customer_id

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have? --

SELECT s.customer_id,
    SUM(Case
        when product_name = 'sushi' then m.price*20
        else m.price*10
    END) as customer_point
FROM sales s
JOIN menu m on s.product_id = m.product_id
GROUP BY s.customer_id;

-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
-- not just sushi how many points do customer A and B have at the end of January?

WITH temp1(customer_id, cus_point_after_become_member)
AS
(
    SELECT s.customer_id, SUM(mn.price*20)
    FROM sales s
    JOIN menu mn on mn.product_id = s.product_id
    JOIN members mb on mb.customer_id = s.customer_id
    WHERE s.order_date >= mb.join_date and s.order_date < '2021-01-30'
    GROUP BY s.customer_id
),

temp2(customer_id, cus_point_before_become_member)
AS
(
    Select s.customer_id, 
        SUM(CASE
            when mn.product_name = 'sushi' then mn.price*20
            else mn.price*10
            END) AS cus_point_before_become_member
    FROM sales s
    JOIN menu mn ON mn.product_id = s.product_id
    JOIN members mb on mb.customer_id = s.customer_id
    WHERE  mb.join_date > s.order_date
    GROUP BY s.customer_id
)

Select t1.customer_id, t1.cus_point_after_become_member+t2.cus_point_before_become_member AS total_point_in_jan
FROM temp2 t2
JOIN temp1 t1 ON t2.customer_id = t1.customer_id