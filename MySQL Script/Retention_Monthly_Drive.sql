SELECT COUNT(contract)
FROM
(
SELECT contract,crmcontract,old_active_status,customer_status,outage_days,ltoperiod,customer_signed_full_name,customer_signed_phone,secondary_phone_number,`type`,created_date,store_name,Expected_Pool_Status,generation,sales_channel,Contract_type,spsid,charged_amount,payment_duration,warranty_end_date,Warranty_Status,segmentation_status,lcp_status
FROM
(
SELECT contract,crmcontract,old_active_status,customer_status,outage_days,ltoperiod,customer_signed_full_name,customer_signed_phone,secondary_phone_number,`type`,created_date,store_name,Expected_Pool_Status,generation,sales_channel,Contract_type,spsid,charged_amount,payment_duration,warranty_end_date,Warranty_Status,segmentation_status,lcp_status,
CASE 
WHEN Expected_Pool_Status = 'CSS_Pool' AND generation = 'LEGACY' AND payment_duration BETWEEN 5 AND 9 THEN 'Legacy'
WHEN Expected_Pool_Status = 'CSS_Pool' AND generation = 'UNIFIED' THEN 'Unified'
ELSE 'Not_Needed' 
END 'Filters'
FROM
(
SELECT contract,crmcontract,old_active_status,customer_status,outage_days,ltoperiod,customer_signed_full_name,customer_signed_phone,
secondary_phone_number,`type`,created_date,store_name,
CASE
WHEN outage_days >= -59 THEN 'CSS_Pool'
WHEN generation = 'UNIFIED' AND outage_days >= -89 THEN 'CSS_Pool'
ELSE 'Legal_Pool' END 'Expected_Pool_Status',generation,sales_channel,
CASE
WHEN `type` = 'RENTAL' THEN 'Unifed_Rental'
WHEN (`type` = 'LTO' OR `type` = 'L2O') AND generation = 'UNIFIED' THEN 'Unifed_L20'
WHEN `type` = 'LTO' AND generation = 'LEGACY' AND ltoperiod = '1800' THEN 'Legacy_Base_1800'
ELSE 'Legacy_Base_1500' END 'Contract_type',spsid,charged_amount,payment_duration,warranty_end_date,
CASE 
WHEN warranty_end_date >= '2023-06-01' THEN 'Out Of Warranty'
ELSE 'Within Warranty' END 'Warranty_Status',segmentation_status,lcp_status
FROM
(
SELECT a.contract,a.crmcontract,a.old_active_status,a.customer_status,a.outage_days,a.ltoperiod,b.customer_signed_full_name,
b.customer_signed_phone,b.secondary_phone_number,a.type,b.created_date,b.store_name,a.generation,a.sales_channel,
a.spsid,c.charged_amount,c.payment_duration,b.warranty_end_date,a.segmentation_status,a.lcp_status
FROM
activity a 
LEFT OUTER JOIN customer_big_table b
ON a.contract = b.full_sfid
LEFT OUTER JOIN 
(SELECT contract,SUM(charged_amount) charged_amount,SUM(payment_duration) payment_duration
FROM `daily_transactions_curr_MTD`
GROUP BY contract) c
ON a.contract = c.contract
)d 
WHERE outage_days <= -1 AND old_active_status NOT IN( 'Cancelled','Owner')
)f
)g
WHERE `Filters` != 'Not_Needed' AND lcp_status != 'LCP'
)h


#...............................CB Segementation......................#
SELECT contract,crmcontract,sales_channel,generation,ltoperiod,spsid,paidperiod,lcp_status,
old_active_status,customer_status,segmentation_status
FROM `activity`
WHERE old_active_status IN ('Active','Churn')



#...............................CB for Paid and Recovery......................#
SELECT crmcontract,sales_channel,generation,ltoperiod,spsid,paidperiod,lcp_status,old_active_status,customer_status,segmentation_status,outage_days

FROM `activity_log`
     WHERE `month_date` = 'Apr-23' AND customer_status IN ('Paid','Recovery') AND lcp_status ='Non-LCP'
     
 #............................Payment Summary-----------------------------------------------------#         
SELECT contract_num,payment_time_units,SUM(`charged_amount`) Amount, SUM(payment_duration) Paid_day
	FROM `daily_transactions_curr_MTD`
	GROUP BY contract_num,payment_time_units