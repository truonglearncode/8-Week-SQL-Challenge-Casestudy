-- A. Customer Nodes Exploration

-- 1. How many unique nodes are there on the Data Bank system?

SELECT COUNT(DISTINCT node_id) AS node_count
FROM customer_nodes

-- 2. What is the number of nodes per region?

SELECT r.region_name, COUNT( /*DISTINCT*/ c.node_id) as node_count
FROM customer_nodes c 
JOIN regions r 
ON c.region_id = r.region_id
GROUP BY r.region_name

-- 3. How many customers are allocated to each region?

SELECT r.region_name, COUNT(DISTINCT customer_id) AS customer_count
FROM customer_nodes c 
JOIN regions r 
ON r.region_id = c.region_id
GROUP BY r.region_name;

-- 4. How many days on average are customers reallocated to a different node?

WITH temp
AS
(
    SELECT customer_id,node_id ,SUM(DATEDIFF(DAY,start_date,end_date)) day_in_node
    FROM customer_nodes
    WHERE end_date <> '9999-12-31'
    GROUP BY customer_id,node_id
)

SELECT AVG(day_in_node) as AVG_day_in_node
FROM temp;

-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

WITH temp
AS
(
    SELECT c.customer_id,r.region_name,c.node_id, SUM(DATEDIFF(DAY,start_date,end_date)) AS day_in_node
    FROM customer_nodes c 
    JOIN regions r 
    ON r.region_id = c.region_id
    WHERE c.end_date <> '9999-12-31'
    GROUP BY c.customer_id,r.region_name,c.node_id
),
temp1
AS
(
    SELECT region_name, day_in_node,
    ROW_NUMBER() OVER(PARTITION BY region_name ORDER BY day_in_node) AS rn
    FROM temp
),
temp2
AS
(
    SELECT region_name, MAX(rn) AS max_rn
    FROM temp1
    GROUP BY region_name
)

SELECT t1.region_name,t1.day_in_node,
CASE
WHEN rn = ROUND(max_rn * 0.5,0) THEN 'median'
WHEN rn = ROUND(max_rn * 0.8,0) THEN '80th percentile'
ELSE '95th percentile'
END AS percentile
FROM temp1 t1 
JOIN temp2 t2
ON t1.region_name = t2.region_name
WHERE t1.rn IN (
    ROUND(max_rn * 0.5,0),
    ROUND(max_rn * 0.8,0),
    ROUND(max_rn * 0.95,0));

WITH temp
AS
(
    SELECT c.customer_id,r.region_name,c.node_id, SUM(DATEDIFF(DAY,start_date,end_date)) AS day_in_node
    FROM customer_nodes c 
    JOIN regions r 
    ON r.region_id = c.region_id
    WHERE c.end_date <> '9999-12-31'
    GROUP BY c.customer_id,r.region_name,c.node_id
)

SELECT DISTINCT region_name, 
 PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY day_in_node) OVER(PARTITION BY region_name) AS median,
 PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY day_in_node) OVER(PARTITION BY region_name) AS percentile_80,
 PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY day_in_node) OVER(PARTITION BY region_name) AS percentile_95
FROM temp;

-- B. Customer Transactions

-- 1. What is the unique count and total amount for each transaction type?

SELECT txn_type, COUNT(txn_type) as type_count, SUM(txn_amount) total_amt
FROM customer_transactions
GROUP BY txn_type;

-- 2. What is the average total historical deposit counts and amounts for all customers?

WITH temp
AS
(
    SELECT customer_id,COUNT(txn_type) AS deposit_count, SUM(txn_amount) as total_deposit_amt
    FROM customer_transactions
    WHERE txn_type = 'deposit'
    GROUP BY customer_id
)
SELECT AVG(deposit_count) avg_deposit_count, AVG(total_deposit_amt) avg_total_deposit_amt
FROM temp;

-- 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

WITH temp
AS
(
    SELECT customer_id,DATEPART(MONTH,txn_date) as month,
    SUM(CASE
    WHEN txn_type = 'deposit' THEN 1
    ELSE 0 
    END) deposit,
    SUM(CASE
    WHEN txn_type <> 'deposit' THEN 1
    ELSE 0 
    END) AS withdrawal_or_purchase
    FROM customer_transactions
    GROUP BY customer_id, DATEPART(MONTH,txn_date)
)

SELECT month, COUNT(*) AS customer_count 
FROM temp
WHERE deposit >= 1 AND withdrawal_or_purchase >= 1
GROUP BY month;

-- 4. What is the closing balance for each customer at the end of the month?

-- FIRST WAY --

WITH temp 
AS
(
    SELECT customer_id,txn_date, DATETRUNC(MONTH,txn_date) AS txn_month,
    SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE - txn_amount END) AS balance
    FROM customer_transactions
    WHERE customer_id = 1
    GROUP BY customer_id,txn_date,DATETRUNC(MONTH,txn_date)
),
balance 
AS 
(
    SELECT *,
    SUM(balance) OVER(PARTITION BY customer_id ORDER BY txn_date) AS balance_sum,
    ROW_NUMBER() OVER(PARTITION BY customer_id, txn_month ORDER BY txn_date DESC) AS rn
    FROM temp
    -- ORDER BY txn_date
)

SELECT customer_id,DATEADD(DAY,-1,DATEADD(MONTH,1,txn_month)),balance_sum
FROM balance
WHERE rn = 1;

-- ANOTHER WAY --

WITH monthly_balance
AS
(
    SELECT customer_id,DATEADD(DAY,-1,DATEADD(MONTH,1,DATETRUNC(MONTH,txn_date))) as closing_month,
    SUM(
        CASE 
            WHEN txn_type = 'withdrawal' or txn_type = 'purchase' then -txn_amount
            ELSE txn_amount 
        END
    ) AS txn_balance
    FROM customer_transactions
    WHERE customer_id = 1
    GROUP BY customer_id, txn_date
),
number_series
AS
(
    SELECT 0 AS n 
    UNION ALL
    SELECT n+1
    FROM number_series
    WHERE n<3
),
month_ending
AS
(
SELECT DISTINCT customer_id, DATEADD(MONTH,n,'2020-01-31') as ending_month
FROM customer_transactions
CROSS JOIN number_series
),
monthly_change
AS 
(
    SELECT  me.customer_id,me.ending_month,
            SUM(mb.txn_balance) OVER (PARTITION BY me.customer_id,me.ending_month ORDER BY me.ending_month) total_monthly_change,
            SUM(mb.txn_balance) OVER (PARTITION BY me.customer_id ORDER BY me.ending_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) AS ending_balance 
    FROM month_ending me
    JOIN monthly_balance mb
    ON me.ending_month = mb.closing_month
    AND me.customer_id = mb.customer_id
)

SELECT customer_id, ending_month,COALESCE(total_monthly_change,0) as total_monthly_change, MIN(ending_balance) AS ending_balance
FROM monthly_change
GROUP BY customer_id, ending_month, total_monthly_change
ORDER BY customer_id, ending_month

-- 5. What is the percentage of customers who increase their closing balance by more than 5%?

WITH temp
AS
(
    SELECT *, DATETRUNC(MONTH,txn_date) as txn_month,
    CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE - txn_amount END AS balance
    FROM customer_transactions
    -- WHERE customer_id = 109
),
balance
AS
(
    SELECT *,
    SUM(balance) OVER(PARTITION BY customer_id ORDER BY txn_date) AS balance_sum,
    ROW_NUMBER() OVER(PARTITION BY customer_id, txn_month ORDER BY txn_date DESC) AS rn 
    FROM temp
    -- ORDER BY txn_date
),
temp1
AS
(
    SELECT 
        customer_id, 
        DATEADD(DAY,-1,DATEADD(MONTH,1,txn_month)) as closing_month, 
        DATEADD(DAY, -1,txn_month) as previous_closing_month, 
        balance_sum
    FROM balance
    WHERE rn = 1
),
increase_percentage
AS
(
    SELECT 
        t11.customer_id, 
        t11.closing_month, 
        t11.balance_sum, 
        t12.closing_month AS next_closing_month, 
        t12.balance_sum as next_month_balance,
        ROUND((CAST(t12.balance_sum as float) / CAST(t11.balance_sum as float)),1) - 1 as percentage_increase,
        CASE 
        WHEN t12.balance_sum > t11.balance_sum AND ROUND((CAST(t12.balance_sum as float) / CAST(t11.balance_sum as float)),1) - 1 > 0.05 THEN 1
        ELSE 0
        END as increase_over
    FROM temp1 t11
    JOIN temp1 t12
    ON t11.closing_month = t12.previous_closing_month AND t11.customer_id = t12.customer_id
    WHERE t11.balance_sum <> 0
)

SELECT 
CONCAT(ROUND(CAST(SUM(increase_over) as float) / CAST(COUNT(increase_over) as float) * 100, 1),'%') AS percentage_of_customer_increase
FROM increase_percentage