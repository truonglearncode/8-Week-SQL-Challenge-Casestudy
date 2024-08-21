# Case Study #3 - Foodie-Fi
## Table of Content
* [Introduction](#introduction)
* [Problem Statement](#problem-statement)
* [Entity Relationship Diagram (ERD)](#erd)
* [Table Description](#table-description)
* [Case Study Question & Solutions](#question-solutions)
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

## Case Study Question & Solutions <a class = 'anchor' id = 'question-solutions'></a>
### A. Customer Journey
Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.
```c
SELECT s.customer_id , s.plan_id, p.plan_name, p.price, s.start_day
FROM subscriptions s
JOIN plans p 
ON s.plan_id = p.plan_id
WHERE customer_id <= 8
```
| ID  | Status | Plan          | Price | Date       |
|-----|--------|---------------|-------|------------|
| 1   | 0      | trial         | 0.00  | 2020-08-01 |
| 1   | 1      | basic monthly | 9.90  | 2020-08-08 |
| 2   | 0      | trial         | 0.00  | 2020-09-20 |
| 2   | 3      | pro annual    | 199.00| 2020-09-27 |
| 3   | 0      | trial         | 0.00  | 2020-01-13 |
| 3   | 1      | basic monthly | 9.90  | 2020-01-20 |
| 4   | 0      | trial         | 0.00  | 2020-01-17 |
| 4   | 1      | basic monthly | 9.90  | 2020-01-24 |
| 4   | 4      | churn         | NULL  | 2020-04-21 |
| 5   | 0      | trial         | 0.00  | 2020-08-03 |
| 5   | 1      | basic monthly | 9.90  | 2020-08-10 |
| 6   | 0      | trial         | 0.00  | 2020-12-23 |
| 6   | 1      | basic monthly | 9.90  | 2020-12-30 |
| 6   | 4      | churn         | NULL  | 2021-02-26 |
| 7   | 0      | trial         | 0.00  | 2020-02-05 |
| 7   | 1      | basic monthly | 9.90  | 2020-02-12 |
| 7   | 2      | pro monthly   | 19.90 | 2020-05-22 |

***Key Finding:***

Almost customer entries with trial plan because it free and customer want to try some feature, user experience and everything make application helpful in future befrore customer consider to upgrade their plan up to next level

A trial plan give customer can try application for free in 7 days after that customer can choose a plan to upgrade for continue using service and it require charge for each month

Several customer always choose basic montly plan after using trial plan service and it require 9.90$ charge per month 
### B. Data Analysis Questions 
**1. How many customers has Foodie-Fi ever had?**
```c
SELECT COUNT(DISTINCT(customer_id)) AS customer_count
FROM subscriptions
```
|customer_count|
|-|
|1000|

**2. What is the monthly distribution of trial plan start_date values for our dataset?**
```c
SELECT DATETRUNC(MONTH,start_day) AS month, COUNT(customer_id) AS customer_count
FROM subscriptions s 
JOIN plans p 
ON s.plan_id = p.plan_id
WHERE p.plan_name = 'trial'
GROUP BY DATETRUNC(MONTH,start_day)
```
| month       | customer_count |
|------------|-------|
| 2020-01-01 | 88    |
| 2020-02-01 | 68    |
| 2020-03-01 | 94    |
| 2020-04-01 | 81    |
| 2020-05-01 | 88    |
| 2020-06-01 | 79    |
| 2020-07-01 | 89    |
| 2020-08-01 | 88    |
| 2020-09-01 | 87    |
| 2020-10-01 | 79    |
| 2020-11-01 | 75    |
| 2020-12-01 | 84    |

**3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name**
```c
SELECT p.plan_name, COUNT(*) as customer_count
FROM subscriptions s 
JOIN plans p 
ON s.plan_id = p.plan_id
WHERE DATEPART(YEAR,start_day) > 2020
GROUP BY p.plan_name
```
| plan_name         | customer_count |
|--------------|----------|
| basic monthly| 8        |
| churn        | 71       |
| pro annual   | 63       |
| pro monthly  | 60       |

**4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?**
```c
SELECT COUNT(DISTINCT customer_id) as customer_count,
(SELECT COUNT(DISTINCT customer_id) FROM subscriptions WHERE plan_id = 4) as customer_churn_count, 
ROUND(CAST(SUM(CASE 
WHEN plan_name = 'churn' THEN 1 
ELSE 0
END) as float)/ COUNT(DISTINCT customer_id) * 100,1) as customer_churn_percentage
FROM subscriptions s 
JOIN plans p 
ON s.plan_id = p.plan_id
```
| customer_count | customer_churn_count | customer_churn_percentage |
|---------|---------|---------|
| 1000    | 307     | 30.7    |

**5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?**
```c
WITH temp 
AS
(
    SELECT s.customer_id, p.plan_name,
    ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY start_day) upgrade_plan
    FROM subscriptions s 
    JOIN plans p 
    ON s.plan_id = p.plan_id
)

SELECT (SELECT COUNT(*) FROM temp WHERE upgrade_plan = 2 AND plan_name = 'churn') as customer_churn_after_trial_count,
CAST(SUM(CASE 
WHEN upgrade_plan = 2 AND plan_name = 'churn' THEN 1 
ELSE 0
END) as float)/ COUNT(DISTINCT customer_id) * 100 AS customer_churn_after_trial_count_percentage
FROM temp;
```
| customer_churn_after_trial_count | customer_churn_after_trial_count_percentage |
|---------|---------|
| 92      | 9.2     |

**6. What is the number and percentage of customer plans after their initial free trial?**
```c
WITH temp 
AS
(
    SELECT s.customer_id,p.plan_name, 
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY start_day) upgrade_plan
    FROM subscriptions s
    JOIN plans p
    ON s.plan_id = p.plan_id
)
SELECT plan_name,COUNT(plan_name) customer_upgrade_after_trial_count,
ROUND(CAST(COUNT(plan_name) as float)/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions) * 100, 1) customer_upgrade_after_trial_percentage
FROM temp
WHERE upgrade_plan = 2 AND plan_name <> 'churn'
GROUP BY plan_name;
```
| plan_name          | customer_upgrade_after_trial_count | customer_upgrade_after_trial_percentage |
|---------------|---------|---------|
| pro annual    | 37      | 3.7     |
| pro monthly   | 325     | 32.5    |
| basic monthly | 546     | 54.6    |

**7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?**
```c
WITH temp
AS
(
    SELECT s.customer_id,s.plan_id, s.start_day, p.plan_name,
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY start_day DESC) as last_upgrade
    FROM subscriptions s
    JOIN plans p
    ON s.plan_id = p.plan_id
    WHERE start_day <= '2020-12-31'
)

SELECT plan_name, COUNT(plan_name) as customer_count,
ROUND(CAST(COUNT(plan_name) as float)/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions) * 100, 1) as customer_percentage
FROM temp
WHERE last_upgrade = 1
GROUP BY plan_name;
```
| plan_name          | customer_count| customer_percentage |
|---------------|-------|------------|
| Pro Annual    | 195   | 19.5%      |
| Pro Monthly   | 326   | 32.6%      |
| Churn         | 236   | 23.6%      |
| Basic Monthly | 224   | 22.4%      |
| Trial         | 19    | 1.9%       |

**8. How many customers have upgraded to an annual plan in 2020?**
```c
SELECT COUNT(s.customer_id) as customer_upgrade_to_annual_plan_count
FROM subscriptions s
JOIN plans p
ON s.plan_id = p.plan_id
WHERE DATEPART(YEAR,start_day) = 2020 AND p.plan_name = 'pro annual';
```
|customer_upgrade_to_annual_plan_count|
|-|
|195|

**9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?**
```c
WITH trial_temp
AS
(
    SELECT s.customer_id,s.start_day
    FROM subscriptions s
    JOIN plans p
    ON s.plan_id = p.plan_id
    WHERE plan_name = 'trial'
),
annual_temp
AS
(
SELECT s.customer_id,s.start_day
FROM subscriptions s
JOIN plans p
ON s.plan_id = p.plan_id
WHERE plan_name = 'pro annual'
)

SELECT AVG(DATEDIFF(DAY,t.start_day,a.start_day)) avg_day_from_trial_to_annual_plan
FROM trial_temp t
JOIN annual_temp a 
ON t.customer_id = a.customer_id
```
|avg_day_from_trial_to_annual_plan|
|-|
|104|

**10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)**
```c
WITH trial_temp
AS
(
    SELECT s.customer_id,s.start_day
    FROM subscriptions s
    JOIN plans p
    ON s.plan_id = p.plan_id
    WHERE plan_name = 'trial'
),
annual_temp
AS
(
SELECT s.customer_id,s.start_day
FROM subscriptions s
JOIN plans p
ON s.plan_id = p.plan_id
WHERE plan_name = 'pro annual'
)

SELECT 
    CASE
    WHEN DATEDIFF(DAY,t.start_day,a.start_day) <= 30 THEN CONVERT(varchar,'0-30 days')
    WHEN DATEDIFF(DAY,t.start_day,a.start_day) <= 60 THEN CONVERT(varchar,'31-60 days')
    WHEN DATEDIFF(DAY,t.start_day,a.start_day) <= 90 THEN CONVERT(varchar,'61-90 days')
    WHEN DATEDIFF(DAY,t.start_day,a.start_day) <= 120 THEN CONVERT(varchar,'91-120 days')
    WHEN DATEDIFF(DAY,t.start_day,a.start_day) <= 150 THEN CONVERT(varchar,'121-150 days')
    WHEN DATEDIFF(DAY,t.start_day,a.start_day) <= 180 THEN CONVERT(varchar,'151-180 days')
    WHEN DATEDIFF(DAY,t.start_day,a.start_day) <= 210 THEN CONVERT(varchar,'181-210 days')
    WHEN DATEDIFF(DAY,t.start_day,a.start_day) <= 240 THEN CONVERT(varchar,'211-240 days')
    WHEN DATEDIFF(DAY,t.start_day,a.start_day) <= 270 THEN CONVERT(varchar,'241-270 days')
    WHEN DATEDIFF(DAY,t.start_day,a.start_day) <= 300 THEN CONVERT(varchar,'271-300 days')
    WHEN DATEDIFF(DAY,t.start_day,a.start_day) <= 330 THEN CONVERT(varchar,'301-330 days')
    ELSE CONVERT(varchar,'331-370 days')
    END as days_breakdown,
    COUNT(t.customer_id) as customer_count
FROM trial_temp t
JOIN annual_temp a 
ON t.customer_id = a.customer_id
GROUP BY 
    CASE
    WHEN DATEDIFF(DAY,t.start_day,a.start_day) <= 30 THEN CONVERT(varchar,'0-30 days')
    WHEN DATEDIFF(DAY,t.start_day,a.start_day) <= 60 THEN CONVERT(varchar,'31-60 days')
    WHEN DATEDIFF(DAY,t.start_day,a.start_day) <= 90 THEN CONVERT(varchar,'61-90 days')
    WHEN DATEDIFF(DAY,t.start_day,a.start_day) <= 120 THEN CONVERT(varchar,'91-120 days')
    WHEN DATEDIFF(DAY,t.start_day,a.start_day) <= 150 THEN CONVERT(varchar,'121-150 days')
    WHEN DATEDIFF(DAY,t.start_day,a.start_day) <= 180 THEN CONVERT(varchar,'151-180 days')
    WHEN DATEDIFF(DAY,t.start_day,a.start_day) <= 210 THEN CONVERT(varchar,'181-210 days')
    WHEN DATEDIFF(DAY,t.start_day,a.start_day) <= 240 THEN CONVERT(varchar,'211-240 days')
    WHEN DATEDIFF(DAY,t.start_day,a.start_day) <= 270 THEN CONVERT(varchar,'241-270 days')
    WHEN DATEDIFF(DAY,t.start_day,a.start_day) <= 300 THEN CONVERT(varchar,'271-300 days')
    WHEN DATEDIFF(DAY,t.start_day,a.start_day) <= 330 THEN CONVERT(varchar,'301-330 days')
    ELSE CONVERT(varchar,'331-370 days')
    END;
```
| days_breakdown     | customer_count |
|----------------|-------|
| 0-30 days      | 49    |
| 31-60 days     | 24    |
| 61-90 days     | 34    |
| 91-120 days    | 35    |
| 121-150 days   | 42    |
| 151-180 days   | 36    |
| 181-210 days   | 26    |
| 211-240 days   | 4     |
| 241-270 days   | 5     |
| 271-300 days   | 1     |
| 301-330 days   | 1     |
| 331-370 days   | 1     |

**11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?**
```c
WITH pro_temp
AS
(
SELECT s.customer_id,s.start_day as pro_monthly_start_date
FROM subscriptions s
JOIN plans p
ON s.plan_id = p.plan_id
WHERE plan_name = 'pro monthly'
),
basic_temp
AS
(
SELECT s.customer_id,s.start_day as basic_monthly_start_date
FROM subscriptions s
JOIN plans p
ON s.plan_id = p.plan_id
WHERE plan_name = 'basic monthly'
)

SELECT *
FROM pro_temp p 
JOIN basic_temp b
ON p.customer_id = b.customer_id
WHERE p.pro_monthly_start_date < basic_monthly_start_date
```
***In Fact: No one downgrade from pro monthly plan to basic monthly plan***
