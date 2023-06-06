
*/Weekly AND Monthly Revenue Queries */
--Repayment sheet

SELECT * FROM daily_payments_mar21

---Repayment Revenue AND UNIQUE customers MTD

SELECT CASE WHEN payment_channel = 'MTN' AND Product_Type ='Classic' THEN 'MTN-Legacy'
WHEN payment_channel = 'MTN' AND Product_Type <> 'Classic' THEN 'MTN-Unified'
WHEN product_code LIKE '%NWO%' THEN 'LCP'
ELSE 'Airtel_Non-LCP' END Revenue_Category, SUM(CASE WHEN transaction_date < CURDATE() THEN charged_amount END) Revenue, COUNT(DISTINCT contract) Unique_Customers
FROM daily_payments_mar22
WHERE repayment_status = 'Subsequent_Repayment'
GROUP BY Revenue_Category;



 

SELECT CASE WHEN payment_channel = 'MTN' AND Product_Type ='Classic' THEN 'MTN-Legacy'
WHEN payment_channel = 'MTN' AND Product_Type <> 'Classic' THEN 'MTN-Unified'
WHEN product_code LIKE '%NWO%' THEN 'LCP'
ELSE 'Airtel_Non-LCP' END Revenue_Category, SUM(CASE WHEN transaction_date < CURDATE()- INTERVAL 1 MONTH THEN charged_amount END) Revenue, COUNT(DISTINCT contract) Unique_Customers
FROM daily_payments_feb22
WHERE repayment_status = 'Subsequent_Repayment'
GROUP BY Revenue_Category;




SELECT * FROM Feb_Mar_Revenue

CREATE TABLE Feb_Mar_Revenue
AS 
SELECT DATE(transaction_date) transaction_date, contract, product_category, CASE WHEN payment_channel = 'MTN' AND Product_Type ='Classic' THEN 'MTN-Legacy'
WHEN payment_channel = 'MTN' AND Product_Type <> 'Classic' THEN 'MTN-Unified'
WHEN product_code LIKE '%NWO%' THEN 'LCP'
ELSE 'Airtel_Non-LCP' END Revenue_Category, charged_amount Revenue
FROM daily_payments_feb22
WHERE repayment_status = 'Subsequent_Repayment'

UNION ALL

SELECT DATE(transaction_date) transaction_date, contract, product_category, 
CASE WHEN payment_channel = 'MTN' AND Product_Type ='Classic' THEN 'MTN-Legacy'
WHEN payment_channel = 'MTN' AND Product_Type <> 'Classic' THEN 'MTN-Unified'
WHEN product_code LIKE '%NWO%' THEN 'LCP'
ELSE 'Airtel_Non-LCP' END Revenue_Category, charged_amount Revenue
FROM daily_payments_mar22
WHERE repayment_status = 'Subsequent_Repayment'


SELECT Revenue_Category, 
SUM(CASE WHEN transaction_date < CURDATE()- INTERVAL 1 MONTH THEN Revenue END) Feb_revenue,
SUM(CASE WHEN transaction_date > LAST_DAY(NOW() - INTERVAL 1 MONTH) AND transaction_date < CURDATE() THEN Revenue END) mar_revenue
FROM Feb_Mar_Revenue
GROUP BY Revenue_Category;


SELECT Revenue_Category, 
SUM(CASE WHEN transaction_date < CURDATE()- INTERVAL 1 MONTH THEN Revenue END) Feb_MTD_revenue,
COUNT(DISTINCT CASE WHEN transaction_date < CURDATE()- INTERVAL 1 MONTH THEN contract END) Feb_MTD_Unique_Customers,
SUM(CASE WHEN transaction_date BETWEEN LAST_DAY(CURDATE()) - INTERVAL DAY(LAST_DAY(CURDATE()))-1 DAY
 AND CURDATE()- INTERVAL 1 DAY THEN Revenue END) mar_MTD_revenue,
 COUNT(DISTINCT CASE WHEN transaction_date BETWEEN LAST_DAY(CURDATE()) - INTERVAL DAY(LAST_DAY(CURDATE()))-1 DAY
 AND CURDATE()- INTERVAL 1 DAY THEN contract END) mar_MTD_Unique_Customers
FROM Feb_Mar_Revenue
GROUP BY Revenue_Category;


SELECT `customer_status`, COUNT(`contract`) COUNT
FROM `activity_log`
WHERE`month_date` = 'Mar-23' AND `customer_status`='Retrieval'
GROUP BY `customer_status`
