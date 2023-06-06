##### This is for AG Ageing Rates & New Report.... To spool out the report
SELECT DATE_FORMAT(`entry_date`, "%b-%y") AS Service_Joined_Month, COUNT(DISTINCT `contract`) Original_Count,
AVG(`expected_paidperiod`) Monthly_Payment_Due,
COUNT(CASE WHEN `paidperiod_may23` >= `ltoperiod` THEN `contract` END) Owners,
COUNT(CASE WHEN `paidperiod_may23` < `ltoperiod` THEN `contract` END) Current_Count,
COUNT(CASE WHEN `paidperiod_may23` >= `expected_paidperiod` AND own_status = 'LTO' AND transfer_check = 0 THEN `contract` END)
+
COUNT(CASE WHEN `paidperiod_may23` < `expected_paidperiod` AND own_status = 'LTO' AND final_collection_statusiii != '>5 Days Unpaid' THEN `contract` END) Current_Paid,
SUM(CASE WHEN own_status = 'Owner' THEN `ltoperiod` ELSE `expected_paidperiod` END) Target_Current_Paid_Months,
SUM(CASE WHEN own_status = 'Owner' THEN `ltoperiod` ELSE CASE WHEN `paidperiod_may23` > `expected_paidperiod` THEN `expected_paidperiod` ELSE `paidperiod_may23` END END) Actual_Current_Paid_Months,
SUM(CASE WHEN transfer_check = 0 AND own_status = 'LTO' AND `current_payment_status` = 'Revised Anniversary' THEN `expected_paidperiod`-`paidperiod_may23` END) Delayed_Payment_Months,
SUM(CASE WHEN transfer_check = 0 AND final_collection_statusiii = '>5 Days Unpaid' AND own_status = 'LTO' THEN `expected_paidperiod`-`paidperiod_may23` ELSE 
CASE WHEN transfer_check = 1 THEN `expected_paidperiod`-`paidperiod_may23` END END) Unpaid_Months
FROM `ag_ageing`
GROUP BY `entry_date`;

##### This is for Owners Report and Overtime Payment
SELECT DATE_FORMAT(`entry_date`, "%b-%y") AS Service_Joined_Month, SUM(Owners_Count) Owners_Count, SUM(Target_Owner_Payment_Months) Target_Owner_Payment_Months, SUM(Actual_Owner_Payment_Months) Actual_Owner_Payment_Months
FROM (
SELECT `entry_date`, COUNT(CASE WHEN `own_status` = 'Owner' THEN `contract` END) Owners_Count,
SUM(CASE WHEN own_status = 'Owner' THEN `ltoperiod` END) Target_Owner_Payment_Months,
SUM(CASE WHEN own_status = 'Owner' AND DAY(`entry_date`) = 31 THEN TIMESTAMPDIFF(MONTH, `entry_date`, COALESCE(`payment_date_may23`,`payment_date`))+1
ELSE TIMESTAMPDIFF(MONTH, `entry_date`, COALESCE(`payment_date_may23`,`payment_date`))+1 END) Actual_Owner_Payment_Months
FROM `ag_ageing`
WHERE own_status = 'Owner'
AND `entry_date` <= '2022-03-31'
GROUP BY `entry_date`
              ) a
GROUP BY Service_Joined_Month;


SELECT DATE_FORMAT(`entry_date`, "%b-%y") AS Service_Joined_Month,  COUNT(DISTINCT `contract`) Original_Count,
AVG(`expected_paidperiod`) Monthly_Payment_Due,`paidperiod`,`current_payment_status`,`final_collection_statusiii`,`own_status`  FROM `ag_ageing`
GROUP BY `paidperiod`,`current_payment_status`,`final_collection_statusiii`,`own_status`,`entry_date`