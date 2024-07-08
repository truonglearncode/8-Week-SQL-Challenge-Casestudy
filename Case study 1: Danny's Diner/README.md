# CASE STUDY #1: DANNY'S DINER
## Table of Content
* [Introduction](#introduction)
* [Problem Statement](#problem-statement)
* [Entity Relationship Diagram (ERD)](#erd)
* [Table Description](#table-description)
* [Case Study Question](#case-question)
## Introduction <a class = 'anchor' id = 'introduction'></a>
Danny’s Dinner is a cute little restaurant that sells 3 popular Japanese foods: sushi, curry and ramen - The restaurant has captured some very basic data from a few months of operation.
Use this data to discover some business problem to help restaurant improve activity performance and run ahead the business by using SQL to go deeper and answer 10 main question and 2 bonus question about customers, visit patterns, how much money they’ve spent and kind of food their favorite on the menu
## Problem Statement <a class = 'anchor' id = 'problem-statement'></a>
Use data to answer a few simple questions about customers, their visiting patterns, how much money they’ve spent and also which menu items are their favorite. Having this deeper connection with customers will deliver a better and more personalized experience for loyal customers.
Using these insights to help decide whether should expand the existing customer loyalty program
## Entity Relationship Diagram (ERD) <a class = 'anchor' id = 'erd'></a>
3 Table: **sales**, **members**, **menu**

![Case Study #1 - Entity Relationship Diagram (ERD).png](https://github.com/truongwfdata/SQL-Challenge/blob/main/Case%20study%201%3A%20Danny's%20Diner/Case%20Study%20%231%20-%20Entity%20Relationship%20Diagram%20(ERD).png)

## Table Description <a class = 'anchor' id = 'table-description'></a>
### *Table 1: Sales*
The Sales table captures all customer_id level purchases with an corresponding order_date and product_id information for when and what menu items were ordered

![sale_table](https://github.com/truongwfdata/SQL-Challenge/blob/main/Case%20study%201%3A%20Danny's%20Diner/Case%20Study%20%231%20-%20sales%20table.png)
### *Table 2: menu*
The menu table maps the product_id to the actual product_name and price of each menu items

![menu_table](https://github.com/truongwfdata/SQL-Challenge/blob/main/Case%20study%201%3A%20Danny's%20Diner/Case%20Study%20%231%20-%20menu%20table.png)
### *Table 3: members*
The members table captures the join_date when customer_id joined the loyalty program

![member_table](https://github.com/truongwfdata/SQL-Challenge/blob/main/Case%20study%201%3A%20Danny's%20Diner/Case%20Study%20%231%20-%20members%20table.png)
## Case Study Question <a class = 'anchor' id = 'case-question'></a>
1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
### *View all information about this case [here](https://8weeksqlchallenge.com/case-study-1/)*
