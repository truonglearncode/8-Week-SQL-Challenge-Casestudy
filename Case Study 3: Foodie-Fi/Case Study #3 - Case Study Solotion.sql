-- A. Customer Journey

-- Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.
-- Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

SELECT s.customer_id , s.plan_id, p.plan_name, p.price, s.start_day
FROM subscriptions s
JOIN plans p 
ON s.plan_id = p.plan_id
WHERE customer_id <= 8

-- Almost customer entries with trial plan because it free and customer want to try some feature, user experience and everything make application helpful in future befrore customer consider to upgrade their plan up to next level
-- A trial plan give customer can try application for free in 7 days after that customer can choose a plan to upgrade for continue using service and it require charge for each month
-- Several customer always choose basic montly plan after using trial plan service and it require 9.90$ charge per month 

-- B. Data Analysis Questions

-- 1. How many customers has Foodie-Fi ever had?

SELECT COUNT(DISTINCT(customer_id)) AS customer_count
FROM subscriptions

-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

SELECT DATETRUNC(MONTH,start_day) AS month, COUNT(customer_id) AS customer_count
FROM subscriptions s 
JOIN plans p 
ON s.plan_id = p.plan_id
WHERE p.plan_name = 'trial'
GROUP BY DATETRUNC(MONTH,start_day)

-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

SELECT p.plan_name, COUNT(*) as customer_count
FROM subscriptions s 
JOIN plans p 
ON s.plan_id = p.plan_id
WHERE DATEPART(YEAR,start_day) > 2020
GROUP BY p.plan_name

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

SELECT COUNT(DISTINCT customer_id) as customer_count,
(SELECT COUNT(DISTINCT customer_id) FROM subscriptions WHERE plan_id = 4) as customer_churn_count, 
ROUND(CAST(SUM(CASE 
WHEN plan_name = 'churn' THEN 1 
ELSE 0
END) as float)/ COUNT(DISTINCT customer_id) * 100,1) as customer_churn_percentage
FROM subscriptions s 
JOIN plans p 
ON s.plan_id = p.plan_id

-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

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

-- 6. What is the number and percentage of customer plans after their initial free trial?

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

-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

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

-- 8. How many customers have upgraded to an annual plan in 2020?

SELECT COUNT(s.customer_id) as customer_upgrade_to_annual_plan_count
FROM subscriptions s
JOIN plans p
ON s.plan_id = p.plan_id
WHERE DATEPART(YEAR,start_day) = 2020 AND p.plan_name = 'pro annual';

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

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

-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

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

-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

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

-- No one downgrade from pro monthly plan to basic monthly plan