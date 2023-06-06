#-----------Unified Business check for price change Rev_Customer_Status Movement(Positive,Nuetral & Negative)------------------#
SELECT contract, Avg_Jul_Oct_Rev, Dec22_Paidperiod, Dec22_Revenue, Jan23_Revenue, Feb23_Pd, Feb23_Revenue, Dec22_PP,Feb23_PP,customer_status Feb22_Status,Rev_Customer_Status,New_Rev_Customer_Status,
CASE WHEN customer_status IN('Retrieval','Cancelled') THEN 'Retrieval/Cancelled'
     WHEN customer_status = 'Owner' THEN 'Owner'
     WHEN New_Rev_Customer_Status = 'Postive' THEN 'Positive'
     WHEN Dec22_Paidperiod > 2 THEN 'Positive'
     WHEN (Feb23_PP - Dec22_PP)>= 2 THEN 'Positive'
     ELSE New_Rev_Customer_Status END Final_Status
FROM
(
#------Joining the Customer PP,Status,Annvi and Transaction to the Business Check table--------- 
SELECT a.contract,Dec_Annvi,(Jul22_Paidperiod + Aug22_Paidperiod + Sep22_Paidperiod + Oct22_Paidperiod)/4 Avg_Jul_Oct_PP,
(Jul22_Revenue + Aug22_Revenue + Sep22_Revenue + Oct22_Revenue)/4 Avg_Jul_Oct_Rev,
Dec22_Paidperiod,Dec22_Revenue,Jan23_Pd,Jan23_Revenue,Feb23_Pd,Feb23_Revenue,Dec22_PP,Feb23_PP,
CASE
WHEN ((Jul22_Revenue + Aug22_Revenue + Sep22_Revenue + Oct22_Revenue)/4) < Dec22_Revenue THEN 'Positive'
WHEN ((Jul22_Revenue + Aug22_Revenue + Sep22_Revenue + Oct22_Revenue)/4) = Dec22_Revenue THEN 'Neutral'
ELSE 'Negative'
END Rev_Customer_Status, 
CASE
WHEN ((Jul22_Revenue + Aug22_Revenue + Sep22_Revenue + Oct22_Revenue)/4) < Feb23_Revenue THEN 'Positive'
WHEN ((Jul22_Revenue + Aug22_Revenue + Sep22_Revenue + Oct22_Revenue)/4) = Feb23_Revenue THEN 'Neutral'
ELSE 'Negative'
END New_Rev_Customer_Status, customer_status
FROM `business_check_unified` a

LEFT JOIN

#-----------Customer Paidperiod, Status $ Dec Ref Activation end----------
(SELECT a.contract,c.`ref_activation_end` Dec_Annvi, b.`customer_status`,
SUM(CASE WHEN a.`month_date` = 'Dec-22' THEN a.paidperiod END) Dec22_PP,
SUM(CASE WHEN a.`month_date` = 'Feb-23' THEN a.paidperiod END) Feb23_PP
FROM `activity_log` a
LEFT JOIN
(SELECT * FROM `activity_log` WHERE `month_date` = 'Feb-23')b
ON a.contract = b.contract
LEFT JOIN
(SELECT * FROM `activity_log` WHERE `month_date` = 'Nov-22')c
ON a.`contract` = c.`contract`
GROUP BY contract,customer_status, Dec_Annvi) b

ON a.contract = b.contract

LEFT JOIN
#---------Transaction------------
(SELECT contract,
SUM( CASE WHEN report_date = '2023-02-01' THEN payment_duration END) Jan23_Pd, 
SUM( CASE WHEN report_date = '2023-02-01' THEN `charged_amount` END) Jan23_Revenue, 
SUM( CASE WHEN report_date = '2023-03-01' THEN payment_duration END) Feb23_Pd, 
SUM( CASE WHEN report_date = '2023-03-01' THEN `charged_amount` END) Feb23_Revenue
 FROM `daily_transactions` 
 GROUP BY contract) c
ON a.contract = c.contract
 
WHERE Dec_Annvi BETWEEN '2022-12-01' AND '2022-12-31'
)d;










#-----------Legal Business check for price change Rev_Customer_Status Movement(Positive,Nuetral & Negative)------------------#
SELECT contract, Avg_Jul_Oct_Rev, Dec22_Paidperiod, Dec22_Revenue, Jan23_Revenue, Feb23_Pd, Feb23_Revenue, Dec22_PP,Feb23_PP,customer_status Feb22_Status,Rev_Customer_Status,New_Rev_Customer_Status,
CASE WHEN customer_status IN('Retrieval','Cancelled') THEN 'Retrieval/Cancelled'
     WHEN customer_status = 'Owner' THEN 'Owner'
     WHEN New_Rev_Customer_Status = 'Postive' THEN 'Positive'
     WHEN Dec22_Paidperiod > 60 THEN 'Positive'
     WHEN (Feb23_PP - Dec22_PP)>= 60 THEN 'Positive'
     ELSE New_Rev_Customer_Status END Final_Status
FROM
(
#------Joining the Customer PP,Status,Annvi and Transaction to the Business Check table--------- 
SELECT a.contract,Dec_Annvi,(Jul22_Paidperiod + Aug22_Paidperiod + Sep22_Paidperiod + Oct22_Paidperiod)/4 Avg_Jul_Oct_PP,
(Jul22_Revenue + Aug22_Revenue + Sep22_Revenue + Oct22_Revenue)/4 Avg_Jul_Oct_Rev,
Dec22_Paidperiod,Dec22_Revenue,Jan23_Pd,Jan23_Revenue,Feb23_Pd,Feb23_Revenue,Dec22_PP,Feb23_PP,
CASE
WHEN ((Jul22_Revenue + Aug22_Revenue + Sep22_Revenue + Oct22_Revenue)/4) < Dec22_Revenue THEN 'Positive'
WHEN ((Jul22_Revenue + Aug22_Revenue + Sep22_Revenue + Oct22_Revenue)/4) = Dec22_Revenue THEN 'Neutral'
ELSE 'Negative'
END Rev_Customer_Status, 
CASE
WHEN ((Jul22_Revenue + Aug22_Revenue + Sep22_Revenue + Oct22_Revenue)/4) < Feb23_Revenue THEN 'Positive'
WHEN ((Jul22_Revenue + Aug22_Revenue + Sep22_Revenue + Oct22_Revenue)/4) = Feb23_Revenue THEN 'Neutral'
ELSE 'Negative'
END New_Rev_Customer_Status, customer_status
FROM `business_check_legacy` a

LEFT JOIN

#-----------Customer Paidperiod, Status $ Dec Ref Activation end----------
(SELECT a.contract,c.`ref_activation_end` Dec_Annvi, b.`customer_status`,
SUM(CASE WHEN a.`month_date` = 'Dec-22' THEN a.paidperiod END) Dec22_PP,
SUM(CASE WHEN a.`month_date` = 'Feb-23' THEN a.paidperiod END) Feb23_PP
FROM `activity_log` a
LEFT JOIN
(SELECT * FROM `activity_log` WHERE `month_date` = 'Feb-23')b
ON a.contract = b.contract
LEFT JOIN
(SELECT * FROM `activity_log` WHERE `month_date` = 'Nov-22')c
ON a.`contract` = c.`contract`
GROUP BY contract,customer_status, Dec_Annvi) b

ON a.contract = b.contract

LEFT JOIN
#---------Transaction------------
(SELECT contract,
SUM( CASE WHEN report_date = '2023-02-01' THEN payment_duration END) Jan23_Pd, 
SUM( CASE WHEN report_date = '2023-02-01' THEN `charged_amount` END) Jan23_Revenue, 
SUM( CASE WHEN report_date = '2023-03-01' THEN payment_duration END) Feb23_Pd, 
SUM( CASE WHEN report_date = '2023-03-01' THEN `charged_amount` END) Feb23_Revenue
 FROM `daily_transactions` 
 GROUP BY contract) c
ON a.contract = c.contract
 
WHERE Dec_Annvi BETWEEN '2022-12-01' AND '2022-12-31'
)d;






#------------------------Legacy Price Change Tracking------------------------
SELECT a.*,
CASE 
WHEN  b.charged_amount > 0 THEN 'Paid'
ELSE 'No payment' END Payment_status, `light_status`,d.`created_date`,d.`customer_signed_phone`,d.`system_id`,d.`generation`
FROM `business_check_unified_tracking` a

LEFT JOIN

(SELECT `contract`,`product_category`, `charged_amount`
FROM
(
SELECT `contract`, `contract_num`, `product_category`, `charged_amount`, ROW_NUMBER () OVER (PARTITION BY `contract` ORDER BY `charged_amount` DESC) AS highest_plan
FROM `daily_transactions`
WHERE `report_date` IN ('2023-01-01','2023-02-01','2023-03-01')
AND `contract` IN (SELECT `contract` FROM `business_check_unified_tracking` )
)a WHERE highest_plan = 1
)b
ON a.contract = b.contract

LEFT JOIN

(
SELECT DISTINCT`contract`,`customer_status`, `light_status`
FROM `activity_log` 
WHERE `month_date` = 'Feb-23'
AND `contract` IN (SELECT `contract` FROM `business_check_unified_tracking`)
)c
ON a.contract = c.contract

LEFT JOIN
`customer_big_table` d
ON a.contract = d.`full_sfid`
WHERE Subs_Date_Categorization = 'Before Comms' AND Expiry_Period = 'Expires_in_Feb23'


#................Forward Check on Price change.............................#
SELECT a.`contract`,a.`crmcontract`,a.lcp_status,a.generation,a.outage_days Prev_Dark_Day,b.outage_days Curr_Dark_Day, 
a.`customer_status` Prev_Status,b.`customer_status` Curr_Status, Mar22_Revenue, SUM(d.`charged_amount`) Mar23_Revenue,
CASE WHEN SUM(d.`charged_amount`) >= 1 THEN 'Paid' ELSE 'No_payment' END Payment_status
FROM
(SELECT * FROM activity_log WHERE `month_date` = 'Mar-22') a
LEFT OUTER JOIN
activity b
ON a.`contract` = b.`contract`
LEFT JOIN
(SELECT contract, SUM(`charged_amount`)Mar22_Revenue 
FROM `daily_transactions`
WHERE `report_date` = '2022-04-01' AND `repayment_status` ='Subsequent_Repayment' GROUP BY contract ) c
ON a.`contract` = c.`contract`
LEFT JOIN
`daily_transactions_curr_MTD` d
ON a.`contract` = d.`contract`
GROUP BY `contract`,`crmcontract`, lcp_status, generation, Prev_Dark_Day, Curr_Dark_Day,Prev_Status,Curr_Status,Mar22_Revenue


