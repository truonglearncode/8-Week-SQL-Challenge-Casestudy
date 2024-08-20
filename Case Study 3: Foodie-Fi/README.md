# Case Study #3 - Foodie-Fi
## Table of Content
* [Introduction](#introduction)
* [Problem Statement](#problem-statement)
* [Entity Relationship Diagram (ERD)](#erd)
* [Table Description](#table-description)
* [Case Study Question](#case-question)
## Introduction <a class = 'anchor' id = 'introduction'></a>
Subscription based businesses are super popular and this application is a new streaming service that only had food related content - something like Netflix but with only cooking shows!

This app provide service to customers by selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world!

## Problem Statement <a class = 'anchor' id = 'problem-statement'></a>

In this business, Data driven mindset must have for everyone and wanted to ensure all future investment decisions and new features were decided using data. This case study focuses on using subscription style digital data to answer important business questions.

## Entity Relationship Diagram (ERD) <a class = 'anchor' id = 'erd'></a>
2 Table: **plans**, **subscriptions**

![ERD](https://github.com/truonglearncode/SQL-Casestudy/blob/main/Case%20Study%203%3A%20Foodie-Fi/Entity%20Relationship%20Diagram%20(ERD).png)

## Table Description <a class = 'anchor' id = 'table-description'></a>
### *Table 1: plans*
Customers can choose which plans to join Foodie-Fi when they first sign up.

Basic plan customers have limited access and can only stream their videos and is only available monthly at $9.90

Pro plan customers have no watch time limits and are able to download videos for offline viewing. Pro plans start at $19.90 a month or $199 for an annual subscription.

Customers can sign up to an initial 7 day free trial will automatically continue with the pro monthly subscription plan unless they cancel, downgrade to basic or upgrade to an annual pro plan at any point during the trial.

When customers cancel their Foodie-Fi service - they will have a churn plan record with a null price but their plan will continue until the end of the billing period.

![Plans Table](https://github.com/truonglearncode/SQL-Casestudy/blob/main/Case%20Study%203%3A%20Foodie-Fi/Plans%20Table.png)

### *Table 2: subscriptions*
Customer subscriptions show the exact date where their specific plan_id starts.

If customers downgrade from a pro plan or cancel their subscription - the higher plan will remain in place until the period is over - the start_date in the subscriptions table will reflect the date that the actual plan changes.

When customers upgrade their account from a basic plan to a pro or annual pro plan - the higher plan will take effect straightaway.

When customers churn - they will keep their access until the end of their current billing period but the start_date will be technically the day they decided to cancel their service.

![Subscriptions Table](https://github.com/truonglearncode/SQL-Casestudy/blob/main/Case%20Study%203%3A%20Foodie-Fi/Subscriptions%20Table.png)

## Case Study Question <a class = 'anchor' id = 'case-question'></a>
### A. Customer Journey
Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

### B. Data Analysis Questions
1. How many customers has Foodie-Fi ever had?
2. What is the monthly distribution of trial plan start_date values for our dataset?
3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
6. What is the number and percentage of customer plans after their initial free trial?
7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
8. How many customers have upgraded to an annual plan in 2020?
9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
