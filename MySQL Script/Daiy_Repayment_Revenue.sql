SELECT * FROM `daily_transactions_curr_MTD`
LIMIT 10

SELECT `customer_status`,`lcp_status`, payment_classification, repayment_status,Revenue
FROM
(SELECT contract, payment_classification, repayment_status,SUM(charged_amount) Revenue
FROM `daily_transactions_curr_MTD`
GROUP BY contract,payment_classification, repayment_status) a
LEFT JOIN
`activity` b
ON a.contract = b.contract

SELECT * FROM `daily_repayment_revenue`
LIMIT 10

SELECT repayment_status,Revenue_Category, SUM(revenue) 
FROM `daily_repayment_revenue`
WHERE repayment_status = 'Subsequent_Repayment' AND Transact_Date BETWEEN '2023-02-01' AND '2023-02-28'
GROUP BY repayment_status,Revenue_Category

#------------------Revenue_Category--------------------------------------------------#

SELECT Revenue_Category, 
SUM(CASE WHEN report_date = '2023-03-01' THEN Revenue END) This_Month_revenue,
COUNT(DISTINCT CASE WHEN report_date = '2023-03-01' THEN contract END) This_Month_Unique_Customers,
SUM(CASE WHEN report_date = '2023-02-01'
              AND `Transact_Date` < '2023-02-01' THEN Revenue END) Last_Month_revenue,
COUNT(DISTINCT CASE WHEN report_date = '2023-02-01'
              AND `Transact_Date` < '2023-02-01' THEN contract END) Last_Month_unique_customers
FROM `daily_repayment_revenue`
GROUP BY Revenue_Category;


#-------------------------------Daiy_Repayment_Revenue-------------------------------------#
SELECT a.Transact_Date, a.report_date, a.contract, a.contract_num, a.revenue, 
a.tenant_name, a.generation, a.payment_channel, a.product_category, a.repayment_status, 
a.Revenue_Category,a.weekday, state, b.region
FROM 
(SELECT DATE(transaction_date) Transact_Date, report_date, contract, contract_num, charged_amount revenue, 
tenant_name, generation, payment_channel, `product_description`, product_category, repayment_status, 
CASE WHEN payment_channel = 'MTN' AND Product_Type ='Classic' THEN 'MTN-Legacy'
WHEN payment_channel = 'MTN' AND Product_Type <> 'Classic' THEN 'MTN-Unified'
WHEN product_code LIKE '%NWO%' THEN 'LCP'
WHEN product_code = 'null' AND `product_description` LIKE '%Lite tool%' THEN 'LCP'
ELSE 'Airtel_Non-LCP' END Revenue_Category, `weekday`
FROM daily_transactions
WHERE repayment_status = 'Subsequent_Repayment'
AND `report_date` >= '2023-12-01') a

LEFT OUTER JOIN

(SELECT contract, state, region FROM `customer_location`) b
ON a.contract = b.contract

SELECT Revenue_Category,`customer_status`,This_Month_revenue
FROM
(SELECT Revenue_Category,contract,
SUM(CASE WHEN report_date = '2023-02-01' THEN Revenue END) This_Month_revenue,
COUNT(DISTINCT CASE WHEN report_date = '2023-02-01' THEN contract END) This_Month_Unique_Customers
FROM `daily_repayment_revenue`
GROUP BY Revenue_Category,contract)a
LEFT JOIN
(SELECT * FROM activity_log WHERE `month_date` = 'Jan-23' )  b
ON a.contract = b.contract