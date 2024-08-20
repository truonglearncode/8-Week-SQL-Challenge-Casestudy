# CASE STUDY #1: DANNY'S DINER
## Table of Content
* [Introduction](#introduction)
* [Problem Statement](#problem-statement)
* [Entity Relationship Diagram (ERD)](#erd)
* [Table Description](#table-description)
* [Case Study Question & Solutions](#solutions)
## Introduction <a class = 'anchor' id = 'introduction'></a>
Danny’s Dinner is a cute little restaurant that sells 3 popular Japanese foods: sushi, curry and ramen - The restaurant has captured some very basic data from a few months of operation.

Use this data to discover some business problem to help restaurant improve activity performance and run ahead the business by using SQL to go deeper and answer 10 main question and 2 bonus question about customers, visit patterns, how much money they’ve spent and kind of food their favorite on the menu

*View all information about this case [here](https://8weeksqlchallenge.com/case-study-1/)*
## Problem Statement <a class = 'anchor' id = 'problem-statement'></a>
Use data to answer a few simple questions about customers, their visiting patterns, how much money they’ve spent and also which menu items are their favorite. Having this deeper connection with customers will deliver a better and more personalized experience for loyal customers.

Using these insights to help decide whether should expand the existing customer loyalty program
## Entity Relationship Diagram (ERD) <a class = 'anchor' id = 'erd'></a>
3 Table: **sales**, **members**, **menu**

![(ERD)](https://github.com/truonglearncode/SQL-Casestudy/blob/main/Case%20study%201%3A%20Danny's%20Diner/Entity%20Relationship%20Diagram%20(ERD).png)

## Table Description <a class = 'anchor' id = 'table-description'></a>
### *Table 1: Sales*
The Sales table captures all customer_id level purchases with an corresponding order_date and product_id information for when and what menu items were ordered

![Sales Table](https://github.com/truonglearncode/SQL-Casestudy/blob/main/Case%20study%201%3A%20Danny's%20Diner/Sales%20Table.png)

### *Table 2: menu*
The menu table maps the product_id to the actual product_name and price of each menu items

![Menu Table](https://github.com/truonglearncode/SQL-Casestudy/blob/main/Case%20study%201%3A%20Danny's%20Diner/Menu%20Table.png)
### *Table 3: members*
The members table captures the join_date when customer_id joined the loyalty program

![Members Table](https://github.com/truonglearncode/SQL-Casestudy/blob/main/Case%20study%201%3A%20Danny's%20Diner/Members%20Table.png)

## Case Study Question & Solutions <a class = 'anchor' id = 'solutions'></a>
**1. What is the total amount each customer spent at the restaurant?**
```c
SELECT customer_id, SUM(price) AS total_amount
FROM sales s 
JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id
```
|customer_id|total_amount|
|-----------|------------|
|A|76|
|B|74|
|C|36|

**2. How many days has each customer visited the restaurant?**
```c
SELECT customer_id, COUNT(DISTINCT order_date) AS day_visited
FROM sales
GROUP BY customer_id;
```
|customer_id|day_visited|
|-|-|
|A|4|
|B|6|
|C|2|

**3. What was the first item from the menu purchased by each customer?**
```c
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
```
|customer_id|order_date|product_name|
|-|-|-|
|A|	2021-01-01|	curry|
|A|	2021-01-01|	sushi|
|B|	2021-01-01|	curry|
|C|	2021-01-01|	ramen|

**4. What is the most purchased item on the menu and how many times was it purchased by all customers?**
```c
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
```
|customer_id|product_name|most_item_purchase|customer_purchase|
|-|-|-|-|
| A      | ramen | 8      | 3      |
| B      | ramen | 8      | 2      |
| C      | ramen | 8      | 3      |

**5. Which item was the most popular for each customer?**
```c
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
```
|customer_id|product_name|purchase_quantity|
|-|-|-|
| A      | ramen | 3     |
| B      | sushi | 2     |
| B      | curry | 2     |
| B      | ramen | 2     |
| C      | ramen | 3     |

**6. Which item was purchased first by the customer after they became a member?**
```c
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

SELECT customer_id,join_date,order_date, product_name
FROM temp
WHERE rank = 1
```
|customer_id|join_date|order_date|product_name|
|-|-|-|-|
| A      | 2021-01-07 | 2021-01-07 | curry |
| B      | 2021-01-09 | 2021-01-11 | sushi |

**7. Which item was purchased just before the customer became a member?**
```c
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
```
| customer_id | join_date | order_date   | product_name  |
|--------|------------|------------|-------|
| A      | 2021-01-07 | 2021-01-01 | sushi |
| A      | 2021-01-07 | 2021-01-01 | curry |
| B      | 2021-01-09 | 2021-01-04 | sushi |

**8. What is the total items and amount spent for each member before they became a member?**
```c
SELECT s.customer_id, COUNT(*) as total_item, SUM(mn.price) amount_spent
FROM sales s 
JOIN menu mn 
ON s.product_id = mn.product_id
JOIN members mb 
ON mb.customer_id = s.customer_id
WHERE order_date < join_date
GROUP BY s.customer_id
```
| customer_id | total_item | amount_spent |
|--------|--------|--------|
| A      | 2      | 25     |
| B      | 3      | 40     |

**9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**
```c
SELECT s.customer_id,
SUM(CASE 
        WHEN s.product_id = 1 THEN price*20
        ELSE price*10
    END) AS total_point
FROM sales s 
JOIN menu m 
ON s.product_id = m.product_id
GROUP BY s.customer_id;
```
| customer_id | total_point |
|--------|-------|
| A      | 860   |
| B      | 940   |
| C      | 360   |

**10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**
```c
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

SELECT customer_id, SUM(customer_point) AS customer_point
FROM tempt
WHERE order_date < '2021-02-01'
GROUP BY customer_id
```
| customer_id | customer_point |
|--------|-------|
| A      | 1370  |
| B      | 940   |
