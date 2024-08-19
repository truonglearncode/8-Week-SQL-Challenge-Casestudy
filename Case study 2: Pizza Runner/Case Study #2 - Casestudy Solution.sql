-- CASE STUDY QUESTION --

-- A. PIZZA METRICS --

-- 1. How many pizzas were ordered? --

SELECT COUNT(pizza_id) total_pizza_ordered
FROM customer_orders

-- 2. How many unique customer orders were made?

SELECT COUNT(DISTINCT order_id) AS unique_customer
FROM customer_orders

-- 3. How many successful orders were delivered by each runner?

SELECT runner_id,COUNT(*) AS total_successfull_orders
FROM runner_orders
WHERE cancellation = ''
GROUP BY runner_id

-- 4. How many of each type of pizza was delivered?

SELECT c.pizza_id, CAST(p.pizza_name AS varchar) AS pizza_name, COUNT(*) AS total_pizza_dilivered
FROM customer_orders c 
JOIN runner_orders r 
ON c.order_id = r.order_id
JOIN pizza_names p 
ON c.pizza_id = p.pizza_id
WHERE cancellation = ''
GROUP BY c.pizza_id, CAST(p.pizza_name AS varchar);

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT c.customer_id, CAST(pizza_name as varchar) as  pizza_name, COUNT(*) AS pizza_ordered
FROM customer_orders c 
JOIN pizza_names p 
ON c.pizza_id = p.pizza_id
GROUP BY c.customer_id, CAST(pizza_name as varchar)
ORDER BY c.customer_id

WITH temp 
AS
(
    SELECT c.customer_id, CAST(p.pizza_name as varchar) as pizza_name,
        CASE 
            WHEN CAST(p.pizza_name as varchar) = 'Meatlovers' THEN 1
            ELSE 0
        END as Meatlovers_ordered,
        CASE
            WHEN CAST(p.pizza_name as varchar) = 'Vegetarian' THEN 1
            ELSE 0
        END as Vegetarian_ordered
    FROM customer_orders c 
    JOIN pizza_names p 
    ON c.pizza_id = p.pizza_id
)
SELECT  customer_id, 
        SUM(Meatlovers_ordered) AS Meatlovers_ordered, 
        SUM(Vegetarian_ordered) as Vegetarian_ordered
FROM temp
GROUP BY customer_id

-- 6. What was the maximum number of pizzas delivered in a single order?

SELECT TOP 1 c.order_id, COUNT(c.pizza_id) as pizza_per_order
FROM customer_orders c
JOIN  runner_orders r 
ON c.order_id = r.order_id
WHERE cancellation = ''
GROUP BY c.order_id
ORDER BY 2 DESC

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

WITH temp 
AS
(
SELECT c.customer_id,c.exclusions,c.extras,
    CASE
        WHEN exclusions <> '' OR extras <> '' THEN 1
        ELSE 0
    END change,
    CASE
        WHEN exclusions = '' AND extras = '' THEN 1
        ELSE 0
    END as no_changes
FROM customer_orders c
JOIN runner_orders r
ON c.order_id = r.order_id
WHERE cancellation = ''
)

SELECT customer_id, SUM(change) as change, SUM(no_changes) as no_change
FROM temp
GROUP BY customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?

SELECT COUNT(*) AS both_exclusions_and_extras
FROM customer_orders c
JOIN runner_orders r
ON c.order_id = r.order_id
WHERE cancellation = '' AND exclusions <> '' AND extras <> ''

-- 9. What was the total volume of pizzas ordered for each hour of the day?

SELECT DATEPART(HOUR,order_time) Hour_of_day, COUNT(*) AS pizza_count
FROM customer_orders c
JOIN runner_orders r
ON c.order_id = r.order_id
GROUP BY DATEPART(HOUR,order_time);

-- 10. What was the volume of orders for each day of the week?

SELECT FORMAT(DATEADD(DAY, 0, order_time),'dddd') as day_of_week, COUNT(*) total_pizza_ordered
FROM customer_orders c
JOIN runner_orders r
ON c.order_id = r.order_id
GROUP BY FORMAT(DATEADD(DAY, 0, order_time),'dddd');

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

SELECT day_of_week, COUNT(*) AS total_pizza_ordered
FROM TEMP
GROUP BY day_of_week

-- B. Runner and Customer Experience --

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01) --

SELECT DATEPART(WEEK,registration_date) weeks, COUNT(*) runner_sign_up
FROM runner 
GROUP BY DATEPART(WEEK,registration_date)

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order? --

SELECT r.runner_id, AVG(DATEDIFF(MINUTE,c.order_time,r.pickup_time)) avg_time
FROM runner_orders r 
JOIN customer_orders c 
ON r.order_id = c.order_id
WHERE cancellation = ''
GROUP BY r.runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare? --

WITH temp 
AS
(
    SELECT c.order_id,DATEDIFF(MINUTE,order_time,pickup_time) AS time_to_prepare, COUNT(c.order_id) pizza_orders
    FROM runner_orders r 
    JOIN customer_orders c 
    ON r.order_id = c.order_id
    WHERE cancellation = ''
    GROUP BY c.order_id,DATEDIFF(MINUTE,order_time,pickup_time)
)

SELECT pizza_orders, AVG(time_to_prepare) avg_time_to_prepare
FROM temp
GROUP BY pizza_orders;

-- 4. What was the average distance travelled for each customer? --

SELECT c.customer_id, AVG(distance) AS avg_distance
FROM runner_orders r 
JOIN customer_orders c 
ON r.order_id = c.order_id
WHERE cancellation = ''
GROUP BY c.customer_id

-- 5. What was the difference between the longest and shortest delivery times for all orders? --

SELECT MAX(duration) - MIN(duration) AS delivery_time_diff
FROM runner_orders r 
WHERE cancellation = ''

-- 6.What was the average speed for each runner for each delivery and do you notice any trend for these values? --

SELECT  c.order_id,r.runner_id,r.distance,r.duration as duration_min, 
        ROUND(CAST(r.duration as float)/60,2) duration_hour, 
        COUNT(c.pizza_id) as pizza_ordered, 
        CONCAT(ROUND(r.distance/ROUND(CAST(r.duration as float)/60,2),2), ' km/h') AS speed
FROM runner_orders r 
JOIN customer_orders c 
ON r.order_id = c.order_id
WHERE cancellation = ''
GROUP BY c.order_id,r.runner_id, r.distance, r.duration
ORDER BY r.runner_id

SELECT runner_id, AVG(duration) AVG_duration
FROM runner_orders
GROUP BY runner_id;

-- 7. What is the successful delivery percentage for each runner? --

SELECT runner_id,
        CAST(SUM(CASE
            WHEN cancellation <> '' then 0
            ELSE 1
            END) as float)/COUNT(*) * 100 AS successful_percentage
FROM runner_orders
GROUP BY runner_id;

-- C. Ingredient Optimisation --

-- 1. What are the standard ingredients for each pizza? --

WITH temp
AS
(
SELECT pizza_id, TRIM(ev.[value]) AS topping
FROM pizza_recipes
CROSS APPLY string_split(CAST(topping as varchar),',') ev
)

SELECT t.pizza_id, CAST(pn.pizza_name as varchar) as pizza_name, STRING_AGG(CAST(pt.topping_name as varchar),',') AS pizza_toppings
FROM temp t 
JOIN pizza_toppings pt
ON pt.topping_id = t.topping
JOIN pizza_names pn 
ON pn.pizza_id = t.pizza_id
GROUP BY t.pizza_id, CAST(pn.pizza_name as varchar);

-- 2. What was the most commonly added extra? --

SELECT TOP 1 TRIM(ev2.[value]) topping_added, CAST(p.topping_name as varchar) topping_name, COUNT(*) times_added
FROM customer_orders c
CROSS APPLY string_split(extras,',') ev2
JOIN pizza_toppings p 
ON ev2.[value] = p.topping_id
WHERE ev2.[value] <> ''
GROUP BY  CAST(p.topping_name as varchar), ev2.[value]
ORDER BY COUNT(*) DESC

-- 3. What was the most common exclusion? --

SELECT TOP 1 TRIM(ev3.[value]) as exclusion_topping_id,CAST(p.topping_name as varchar) as topping_name, COUNT(*) times_exclusion
FROM customer_orders c 
CROSS APPLY string_split(exclusions,',') ev3
JOIN pizza_toppings p 
ON p.topping_id = ev3.[value]
WHERE ev3.[value] <> ''
GROUP BY ev3.[value], CAST(p.topping_name as varchar)
ORDER BY COUNT(*) DESC;

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
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

WITH temp_extra
AS
(
    SELECT c.order_id,c.pizza_id,c.extras, STRING_AGG(CAST(topping_name as varchar), ',') AS added_extra
    FROM customer_orders c
    CROSS APPLY string_split(extras,',') AS ev1
    JOIN pizza_toppings p 
    ON p.topping_id = ev1.[value]
    -- WHERE ev1.[value] <> ''
    GROUP BY c.order_id,c.pizza_id,c.extras
),
temp_exclusion
AS
(
    SELECT c.order_id,c.pizza_id, c.exclusions, STRING_AGG(CAST(topping_name as varchar), ',') as excluded
    FROM customer_orders c 
    CROSS APPLY string_split(exclusions,',') AS ev2
    JOIN pizza_toppings p 
    ON p.topping_id = ev2.[value]
    -- WHERE ev2.[value] <> ''
    GROUP BY c.order_id,c.pizza_id, c.exclusions
)

SELECT c.order_id,
CONCAT(
    CASE 
    WHEN CAST(pn.pizza_name as varchar) = 'Meatlovers' THEN 'Meat lovers' 
    ELSE CAST(pn.pizza_name as varchar) 
    END,
    COALESCE('- Extra ' + ext.added_extra,''), 
    COALESCE('- Exclude ' + exc.excluded,'')) as ordered_detail
FROM customer_orders c 
LEFT JOIN temp_extra ext
ON ext.order_id = c.order_id AND ext.pizza_id = c.pizza_id AND ext.extras = c.extras
LEFT JOIN temp_exclusion exc 
ON exc.order_id = c.order_id AND exc.pizza_id = c.pizza_id AND exc.exclusions = c.exclusions
JOIN pizza_names pn 
ON pn.pizza_id = c.pizza_id
-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredient
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"


WITH extra_temp
AS
(
    SELECT c.order_id, c.pizza_id, c.extras, pt.topping_id, pt.topping_name
    FROM customer_orders c 
    CROSS APPLY string_split(c.extras,',') as ev1
    JOIN pizza_toppings pt 
    ON ev1.[value] = pt.topping_id
),
excluded_temp
AS
(
    SELECT c.order_id,c.pizza_id,c.exclusions,pt.topping_id, pt.topping_name
    FROM customer_orders c 
    CROSS APPLY string_split(c.exclusions,',') AS ev2
    JOIN pizza_toppings pt 
    ON ev2.[value] = pt.topping_id
),
orders_temp
AS
(
    SELECT c.order_id,c.pizza_id, pt.topping_id,pt.topping_name
    FROM customer_orders c 
    JOIN pizza_recipes pr
    ON c.pizza_id = pr.pizza_id
    CROSS APPLY string_split(CAST(pr.topping as varchar),',') ev3 
    JOIN pizza_toppings pt 
    ON pt.topping_id = ev3.[value]
),
orders_with_ext_and_exc_temp
AS
(
    SELECT o.order_id,o.pizza_id,o.topping_id,o.topping_name
    FROM orders_temp o 
    LEFT JOIN excluded_temp exc
    ON o.order_id = exc.order_id AND o.pizza_id = exc.pizza_id AND o.topping_id = exc.topping_id
    WHERE exc.topping_id is NULL

    UNION ALL

    SELECT order_id, pizza_id, topping_id, topping_name
    FROM extra_temp
),
ingredient_temp
AS
(
    SELECT o.order_id,CAST(pn.pizza_name AS varchar) as pizza_name , CAST(o.topping_name as varchar) as topping_name, COUNT(topping_id) AS topping_count
    FROM orders_with_ext_and_exc_temp o 
    JOIN pizza_names pn
    ON pn.pizza_id = o.pizza_id
    GROUP BY o.order_id, CAST(pn.pizza_name AS varchar), CAST(o.topping_name as varchar)
),
ingredient_total
AS
(
    SELECT order_id,CAST(pizza_name as varchar) as pizza_name,
    STRING_AGG(CASE 
    WHEN topping_count>1 THEN CONCAT(topping_count, 'x', CAST(topping_name as varchar))
    ELSE topping_name
    END, ',') as ingredient
    FROM ingredient_temp 
    GROUP BY order_id,CAST(pizza_name as varchar)
)
SELECT order_id, CONCAT(CAST(pizza_name as varchar(250)),':',CAST(ingredient as varchar(250))) as ingredient_list
FROM ingredient_total
ORDER BY order_id;

-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

WITH extra_temp
AS
(
    SELECT c.order_id, c.pizza_id, c.extras, pt.topping_id, pt.topping_name
    FROM customer_orders c 
    CROSS APPLY string_split(c.extras,',') as ev1
    JOIN pizza_toppings pt 
    ON ev1.[value] = pt.topping_id
),
excluded_temp
AS
(
    SELECT c.order_id,c.pizza_id,c.exclusions,pt.topping_id, pt.topping_name
    FROM customer_orders c 
    CROSS APPLY string_split(c.exclusions,',') AS ev2
    JOIN pizza_toppings pt 
    ON ev2.[value] = pt.topping_id
),
orders_temp
AS
(
    SELECT c.order_id,c.pizza_id, pt.topping_id,pt.topping_name
    FROM customer_orders c 
    JOIN pizza_recipes pr
    ON c.pizza_id = pr.pizza_id
    CROSS APPLY string_split(CAST(pr.topping as varchar),',') ev3 
    JOIN pizza_toppings pt 
    ON pt.topping_id = ev3.[value]
),
orders_with_ext_and_exc_temp
AS
(
    SELECT o.order_id,o.pizza_id,o.topping_id,o.topping_name
    FROM orders_temp o 
    LEFT JOIN excluded_temp exc
    ON o.order_id = exc.order_id AND o.pizza_id = exc.pizza_id AND o.topping_id = exc.topping_id
    WHERE exc.topping_id is NULL

    UNION ALL

    SELECT order_id, pizza_id, topping_id, topping_name
    FROM extra_temp
)

SELECT CAST(o.topping_name as varchar) AS topping_name, COUNT(o.topping_id) AS topping_count 
FROM orders_with_ext_and_exc_temp o 
JOIN runner_orders r 
ON o.order_id = r.order_id
WHERE r.cancellation = ''
GROUP BY CAST(o.topping_name as varchar)
ORDER BY COUNT(*) DESC