# CASE STUDY #2: PIZZA RUNNER
## Table of content
* [Introduction](#introduction)
* [Problem Statement](#problem-statement)
* [Entity Relationship Diagram (ERD)](#erd)
* [Table Description](#table-description)
* [Case Study Question](#case-question)
## Introduction <a class = 'anchor' id = 'introduction'></a>
Pizza Runner is a business using runners to deliver fresh pizza to customers using a mobile app to place an order. This dataset can be used to figure out some business insight about operation, customer, staff, …  that was going to be critical for business’s growth and optimize operation
## Problem Statement <a class = 'anchor' id = 'problem-statement'></a>
I’m using the Azure Data Studio app to write SQL statements for this Case Study. I focus to discover 3 important point:
* Pizza Metrics
* Runner and Customer Experience
* Ingredient Optimisation
## Entity Relationship Diagram (ERD) <a class = 'anchor' id = 'erd'></a>
6 Table: **runner_orders**, **runners**, **customer_orders**, **pizza_names**,**pizza_recipes**, **pizza_toppings**

![Case Study #2 - Entity Relationship Diagram (ERD).png](https://github.com/truonglearncode/SQL-Casestudy/blob/main/Case%20study%202%3A%20Pizza%20Runner/Entity%20Relationship%20Diagram%20(ERD).png)

## Table Description <a class = 'anchor' id = 'table-description'></a>
### *Table 1: runners*
The runners table shows the registration_date for each new runner

![(ERD)](https://github.com/truonglearncode/SQL-Casestudy/blob/main/Case%20study%202%3A%20Pizza%20Runner/Runner%20Table.png)

### *Table 2: customer_orders*
The customer_orders table with 1 row for each individual pizza that is part of the order
The pizza_id relates to the type of pizza which was ordered whilst the exclusions are the ingredient_id values which should be removed from the pizza and the extras are the ingredient_id values which need to be added to the pizza
Customer can order multiple pizzas in a single order with varying exclusions and extras values even if the pizza is the same type

![Customer Order Table](https://github.com/truonglearncode/SQL-Casestudy/blob/main/Case%20study%202%3A%20Pizza%20Runner/Customer%20Order%20Table.png)

### *Table 3: runner_orders*
After each orders are received through the system - they are assigned to a runner - however not all  orders are fully completed and can be canceled by the restaurant or the customer
The pickup_time is the timestamp at which the runner arrives at the Pizza Runner headquarters to pick up the freshly cooked pizzas. The distance and duration fields are related to how far and long the runner had to travel to deliver the order to the respective customer

![Runner Order Table](https://github.com/truonglearncode/SQL-Casestudy/blob/main/Case%20study%202%3A%20Pizza%20Runner/Runner%20Order%20Table.png)

### *Table 4: pizza_names*
2 pizzas available is MeatLover and Vegetarian

![Pizza Names Table](https://github.com/truonglearncode/SQL-Casestudy/blob/main/Case%20study%202%3A%20Pizza%20Runner/Pizza%20Name%20Table.png)

### *Table 5: pizza_recipes*
Each pizza_id has a standard set of toppings which are used as part of pizza recipe

![Pizza Recipes Table](https://github.com/truonglearncode/SQL-Casestudy/blob/main/Case%20study%202%3A%20Pizza%20Runner/Pizza%20Recipes%20Table.png)

### *Table 6: pizza_toppings*
This table contains all of the topping_name values with their corresponding topping_id value

![Pizza Toppings Table](https://github.com/truonglearncode/SQL-Casestudy/blob/main/Case%20study%202%3A%20Pizza%20Runner/Pizza%20Toppings%20Table.png)

## Case Study Question <a class = 'anchor' id = 'case-question'></a>
### A. Pizza Metrics
**1. How many pizzas were ordered?**
```c
SELECT COUNT(pizza_id) total_pizza_ordered
FROM customer_orders
```
| total_pizza_ordered  |
|-------|
| 14 |

**2. How many unique customer orders were made?**
```c
SELECT COUNT(DISTINCT order_id) AS unique_customer
FROM customer_orders
```
| unique_customer  |
|-------|
| 10|

**3. How many successful orders were delivered by each runner?**
```c
SELECT runner_id,COUNT(*) AS total_successfull_orders
FROM runner_orders
WHERE cancellation = ''
GROUP BY runner_id
```
| runner_id | total_successfull_orders |
|----------|----------|
| 1        | 4        |
| 2        | 3        |
| 3        | 1        |

**4. How many of each type of pizza was delivered?**
```c
SELECT c.pizza_id, CAST(p.pizza_name AS varchar) AS pizza_name, COUNT(*) AS total_pizza_dilivered
FROM customer_orders c 
JOIN runner_orders r 
ON c.order_id = r.order_id
JOIN pizza_names p 
ON c.pizza_id = p.pizza_id
WHERE cancellation = ''
GROUP BY c.pizza_id, CAST(p.pizza_name AS varchar);
```
| pizza_id | pizza_name  | total_pizza_dilivered |
|----|-------------|----------|
| 1  | Meatlovers  | 9        |
| 2  | Vegetarian  | 3        |

**5. How many Vegetarian and Meatlovers were ordered by each customer?**
```c
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
```
| customer_id  | Meatlovers_ordered | Vegetarian_ordered |
|-----|----------|----------|
| 101 | 2        | 1        |
| 102 | 2        | 1        |
| 103 | 3        | 1        |
| 104 | 3        | 0        |
| 105 | 0        | 1        |

**6. What was the maximum number of pizzas delivered in a single order?**
```c
SELECT TOP 1 c.order_id, COUNT(c.pizza_id) as pizza_per_order
FROM customer_orders c
JOIN  runner_orders r 
ON c.order_id = r.order_id
WHERE cancellation = ''
GROUP BY c.order_id
ORDER BY 2 DESC
```
| order_id | pizza_per_order |
|----------|----------|
| 4         | 3        |

**7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?**
```c
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
```
| customer_id  | change | no_change |
|-----|----------|----------|
| 101 | 0        | 2        |
| 102 | 0        | 3        |
| 103 | 3        | 0        |
| 104 | 1        | 2        |
| 105 | 0        | 1        |

**8. How many pizzas were delivered that had both exclusions and extras?**
```c
SELECT COUNT(*) AS both_exclusions_and_extras
FROM customer_orders c
JOIN runner_orders r
ON c.order_id = r.order_id
WHERE cancellation = '' AND exclusions <> '' AND extras <> ''
```
| both_exclusions_and_extras |
|-------|
| 1 |

**9. What was the total volume of pizzas ordered for each hour of the day?**
```c
SELECT DATEPART(HOUR,order_time) Hour_of_day, COUNT(*) AS pizza_count
FROM customer_orders c
JOIN runner_orders r
ON c.order_id = r.order_id
GROUP BY DATEPART(HOUR,order_time);
```
| Hour_of_day  | pizza_count|
|-----|----------|
| 11  | 1        |
| 13  | 3        |
| 18  | 3        |
| 19  | 1        |
| 21  | 3        |
| 23  | 3        |

**10. What was the volume of orders for each day of the week?**
```c
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
```
| day_of_week       | total_pizza_ordered |
|-----------|-------|
| FRIDAY    | 1     |
| SATURDAY  | 5     |
| THURDAY   | 3     |
| WEDNESDAY | 5     |

### B. Runner and Customer Experience
**1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)**
```c
SELECT DATEPART(WEEK,registration_date) weeks, COUNT(*) runner_sign_up
FROM runner 
GROUP BY DATEPART(WEEK,registration_date)
```
| weeks  | runner_sign_up |
|-----|-------|
| 1   | 1     |
| 2   | 2     |
| 3   | 1     |

**2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?**
```c
SELECT r.runner_id, AVG(DATEDIFF(MINUTE,c.order_time,r.pickup_time)) avg_time
FROM runner_orders r 
JOIN customer_orders c 
ON r.order_id = c.order_id
WHERE cancellation = ''
GROUP BY r.runner_id;
```
| runner_id  | avg_time|
|-----|-------|
| 1   | 15    |
| 2   | 24    |
| 3   | 10    |

**3. Is there any relationship between the number of pizzas and how long the order takes to prepare?**
```c
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
```
| pizza_orders  | avg_time_to_prepare |
|-----|-------|
| 1   | 12    |
| 2   | 18    |
| 3   | 30    |

**4. What was the average distance travelled for each customer?**
```c
SELECT c.customer_id, ROUND(CAST(AVG(distance) as float),1) AS avg_distance
FROM runner_orders r 
JOIN customer_orders c 
ON r.order_id = c.order_id
WHERE cancellation = ''
GROUP BY c.customer_id
```
| customer_id  | avg_distance |
|-----|-------|
| 101 | 20    |
| 102 | 16.3  |
| 103 | 23    |
| 104 | 10    |
| 105 | 25    |

**5. What was the difference between the longest and shortest delivery times for all orders?**
```c
SELECT MAX(duration) - MIN(duration) AS delivery_time_diff
FROM runner_orders r 
WHERE cancellation = ''
```
| delivery_time_diff |
|-------|
| 30|

**6. What was the average speed for each runner for each delivery and do you notice any trend for these values?**
```c
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
```
| order_id  | runner_id | distance | duration_min | duration_hour | pizza_ordered | speed       |
|-----|-------|---------|---------|-------|----------|-------------|
| 1   | 1     | 20      | 32      | 0.53  | 1        | 37.74 km/h  |
| 2   | 1     | 20      | 27      | 0.45  | 1        | 44.44 km/h  |
| 3   | 1     | 13      | 20      | 0.33  | 2        | 39.39 km/h  |
| 10  | 1     | 10      | 10      | 0.17  | 2        | 58.82 km/h  |
| 4   | 2     | 23      | 40      | 0.67  | 3        | 34.33 km/h  |
| 7   | 2     | 25      | 25      | 0.42  | 1        | 59.52 km/h  |
| 8   | 2     | 23      | 15      | 0.25  | 1        | 92 km/h     |
| 5   | 3     | 10      | 15      | 0.25  | 1        | 40 km/h     |

**7. What is the successful delivery percentage for each runner?**
```c
SELECT runner_id,
        CAST(SUM(CASE
            WHEN cancellation <> '' then 0
            ELSE 1
            END) as float)/COUNT(*) * 100 AS successful_percentage
FROM runner_orders
GROUP BY runner_id;
```
| runner_id  | successful_percentage |
|-----|-------|
| 1   | 100   |
| 2   | 75    |
| 3   | 50    |

### C. Ingredient Optimisation
**1. What are the standard ingredients for each pizza?**
```c
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
```
| pizza_id  | pizza_name  | pizza_toppings                                       |
|-----|-------------|-----------------------------------------------------|
| 1   | Meatlovers  | Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
| 2   | Vegetarian  | Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce |

**2. What was the most commonly added extra?**
```c
SELECT TOP 1 TRIM(ev2.[value]) topping_added_id, CAST(p.topping_name as varchar) topping_name, COUNT(*) added_times
FROM customer_orders c
CROSS APPLY string_split(extras,',') ev2
JOIN pizza_toppings p 
ON ev2.[value] = p.topping_id
WHERE ev2.[value] <> ''
GROUP BY  CAST(p.topping_name as varchar), ev2.[value]
ORDER BY COUNT(*) DESC
```
| topping_added_id  | topping_name | added_times |
|-----|------------|----------|
| 1   | Bacon      | 2        |

**3. What was the most common exclusion?**
```c
SELECT TOP 1 TRIM(ev3.[value]) as exclusion_topping_id,CAST(p.topping_name as varchar) as topping_name, COUNT(*) times_exclusion
FROM customer_orders c 
CROSS APPLY string_split(exclusions,',') ev3
JOIN pizza_toppings p 
ON p.topping_id = ev3.[value]
WHERE ev3.[value] <> ''
GROUP BY ev3.[value], CAST(p.topping_name as varchar)
ORDER BY COUNT(*) DESC;
```
| exclusion_topping_id  | topping_name | exclusion_times |
|-----|------------|----------|
| 1   | Bacon      | 2        |
| 4   | Cheese     | 4        |

**4. Generate an order item for each record in the customers_orders table in the format of one of the following:**
**- Meat Lovers**
**- Meat Lovers - Exclude Beef**
**- Meat Lovers - Extra Bacon**
**- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers**
```c
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
```
| order_id  | ordered_detail                             |
|-----|-------------------------------------------|
| 1   | Meat lovers                               |
| 2   | Meat lovers                               |
| 3   | Meat lovers                               |
| 3   | Vegetarian                                |
| 4   | Meat lovers - Exclude Cheese, Cheese      |
| 4   | Meat lovers - Exclude Cheese, Cheese      |
| 4   | Vegetarian - Exclude Cheese               |
| 5   | Meat lovers                               |
| 6   | Vegetarian                                |
| 7   | Vegetarian                                |
| 8   | Meat lovers                               |
| 9   | Meat lovers - Extra Bacon, Chicken - Exclude Cheese |
| 10  | Meat lovers                               |
| 10  | Meat lovers - Extra Bacon, Cheese - Exclude BBQ Sauce, Mushrooms |

**5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients. For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"**
```c
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
```
| ID  | Ingredients                                                                 |
|-----|-----------------------------------------------------------------------------|
| 1   | Meatlovers:Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami       |
| 2   | Meatlovers:Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami       |
| 3   | Meatlovers:Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami       |
| 3   | Vegetarian:Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes                  |
| 4   | Meatlovers:2x Bacon, 2x BBQ Sauce, 2x Beef, 2x Chicken, 2x Mushrooms, 2x Pepperoni, 2x Salami |
| 4   | Vegetarian:Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes                          |
| 5   | Meatlovers:Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami       |
| 6   | Vegetarian:Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes                  |
| 7   | Vegetarian:Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes                  |
| 8   | Meatlovers:Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami       |
| 9   | Meatlovers:2x Bacon, BBQ Sauce, Beef, 2x Chicken, Mushrooms, Pepperoni, Salami         |
| 10  | Meatlovers:3x Bacon, 2x Beef, 3x Cheese, 2x Chicken, 2x Pepperoni, 2x Salami           |

**6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?**
```c
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
```
| topping_name   | topping_count  |
|---------------|----------|
| Bacon         | 10       |
| Cheese        | 10       |
| Mushrooms     | 10       |
| Pepperoni     | 9        |
| Chicken       | 9        |
| Salami        | 9        |
| Beef          | 9        |
| BBQ Sauce     | 7        |
| Peppers       | 3        |
| Onions        | 3        |
| Tomato Sauce  | 3        |
| Tomatoes      | 3        |
