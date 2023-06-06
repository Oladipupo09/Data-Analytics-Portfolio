#-------------------Active_Eligibility to Owner for Old Customer Status---------------#
SELECT lcp_status,old_active_status,
COUNT(CASE WHEN seniority >= LTPeriod THEN contract END) 'Eligible_To_Owner',
COUNT(CASE WHEN seniority < LTPeriod THEN contract END) 'Not_Eligible_To_Owner'
FROM
(
SELECT lcp_status,contract,seniority,old_active_status, 
CASE 
WHEN generation = 'UNIFIED' AND ltoperiod = '48' THEN '1460'
WHEN generation = 'UNIFIED' AND ltoperiod = '24' THEN '730'
WHEN generation = 'UNIFIED' AND ltoperiod = '12' THEN '365'
ELSE ltoperiod
END 'LTPeriod'
FROM
(
SELECT a.lcp_status,a.contract,a.crmcontract,a.generation,a.last_payment_date,a.contract_creation,a.type,
a.ltoperiod,a.paidperiod,a.old_active_status,b.seniority
FROM activity a
LEFT JOIN customer_big_table b
ON a.contract = b.full_sfid
WHERE old_active_status = 'Active'
)c
WHERE old_active_status = 'Active'
)D
GROUP BY lcp_status,old_active_status


#-------------------Paid_Eligibility to Owner for New Customer Status---------------#
SELECT lcp_status,customer_status,
COUNT(CASE WHEN seniority >= LTPeriod THEN contract END) 'Eligible_To_Owner',
COUNT(CASE WHEN seniority < LTPeriod THEN contract END) 'Not_Eligible_To_Owner'
FROM
(
SELECT lcp_status,contract,seniority,customer_status, 
CASE 
WHEN generation = 'UNIFIED' AND ltoperiod = '48' THEN '1460'
WHEN generation = 'UNIFIED' AND ltoperiod = '24' THEN '730'
WHEN generation = 'UNIFIED' AND ltoperiod = '12' THEN '365'
WHEN generation = 'UNIFIED' AND ltoperiod = '28' THEN '851'
ELSE ltoperiod
END 'LTPeriod'
FROM
(
SELECT a.lcp_status,a.contract,a.crmcontract,a.generation,a.last_payment_date,a.contract_creation,a.type,
a.ltoperiod,a.paidperiod,a.customer_status,b.seniority
FROM activity a
LEFT JOIN customer_big_table b
ON a.`crmcontract` = b.`contract_id`
WHERE customer_status = 'paid'
)c
WHERE customer_status = 'paid'
)D
GROUP BY lcp_status,customer_status

#-------------------Recovery_Eligibility to Owner for New Customer Status---------------#
SELECT lcp_status,customer_status,
COUNT(CASE WHEN seniority >= LTPeriod THEN contract END) 'Eligible_To_Owner',
COUNT(CASE WHEN seniority < LTPeriod THEN contract END) 'Not_Eligible_To_Owner'
FROM
(
SELECT lcp_status,contract,seniority,customer_status, 
CASE 
WHEN generation = 'UNIFIED' AND ltoperiod = '48' THEN '1460'
WHEN generation = 'UNIFIED' AND ltoperiod = '28' THEN '851'
WHEN generation = 'UNIFIED' AND ltoperiod = '24' THEN '730'
WHEN generation = 'UNIFIED' AND ltoperiod = '12' THEN '365'
ELSE ltoperiod
END 'LTPeriod'
FROM
(
SELECT a.lcp_status,a.contract,a.crmcontract,a.generation,a.last_payment_date,a.contract_creation,a.type,
a.ltoperiod,a.paidperiod,a.customer_status,b.seniority
FROM activity a
LEFT JOIN customer_big_table b
ON a.contract = b.full_sfid
WHERE customer_status = 'Recovery'
)c
WHERE customer_status = 'Recovery'
)D
GROUP BY lcp_status,customer_status


#-------------Customer Base for Old Customer Status---------------------------#
SELECT lcp_status,old_active_status,customer_status,`contract`,`crmcontract`,COUNT(contract) CB_Counts
FROM (SELECT * FROM activity_log WHERE `month_date` = 'Nov-22') a #activity_log WHERE `month_date` = 'Aug-22' #activity
GROUP BY old_active_status,lcp_status,`contract`,`crmcontract`,customer_status

#-------------Customer Base for New Customer Status---------------------------#
SELECT lcp_status,customer_status,COUNT(contract) CB_Counts
FROM activity_log WHERE `month_date` = 'Oct-22'
GROUP BY lcp_status,customer_status
#crmcontract,contract, 
#SELECT contract,`crmcontract`,lcp_status,customer_status
#FROM activity
#where customer_status = 'Retrieval' and lcp_status = 'LCP'


#----------------Active Base Subtype Breakdown for Old Customer Status---------------------------#
SELECT New_Subtype,
CASE WHEN lcp_status = 'Non-LCP' THEN CB_Counts END 'Non-LCP',
CASE WHEN lcp_status = 'LCP' THEN CB_Counts END 'LCP'
FROM
(
SELECT lcp_status,
CASE 
WHEN subtype = 'B9' THEN 'B9'
WHEN subtype = 'A' THEN 'A'
WHEN subtype IN ('B7','0') THEN 'B7'
ELSE 'B9'
END 'New_Subtype',CB_Counts
FROM
(
SELECT a.lcp_status,a.old_active_status,b.subtype,COUNT(a.contract) CB_Counts
FROM activity a 
LEFT JOIN customer_big_table b
ON a.contract = b.full_sfid
WHERE old_active_status = 'Active'
GROUP BY lcp_status,old_active_status,subtype
)c
)d
#----------------Paid Base Subtype Breakdown for New Customer Status---------------------------#

SELECT a.lcp_status,a.customer_status,b.subtype,COUNT(a.contract) CB_Counts
FROM activity a 
LEFT JOIN customer_big_table b
ON a.contract = b.full_sfid
WHERE customer_status IN ('paid','Recovery')
GROUP BY lcp_status,customer_status,subtype


#activity a


#----------------Churn Base Subtype Breakdown for Old Customer Status---------------------------#
SELECT lcp_status,
CASE 
WHEN subtype = 'B9' THEN 'B9'
WHEN subtype IN ('A','B7','0') THEN 'B7 & Other'
ELSE 'B9'
END 'New_Subtype',CB_Counts
FROM
(
SELECT a.lcp_status,a.old_active_status,b.subtype,COUNT(a.contract) CB_Counts
FROM activity a 
LEFT JOIN customer_big_table b
ON a.contract = b.full_sfid
WHERE old_active_status = 'Churn'
GROUP BY lcp_status,old_active_status,subtype
)c

#----------------Retrieval Base Subtype Breakdown for New Customer Status---------------------------#
SELECT lcp_status,
CASE 
WHEN subtype = 'B9' THEN 'B9'
WHEN subtype IN ('A','B7','0') THEN 'B7 & Other'
ELSE 'B9'
END 'New_Subtype',CB_Counts
FROM
(
SELECT a.lcp_status,a.customer_status,b.subtype,COUNT(a.contract) CB_Counts
FROM activity a 
LEFT JOIN customer_big_table b
ON a.contract = b.full_sfid
WHERE customer_status = 'Retrieval'
GROUP BY lcp_status,customer_status,subtype
)c


SELECT `customer_status`, COUNT(`contract`)
FROM activity 
GROUP BY customer_status

#--------------Heading to Churn Left for Aug'22 at 28th Old Definition---------------#
SELECT COUNT(contract)
FROM
(
SELECT a.Contract, a.old_active_status, a.outage_days, a.lcp_status, b.contract_id, b.customer_signed_full_name, b.customer_signed_phone
FROM
(
SELECT lcp_status,old_active_status,outage_days,Contract
FROM activity
WHERE outage_days <= -41  AND outage_days >= -59 AND old_active_status = 'Active'
GROUP BY lcp_status,old_active_status,outage_days,Contract
)a
LEFT JOIN customer_big_table b
ON a.Contract = b.full_sfid
)c


#--------------Heading to Retrieval Left for Aug'22 at 28th New definition---------------#
SELECT COUNT(contract)
FROM
(
SELECT a.Contract, a.customer_status, a.outage_days, a.lcp_status, b.contract_id, b.customer_signed_full_name, b.customer_signed_phone
FROM
(
SELECT lcp_status,customer_status,outage_days,Contract
FROM activity
WHERE outage_days <= -31  AND outage_days >= -40 AND customer_status IN ('paid','Recovery')
GROUP BY lcp_status,customer_status,outage_days,Contract
)a
LEFT JOIN customer_big_table b
ON a.Contract = b.full_sfid
)c

#................Heading to churn Movement...................................#

SELECT a.crmcontract,b.Amount,b.Paid_day,a.old_active_status,a.outage_days,a.ltoperiod,a.`type`,a.generation,c.Curr_Status,lcp_status
FROM 
(
(SELECT contract,crmcontract,old_active_status,outage_days,ltoperiod,`type`,generation,sales_channel,
CASE
WHEN `type` = 'RENTAL' THEN 'Unified_Rental'
WHEN (`type` = 'LTO' OR `type` = 'L2O') AND generation = 'UNIFIED' THEN 'Unified_L20'
WHEN `type` = 'LTO' AND generation = 'LEGACY' AND ltoperiod = '1800' THEN 'Legacy_Base_1800'
ELSE 'Legacy_Base_1500' END 'Contract_type',spsid,segmentation_status,lcp_status
FROM (SELECT * FROM activity_log WHERE `month_date` = 'Nov-22')a
WHERE outage_days <= -29 AND outage_days >= -59  AND old_active_status NOT IN( 'Cancelled','Owner'))a
LEFT OUTER JOIN
(SELECT contract_num,SUM(`charged_amount`) Amount, SUM(payment_duration) Paid_day
FROM `daily_transactions_curr_MTD`
GROUP BY contract_num) b
ON a.crmcontract = b.contract_num
LEFT OUTER JOIN
(SELECT crmcontract,`old_active_status` Curr_Status
FROM `activity`)c
ON a.crmcontract = c.crmcontract
)


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
FROM (SELECT * FROM activity_log WHERE `month_date` = 'Feb-23')a
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



SELECT a.lcp_status,a.customer_status,b.subtype,COUNT(a.contract) CB_Counts
FROM activity a 
LEFT JOIN customer_big_table b
ON a.contract = b.full_sfid
WHERE customer_status IN ('paid','Recovery','Retrieval')
GROUP BY lcp_status,customer_status,subtype


SELECT	lcp_status, COUNT(contract)
FROM activity
WHERE customer_status ='Recovery'
GROUP BY lcp_status

SELECT	lcp_status, customer_status, COUNT(contract)
FROM activity
GROUP BY lcp_status, customer_status