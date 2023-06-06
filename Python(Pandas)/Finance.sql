*/Weekly and Monthly Revenue Queries */
--Repayment sheet

---Repayment Revenue and unique customers MTD

select case when payment_channel = 'MTN' and Product_Type ='Classic' then 'MTN-Legacy'
when payment_channel = 'MTN' and Product_Type <> 'Classic' then 'MTN-Unified'
when product_code like '%NWO%' then 'LCP'
else 'Airtel_Non-LCP' end Revenue_Category, sum(charged_amount) Mar_Revenue, count(distinct contract) Unique_Customers
from daily_payments_mar22
where repayment_status = 'Subsequent_Repayment'
group by Revenue_Category;


select case when payment_channel = 'MTN' and Product_Type ='Classic' then 'MTN-Legacy'
when payment_channel = 'MTN' and Product_Type <> 'Classic' then 'MTN-Unified'
when product_code like '%NWO%' then 'LCP'
else 'Airtel_Non-LCP' end Revenue_Category, sum(charged_amount) Feb_Revenue, count(distinct contract) Unique_Customers
from daily_payments_feb22
where repayment_status = 'Subsequent_Repayment'
group by Revenue_Category;


Create table Feb_Mar_Revenue
as 
select DATE(transaction_date) transaction_date, report_date, contract, product_category, case when payment_channel = 'MTN' and Product_Type ='Classic' then 'MTN-Legacy'
when payment_channel = 'MTN' and Product_Type <> 'Classic' then 'MTN-Unified'
when product_code like '%NWO%' then 'LCP'
else 'Airtel_Non-LCP' end Revenue_Category, charged_amount Revenue
from daily_payments_feb22
where repayment_status = 'Subsequent_Repayment'

union all

select DATE(transaction_date) transaction_date, report_date, contract, product_category, 
case when payment_channel = 'MTN' and Product_Type ='Classic' then 'MTN-Legacy'
when payment_channel = 'MTN' and Product_Type <> 'Classic' then 'MTN-Unified'
when product_code like '%NWO%' then 'LCP'
else 'Airtel_Non-LCP' end Revenue_Category, charged_amount Revenue
from daily_payments_mar22
where repayment_status = 'Subsequent_Repayment';

select Revenue_Category, 
sum(case when report_date < curdate() then Revenue end) feb_revenue,
sum(case when report_date = curdate() then Revenue end) mar_revenue
from Feb_Mar_Revenue
group by Revenue_Category;

select Revenue_Category, product_category,
sum(case when report_date < '2022-04-01' then Revenue end) feb_revenue,
count(distinct case when report_date < '2022-04-01' then contract end) feb_unique_customers,
sum(case when report_date = '2022-04-01' then Revenue end) mar_revenue,
count(distinct case when report_date = '2022-04-01' then contract end) Mar_Unique_Customers
from Feb_Mar_Revenue
group by Revenue_Category, product_category;

select Revenue_Category, product_category,
sum(case when report_date <> '2022-04-01' then Revenue end) feb_revenue,
count(distinct case when report_date <> '2022-04-01' then contract end) feb_unique_customers,
sum(case when report_date = '2022-04-01' then Revenue end) mar_revenue,
count(distinct case when report_date = '2022-04-01' then contract end) Mar_Unique_Customers
from Feb_Mar_Revenue
group by Revenue_Category, product_category;


select case when region is null then 'Unknown'
else region end region, Revenue_Category,
sum(case when report_date <> '2022-04-01' then Revenue end) feb_revenue,
count(distinct case when report_date <> '2022-04-01' then contract end) feb_unique_customers,
sum(case when report_date = '2022-04-01' then Revenue end) mar_revenue,
count(distinct case when report_date = '2022-04-01' then contract end) Mar_Unique_Customers
from `location_revenue`
group by case when region is null then 'Unknown'
else region end, product_category;


Create index feb22_payment_index on
`daily_payments_feb22` (contract);

Create index mar22_payment_index on
`daily_payments_mar22` (contract);


select Revenue_Category, Product_Category,
sum(case when transaction_date < curdate()- INTERVAL 1 MONTH then Revenue end) Feb_MTD_revenue,
count(distinct case when transaction_date < curdate()- INTERVAL 1 MONTH then contract end) Feb_MTD_Unique_Customers,
sum(case when transaction_date between LAST_DAY(CURDATE()) - INTERVAL DAY(LAST_DAY(CURDATE()))-1 DAY
and curdate()- interval 1 day then Revenue end) mar_MTD_revenue,
count(distinct case when transaction_date between LAST_DAY(CURDATE()) - INTERVAL DAY(LAST_DAY(CURDATE()))-1 DAY
and curdate()- interval 1 day then contract end) mar_MTD_Unique_Customers
from Feb_Mar_Revenue
group by Revenue_category, Product_Category;

Select curdate()- INTERVAL 1 MONTH

select transaction_date, report_date, Revenue_Category, sum(Revenue) Revenue, count(contract) Payment_Count
from Feb_Mar_Revenue
group by transaction_date, report_date, Revenue_Category;


select Revenue_Category, product_category,
count(case when report_date <> '2022-04-01' then contract end) feb_subscribers,
count(case when report_date = '2022-04-01' then contract end) mar_subscribers
from Feb_Mar_Revenue
group by Revenue_Category, product_category;


Select * from daily_payments_mar22
limit 200;


SELECT contract, transaction_date, charged_amount,
       row_number() OVER(PARTITION BY contract ORDER BY transaction_date) Rank
FROM `daily_payments_mar22`;



SET @row_number = 0;

SELECT *, (@row_number:=@row_number + 1) AS row_num  
FROM `daily_payments_mar22`
ORDER BY transaction_date
limit 250;

Create Table first_payment_mar22
as
SELECT t1.*
FROM `daily_payments_mar22` t1
WHERE t1.transaction_date = (SELECT conMIN(t2.transaction_date)
                 FROM `daily_payments_mar22` t2
                 WHERE t1.transaction_date = t2.transaction_date)




SELECT contract, MIN(transaction_date)
FROM `daily_payments_mar22`
group by contract
limit 20;

SELECT t1.*
FROM lms_attendance t1
WHERE t1.time = (SELECT MAX(t2.time)
                 FROM lms_attendance t2
                 WHERE t2.user = t1.user)
                 
drop table `first_payment_mar22`


Create Table location_revenue
as 
Select a.*, state, region
from (
(Select * from `feb_mar_revenue`) a
left outer join
(Select contract, state, region
from `ng_location`)  b
on a.contract = b.contract
	 )