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
1. How many pizzas were ordered?
2. How many unique customer orders were made?
3. How many successful orders were delivered by each runner?
4. How many of each type of pizza was delivered?
5. How many Vegetarian and Meatlovers were ordered by each customer?
6. What was the maximum number of pizzas delivered in a single order?
7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
8. How many pizzas were delivered that had both exclusions and extras?
9. What was the total volume of pizzas ordered for each hour of the day?
10. What was the volume of orders for each day of the week?

### B. Runner and Customer Experience
1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
4. What was the average distance travelled for each customer?
5. What was the difference between the longest and shortest delivery times for all orders?
6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
7. What is the successful delivery percentage for each runner?

### C. Ingredient Optimisation
1. What are the standard ingredients for each pizza?
2. What was the most commonly added extra?
3. What was the most common exclusion?
4. Generate an order item for each record in the customers_orders table in the format of one of the following:
- Meat Lovers
- Meat Lovers - Exclude Beef
- Meat Lovers - Extra Bacon
- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients. For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

