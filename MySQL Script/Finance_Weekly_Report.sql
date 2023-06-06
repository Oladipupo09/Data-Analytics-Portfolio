/* Repayment Revenue AND UNIQUE customers MTD */
SELECT Revenue_Category, 
SUM(CASE WHEN report_date = CURDATE() THEN Revenue END) This_Month_revenue,
COUNT(DISTINCT CASE WHEN report_date = CURDATE() THEN contract END) This_Month_Unique_Customers,
SUM(CASE WHEN report_date = LAST_DAY(CURDATE() - INTERVAL 1 MONTH)+INTERVAL 1 DAY
              AND `Transact_Date` < (CURDATE() - INTERVAL 1 MONTH) THEN Revenue END) Last_Month_revenue,
COUNT(DISTINCT CASE WHEN report_date = LAST_DAY(CURDATE() - INTERVAL 1 MONTH)+INTERVAL 1 DAY 
              AND `Transact_Date` < (CURDATE() - INTERVAL 1 MONTH) THEN contract END) Last_Month_unique_customers
FROM `daily_repayment_revenue`
GROUP BY Revenue_Category;


### Month End Status Run
SELECT Revenue_Category, 
SUM(CASE WHEN report_date = CURDATE()#- INTERVAL 1 DAY 
              THEN Revenue END) This_Month_revenue,
COUNT(DISTINCT CASE WHEN report_date = CURDATE()#- INTERVAL 1 DAY 
              THEN contract END) This_Month_Unique_Customers,
SUM(CASE WHEN report_date = (CURDATE() - INTERVAL 1 MONTH)#- INTERVAL 1 DAY
              AND `Transact_Date` < (CURDATE() - INTERVAL 1 MONTH)#- INTERVAL 1 DAY
              THEN Revenue END) Last_Month_revenue,
COUNT(DISTINCT CASE WHEN report_date = (CURDATE() - INTERVAL 1 MONTH)#- INTERVAL 1 DAY
              AND `Transact_Date` < (CURDATE() - INTERVAL 1 MONTH)#- INTERVAL 1 DAY
              THEN contract END) Last_Month_unique_customers
FROM `daily_repayment_revenue`
GROUP BY Revenue_Category;



### For Paid Base
SELECT generation,`sales_channel`, `lcp_status`, COUNT(`contract`) This_Month_Count
FROM `activity`
WHERE `customer_status` = 'Paid'
#AND `month_date` = 'Dec-22'
GROUP BY generation,`sales_channel`, `lcp_status`;


## For Prev Paid Base
SELECT `generation`, `sales_channel`, `lcp_status`, COUNT(`contract`) Last_Month_Count
FROM `activity_log` 
WHERE `month_date` = 'Mar-23'
AND `customer_status` = 'Paid'
GROUP BY `generation`,`sales_channel`, `lcp_status`;



## Active Base on 1st of Month
SELECT 
COUNT( CASE WHEN `old_active_status`= 'Active' AND `month_date` = 'Mar-23' THEN contract END)'This_Month_Open_AIB',
COUNT( CASE WHEN `old_active_status`= 'Active' AND `month_date` = 'Feb-23' THEN contract END)'Last_Month_Open_AIB'
FROM  `activity_log` 

## Paid&Recovery Base on 1st of Month
SELECT 
COUNT( CASE WHEN `customer_status` IN ('Paid','Recovery') AND `month_date` = 'Mar-23' THEN contract END)'This_Month_Open_PR',
COUNT( CASE WHEN `customer_status` IN ('Paid','Recovery')  AND `month_date` = 'Feb-23' THEN contract END)'Last_Month_Open_PR'
FROM  `activity_log` 


SELECT * FROM `daily_repayment_revenue`


#-----------Daily Revenue-------------------------#
SELECT CAST(`transaction_date` AS DATE) Transact_Date,
CASE WHEN tenant_name = 'MTN_NG' AND Product_Type = 'Classic' THEN 'MTN-Legacy'
WHEN tenant_name = 'MTN_NG' AND Product_Type <> 'Classic' THEN 'MTN-Unified'
WHEN `product_description` LIKE '%NWO%' AND contract NOT IN ('a0D6700001DGhlVEAT','a0D6700001Ea5R4EAJ','a0D6700001DGhnYEAT','a0D6700001DGhoMEAT','a0D6700001DGhnJEAT') THEN 'LCP'
#WHEN tenant_name = 'AIRTEL_NG' AND product_code = 'null' AND product_description LIKE '%Lite tool%' THEN 'LCP'
#WHEN tenant_name = 'AIRTEL_NG' AND payment_channel = 'DIRECT NG Bank' AND product_code LIKE '%NWO%' and contract not in ('a0D6700001DGhlVEAT','a0D6700001Ea5R4EAJ','a0D6700001DGhnYEAT','a0D6700001DGhoMEAT','a0D6700001DGhnJEAT') THEN 'LCP'
WHEN tenant_name = 'AIRTEL_NG' AND product_type <> 'Classic' AND generation = 'Unified' THEN 'Airtel_Non-LCP'
WHEN contract IN ('a0D6700001DGhlVEAT','a0D6700001Ea5R4EAJ','a0D6700001DGhnYEAT','a0D6700001DGhoMEAT','a0D6700001DGhnJEAT') THEN 'Airtel_Non-LCP'
ELSE 'Check' END Revenue_Category, COUNT(contract) Payment_Count, SUM(`charged_amount`) Revenue
FROM `daily_transactions`
WHERE `report_date` ='2023-04-01' AND repayment_status = 'Subsequent_Repayment'
GROUP BY Transact_Date,Revenue_Category





#------------------Per Product Category------------------------------#
SELECT
CASE WHEN tenant_name = 'MTN_NG' AND Product_Type = 'Classic' THEN 'MTN-Legacy'
WHEN tenant_name = 'MTN_NG' AND Product_Type <> 'Classic' THEN 'MTN-Unified'
WHEN `product_description` LIKE '%NWO%' AND contract NOT IN ('a0D6700001DGhlVEAT','a0D6700001Ea5R4EAJ','a0D6700001DGhnYEAT','a0D6700001DGhoMEAT','a0D6700001DGhnJEAT') THEN 'LCP'
#WHEN tenant_name = 'AIRTEL_NG' AND product_code = 'null' AND product_description LIKE '%Lite tool%' THEN 'LCP'
#WHEN tenant_name = 'AIRTEL_NG' AND payment_channel = 'DIRECT NG Bank' AND product_code LIKE '%NWO%' and contract not in ('a0D6700001DGhlVEAT','a0D6700001Ea5R4EAJ','a0D6700001DGhnYEAT','a0D6700001DGhoMEAT','a0D6700001DGhnJEAT') THEN 'LCP'
WHEN tenant_name = 'AIRTEL_NG' AND product_type <> 'Classic' AND generation = 'Unified' THEN 'Airtel_Non-LCP'
WHEN contract IN ('a0D6700001DGhlVEAT','a0D6700001Ea5R4EAJ','a0D6700001DGhnYEAT','a0D6700001DGhoMEAT','a0D6700001DGhnJEAT') THEN 'Airtel_Non-LCP'
ELSE 'Check' END Revenue_Category, generation, product_category, 
SUM(CASE WHEN `report_date` ='2023-04-01' THEN `charged_amount` END) This_Month_Revenue, 
COUNT(CASE WHEN `report_date` ='2023-04-01' THEN contract END) This_month_Subscription_Count,
SUM(CASE WHEN `report_date` ='2023-03-01' THEN `charged_amount` END) Last_Month_Revenue, 
COUNT(CASE WHEN `report_date` ='2023-03-01' THEN contract END) Last_month_Subscription_Count
FROM `daily_transactions`
WHERE repayment_status = 'Subsequent_Repayment'
GROUP BY Revenue_Category,generation, product_category


/* Repayment Revenue AND UNIQUE customers MTD */
SELECT CASE WHEN tenant_name = 'MTN_NG' AND Product_Type = 'Classic' THEN 'MTN-Legacy'
WHEN tenant_name = 'MTN_NG' AND Product_Type <> 'Classic' THEN 'MTN-Unified'
WHEN `product_description` LIKE '%NWO%' AND contract NOT IN ('a0D6700001DGhlVEAT','a0D6700001Ea5R4EAJ','a0D6700001DGhnYEAT','a0D6700001DGhoMEAT','a0D6700001DGhnJEAT') THEN 'LCP'
#WHEN tenant_name = 'AIRTEL_NG' AND product_code = 'null' AND product_description LIKE '%Lite tool%' THEN 'LCP'
#WHEN tenant_name = 'AIRTEL_NG' AND payment_channel = 'DIRECT NG Bank' AND product_code LIKE '%NWO%' and contract not in ('a0D6700001DGhlVEAT','a0D6700001Ea5R4EAJ','a0D6700001DGhnYEAT','a0D6700001DGhoMEAT','a0D6700001DGhnJEAT') THEN 'LCP'
WHEN tenant_name = 'AIRTEL_NG' AND product_type <> 'Classic' AND generation = 'Unified' THEN 'Airtel_Non-LCP'
WHEN contract IN ('a0D6700001DGhlVEAT','a0D6700001Ea5R4EAJ','a0D6700001DGhnYEAT','a0D6700001DGhoMEAT','a0D6700001DGhnJEAT') THEN 'Airtel_Non-LCP'
ELSE 'Check' END Revenue_Category, 
SUM(CASE WHEN report_date = CURDATE() THEN `charged_amount` END) This_Month_revenue,
COUNT(DISTINCT CASE WHEN report_date = CURDATE() THEN contract END) This_Month_Unique_Customers,
SUM(CASE WHEN report_date = LAST_DAY(CURDATE() - INTERVAL 1 MONTH)+INTERVAL 1 DAY
              AND CAST(`transaction_date` AS DATE) < (CURDATE() - INTERVAL 1 MONTH) THEN `charged_amount` END) Last_Month_revenue,
COUNT(DISTINCT CASE WHEN report_date = LAST_DAY(CURDATE() - INTERVAL 1 MONTH)+INTERVAL 1 DAY 
              AND CAST(`transaction_date` AS DATE) < (CURDATE() - INTERVAL 1 MONTH) THEN contract END) Last_Month_unique_customers
FROM `daily_transactions`
WHERE repayment_status = 'Subsequent_Repayment'
GROUP BY Revenue_Category;

SELECT CURDATE() - INTERVAL 1 MONTH
FROM`daily_transactions`