# CASE STUDY #1: DANNY'S DINER
## Introduction:
Danny’s Dinner is a cute little restaurant that sells 3 popular Japanese foods: sushi, curry and ramen - The restaurant has captured some very basic data from a few months of operation.
Use this data to discover some business problem to help restaurant improve activity performance and run ahead the business by using SQL to go deeper and answer 10 main question and 2 bonus question about customers, visit patterns, how much money they’ve spent and kind of food their favorite on the menu
## Problem Statement
Use data to answer a few simple questions about customers, their visiting patterns, how much money they’ve spent and also which menu items are their favorite. Having this deeper connection with customers will deliver a better and more personalized experience for loyal customers.
Using these insights to help decide whether should expand the existing customer loyalty program
## Entity Relationship Diagram (ERD)
3 Table: **sales**, **members**, **menu**

![Case Study #1 - Entity Relationship Diagram (ERD).png](https://github.com/truongwfdata/SQL-Challenge/blob/main/Case%20study%201%3A%20Danny's%20Diner/Case%20Study%20%231%20-%20Entity%20Relationship%20Diagram%20(ERD).png)

## Table Description
### Table 1: Sales
The Sales table captures all customer_id level purchases with an corresponding order_date and product_id information for when and what menu items were ordered

### Table 2: menu
The menu table maps the product_id to the actual product_name and price of each menu items

### Table 3: members
The members table captures the join_date when customer_id joined the loyalty program

