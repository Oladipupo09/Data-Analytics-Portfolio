#----------------------Heading to churn as at 1st of every Month for Old Customer Status---------------------------# 
SELECT lcp_status,segmentation_status,Contract_type,COUNT(contract) Counts
FROM
(
SELECT contract,crmcontract,old_active_status,outage_days,ltoperiod,`type`,generation,sales_channel,
CASE
WHEN `type` = 'RENTAL' THEN 'Unified_Rental'
WHEN (`type` = 'LTO' OR `type` = 'L2O') AND generation = 'UNIFIED' THEN 'Unified_L20'
WHEN `type` = 'LTO' AND generation = 'LEGACY' AND ltoperiod = '1800' THEN 'Legacy_Base_1800'
ELSE 'Legacy_Base_1500' END 'Contract_type',spsid,segmentation_status,lcp_status
FROM (SELECT * FROM activity_log WHERE `month_date` = 'Nov-22')a
WHERE outage_days <= -29 AND outage_days >= -59  AND old_active_status NOT IN( 'Cancelled','Owner')
)a
GROUP BY segmentation_status,Contract_type,lcp_status

activity
#----------------------Heading to churn as at 1st of every Month for New Customer Status---------------------------# 
SELECT lcp_status, SUM(counts)
FROM
(
SELECT segmentation_status,Contract_type,customer_status,lcp_status,COUNT(contract) Counts
FROM
(
SELECT contract,crmcontract,customer_status,outage_days,ltoperiod,`type`,generation,sales_channel,
CASE
WHEN `type` = 'RENTAL' THEN 'Unified_Rental'
WHEN (`type` = 'LTO' OR `type` = 'L2O') AND generation = 'UNIFIED' THEN 'Unified_L20'
WHEN `type` = 'LTO' AND generation = 'LEGACY' AND ltoperiod = '1800' THEN 'Legacy_Base_1800'
ELSE 'Legacy_Base_1500' END 'Contract_type',spsid,segmentation_status,lcp_status
FROM activity_log WHERE `month_date` = 'May-23' AND
outage_days <= -11 AND outage_days >= -40  AND customer_status NOT IN( 'Cancelled','Owner')
)b
GROUP BY segmentation_status,Contract_type,customer_status,lcp_status
)a
GROUP BY lcp_status 




#...........................................Heading to retrieval.................................................#
SELECT a.crmcontract,b.Amount,b.Paid_day,a.`customer_status`,a.outage_days,a.ltoperiod,a.`type`,a.generation,c.Curr_Status,a.lcp_status
FROM 
(
(SELECT contract,crmcontract,customer_status,outage_days,ltoperiod,`type`,generation,sales_channel,
CASE
WHEN `type` = 'RENTAL' THEN 'Unified_Rental'
WHEN (`type` = 'LTO' OR `type` = 'L2O') AND generation = 'UNIFIED' THEN 'Unified_L20'
WHEN `type` = 'LTO' AND generation = 'LEGACY' AND ltoperiod = '1800' THEN 'Legacy_Base_1800'
ELSE 'Legacy_Base_1500' END 'Contract_type',spsid,segmentation_status,lcp_status
FROM (SELECT * FROM activity_log WHERE `month_date` = 'Apr-23')a
WHERE outage_days <= -10 AND outage_days >= -40  AND customer_status NOT IN( 'Cancelled','Owner'))a
LEFT OUTER JOIN
(SELECT contract_num,SUM(`charged_amount`) Amount, SUM(payment_duration) Paid_day
FROM `daily_transactions_curr_MTD`
GROUP BY contract_num) b
ON a.crmcontract = b.contract_num
LEFT OUTER JOIN
(SELECT crmcontract,`customer_status` Curr_Status
FROM `activity`)c
ON a.crmcontract = c.crmcontract
)

