CREATE DATABASE PIZZA_RUNNER

CREATE TABLE runner(
    runner_id INTEGER,
    registration_date DATE
)

INSERT INTO runner
    (runner_id,registration_date)
VALUES
    (1,'2021-01-01'),
    (2,'2021-01-03'),
    (3,'2021-01-08'),
    (4,'2021-01-15')

DROP TABLE IF EXISTS customer_orders
CREATE TABLE customer_orders(
    order_id INTEGER,
    customer_id INTEGER,
    pizza_id INTEGER,
    exclusions VARCHAR(4),
    extras varchar(4),
    order_time DATETIME
)

INSERT INTO customer_orders
    (order_id,customer_id,pizza_id,exclusions,extras,order_time)
VALUES
    ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
    ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
    ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
    ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
    ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
    ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
    ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
    ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
    ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
    ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
    ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
    ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
    ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
    ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');

CREATE TABLE runner_orders(
    order_id INTEGER,
    runner_id INTEGER,
    pickup_time VARCHAR(19),
    distance VARCHAR(7),
    duration VARCHAR(10),
    cancellation VARCHAR(23)
)

INSERT INTO runner_orders
    (order_id,runner_id,pickup_time,distance,duration,cancellation)
VALUES
    ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
    ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
    ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
    ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
    ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
    ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
    ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
    ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
    ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
    ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');

CREATE TABLE pizza_names(
    pizza_id INTEGER,
    pizza_name TEXT
)

INSERT INTO pizza_names
    (pizza_id,pizza_name)
VALUES
    (1, 'Meatlovers'),
    (2, 'Vegetarian');

CREATE TABLE pizza_recipes (
    pizza_id INTEGER,
    topping TEXT
)

INSERT INTO pizza_recipes
    (pizza_id,topping)
VALUES
    (1, '1, 2, 3, 4, 5, 6, 8, 10'),
    (2, '4, 6, 7, 9, 11, 12');

CREATE TABLE pizza_toppings(
    topping_id INTEGER,
    topping_name TEXT
)

INSERT INTO pizza_toppings
    (topping_id,topping_name)
VALUES
    (1, 'Bacon'),
    (2, 'BBQ Sauce'),
    (3, 'Beef'),
    (4, 'Cheese'),
    (5, 'Chicken'),
    (6, 'Mushrooms'),
    (7, 'Onions'),
    (8, 'Pepperoni'),
    (9, 'Peppers'),
    (10, 'Salami'),
    (11, 'Tomatoes'),
    (12, 'Tomato Sauce');



-- DATA CLEANING --

-- TABLE RUNNER_ORDERS --

SELECT order_id, runner_id,
    CASE
        WHEN pickup_time = 'null' then null
        else pickup_time
    END as pickup_time,
    CASE
        WHEN distance = 'null' then null
        WHEN distance LIKE '%km' then TRIM('km' from distance)
        else distance
    END as distance,
    CASE 
        WHEN duration = 'null' then null
        WHEN duration LIKE '%mins' then TRIM('mins' from duration)
        WHEN duration LIKE '%minute' then TRIM('minute' from duration)
        WHEN duration LIKE '%minutes' then TRIM('minutes' from duration)
        else duration
    END as duration,
    CASE
        WHEN cancellation is null OR cancellation = 'null' then ''
        else cancellation
    END as cancellation
FROM runner_orders

UPDATE runner_orders
SET
pickup_time = 
(CASE
        WHEN pickup_time = 'null' then null
        else pickup_time
    END),
distance =
    (CASE
        WHEN distance = 'null' then null
        WHEN distance LIKE '%km' then TRIM('km' from distance)
        else distance
    END),
duration = 
    (CASE 
        WHEN duration = 'null' then null
        WHEN duration LIKE '%mins' then TRIM('mins' from duration)
        WHEN duration LIKE '%minute' then TRIM('minute' from duration)
        WHEN duration LIKE '%minutes' then TRIM('minutes' from duration)
        else duration
    END),
cancellation = 
    (CASE
        WHEN cancellation is null OR cancellation = 'null' then ''
        else cancellation
    END)

SELECT * FROM runner_orders

ALTER TABLE runner_orders
ALTER COLUMN pickup_time DATETIME
ALTER TABLE runner_orders
ALTER COLUMN distance NUMERIC
ALTER TABLE runner_orders
ALTER COLUMN duration INTEGER

-- TABLE CUSTOMER_ORDERS --

SELECT * FROM customer_orders

UPDATE customer_orders
SET
exclusions = '',
extras =''
WHERE (
    exclusions is null OR exclusions = 'null' OR extras is null or extras = 'null'
    )

-- CASE STUDY QUESTION --

-- A. PIZZA METRICS --

-- 1. How many pizzas were ordered? --

SELECT COUNT(pizza_id) AS pizza_sold
FROM customer_orders

-- 2. How many unique customer orders were made?

SELECT COUNT(DISTINCT(order_id)) as unique_cus
FROM customer_orders

-- 3. How many successful orders were delivered by each runner?

SELECT runner_id, COUNT(*) as successful_orders
FROM runner_orders
WHERE cancellation = ''
GROUP BY runner_id

-- 4. How many of each type of pizza was delivered?

SELECT pizza_id, COUNT(pizza_id) as pizza_type_sold
FROM customer_orders c
JOIN runner_orders r on c.order_id = r.order_id
WHERE cancellation = ''
GROUP BY pizza_id;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

WITH TEMP(customer_id,total_Meat_Lover)
AS
(
    SELECT c.customer_id,COUNT(p.pizza_id)
    FROM customer_orders c 
    JOIN pizza_names p on c.pizza_id = p.pizza_id
    WHERE p.pizza_id = '1'
    GROUP BY c.customer_id
),
TEMP1(customer_id,total_Vegetarian)
AS
(
    SELECT c.customer_id, COUNT(p.pizza_id)
    FROM customer_orders c
    JOIN pizza_names p on p.pizza_id = c.pizza_id
    WHERE p.pizza_id = '2'
    GROUP BY c.customer_id
)
SELECT t0.customer_id, total_Meat_Lover, total_Vegetarian
FROM TEMP t0 
JOIN TEMP1 t1 ON t0.customer_id = t1.customer_id

-- ALTER TABLE pizza_names
-- ALTER COLUMN pizza_name VARCHAR(10)

-- SELECT c.customer_id, p.pizza_name, COUNT(*) AS pizza_sold
-- FROM customer_orders c 
-- JOIN pizza_names p ON p.pizza_id = c.pizza_id
-- GROUP BY c.customer_id, p.pizza_name

-- 6. What was the maximum number of pizzas delivered in a single order?

SELECT TOP 1 order_id, COUNT(pizza_id) as max_number_of_pizza
FROM customer_orders
GROUP BY order_id
ORDER BY COUNT(pizza_id) DESC

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

WITH TEMP(customer_id,change,no_change)
AS
(
    SELECT customer_id,
    CASE
        WHEN exclusions <> '' OR extras <> '' then 1
        else 0
    END as change,
    CASE
        WHEN exclusions = '' AND extras = '' then 1
        else 0
    END as no_change
    FROM customer_orders c
    JOIN runner_orders r on c.order_id = r.order_id
    WHERE r.cancellation = ''
)

SELECT customer_id,SUM(change) AS at_least_1_change,Sum(no_change) AS no_change
FROM TEMP
GROUP BY customer_id

-- if convert VALUES FROM '' to null, i can use this code below

-- SELECT customer_id, COUNT(*) as no_changes
-- FROM customer_orders c
-- JOIN runner_orders r on c.order_id = r.order_id
-- WHERE cancellation = '' and exclusions = '' AND extras = ''
-- GROUP BY customer_id

-- SELECT customer_id, COUNT(*) as changes
-- FROM customer_orders c
-- JOIN runner_orders r ON c.order_id = r.order_id
-- WHERE exclusions LIKE '%' OR extras LIKE '%' AND cancellation = ''
-- GROUP BY customer_id

-- 8. How many pizzas were delivered that had both exclusions and extras?

SELECT COUNT(*) as both_exclusions_and_extras
FROM customer_orders c
JOIN runner_orders r on c.order_id = r.order_id
WHERE r.cancellation = '' AND exclusions <> '' AND extras <> ''

-- 9. What was the total volume of pizzas ordered for each hour of the day?

SELECT DATEPART(HOUR,order_time) AS hour_of_day, COUNT(*) total_vol
FROM customer_orders
GROUP BY DATEPART(HOUR,order_time);

-- 10. What was the volume of orders for each day of the week?

WITH TEMP 
AS
(
    SELECT*,
    Case
        WHEN DATEPART(WEEKDAY,order_time) = 2 then 'MONDAY'
        WHEN DATEPART(WEEKDAY,order_time) = 3 then 'TUESDAY'
        WHEN DATEPART(WEEKDAY,order_time) = 4 then 'WEDNESDAY'
        WHEN DATEPART(WEEKDAY,order_time) = 5 then 'THURDAY'
        WHEN DATEPART(WEEKDAY,order_time) = 6 then 'FRIDAY'
        WHEN DATEPART(WEEKDAY,order_time) = 7 then 'SATURDAY'
        WHEN DATEPART(WEEKDAY,order_time) = 1 then 'SUNDAY'
    END AS day_of_week
    FROM customer_orders
)

SELECT day_of_week, COUNT(*)
FROM TEMP
GROUP BY day_of_week

-- B. Runner and Customer Experience --

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01) --

SELECT DATEPART(WEEK,registration_date) AS weeks, COUNT(*) runner_signup_count
FROM runner
GROUP By DATEPART(WEEK,registration_date)

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order? --

SELECT r.runner_id,AVG(DATEDIFF(MINUTE,c.order_time,r.pickup_time)) AS AVG_time
FROM runner_orders r 
JOIN customer_orders c on r.order_id = c.order_id
WHERE pickup_time IS NOT NULL
GROUP BY r.runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare? --

WITH TEMP1(order_id, mins_to_pickup)
AS
(
    SELECT distinct r.order_id, DATEDIFF(MINUTE,c.order_time,r.pickup_time)
    FROM runner_orders r 
    JOIN customer_orders c on r.order_id = c.order_id
    WHERE pickup_time IS NOT NULL
),
TEMP2(order_id, pizza_quantity_per_order)
AS
(
    SELECT r.order_id,COUNT(*)
    FROM runner_orders r 
    JOIN customer_orders c on r.order_id = c.order_id
    GROUP BY r.order_id
)

SELECT pizza_quantity_per_order, AVG(t1.mins_to_pickup) AS avg_time_to_prepare
FROM TEMP1 t1
JOIN TEMP2 t2 on t1.order_id = t2.order_id
GROUP BY pizza_quantity_per_order

-- 4. What was the average distance travelled for each customer? --

SELECT customer_id, AVG(distance) avg_distance
FROM runner_orders r
JOIN customer_orders c on r.order_id = c.order_id
WHERE distance is not NULL
GROUP BY customer_id

-- 5. What was the difference between the longest and shortest delivery times for all orders? --

SELECT MAX(duration) - MIN(duration) as delivery_time_diff
FROM runner_orders 

-- 6.What was the average speed for each runner for each delivery and do you notice any trend for these values? --

SELECT runner_id, AVG(duration) AVG_duration, AVG(distance) AVG_distance
FROM runner_orders
GROUP BY runner_id;

-- 7. What is the successful delivery percentage for each runner? --

WITH TEMP1(runner_id, complete_ord, cancel_ord)
AS
(
    SELECT runner_id,
    CASE
        WHEN cancellation = '' then 1
        else 0
    END complete_ord,
    CASE
        WHEN cancellation <> '' THEN 1
        ELSE 0
    END cancel_ord
    FROM runner_orders r 
    JOIN customer_orders c on r.order_id = c.order_id
)

SELECT runner_id, SUM(complete_ord) * 100 / NULLIF(SUM(complete_ord) + SUM(cancel_ord),0) as successfull_delivery_percentage
FROM TEMP1
GROUP BY runner_id;

-- C. Ingredient Optimisation --

-- 1. What are the standard ingredients for each pizza? --

WITH TEMP
AS 
(
    SELECT pizza_id, cs.[value]
    FROM pizza_recipes
    CROSS APPLY string_split(CAST(topping as varchar(30)),',') cs
)

SELECT n.pizza_id,CAST(n.pizza_name as varchar(30)) as pizza_name, STRING_AGG(CAST(t.topping_name as varchar(30)),',') as standard_ingredients
FROM pizza_names n
JOIN TEMP t1 on n.pizza_id = t1.pizza_id
JOIN pizza_toppings t ON t.topping_id = t1.[value]
GROUP BY n.pizza_id, CAST(n.pizza_name as varchar(30));

-- 2. What was the most commonly added extra? --

WITH TEMP
AS
(
    SELECT extras_split.[value] AS extras,COUNT(extras_split.[value]) AS extras_count
    FROM customer_orders o
    CROSS APPLY string_split(extras,',') extras_split
    WHERE extras_split.[value] <> ''
    GROUP BY extras_split.[value]
)

SELECT TOP 1 t.topping_name, t1.extras_count
FROM pizza_toppings t
JOIN TEMP t1 on t1.extras = t.topping_id
ORDER BY t1.extras_count DESC

-- 3. What was the most common exclusion? --

WITH TEMP
AS
(
    SELECT exclu_split.[value] as exclusions, COUNT(exclu_split.[value]) AS exclu_count
    FROM customer_orders c
    CROSS APPLY string_split(exclusions,',') AS exclu_split
    WHERE exclu_split.[value] <> ''
    GROUP BY exclu_split.[value]
)

SELECT TOP 1 t.topping_name, t1.exclu_count
FROM pizza_toppings t
JOIN TEMP t1 on t.topping_id = t1.exclusions
ORDER BY exclu_count DESC

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:

-- Meat Lovers

WITH TEMP 
AS
(
    SELECT pizza_id, topping_split.[value]
    FROM pizza_recipes
    CROSS APPLY string_split(CAST(topping as varchar(30)),',') as topping_split
    WHERE pizza_id = 1
)

SELECT t1.pizza_id, CAST(n.pizza_name as varchar(30)), STRING_AGG(CAST(topping_name AS varchar(30)),',')
FROM pizza_toppings t
JOIN TEMP t1 on t1.[value] = t.topping_id
JOIN pizza_names n on n.pizza_id = t1.pizza_id
WHERE CAST(topping_name AS varchar(30)) <> 'Beef'
GROUP BY t1.pizza_id, CAST(n.pizza_name as varchar(30))

SELECT *
FROM customer_orders
CROSS APPLY string_split(extras,',') as extras_split
CROSS APPLY string_split(exclusions,',') AS exclu_split

-- Meat Lovers - Exclude Beef

-- Meat Lovers - Extra Bacon

-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients

-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

-- D. Pricing and Ratings --

-- If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

SELECT 
SUM(CASE
        WHEN c.pizza_id = 1 THEN 12
        ELSE 10
    END) AS total_earning
FROM pizza_names n
JOIN customer_orders c on n.pizza_id = c.pizza_id
JOIN runner_orders r on c.order_id =r.order_id
WHERE r.cancellation = ''

-- What if there was an additional $1 charge for any pizza extras?

WITH TEMP1
AS
SELECT 
SUM(CASE
    WHEN c.pizza_id = 1 then 12
    ELSE  10
END)  
FROM customer_orders c 
JOIN runner_orders r ON c.order_id = r.order_id
WHERE cancellation = ''


SELECT pizza_id, TRIM(extras_split.[value])
FROM customer_orders
CROSS APPLY string_split(extras,',') extras_split


-- Add cheese is $1 extra
-- The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
-- Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
-- customer_id
-- order_id
-- runner_id
-- rating
-- order_time
-- pickup_time
-- Time between order and pickup
-- Delivery duration
-- Average speed
-- Total number of pizzas
-- If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?