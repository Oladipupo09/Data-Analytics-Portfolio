

#-----------------Quarterly Balanced Owned------------------------------------------#

SELECT Contract, ReportDate, sales_channel, generation, `TYPE`, contract_creation,  crmcontract, old_active_status, dpn_date, 
ref_activation_end,ltoperiod, paidperiod,  Channel, Rev_share,(Total_Paid_days + Paid_days_balance) Revenue_days, 
Total_Paid_days, Paid_days_balance,
 CASE 
     WHEN Rev_share = 0.5 THEN Paid_days_balance*98
     WHEN Rev_share = 0.8 THEN Paid_days_balance*156.8
     ELSE Paid_days_balance*196 END deferred_income
FROM
(
SELECT Contract, ReportDate, sales_channel, generation, `TYPE`, contract_creation,  crmcontract, old_active_status, 
'2023-03-31' dpn_date, ref_activation_end,
CASE 
     WHEN (CASE 
     WHEN generation = 'UNIFIED' THEN paidperiod * 30.4 
     ELSE paidperiod END) >= (CASE WHEN generation = 'UNIFIED' THEN ltoperiod * 30.4 ELSE ltoperiod END) 
     OR old_active_status = 'Owner' THEN 0
     WHEN DATEDIFF(ref_activation_end,'2023-03-31') < 0 THEN 0
     ELSE DATEDIFF(ref_activation_end,'2023-03-31') END Paid_days_balance,

 CASE 
     WHEN `sales_channel` = 'MTN_NG' THEN 'MTN'
     WHEN `generation` = 'Unified' AND `sales_channel` = 'AIRTEL_NG' AND `lcp_status` ='Non-LCP' THEN 'Non-MTN'
     ELSE 'LCP' END Channel,
 CASE 
     WHEN `sales_channel` = 'MTN_NG' AND contract_creation <= '2021-03-30' AND `generation` = 'Legacy' THEN 0.5
     WHEN `sales_channel` = 'MTN_NG' AND contract_creation >= '2021-03-30' AND `generation` = 'Legacy' THEN 0.8
     WHEN `sales_channel` = 'MTN_NG' AND contract_creation >= '2020-03-31' AND `generation` = 'Unified' THEN 0.8
     ELSE 1 END Rev_share,
ltoperiod, paidperiod,
CASE 
     WHEN generation = 'UNIFIED' THEN paidperiod * 30.4 
     ELSE paidperiod END Total_Paid_days 

FROM `activity_log` 
WHERE TYPE <> 'Outright' AND `month_date` ='Mar-23'
)a