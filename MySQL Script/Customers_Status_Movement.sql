#................Customer  status monthly trend for Old Status.............#
SELECT old_active_status,lcp_status,
COUNT(CASE WHEN month_date ='Jan-22' THEN contract END) 'Jan-22',
COUNT(CASE WHEN month_date ='Feb-22' THEN contract END) 'Feb-22',
COUNT(CASE WHEN month_date ='Mar-22' THEN contract END) 'Mar-22',
COUNT(CASE WHEN month_date ='Apr-22' THEN contract END) 'Apr-22',
COUNT(CASE WHEN month_date ='May-22' THEN contract END) 'May-22',
COUNT(CASE WHEN month_date ='Jun-22' THEN contract END) 'Jun-22',
COUNT(CASE WHEN month_date ='Jul-22' THEN contract END) 'Jul-22'
FROM customer_status
GROUP BY old_active_status,lcp_status

#................Customer  Old status Prev. and Current month Comparison.............#
SELECT Prev_M_Old_status, Curr_M_Old_status, lcp_status, COUNT(contract) Counts
FROM
(
SELECT a.contract, a.old_active_status Prev_M_Old_status, b.old_active_status Curr_M_Old_status, a.lcp_status
FROM
(
(SELECT contract,old_active_status,lcp_status
FROM customer_status
WHERE `month_date`='Jun-22')a
LEFT OUTER JOIN (SELECT * FROM `customer_status`
WHERE `month_date`='Jul-22')b
ON a.contract = b.contract
)
)d
GROUP BY Prev_M_Old_status, Curr_M_Old_status,lcp_status



#................Customer  status monthly trend for new status.............#
SELECT customer_status,lcp_status,
COUNT(CASE WHEN month_date ='Jan-22' THEN contract END) 'Jan-22',
COUNT(CASE WHEN month_date ='Feb-22' THEN contract END) 'Feb-22',
COUNT(CASE WHEN month_date ='Mar-22' THEN contract END) 'Mar-22',
COUNT(CASE WHEN month_date ='Apr-22' THEN contract END) 'Apr-22',
COUNT(CASE WHEN month_date ='May-22' THEN contract END) 'May-22',
COUNT(CASE WHEN month_date ='Jun-22' THEN contract END) 'Jun-22',
COUNT(CASE WHEN month_date ='Jul-22' THEN contract END) 'Jul-22',
COUNT(CASE WHEN month_date ='Aug-22' THEN contract END) 'Aug-22',
COUNT(CASE WHEN month_date ='Sep-22' THEN contract END) 'Sep-22',
COUNT(CASE WHEN month_date ='Oct-22' THEN contract END) 'Oct-22'
FROM customer_status
GROUP BY customer_status,lcp_status

#................Customer  New status Prev. and Current month Comparison.............#
SELECT New_status_PM, New_status_CM, lcp_status, COUNT(contract) Counts
FROM
(
SELECT a.contract, a.customer_status New_status_PM, b.customer_status New_status_CM, a.lcp_status
FROM
(
(SELECT contract,customer_status,lcp_status
FROM customer_status
WHERE `month_date`='Jul-22')a
LEFT OUTER JOIN (SELECT * FROM `customer_status`
WHERE `month_date`='Aug-22')b
ON a.contract = b.contract
)
)d
GROUP BY New_status_PM, New_status_CM,lcp_status




#-----------------Customer base New Sales in May------------------------------------------#

SELECT contract_creation,lcp_status, old_active_status,COUNT(contract)Counts
FROM `activity_log`
WHERE contract_creation >  (CURDATE() - INTERVAL 1 MONTH  - INTERVAL 15 DAY)
GROUP BY lcp_status, old_active_status,contract_creation



SELECT CURDATE() - INTERVAL 1 MONTH  - INTERVAL 15 DAY

#select (CURDATE() – interval 1 month) – interval day(CURDATE() – interval 1 month) day interval 1 day;

#select curDate()

SELECT contract,lcp_status, old_active_status
FROM `activity_log` WHERE `month_date` = 'Jul-22'


#..........................Customer Movement............................#
SELECT a.`contract`,a.`crmcontract`,a.lcp_status,a.generation,a.outage_days Prev_Dark_Day,b.outage_days Curr_Dark_Day, 
a.`customer_status` Prev_Status,b.`customer_status` Curr_Status, COUNT(a.contract) CB_Counts
FROM 
(SELECT * FROM activity_log WHERE `month_date` = 'Apr-23' ) a
LEFT OUTER JOIN
activity b
ON a.`contract` = b.`contract`
GROUP BY `contract`,`crmcontract`, lcp_status, generation, Prev_Dark_Day, Curr_Dark_Day,Prev_Status,Curr_Status


#---------------Customer movement with Repayment revenue-----------------------------------------#
SELECT a.`contract`,a.`crmcontract`,a.lcp_status,a.generation,a.outage_days Prev_Dark_Day,b.outage_days Curr_Dark_Day, 
a.`customer_status` Prev_Status,b.`customer_status` Curr_Status, SUM(`charged_amount`) Revenue, COUNT(a.contract) CB_Counts
FROM 
(SELECT * FROM activity_log WHERE `month_date` = 'Apr-23' ) a
LEFT OUTER JOIN
activity b
ON a.`contract` = b.`contract`
LEFT JOIN
`daily_transactions_curr_MTD` c
ON a.`contract` = c.`contract`
GROUP BY `contract`,`crmcontract`, lcp_status, generation, Prev_Dark_Day, Curr_Dark_Day,Prev_Status,Curr_Status


`daily_transactions_curr_MTD` 

SELECT `contract`,`crmcontract`, lcp_status, generation,`customer_status`,`contract_creation`
FROM activity

SELECT COUNT(contract) FROM activity_log WHERE `month_date` = 'Apr-23' AND `customer_status` ='Paid' AND lcp_status !='LCP'