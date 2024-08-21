# CASE STUDY #4: DATA BANK
## Table of Content
* [Introduction](#introduction)
* [Problem Statement](#problem-statement)
* [Entity Relationship Diagram (ERD)](#erd)
* [Table Description](#table-description)
* [Case Study Question & Solutions](#question-solutions)
## Introduction <a class = 'anchor' id = 'introduction'></a>
There is a new innovation in the financial industry called Neo-Banks: new aged digital only banks without physical branches.

Nowaday, there should be some sort of intersection between these new age banks, cryptocurrency and the data world…so a new initiative has been founded - Data Bank!

Data Bank runs just like any other digital bank - but it isn’t only for banking activities, they also have the world’s most secure distributed data storage platform!

Customers are allocated cloud data storage limits which are directly linked to how much money they have in their accounts. There are a few interesting caveats that go with this business model, and this is where the Data Bank team need your help!
## Problem Statement <a class = 'anchor' id = 'problem-statement'></a>
The management team at Data Bank want to increase their total customer base - but also need some help tracking just how much data storage their customers will need.

This case study is all about calculating metrics, growth and helping the business analyse their data in a smart way to better forecast and plan for their future developments!
## Entity Relationship Diagram (ERD) <a class = 'anchor' id = 'erd'></a>
3 Table: **regions**, **customer_nodes**, **customer_transactions**

![ERD](https://github.com/truonglearncode/SQL-Casestudy/blob/main/Case%20study%204:%20Data%20Bank/Entity%20Relationship%20Diagram%20(ERD).png)

## Table Description <a class = 'anchor' id = 'table-description'></a>
### *Table 1: regions*
Just like popular cryptocurrency platforms - Data Bank is also run off a network of nodes where both money and data is stored across the globe. In a traditional banking sense - you can think of these nodes as bank branches or stores that exist around the world.

This regions table contains the region_id and their respective region_name values

![Regions Table](https://github.com/truonglearncode/SQL-Casestudy/blob/main/Case%20study%204%3A%20Data%20Bank/Regions%20Table.png)

### *Table 2: customer_nodes*
Customers are randomly distributed across the nodes according to their region - this also specifies exactly which node contains both their cash and data.

This random distribution changes frequently to reduce the risk of hackers getting into Data Bank’s system and stealing customer’s money and data!

![Customer Nodes Table](https://github.com/truonglearncode/SQL-Casestudy/blob/main/Case%20study%204%3A%20Data%20Bank/Customer%20Nodes%20Table.png)

### *Table 3: customer_transactions*
This table stores all customer deposits, withdrawals and purchases made using their Data Bank debit card.

![Customer Transactions Table](https://github.com/truonglearncode/SQL-Casestudy/blob/main/Case%20study%204%3A%20Data%20Bank/Customer%20Transactions%20Table.png)

## Case Study Question & Solutions <a class = 'anchor' id = 'question-solutions'></a>
### A. Customer Nodes Exploration
**1. How many unique nodes are there on the Data Bank system?**
```c
SELECT COUNT(DISTINCT node_id) AS node_count
FROM customer_nodes
```
|node_count|
|-|
|5|

**2. What is the number of nodes per region?**
```c
SELECT r.region_name, COUNT( /*DISTINCT*/ c.node_id) as node_count
FROM customer_nodes c 
JOIN regions r 
ON c.region_id = r.region_id
GROUP BY r.region_name
```
| region_name  | node_count |
|------------|-------|
| Africa     | 714   |
| America    | 735   |
| Asia       | 665   |
| Australia  | 770   |
| Europe     | 616   |

**3. How many customers are allocated to each region?**
```c
SELECT r.region_name, COUNT(DISTINCT customer_id) AS customer_count
FROM customer_nodes c 
JOIN regions r 
ON r.region_id = c.region_id
GROUP BY r.region_name;
```
| region_name  | customer_count |
|------------|-------|
| Africa     | 102   |
| America    | 105   |
| Asia       | 95    |
| Australia  | 110   |
| Europe     | 88    |

**4. How many days on average are customers reallocated to a different node?**
```c
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
```
|AVG_day_in_node|
|-|
|23|

**5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?**
```c
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
ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY day_in_node) OVER(PARTITION BY region_name) AS FLOAT),1) AS median,
ROUND(CAST(PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY day_in_node) OVER(PARTITION BY region_name) AS FLOAT),1) AS percentile_80,
ROUND(CAST(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY day_in_node) OVER(PARTITION BY region_name) AS FLOAT),1) AS percentile_95
FROM temp;
```
| region_name  | median | percentile_80| percentile_95 |
|------------|---------|---------|---------|
| Africa     | 22      | 35      | 54      |
| America    | 22      | 34      | 53.7    |
| Asia       | 22      | 34.6    | 52      |
| Australia  | 21      | 34      | 51      |
| Europe     | 23      | 34      | 51.4    |

### B. Customer Transactions
**1. What is the unique count and total amount for each transaction type?**
```c
SELECT txn_type, COUNT(txn_type) as type_count, SUM(txn_amount) total_amt
FROM customer_transactions
GROUP BY txn_type;
```
| txn_type | type_count | total_amt  |
|------------------|-------|---------|
| Withdrawal       | 1580  | 793003  |
| Deposit          | 2671  | 1359168 |
| Purchase         | 1617  | 806537  |

**2. What is the average total historical deposit counts and amounts for all customers?**
```c
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
```
| avg_deposit_count | avg_total_deposit_amt |
|---------|---------|
| 5       | 2718    |

**3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?**
```c
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
```
| month | customer_count  |
|---------|---------|
| 1       | 295     |
| 2       | 298     |
| 3       | 329     |
| 4       | 138     |

**4. What is the closing balance for each customer at the end of the month?**
```c
WITH temp 
AS
(
    SELECT customer_id,txn_date, DATETRUNC(MONTH,txn_date) AS txn_month,
    SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE - txn_amount END) AS balance
    FROM customer_transactions
    -- WHERE customer_id = 1
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

SELECT TOP 10 customer_id,DATEADD(DAY,-1,DATEADD(MONTH,1,txn_month)) AS closing_month,balance_sum
FROM balance
WHERE rn = 1;
```
| customer_id | closing_month       | balance_sum |
|----|------------|-------|
| 1  | 2020-01-31 | 312   |
| 1  | 2020-03-31 | -640  |
| 2  | 2020-01-31 | 549   |
| 2  | 2020-03-31 | 610   |
| 3  | 2020-01-31 | 144   |
| 3  | 2020-02-29 | -821  |
| 3  | 2020-03-31 | -1222 |
| 3  | 2020-04-30 | -729  |
| 4  | 2020-01-31 | 848   |
| 4  | 2020-03-31 | 655   |

**5. What is the percentage of customers who increase their closing balance by more than 5%?**
```c
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
```
|percentage_of_customer_increase|
|-|
|21%|
