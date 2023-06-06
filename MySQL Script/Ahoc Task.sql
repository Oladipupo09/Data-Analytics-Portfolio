SELECT *
FROM `lcp_base`
WHERE `created_date` BETWEEN '2022-09-01' AND '2022-09-30' 
#..............................current active in dark.......................................#
SELECT a.contract,a.`crmcontract`, a.lcp_status,a.outage_days,a.type,a.old_active_status,a.spsid,a.sales_channel,
a.generation,b.customer_signed_full_name,b.customer_signed_phone,SUM(c.charged_amount),SUM(c.payment_duration)
FROM  (SELECT* FROM activity WHERE `outage_days` < 0 AND `old_active_status` = 'Active') a
LEFT OUTER JOIN customer_big_table b
ON a.contract = b.full_sfid
LEFT OUTER JOIN (SELECT* FROM`daily_transactions_curr_MTD`) c
ON a.contract = c.contract
GROUP BY contract,crmcontract,spsid,sales_channel,lcp_status,`type`,outage_days,generation,
old_active_status,customer_signed_full_name,customer_signed_phone

#WHERE charged_amount < 1

SELECT DISTINCT COUNT(contract),STATUS
FROM `lcp_base`
WHERE `created_date`> '2022-05-31'
GROUP BY STATUS
#...................All B9 System for Hack Alert Report..........................#
SELECT a.contract, a.crmcontract, a.spsid, a.old_active_status, a.generation, a.sales_channel, 
c.state, a.lcp_status, b.subtype, b.product_name, a.`contract_creation`,a.`customer_status`
FROM (SELECT* FROM  customer_big_table WHERE `subtype`= 'B9') b
LEFT OUTER JOIN (SELECT* FROM `activity_log` WHERE `month_date` = 'Sep-22') a
ON a.contract = b.full_sfid 
LEFT OUTER JOIN (SELECT* FROM`customer_location`) c
ON a.contract = c.contract 

SELECT `crmcontract`,`paidperiod`,`ltoperiod`,`old_active_status`
FROM `activity_log`
WHERE `month_date` = 'Jul-22'

SELECT COUNT(contract)
FROM `may22_win_back`






SELECT EXTRACT(YEAR FROM '2018-07-22')
SELECT YEAR(CURRENT_TIMESTAMP)


SELECT Joining_Year,lcp_status,Outright,Early_Payer_to_Owner,Late_Payer_to_Owner, (Outright + Early_Payer_to_Owner + Late_Payer_to_Owner) Grand_total
FROM
(
SELECT YEAR(created_date) Joining_Year,lcp_status,
COUNT(CASE WHEN Owner_Payer_Status = 'OUTRIGHT' THEN contract END) 'Outright',
COUNT(CASE WHEN Owner_Payer_Status = 'Early_Payer_to_Owner' THEN contract END) 'Early_Payer_to_Owner',
COUNT(CASE WHEN Owner_Payer_Status = 'Late_Payer_to_Owner' THEN contract END) 'Late_Payer_to_Owner'
FROM
(
SELECT lcp_status,contract,crmcontract,last_payment_date,created_date,`type`,ltoperiod, 
CASE
WHEN `type` = 'OUTRIGHT' THEN 'OUTRIGHT'
WHEN last_payment_date > ADDDATE(created_date,INTERVAL ltoperiod DAY) AND `type` != 'OUTRIGHT' AND ltoperiod != '48' AND ltoperiod != '24' AND ltoperiod != '12' THEN 'Late_Payer_to_Owner'
WHEN last_payment_date <= ADDDATE(created_date,INTERVAL ltoperiod DAY) AND `type` != 'OUTRIGHT' AND ltoperiod != '48' AND ltoperiod != '24' AND ltoperiod != '12' THEN 'Early_Payer_to_Owner'
WHEN ltoperiod = '48' AND last_payment_date > ADDDATE(created_date,INTERVAL 1460 DAY) AND `type` != 'OUTRIGHT'  THEN 'Late_Payer_to_Owner'
WHEN ltoperiod = '48' AND last_payment_date <= ADDDATE(created_date,INTERVAL 1460 DAY) AND `type` != 'OUTRIGHT' THEN 'Early_Payer_to_Owner'
WHEN ltoperiod = '24' AND last_payment_date > ADDDATE(created_date,INTERVAL 730 DAY) AND `type` != 'OUTRIGHT' THEN 'Late_Payer_to_Owner'
WHEN ltoperiod = '24' AND last_payment_date <= ADDDATE(created_date,INTERVAL 730 DAY) AND `type` != 'OUTRIGHT' THEN 'Early_Payer_to_Owner'
WHEN ltoperiod = '12' AND last_payment_date > ADDDATE(created_date,INTERVAL 365 DAY) AND `type` != 'OUTRIGHT' THEN 'Late_Payer_to_Owner'
WHEN ltoperiod = '12' AND last_payment_date <= ADDDATE(created_date,INTERVAL 365 DAY) AND `type` != 'OUTRIGHT' THEN 'Early_Payer_to_Owner'
ELSE 'Null'
END Owner_Payer_Status
FROM
(
SELECT a.lcp_status,a.contract,a.crmcontract,a.old_active_status,a.ltoperiod,a.type,a.last_payment_date,b.created_date
FROM activity a
LEFT JOIN customer_big_table b
ON a.contract = b.full_sfid
WHERE old_active_status = 'Owner'
)c
)d
GROUP BY Joining_Year,lcp_status
)e
GROUP BY Joining_Year,lcp_status,Outright,Early_Payer_to_Owner,Late_Payer_to_Owner



#-----------------------------Onwer Report----------------------------------#
SELECT Joining_Year,lcp_status,(Outright+OWNER+Active+Churn) Customer_Base,(Active+Outright+OWNER) Definition_Active, Active, Churn,(Outright+OWNER) OWNER
FROM
(
SELECT Joining_Year,lcp_status,
COUNT(CASE WHEN Owner_Status = 'OUTRIGHT' THEN contract_id END) 'Outright',
COUNT(CASE WHEN Owner_Status = 'Owner' THEN contract_id END) 'Owner',
COUNT(CASE WHEN Owner_Status = 'Active' THEN contract_id END) 'Active',
COUNT(CASE WHEN Owner_Status = 'Churn' THEN contract_id END) 'Churn'
FROM
(
SELECT YEAR(a.`created_date`) Joining_Year,a.`contract_id`,b.lcp_status, 
CASE
WHEN b.`type` = 'OUTRIGHT' THEN 'OUTRIGHT' ELSE b.old_active_status END 'Owner_Status'
FROM (SELECT * FROM `activity_log` WHERE `month_date` = 'Oct-22' AND `old_active_status` IN ('Active','Churn','Owner')) b
LEFT JOIN customer_big_table a
ON b.`contract` = a.`full_sfid`
GROUP BY contract_id,created_date,old_active_status,Owner_Status,lcp_status
)c
GROUP BY Joining_Year,lcp_status
)d
GROUP BY Joining_Year,lcp_status, Active,Churn



#------------------Payment Summary---------------------------#
SELECT a.crmcontract,SUM(b.Jun_22_Amount) Jun_amount,SUM(b.Jun_22_Paid_day)Jun_Pd,SUM(b.Jul_22_Amount)Jul_amount,SUM(b.Jul_22_Paid_day)Jul_Pd,
SUM(b.Aug_22_Amount)Aug_amount,SUM(b.Aug_22_Paid_day)Aug_Pd
FROM `activity` a
LEFT JOIN
(
SELECT DISTINCT(`contract_num`),SUM(`payment_duration`) Jul_22_Paid_day,SUM(charged_amount)Jul_Pd
FROM `daily_transactions`
WHERE`report_date` = '2022-11-01'
GROUP BY contract_num
)b
ON a.crmcontract =b.contract_num
GROUP BY crmcontract


SELECT a.crmcontract,b.May_22_Amount,b.May_22_Paid_day
FROM `activity` a
LEFT JOIN
(
SELECT `contract_num`,
SUM(CASE WHEN `report_date` = '2022-07-01' THEN charged_amount END)'Jun_22_Amount',
SUM(CASE WHEN `report_date` = '2022-07-01' THEN `payment_duration` END) 'Jun_22_Paid_day',
SUM(CASE WHEN `report_date` = '2022-08-01' THEN `charged_amount` END) 'Jul_22_Amount',
SUM(CASE WHEN `report_date` = '2022-08-01' THEN `payment_duration` END) 'Jul_22_Paid_day',
SUM(CASE WHEN `report_date` = '2022-06-01' THEN `charged_amount` END) 'May_22_Amount',
SUM(CASE WHEN `report_date` = '2022-06-01' THEN `payment_duration` END) 'May_22_Paid_day'
FROM `daily_transactions`
GROUP BY contract_num
)b
ON a.crmcontract =b.contract_num
WHERE May_22_Amount >=1

#-------------------------Light/Dark Report...................................#
SELECT `crmcontract`,`light_status`,Amount, Paid_day
FROM (SELECT * FROM `activity_log` WHERE `month_date` = 'Dec-22') a
LEFT OUTER JOIN
	(SELECT contract_num,payment_time_units,SUM(`charged_amount`) Amount, SUM(payment_duration) Paid_day
	FROM `daily_transactions` WHERE `report_date` = '2023-01-22'
	GROUP BY contract_num,payment_time_units)b
	ON a.crmcontract = b.contract_num
#`payment_time_units`

SELECT `crmcontract`,`light_status`
FROM `activity_log` WHERE `month_date` = 'Dec-22'

#..........................Churn Serial...........................................#
SELECT a.`contract`,a.`crmcontract`,a.`spsid`,a.`sales_channel`,a.`type`,a.`ltoperiod`,b.`created_date`,a.`generation`,b.subtype
FROM (SELECT * FROM `activity_log` WHERE `month_date` = 'Mar-23') a 
LEFT JOIN customer_big_table b
ON a.contract = b.full_sfid
WHERE `customer_status` = 'Retrieval'

SELECT contract,crmcontract,`customer_status`,`old_active_status`,`paidperiod`,`ltoperiod`
FROM `activity`



SELECT `contract_num`, 
SUM(CASE WHEN month_date = 'Jan-22' THEN Month_Paid_Days END)'Jan_Pd',
SUM(CASE WHEN month_date = 'Feb-22' THEN Month_Paid_Days END)'Feb_Pd',
SUM(CASE WHEN month_date = 'Mar-22' THEN Month_Paid_Days END)'Mar_Pd',
SUM(CASE WHEN month_date = 'Apr-22' THEN Month_Paid_Days END)'Apr_Pd',
SUM(CASE WHEN month_date = 'May-22' THEN Month_Paid_Days END)'May_Pd',
SUM(CASE WHEN month_date = 'Jun-22' THEN Month_Paid_Days END)'Jun_Pd',
SUM(CASE WHEN month_date = 'Jul-22' THEN Month_Paid_Days END)'Jul_Pd',
SUM(CASE WHEN month_date = 'Aug-22' THEN Month_Paid_Days END)'Aug_Pd'
FROM
(
SELECT `contract_num`, DATE_FORMAT(report_date - INTERVAL 1 DAY, "%b-%y") month_date, SUM(`payment_duration`) Month_Paid_Days
FROM `daily_transactions`
GROUP BY `contract_num`, month_date
)a
GROUP BY contract_num


#..........................Customer Movement............................#
SELECT a.`contract`,a.`crmcontract`,a.lcp_status,a.generation,a.outage_days Prev_Dark_Day,b.outage_days Curr_Dark_Day, 
a.`customer_status` Prev_Status,b.`customer_status` Curr_Status, COUNT(a.contract) CB_Counts
FROM 
(SELECT * FROM activity_log WHERE `month_date` = 'Feb-23' ) a
LEFT OUTER JOIN
activity b
ON a.`contract` = b.`contract`
GROUP BY `contract`,`crmcontract`, lcp_status, generation, Prev_Dark_Day, Curr_Dark_Day,Prev_Status,Curr_Status

#..........................OLD Customer Movement............................#
SELECT a.`contract`,a.`crmcontract`,a.lcp_status,a.generation,a.outage_days Prev_Dark_Day,b.outage_days Curr_Dark_Day, 
a.`old_active_status` Prev_Status,a.`paidperiod`, a.`ltoperiod`, b.`old_active_status` Curr_Status, COUNT(a.contract) CB_Counts
FROM 
(SELECT * FROM activity_log WHERE `month_date` = 'Dec-22' ) a
LEFT OUTER JOIN
activity b
ON a.`contract` = b.`contract`
GROUP BY `contract`,`crmcontract`, lcp_status, generation, ltoperiod, paidperiod, Prev_Dark_Day, Curr_Dark_Day,Prev_Status,Curr_Status


SELECT lcp_status,customer_status , COUNT(contract) 
FROM activity 
GROUP BY lcp_status,customer_status 


#---------------------1 dark day at opening of New month----------------------------#
SELECT segmentation_status, COUNT(contract)1st_Of_The_Month_1_Darkday,
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 1 THEN contract END) '1st',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 2 THEN contract END) '2nd',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 3 THEN contract END) '3rd',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 4 THEN contract END) '4th',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 5 THEN contract END) '5th',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 6 THEN contract END) '6th',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 7 THEN contract END) '7th',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 8 THEN contract END) '8th',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 9 THEN contract END) '9th',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 10 THEN contract END) '10th',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 11 THEN contract END) '11th',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 12 THEN contract END) '12th',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 13 THEN contract END) '13th',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 14 THEN contract END) '14th',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 15 THEN contract END) '15th',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 16 THEN contract END) '16th',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 17 THEN contract END) '17th',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 18 THEN contract END) '18th',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 19 THEN contract END) '19th',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 20 THEN contract END) '20th',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 21 THEN contract END) '21st',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 22 THEN contract END) '22nd',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 23 THEN contract END) '23rd',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 24 THEN contract END) '24th',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 25 THEN contract END) '25th',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 26 THEN contract END) '26th',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 27 THEN contract END) '27th',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 28 THEN contract END) '28th',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 29 THEN contract END) '29th',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 30 THEN contract END) '30th',
COUNT(CASE WHEN Day_of_Month IS NULL OR Day_of_Month > 31 THEN contract END) '31st'
FROM
(
SELECT a.contract,a.crmcontract,a.segmentation_status,a.generation,a.lcp_status,a.outage_days,b.Day_of_Month
FROM
(SELECT * FROM activity_log WHERE `month_date` = 'Aug-22' AND `outage_days` = -1  AND lcp_status = 'Non-LCP')a
LEFT OUTER JOIN
(SELECT DISTINCT(contract), DAY(MIN(transaction_date))Day_of_Month FROM `daily_transactions`
WHERE `report_date` = '2022-10-01' GROUP BY contract ) b
ON a.`contract` = b.`contract`
)c
GROUP BY segmentation_status



#---------------------------------Good Customer for UPSELL---------------------------------------------------------#

SELECT lcp_status,crmcontract,generation,created_date,`type`,`customer_signed_full_name`,`customer_signed_phone`,`state`,secondary_phone_number,
	`local_government`,`region`,customer_signed_email,seniority ,segmentation_status,sales_channel,paidperiod,ltoperiod,Price_Left_to_Ownership,Excluded_Price,
CASE
WHEN Price_Left_to_Ownership <= Excluded_Price THEN 'Data_Needed'
ELSE 'Data_Not_Needed' END 'Upsell_Needs_Status'
FROM
(
SELECT lcp_status,crmcontract,generation,created_date,`type`,`customer_signed_full_name`,`customer_signed_phone`,`state`,secondary_phone_number,
	`local_government`,`region`,customer_signed_email,seniority ,segmentation_status,sales_channel,paidperiod,ltoperiod,
CASE
WHEN product_name LIKE 'CLASSIC%' THEN 'CLASSIC'
WHEN product_name LIKE 'PRIME%' THEN 'PRIME'
ELSE 'ECO' END Product_Plan, 
CASE WHEN `type` = 'RENTAL' THEN (48-paidperiod)
ELSE (ltoperiod-paidperiod) END Price_Left_to_Ownership,
CASE
WHEN `type` = 'RENTAL' AND product_name LIKE 'PRIME%' THEN 200000/7920
WHEN `type` = 'RENTAL' AND product_name LIKE 'ECO%' THEN 141000/5880
WHEN ltoperiod = '1800' THEN 200000/257
WHEN ltoperiod = '48' AND product_name LIKE 'PRIME%' THEN 200000/9600
WHEN ltoperiod = '48' AND product_name LIKE 'ECO%' THEN 141000/7200
WHEN ltoperiod = '24' AND product_name LIKE 'PRIME%' THEN 200000/12500
WHEN ltoperiod = '24' AND product_name LIKE 'ECO%' THEN 141000/9500
WHEN ltoperiod = '12' AND product_name LIKE 'PRIME%' THEN 200000/16750
WHEN ltoperiod = '12' AND product_name LIKE 'ECO%' THEN 141000/12000
ELSE 'RENTAL' END Excluded_Price
FROM
(
SELECT a.lcp_status,a.contract,a.crmcontract,a.old_active_status,a.`paidperiod`,
	a.`generation`,a.`sales_channel`,a.ltoperiod,a.type,a.last_payment_date,
	b.created_date,b.`customer_signed_full_name`,b.`customer_signed_phone`,b.`secondary_phone_number`,b.`seniority`,b.`customer_signed_email`,
	b.`paid_period_type`,b.`price_book_name`,b.`product_name`,c.`state`,
	c.`local_government`,c.`region`,a.segmentation_status
FROM activity a
LEFT JOIN customer_big_table b
ON a.contract = b.full_sfid
LEFT JOIN `customer_location` c 
ON a.contract = c.contract
WHERE old_active_status IN ('Active','Churn') AND segmentation_status = 'Good' AND created_date < '2021-11-29'
)D
)e

SELECT `contract`,`crmcontract`,`customer_status`,`segmentation_status`
FROM `activity`


#..............................Churn breakdown Q3...................................#
SELECT month_date,
CASE 
WHEN subtype = 'B9' THEN 'B9'
WHEN subtype IN ('B7') THEN 'B7'
WHEN subtype IN ('A','0') THEN 'Other'
ELSE 'B9'
END 'New_Subtype',CB_Counts
FROM
(
SELECT a.`month_date`,a.old_active_status,b.subtype,COUNT(a.contract) CB_Counts
FROM `activity_log` a 
LEFT JOIN customer_big_table b
ON a.contract = b.full_sfid
WHERE old_active_status = 'Churn' AND `month_date` IN ('Oct-22','Nov-22','Dec-22')
GROUP BY month_date,old_active_status,subtype
)c

SELECT month_date, 
CASE
WHEN `sales_channel` = 'MTN_NG' AND `generation` = 'LEGACY' THEN 'MTN Legacy'
WHEN `sales_channel` = 'MTN_NG' AND `generation` = 'UNIFIED' THEN 'MTN Unified'
WHEN `sales_channel` = 'AIRTEL_NG' AND `generation` = 'UNIFIED' AND `lcp_status`!= 'LCP' THEN 'Non- MTN Unified'
WHEN `sales_channel` = 'AIRTEL_NG' AND `generation` = 'UNIFIED' AND `lcp_status` = 'LCP' THEN 'LCP'
ELSE 'NA' END 'Contract_Categories',COUNT(contract)
FROM `activity_log`
WHERE old_active_status = 'Active' AND `month_date` IN ('Oct-22','Nov-22','Dec-22')
GROUP BY month_date,Contract_Categories

SELECT month_date,old_active_status,`light_status`
FROM `activity_log`
WHERE old_active_status IN ('Active') AND `month_date` IN ('Jul-22','Aug-22','Sep-22')


#.................Pulse of Price Change..............................................#

SELECT `transact_date`, WEEKDAY,
CASE WHEN Product_Category LIKE '%day%' THEN 'MTN-Legacy' ELSE Revenue_Category END AS Revenue_Category,
COUNT(CASE WHEN report_date = CURDATE() THEN `contract` END) Payment_Count,
SUM(CASE WHEN report_date = CURDATE() THEN `revenue` END) Revenue
FROM `daily_repayment_revenue`
WHERE report_date = CURDATE()
GROUP BY Revenue_Category,WEEKDAY,`transact_date`;


SELECT `transact_date`, WEEKDAY,
CASE WHEN Product_Category LIKE '%day%' THEN 'MTN-Legacy' ELSE Revenue_Category END AS Revenue_Category,
COUNT(CASE WHEN report_date = CURDATE() THEN `contract` END) Payment_Count,
SUM(CASE WHEN report_date = CURDATE() THEN `revenue` END) Revenue
FROM `daily_repayment_revenue`
WHERE report_date = CURDATE()
GROUP BY Revenue_Category,Product_Category, WEEKDAY,`transact_date`;


SELECT `transact_date`, WEEKDAY,
COUNT(`contract`) Payment_Count,
SUM(`revenue`) Revenue,
COUNT(CASE WHEN Use_Status = 'Nov_Owner' THEN `contract` END) Owners_Movement
FROM (
SELECT a.`contract`, `transact_date`, WEEKDAY, `revenue`, CASE
								WHEN Oct_Status <> 'Owner' AND Nov_Status = 'Owner'
								THEN 'Nov_Owner' ELSE 'discard' END AS Use_Status
FROM (
(SELECT `contract`,`transact_date`, WEEKDAY, `revenue`,
CASE WHEN Product_Category LIKE '%day%' THEN 'MTN-Legacy' ELSE Revenue_Category END AS Revenue_Category
FROM `daily_repayment_revenue`
WHERE report_date = CURDATE()) a

LEFT OUTER JOIN

(SELECT a.`contract`, b.`customer_status` Oct_Status, a.`customer_status` Nov_Status
FROM (
(SELECT `contract`, `customer_status`
FROM `activity_log`
WHERE `month_date` = 'Nov-22') a
LEFT OUTER JOIN
(SELECT `contract`, `customer_status`
FROM `activity_log`
WHERE `month_date` = 'Oct-22') b
ON a.`contract` = b.`contract`
      )) b
ON a.`contract` = b.`contract`
    )
   ) a
GROUP BY `transact_date`, WEEKDAY;


SELECT * FROM `daily_repayment_revenue`

SELECT CURDATE() - 7
WHERE report_date = CURDATE()


SELECT a.`contract`,a.`crmcontract`,a.`spsid`,a.`sales_channel`,a.`type`,a.`ltoperiod`,a.old_active_status,a.`outage_days`, a.lcp_status, b.`created_date`,a.`generation`,b.subtype, b.`customer_signed_phone`
FROM activity a 
LEFT JOIN customer_big_table b
ON a.contract = b.full_sfid
WHERE  lcp_status = 'Non-LCP' AND old_active_status = 'Active' AND created_date < '2021-10-01'

#..............12 Month LTO Plan moved to Owner Projection...................................#
SELECT DATE_FORMAT(`created_date`,"%M %Y") Entry_date, 
DATE_FORMAT(ADDDATE(`created_date`, INTERVAL 11 MONTH),"%M %Y") Ownership_Month, COUNT(contract) 
	FROM `lcp_base`
		WHERE `product_name` LIKE '%12%'
			GROUP BY created_date
			
#...........................6 Months Customer Base......................................#
SELECT `lcp_status`,`old_active_status`,`generation`,
COUNT(CASE WHEN `month_date` = 'May-22' THEN `contract` END) May_22,
COUNT(CASE WHEN `month_date` = 'Jun-22' THEN `contract` END) Jun_22,
COUNT(CASE WHEN `month_date` = 'Jul-22' THEN `contract` END) Jul_22,
COUNT(CASE WHEN `month_date` = 'Aug-22' THEN `contract` END) Aug_22,
COUNT(CASE WHEN `month_date` = 'Sep-22' THEN `contract` END) Sep_22,
COUNT(CASE WHEN `month_date` = 'Oct-22' THEN `contract` END) Oct_22,
COUNT(CASE WHEN `month_date` = 'Nov-22' THEN `contract` END) Nov_22,
COUNT(CASE WHEN `month_date` = 'Dec-22' THEN `contract` END) Dec_22
FROM activity_log
GROUP BY `lcp_status`,`old_active_status`,`generation`

#................Acquisition.........................................#
SELECT `lcp_status`,`generation`,
COUNT(CASE WHEN `month_date` = 'May-22' AND `contract_creation` BETWEEN '2022-05-01' AND '2022-05-31' THEN `contract` END) May_22,
COUNT(CASE WHEN `month_date` = 'Jun-22' AND `contract_creation` BETWEEN '2022-06-01' AND '2022-06-30' THEN `contract` END) Jun_22,
COUNT(CASE WHEN `month_date` = 'Jul-22' AND `contract_creation` BETWEEN '2022-07-01' AND '2022-07-31' THEN `contract` END) Jul_22,
COUNT(CASE WHEN `month_date` = 'Aug-22' AND `contract_creation` BETWEEN '2022-08-01' AND '2022-08-31' THEN `contract` END) Aug_22,
COUNT(CASE WHEN `month_date` = 'Sep-22' AND `contract_creation` BETWEEN '2022-09-01' AND '2022-09-30' THEN `contract` END) Sep_22,
COUNT(CASE WHEN `month_date` = 'Oct-22' AND `contract_creation` BETWEEN '2022-10-01' AND '2022-10-31' THEN `contract` END) Oct_22,
COUNT(CASE WHEN `month_date` = 'Nov-22' AND `contract_creation` BETWEEN '2022-11-01' AND '2022-11-30' THEN `contract` END) Nov_22,
COUNT(CASE WHEN `month_date` = 'Dec-22' AND `contract_creation` BETWEEN '2022-12-01' AND '2022-12-31' THEN `contract` END) Dec_22
FROM activity_log
GROUP BY `lcp_status`,`generation`			

('Jan-22','Feb-22','Mar-22','Apr-22','May-22','Jun-22','Jul-22','Aug-22','Sep-22','Oct-22')


-------------Legacy Base-----------------------------
SELECT a.* ,b.`customer_status` Oct_Status,c.`customer_status` Nov_Status,d.`customer_status` Dec_Status
FROM
	`business_check_legacy` a
LEFT JOIN 
	(SELECT * FROM `activity_log` WHERE `month_date` = 'Oct-22')b
ON a.`contract` = b.`contract`
LEFT JOIN 
	(SELECT * FROM `activity_log` WHERE `month_date` = 'Nov-22')c
ON a.`contract` = c.`contract`
LEFT JOIN 
	(SELECT * FROM `activity_log` WHERE `month_date` = 'Dec-22')d
ON a.`contract` = d.`contract`

-----------Unified Base------------------------------
SELECT a.* ,b.`customer_status` Oct_Status,c.`customer_status` Nov_Status,d.`customer_status` Dec_Status
FROM
	`business_check_unified` a
LEFT JOIN 
	(SELECT * FROM `activity_log` WHERE `month_date` = 'Oct-22')b
ON a.`contract` = b.`contract`
LEFT JOIN 
	(SELECT * FROM `activity_log` WHERE `month_date` = 'Nov-22')c
ON a.`contract` = c.`contract`
LEFT JOIN 
	(SELECT * FROM `activity_log` WHERE `month_date` = 'Dec-22')d
ON a.`contract` = d.`contract`


SELECT	a.contract,a.Movement_status,a.`generation`,b.payment_duration Sep_Paidperiod,b.charged_amount Sep_Revenue,c.payment_duration Oct_Paidperiod,c.charged_amount Oct_Revenue,
d.payment_duration Nov_Paidperiod,d.charged_amount Nov_Revenue,e.payment_duration Dec_Paidperiod,e.charged_amount Dec_Revenue
FROM
(
SELECT `contract`,Movement_status,`generation`
FROM
(
SELECT `contract`,`generation`,
CASE 
WHEN `month_date` = 'Nov-22' AND `customer_status` = 'Retrieval' THEN 'Nov_Retrieval' 
WHEN `month_date` = 'Dec-22' AND `customer_status` IN ('Paid','Recovery')  THEN 'Dec_PaidRecovery'
WHEN `month_date` = 'Oct-22' AND `customer_status` = 'Retrieval' THEN 'Oct_Retrieval' 
WHEN `month_date` = 'Nov-22' AND `customer_status` IN ('Paid','Recovery')  THEN 'Nov_PaidRecovery'
WHEN `month_date` = 'Sep-22' AND `customer_status` = 'Retrieval' THEN 'Sep_Retrieval' 
WHEN `month_date` = 'Oct-22' AND `customer_status` IN ('Paid','Recovery') THEN 'Oct_PaidRecovery'
ELSE 'NA' END Movement_status
FROM `activity_log`)a
WHERE  Movement_status !='NA')a
LEFT JOIN (SELECT * FROM `daily_transactions` WHERE report_date = '2022-10-01')b
ON a.`contract` = b.`contract`
LEFT JOIN (SELECT * FROM `daily_transactions` WHERE report_date = '2022-11-01')c
ON a.`contract` = c.`contract`
LEFT JOIN (SELECT * FROM `daily_transactions` WHERE report_date = '2022-12-01')d
ON a.`contract` = d.`contract`
LEFT JOIN (SELECT * FROM `daily_transactions` WHERE report_date = '2023-01-01')e
ON a.`contract` = e.`contract`

______________Nov_Retrieval_to Dec_Paid&Recovery__________________

SELECT `contract`,`generation`,Nov_Status,Dec_Status,Nov_Revenue,Dec_Revenue
FROM
(
SELECT a.`contract`,a.`generation`,a.`customer_status` Nov_Status,b.`customer_status` Dec_Status,
SUM(c.charged_amount) Nov_Revenue,SUM(d.charged_amount) Dec_Revenue
FROM 
(SELECT * FROM `activity_log` WHERE `month_date` = 'Nov-22' AND `customer_status` = 'Retrieval')a
LEFT JOIN 
(SELECT * FROM `activity_log` WHERE `month_date` = 'Dec-22' AND `customer_status` IN ('Paid','Recovery'))b
ON a.`contract` = b.`contract`
LEFT JOIN (SELECT * FROM `daily_transactions` WHERE report_date = '2022-12-01')c
ON a.`contract` = c.`contract`
LEFT JOIN (SELECT * FROM `daily_transactions` WHERE report_date = '2023-01-01')d
ON a.`contract` = d.`contract`
GROUP BY `contract`,`generation`,Nov_Status,Dec_Status
)e WHERE Dec_Status IN ('Paid','Recovery')


______________Oct_Retrieval_to Nov_Paid&Recovery__________________

SELECT `contract`,`generation`,Oct_Status,Nov_Status,Oct_Revenue,Nov_Revenue
FROM
(
SELECT a.`contract`,a.`generation`,a.`customer_status` Oct_Status,b.`customer_status` Nov_Status,
SUM(c.charged_amount) Oct_Revenue,SUM(d.charged_amount) Nov_Revenue
FROM 
(SELECT * FROM `activity_log` WHERE `month_date` = 'Oct-22' AND `customer_status` = 'Retrieval')a
LEFT JOIN 
(SELECT * FROM `activity_log` WHERE `month_date` = 'Nov-22' AND `customer_status` IN ('Paid','Recovery'))b
ON a.`contract` = b.`contract`
LEFT JOIN (SELECT * FROM `daily_transactions` WHERE report_date = '2022-11-01')c
ON a.`contract` = c.`contract`
LEFT JOIN (SELECT * FROM `daily_transactions` WHERE report_date = '2022-12-01')d
ON a.`contract` = d.`contract`
GROUP BY `contract`,`generation`,Oct_Status,Nov_Status
)e WHERE Nov_Status IN ('Paid','Recovery')

______________Sep_Retrieval_to Oct_Paid&Recovery__________________

SELECT `contract`,`generation`,Sep_Status,Oct_Status,Sep_Revenue,Oct_Revenue
FROM
(
SELECT a.`contract`,a.`generation`,a.`customer_status` Sep_Status,b.`customer_status` Oct_Status,
SUM(c.charged_amount) Sep_Revenue,SUM(d.charged_amount) Oct_Revenue
FROM 
(SELECT * FROM `activity_log` WHERE `month_date` = 'Sep-22' AND `customer_status` = 'Retrieval')a
LEFT JOIN 
(SELECT * FROM `activity_log` WHERE `month_date` = 'Oct-22' AND `customer_status` IN ('Paid','Recovery'))b
ON a.`contract` = b.`contract`
LEFT JOIN (SELECT * FROM `daily_transactions` WHERE report_date = '2022-10-01')c
ON a.`contract` = c.`contract`
LEFT JOIN (SELECT * FROM `daily_transactions` WHERE report_date = '2022-11-01')d
ON a.`contract` = d.`contract`
GROUP BY `contract`,`generation`,Sep_Status,Oct_Status
)e WHERE Oct_Status IN ('Paid','Recovery')


--------------Customer who are expected to_pay in_dec22-------------------- DATE_FORMAT(`created_date`,"%M %Y")

SELECT contract,Jul22_Paidperiod,Jul22_Revenue,Aug22_Paidperiod,Aug22_Revenue,Sep22_Paidperiod,Sep22_Revenue,
Oct22_Paidperiod,Oct22_Revenue,Nov22_Paidperiod,Nov22_Revenue,Dec22_Paidperiod,Dec22_Revenue,Avg_Jul_Oct_PP,
Avg_Jul_Oct_Rev,Nov_Annvi,Nov_Activation_date,Dec_Annvi,
CASE 
WHEN Nov_Activation_date = '1899-12-30' THEN 'Paid_before_annvi_date_1899_12_30'
WHEN Nov_Annvi < '2022-11-24' AND Nov_Activation_date BETWEEN '2022-11-24' AND '2022-11-30' THEN 'Influenced_by_PC'
WHEN Nov_Annvi > '2022-11-23' AND Nov_Activation_date BETWEEN '2022-11-24' AND '2022-11-30' THEN 'Paid_within_Anniv_date_In_PC'
WHEN Nov_Annvi = Nov_Activation_date THEN 'Paid_Within_Anniv_date'
WHEN Nov_Annvi < Nov_Activation_date THEN 'Paid_After_Anniv_date'
ELSE 'Paid_before_annvi_date'
END Nov_payment_grouping,
CASE
WHEN Avg_Jul_Oct_PP < Dec22_Paidperiod THEN 'Positive'
WHEN Avg_Jul_Oct_PP = Dec22_Paidperiod THEN 'Neutral'
ELSE 'Negative'
END PP_Customer_Status,
CASE
WHEN Avg_Jul_Oct_Rev < Dec22_Revenue THEN 'Positive'
WHEN Avg_Jul_Oct_Rev = Dec22_Revenue THEN 'Neutral'
ELSE 'Negative'
END Rev_Customer_Status
FROM
(
SELECT contract,Jul22_Paidperiod,Jul22_Revenue,Aug22_Paidperiod,Aug22_Revenue,Sep22_Paidperiod,Sep22_Revenue,
Oct22_Paidperiod,Oct22_Revenue,Nov22_Paidperiod,Nov22_Revenue,Dec22_Paidperiod,Dec22_Revenue,(Jul22_Paidperiod + Aug22_Paidperiod + Sep22_Paidperiod + Oct22_Paidperiod)/4 Avg_Jul_Oct_PP,
(Jul22_Revenue + Aug22_Revenue + Sep22_Revenue + Oct22_Revenue)/4 Avg_Jul_Oct_Rev,Nov_Annvi,
CASE
WHEN Nov_Activation_date IS NULL THEN payment_date
ELSE Nov_Activation_date
END Nov_Activation_date, Dec_Annvi
FROM
(
SELECT a.* ,c.`ref_activation_end` Nov_Annvi, d.Nov_Activation_date,b.`last_payment_date` payment_date,b.`ref_activation_end` Dec_Annvi
FROM `business_check_legacy` a
LEFT JOIN 
(SELECT * 
FROM `activity_log` 
WHERE `month_date` = 'Nov-22') b
ON a.`contract` = b.`contract`
LEFT JOIN
(SELECT * 
FROM `activity_log` 
WHERE `month_date` = 'Oct-22') c
ON a.`contract` = c.`contract`
LEFT JOIN 
(SELECT `contract`, MIN(DATE_FORMAT(`transaction_date`,"%Y-%m-%d")) Nov_Activation_date
 FROM `daily_transactions` 
 WHERE report_date = '2022-12-01'
 GROUP BY `contract`)d
ON a.`contract` = d.`contract`
)d WHERE Dec_Annvi BETWEEN '2022-12-01' AND '2022-12-31'
)e


--------------Legacy Customer who are expected to_pay in_dec22-------------------- 

#-----------------Step3- Getting the Payment_status_Grouping, Payment_status, PP_Customer_Status and Rev_Customer_Status
#using case statement )-------------#
SELECT contract,Jul22_Paidperiod,Jul22_Revenue,Aug22_Paidperiod,Aug22_Revenue,Sep22_Paidperiod,Sep22_Revenue,
Oct22_Paidperiod,Oct22_Revenue,Nov22_Paidperiod,Nov22_Revenue,Dec22_Paidperiod,Dec22_Revenue,Avg_Jul_Oct_PP,
Avg_Jul_Oct_Rev,Nov_Annvi,Nov_Activation_date,Dec_Annvi,customer_status,
CASE 
WHEN Dec22_Revenue = 0 THEN 'No_Payment_in_Dec'
WHEN Avg_Jul_Oct_PP < Dec22_Paidperiod THEN 'Paid_higher_in_Dec'
WHEN Avg_Jul_Oct_PP = Dec22_Paidperiod THEN 'Made_Same_payment_in_Dec'
ELSE 'Paid_less_in_Dec'
END Payment_status_Grouping,
CASE 
WHEN Dec22_Revenue = 0 THEN 'No_Payment_in_Dec'
ELSE 'Paid_in_Dec'
END Payment_status,
CASE
WHEN Avg_Jul_Oct_PP < Dec22_Paidperiod THEN 'Positive'
WHEN Avg_Jul_Oct_PP = Dec22_Paidperiod THEN 'Neutral'
ELSE 'Negative'
END PP_Customer_Status,
CASE
WHEN Avg_Jul_Oct_Rev < Dec22_Revenue THEN 'Positive'
WHEN Avg_Jul_Oct_Rev = Dec22_Revenue THEN 'Neutral'
ELSE 'Negative'
END Rev_Customer_Status,1st_Nov22_Seg,1st_Jan23_Seg
FROM
(#-----------------Step2-Getting the AVG of PaidPeriod Jul to Oct and 
#manipulating the Nov_Activation_date by fixing the blank space with last_payment_date )-------------#
SELECT contract,Jul22_Paidperiod,Jul22_Revenue,Aug22_Paidperiod,Aug22_Revenue,Sep22_Paidperiod,Sep22_Revenue,
Oct22_Paidperiod,Oct22_Revenue,Nov22_Paidperiod,Nov22_Revenue,Dec22_Paidperiod,Dec22_Revenue,
(Jul22_Paidperiod + Aug22_Paidperiod + Sep22_Paidperiod + Oct22_Paidperiod)/4 Avg_Jul_Oct_PP,
(Jul22_Revenue + Aug22_Revenue + Sep22_Revenue + Oct22_Revenue)/4 Avg_Jul_Oct_Rev,Nov_Annvi,
CASE
WHEN Nov_Activation_date IS NULL THEN payment_date
ELSE Nov_Activation_date
END Nov_Activation_date, Dec_Annvi,customer_status,1st_Nov22_Seg,1st_Jan23_Seg
FROM
(#-----------------Step1-Getting on the necessary header from the below two table 
#(Activity Log month Dec to Oct) and (daily_transactions)-------------#
SELECT a.* ,c.`ref_activation_end` Nov_Annvi, e.Nov_Activation_date,b.`last_payment_date` payment_date,
b.`ref_activation_end` Dec_Annvi,d.`customer_status`,c.segmentation_status 1st_Nov22_Seg, d.segmentation_status 1st_Jan23_Seg
FROM `business_check_legacy` a
LEFT JOIN 
(SELECT * 
FROM `activity_log` 
WHERE `month_date` = 'Nov-22') b
ON a.`contract` = b.`contract`
LEFT JOIN
(SELECT * 
FROM `activity_log` 
WHERE `month_date` = 'Oct-22') c
ON a.`contract` = c.`contract`
LEFT JOIN 
(SELECT * 
FROM `activity_log` 
WHERE `month_date` = 'Dec-22') d
ON a.`contract` = d.`contract`
LEFT JOIN 
(SELECT `contract`, MIN(DATE_FORMAT(`transaction_date`,"%Y-%m-%d")) Nov_Activation_date
 FROM `daily_transactions` 
 WHERE report_date = '2022-12-01'
 GROUP BY `contract`)e
ON a.`contract` = e.`contract`
)d WHERE Dec_Annvi BETWEEN '2022-12-01' AND '2022-12-31'
)e



-----------------------------Unified Customer who are expected to_pay in_dec22------------------------------ 
#-----------------Step3- Getting the Payment_status_Grouping, Payment_status, PP_Customer_Status and Rev_Customer_Status
#using case statement )-------------#
SELECT contract,Jul22_Paidperiod,Jul22_Revenue,Aug22_Paidperiod,Aug22_Revenue,Sep22_Paidperiod,Sep22_Revenue,
Oct22_Paidperiod,Oct22_Revenue,Nov22_Paidperiod,Nov22_Revenue,Dec22_Paidperiod,Dec22_Revenue,Avg_Jul_Oct_PP,
Avg_Jul_Oct_Rev,Nov_Annvi,Nov_Activation_date,Dec_Annvi,customer_status,
CASE 
WHEN Dec22_Revenue = 0 THEN 'No_Payment_in_Dec'
WHEN Avg_Jul_Oct_PP < Dec22_Paidperiod THEN 'Paid_higher_in_Dec'
WHEN Avg_Jul_Oct_PP = Dec22_Paidperiod THEN 'Made_Same_payment_in_Dec'
ELSE 'Paid_less_in_Dec'
END Payment_status_Grouping,
CASE 
WHEN Dec22_Revenue = 0 THEN 'No_Payment_in_Dec'
ELSE 'Paid_in_Dec'
END Payment_status,
CASE
WHEN Avg_Jul_Oct_PP < Dec22_Paidperiod THEN 'Positive'
WHEN Avg_Jul_Oct_PP = Dec22_Paidperiod THEN 'Neutral'
ELSE 'Negative'
END PP_Customer_Status,
CASE
WHEN Avg_Jul_Oct_Rev < Dec22_Revenue THEN 'Positive'
WHEN Avg_Jul_Oct_Rev = Dec22_Revenue THEN 'Neutral'
ELSE 'Negative'
END Rev_Customer_Status, 1st_Nov22_Seg,1st_Jan23_Seg
FROM
(#-----------------Step2-Getting the AVG of PaidPeriod Jul to Oct and 
#manipulating the Nov_Activation_date by fixing the blank space with last_payment_date )-------------#
SELECT contract,Jul22_Paidperiod,Jul22_Revenue,Aug22_Paidperiod,Aug22_Revenue,Sep22_Paidperiod,Sep22_Revenue,
Oct22_Paidperiod,Oct22_Revenue,Nov22_Paidperiod,Nov22_Revenue,Dec22_Paidperiod,Dec22_Revenue,
(Jul22_Paidperiod + Aug22_Paidperiod + Sep22_Paidperiod + Oct22_Paidperiod)/4 Avg_Jul_Oct_PP,
(Jul22_Revenue + Aug22_Revenue + Sep22_Revenue + Oct22_Revenue)/4 Avg_Jul_Oct_Rev,Nov_Annvi,
CASE
WHEN Nov_Activation_date IS NULL THEN payment_date
ELSE Nov_Activation_date
END Nov_Activation_date, Dec_Annvi,customer_status, 1st_Nov22_Seg,1st_Jan23_Seg
FROM
(#-----------------Step1-Getting on the necessary header from the below two table 
#(Activity Log month Dec to Oct) and (daily_transactions)-------------#
SELECT a.* ,c.`ref_activation_end` Nov_Annvi, e.Nov_Activation_date,b.`last_payment_date` payment_date,
b.`ref_activation_end` Dec_Annvi,d.`customer_status`,c.`segmentation_status` 1st_Nov22_Seg, d.`segmentation_status` 1st_Jan23_Seg
FROM `business_check_unified` a
LEFT JOIN 
(SELECT * 
FROM `activity_log` 
WHERE `month_date` = 'Nov-22') b
ON a.`contract` = b.`contract`
LEFT JOIN
(SELECT * 
FROM `activity_log` 
WHERE `month_date` = 'Oct-22') c
ON a.`contract` = c.`contract`
LEFT JOIN 
(SELECT * 
FROM `activity_log` 
WHERE `month_date` = 'Dec-22') d
ON a.`contract` = d.`contract`
LEFT JOIN 
(SELECT `contract`, MIN(DATE_FORMAT(`transaction_date`,"%Y-%m-%d")) Nov_Activation_date
 FROM `daily_transactions` 
 WHERE report_date = '2022-12-01'
 GROUP BY `contract`)e
ON a.`contract` = e.`contract`
)d WHERE Dec_Annvi BETWEEN '2022-12-01' AND '2022-12-31'
)e






SELECT * FROM `business_check_unified`

SELECT `contract`,`outage_days` 
FROM `activity_log` 
WHERE `month_date` = 'Dec-22'

SELECT a.`contract`,a.`crmcontract`,a.`customer_status`,a.`generation`,a.`sales_channel`,b.`customer_signed_phone`,b.`secondary_phone_number`
FROM activity a 
LEFT JOIN `customer_big_table` b
ON a.`contract` = b.full_sfid





#--------------------------------Unified_Longer_Plan-------------------------------------------------#
SELECT a.`contract`, `product_category`, highest_plan, `ref_activation_end`, oct_segment, dec_segment, a.Expiration_Status, d.Paid_days, d.Payment_status
FROM (
(SELECT a.contract, `product_category`, highest_plan, `ref_activation_end`,
CASE 
WHEN  `ref_activation_end` < '2023-01-23' THEN 'Expired'
WHEN  `ref_activation_end` BETWEEN '2023-01-23' AND '2023-01-31' THEN 'Expires_in_Jan23'
WHEN  `ref_activation_end` BETWEEN '2023-02-01' AND '2023-02-28' THEN 'Expires_in_Feb23'
WHEN  `ref_activation_end` BETWEEN '2023-03-01' AND '2023-03-31' THEN 'Expires_in_Mar23'
WHEN  `ref_activation_end` BETWEEN '2023-04-01' AND '2023-04-30' THEN 'Expires_in_Apr23'
WHEN  `ref_activation_end` BETWEEN '2023-05-01' AND '2023-05-31' THEN 'Expires_in_May23'
WHEN  `ref_activation_end` BETWEEN '2023-06-01' AND '2023-06-30' THEN 'Expires_in_Jun23'
ELSE 'Expires_Jul_and_above' END 'Expiration_Status'
FROM (
(SELECT `contract`, `ref_activation_end`
FROM `activity_log`
WHERE `month_date` = 'Nov-22'
AND `contract` IN (SELECT `contract` FROM `business_check_unified`)
AND `ref_activation_end` > '2022-12-31') a

INNER JOIN

(SELECT `contract`, `product_category`, highest_plan
FROM (
SELECT `contract`, `contract_num`, `product_category`, `charged_amount`, ROW_NUMBER () OVER (PARTITION BY `contract` ORDER BY `charged_amount` DESC) AS highest_plan
FROM `daily_transactions`
WHERE `report_date` = '2022-12-01'
AND `transaction_date` BETWEEN '2022-11-24' AND '2022-11-30'
AND `contract` IN (SELECT `contract` FROM `business_check_unified`)
      ) a
WHERE highest_plan = 1) b
ON a.`contract` = b.`contract`
	)
) a

LEFT OUTER JOIN

(SELECT `contract`, `segmentation_status` oct_segment
FROM `activity_log` WHERE `month_date` = 'Oct-22') b
ON a.`contract` = b.`contract`

LEFT OUTER JOIN

(SELECT `contract`, `segmentation_status` dec_segment
FROM `activity_log` WHERE `month_date` = 'Dec-22') c
ON a.`contract` = c.`contract`

LEFT OUTER JOIN

(SELECT `contract`, SUM(`payment_duration`) Paid_days, 
CASE WHEN SUM(`charged_amount`) > 0 THEN 'Paid'
ELSE 'No_Payment' END 'Payment_status'
FROM `daily_transactions_curr_MTD` GROUP BY `contract`) d
ON a.`contract` = d.`contract`

     )
     
     
#--------------------------------Legacy_Longer_Plan-------------------------------------------------#
SELECT a.`contract`, `product_category`, highest_plan, `ref_activation_end`, oct_segment, dec_segment, a.Expiration_Status, d.Paid_days, d.Payment_status
FROM (
(SELECT a.contract, `product_category`, highest_plan, `ref_activation_end`,
CASE 
WHEN  `ref_activation_end` < '2023-01-23' THEN 'Expired'
WHEN  `ref_activation_end` BETWEEN '2023-01-23' AND '2023-01-31' THEN 'Expires_in_Jan23'
WHEN  `ref_activation_end` BETWEEN '2023-02-01' AND '2023-02-28' THEN 'Expires_in_Feb23'
WHEN  `ref_activation_end` BETWEEN '2023-03-01' AND '2023-03-31' THEN 'Expires_in_Mar23'
WHEN  `ref_activation_end` BETWEEN '2023-04-01' AND '2023-04-30' THEN 'Expires_in_Apr23'
WHEN  `ref_activation_end` BETWEEN '2023-05-01' AND '2023-05-31' THEN 'Expires_in_May23'
WHEN  `ref_activation_end` BETWEEN '2023-06-01' AND '2023-06-30' THEN 'Expires_in_Jun23'
ELSE 'Expires_Jul_and_above' END 'Expiration_Status'
FROM (
(SELECT `contract`, `ref_activation_end`
FROM `activity_log`
WHERE `month_date` = 'Nov-22'
AND `contract` IN (SELECT `contract` FROM `business_check_legacy`)
AND `ref_activation_end` > '2022-12-31') a

INNER JOIN

(SELECT `contract`, `product_category`, highest_plan
FROM (
SELECT `contract`, `contract_num`, `product_category`, `charged_amount`, ROW_NUMBER () OVER (PARTITION BY `contract` ORDER BY `charged_amount` DESC) AS highest_plan
FROM `daily_transactions`
WHERE `report_date` = '2022-12-01'
AND `transaction_date` BETWEEN '2022-11-24' AND '2022-11-30'
AND `contract` IN (SELECT `contract` FROM `business_check_legacy`)
      ) a
WHERE highest_plan = 1) b
ON a.`contract` = b.`contract`
	)
) a

LEFT OUTER JOIN

(SELECT `contract`, `segmentation_status` oct_segment
FROM `activity_log` WHERE `month_date` = 'Oct-22') b
ON a.`contract` = b.`contract`

LEFT OUTER JOIN

(SELECT `contract`, `segmentation_status` dec_segment
FROM `activity_log` WHERE `month_date` = 'Dec-22') c
ON a.`contract` = c.`contract`

LEFT OUTER JOIN

(SELECT `contract`, SUM(`payment_duration`) Paid_days, 
CASE WHEN SUM(`charged_amount`) > 0 THEN 'Paid'
ELSE 'No_Payment' END 'Payment_status'
FROM `daily_transactions_curr_MTD` GROUP BY `contract`) d
ON a.`contract` = d.`contract`

     )     


     #--------------------Customer Email-----------------------------------------------#
     SELECT `customer_signed_phone`,`customer_signed_email`, `full_sfid`,a.`generation`, a.`sales_channel`,`lcp_status`
     FROM `customer_big_table` a
     INNER JOIN `activity` b
     ON a.full_sfid = b.contract
     WHERE b.`product_name` 
     NOT LIKE '%Rental%' 
     AND `customer_signed_email` != 'null'
     AND `customer_status` != 'Cancelled' 
     AND `lcp_status` != 'LCP'


  #--------------------LCP_Breakdown-----------------------#
     SELECT 
     CASE 
     WHEN product_name LIKE 'PRIME%' THEN 'Prime'
     ELSE 'Eco' END 'Product_status',
     CASE 
     WHEN product_name LIKE '%12%' THEN '1_year'
     WHEN product_name LIKE  '%24%' THEN '2_year'
     ELSE '28_months_plan' END 'Plan_status',initial_rate_plan,
     COUNT(DISTINCT contract)
     FROM `lcp_base`
     WHERE `created_date` < '2023-01-01'
     GROUP BY Product_status,Plan_status,initial_rate_plan
     
     
#--------------------Churn Categories breakdown-----------------------------#
     SELECT 
     CASE 
     WHEN `generation` = 'Legacy' THEN 'Legacy'
     WHEN `generation` = 'Unified' AND `sales_channel` = 'MTN_NG' THEN 'Unified_MTN'
     ELSE 'Unified_Non-MTN' END 'Channel_Status', COUNT(DISTINCT contract) Overall_count
     FROM `activity_log`
     WHERE `month_date` = 'Mar-22' AND `old_active_status` = 'Churn'
     GROUP BY Channel_Status     
     
     
 #-----------------Active_Churn_cancelled to Owner--------------------------------------------#  
   
   SELECT
     CASE 
     WHEN a.`generation` = 'Legacy' THEN 'Legacy'
     WHEN a.`generation` = 'Unified' AND a.`sales_channel` = 'MTN_NG' THEN 'Unified_MTN'
     WHEN a.`generation` = 'Unified' AND a.`sales_channel` = 'AIRTEL_NG' AND a.`lcp_status` ='Non-LCP' THEN 'Unified_Non-MTN'
     ELSE 'LCP' END 'Channel_Status',COUNT(DISTINCT a.contract) Overall_count
     FROM (SELECT * FROM `activity_log`
     WHERE `month_date` = 'Jan-22' AND `old_active_status` IN ('Active','Churn','Cancelled')) a
     INNER JOIN
     (SELECT * FROM `activity_log`
     WHERE `month_date` = 'Dec-22' AND `old_active_status` = 'Owner') b
     ON a.contract = b.contract
    GROUP BY Channel_Status
    
    
         #-----------------Paid base genetration breakdown--------------------------------#
     SELECT
     CASE 
     WHEN a.`generation` = 'Legacy' THEN 'Legacy'
     WHEN a.`generation` = 'Unified' AND a.`lcp_status` ='Non-LCP' THEN 'Unified'
     ELSE 'LCP' END 'Channel_Status',COUNT(DISTINCT a.contract) Overall_count
     FROM (SELECT * FROM `activity_log`
     WHERE `month_date` = 'Dec-22' AND `customer_status` = 'paid') a
     GROUP BY Channel_Status
     
     
     #-----------------------Owner for forcast for Non-LCP----------------------------------------------------#     
     
      SELECT contract, b.`created_date`,`ref_activation_end`,`ltoperiod`,`paidperiod`,`last_payment_date`,`age`,
     CASE 
     WHEN a.`generation` = 'Legacy' THEN 'Legacy'
     WHEN a.`generation` = 'Unified' AND a.`sales_channel` = 'MTN_NG' THEN 'Unified_MTN'
     WHEN a.`generation` = 'Unified' AND a.`sales_channel` = 'AIRTEL_NG' AND a.`lcp_status` ='Non-LCP' THEN 'Unified_Non-MTN'
     ELSE 'LCP' END 'Channel_Status'
     FROM (SELECT * FROM `activity_log`
     WHERE `month_date` = 'Dec-22' AND `old_active_status` IN ('Active','Churn')) a
     LEFT JOIN
     `customer_big_table` b
     ON a.contract = b.`full_sfid`

  
   #-----------------------Owner for forcast for LCP----------------------------------------------------#      
     SELECT a.contract,system_id, a.contract_id, a.created_date, price_book_name,a.product_name,
     initial_rate_plan, ltoperiod, paidperiod, ref_activation_end
     FROM (SELECT * FROM`lcp_base`
     WHERE initial_rate_plan ='1 MONTHS' AND `created_date` < '2023-01-01')a
     LEFT JOIN
     (SELECT * FROM `activity_log`
     WHERE `month_date` = 'Dec-22') b
     ON a.contract = b.contract
     
     
     
SELECT contract_num,payment_time_units,SUM(`charged_amount`) Amount, SUM(payment_duration) Paid_day
	FROM `daily_transactions_curr_MTD`
	GROUP BY contract_num,payment_time_units
	
	
SELECT a.contract, a.crmcontract, a.customer_status, a.generation, a.sales_channel, customer_signed_phone, secondary_phone_number
FROM 
(SELECT * FROM `activity`
WHERE sales_channel ='MTN_NG' AND customer_status !='Cancelled')a
LEFT JOIN
`customer_big_table` b
ON a.contract = b.`full_sfid`




#----------------Unified Payment Tracker for price change------------------------------#

SELECT a.*,
CASE 
WHEN  b.charged_amount > 0 THEN 'Paid'
ELSE 'No payment' END Payment_status, `light_status`
FROM `business_check_unified_tracking` a

LEFT JOIN

(SELECT `contract`,`product_category`, `charged_amount`
FROM
(
SELECT `contract`, `contract_num`, `product_category`, `charged_amount`, ROW_NUMBER () OVER (PARTITION BY `contract` ORDER BY `charged_amount` DESC) AS highest_plan
FROM `daily_transactions`
WHERE `report_date` IN ('2023-01-01','2023-02-01')
AND `contract` IN (SELECT `contract` FROM `business_check_unified_tracking`)
)a WHERE highest_plan = 1
)b
ON a.contract = b.contract

LEFT JOIN

(
SELECT DISTINCT`contract`,`customer_status`, `light_status`
FROM `activity_log` 
WHERE `month_date` = 'Jan-23'
AND `contract` IN (SELECT `contract` FROM `business_check_unified_tracking`)
)c
ON a.contract = c.contract


#----------------Legacy payment Tracker for price change------------------------------#

SELECT a.*,
CASE 
WHEN  b.charged_amount > 0 THEN 'Paid'
ELSE 'No payment' END Payment_status, `light_status`
FROM `business_check_legacy_tracking` a

LEFT JOIN

(SELECT `contract`,`product_category`, `charged_amount`
FROM
(
SELECT `contract`, `contract_num`, `product_category`, `charged_amount`, ROW_NUMBER () OVER (PARTITION BY `contract` ORDER BY `charged_amount` DESC) AS highest_plan
FROM `daily_transactions`
WHERE `report_date` IN ('2023-01-01','2023-02-01','2023-03-01')
AND `contract` IN (SELECT `contract` FROM `business_check_legacy_tracking`)
)a WHERE highest_plan = 1
)b
ON a.contract = b.contract

LEFT JOIN

(
SELECT DISTINCT`contract`,`customer_status`, `light_status`
FROM `activity_log` 
WHERE `month_date` = 'Feb-23'
AND `contract` IN (SELECT `contract` FROM `business_check_legacy_tracking`)
)c
ON a.contract = c.contract


-----------------------------Unified Customer who are expected to_pay in_dec22 till Feb23------------------------------ 
#-----------------Step3- Getting the Payment_status_Grouping, Payment_status, PP_Customer_Status and Rev_Customer_Status
#using case statement )-------------#
SELECT contract,Jul22_Paidperiod,Jul22_Revenue,Aug22_Paidperiod,Aug22_Revenue,Sep22_Paidperiod,Sep22_Revenue,
Oct22_Paidperiod,Oct22_Revenue,Nov22_Paidperiod,Nov22_Revenue,Dec22_Paidperiod,Dec22_Revenue,Jan23_Paidperiod,Jan23_Revenue,
Feb23_Paidperiod,Feb23_Revenue,Avg_Jul_Oct_PP,
Avg_Jul_Oct_Rev,Nov_Annvi,Nov_Activation_date,Dec_Annvi,customer_status,
CASE 
WHEN Dec22_Revenue = 0 THEN 'No_Payment_in_Dec'
WHEN Avg_Jul_Oct_PP < Dec22_Paidperiod THEN 'Paid_higher_in_Dec'
WHEN Avg_Jul_Oct_PP = Dec22_Paidperiod THEN 'Made_Same_payment_in_Dec'
ELSE 'Paid_less_in_Dec'
END Payment_status_Grouping,
CASE 
WHEN Dec22_Revenue = 0 THEN 'No_Payment_in_Dec'
ELSE 'Paid_in_Dec'
END Payment_status,
CASE
WHEN Avg_Jul_Oct_PP < Dec22_Paidperiod THEN 'Positive'
WHEN Avg_Jul_Oct_PP = Dec22_Paidperiod THEN 'Neutral'
ELSE 'Negative'
END PP_Customer_Status,
CASE
WHEN Avg_Jul_Oct_Rev < Dec22_Revenue THEN 'Positive'
WHEN Avg_Jul_Oct_Rev = Dec22_Revenue THEN 'Neutral'
ELSE 'Negative'
END Rev_Customer_Status, 1st_Nov22_Seg,1st_Jan23_Seg, Dec22_Customer_Status, Jan23_Customer_Status,
Feb23_Customer_Status
FROM
(#-----------------Step2-Getting the AVG of PaidPeriod Jul to Oct and 
#manipulating the Nov_Activation_date by fixing the blank space with last_payment_date )-------------#
SELECT contract,Jul22_Paidperiod,Jul22_Revenue,Aug22_Paidperiod,Aug22_Revenue,Sep22_Paidperiod,Sep22_Revenue,
Oct22_Paidperiod,Oct22_Revenue,Nov22_Paidperiod,Nov22_Revenue,Dec22_Paidperiod,Dec22_Revenue,Jan23_Paidperiod,Jan23_Revenue,
Feb23_Paidperiod,Feb23_Revenue,(Jul22_Paidperiod + Aug22_Paidperiod + Sep22_Paidperiod + Oct22_Paidperiod)/4 Avg_Jul_Oct_PP,
(Jul22_Revenue + Aug22_Revenue + Sep22_Revenue + Oct22_Revenue)/4 Avg_Jul_Oct_Rev,Nov_Annvi,
CASE
WHEN Nov_Activation_date IS NULL THEN payment_date
ELSE Nov_Activation_date
END Nov_Activation_date, Dec_Annvi,customer_status, 1st_Nov22_Seg,1st_Jan23_Seg, Dec22_Customer_Status, Jan23_Customer_Status,
Feb23_Customer_Status
FROM
(#-----------------Step1-Getting on the necessary header from the below two table 
#(Activity Log month Dec to Oct) and (daily_transactions)-------------#
SELECT a.* ,c.`ref_activation_end` Nov_Annvi, i.Nov_Activation_date,b.`last_payment_date` payment_date,
b.`ref_activation_end` Dec_Annvi,d.`customer_status`,c.`segmentation_status` 1st_Nov22_Seg, d.`segmentation_status` 1st_Jan23_Seg
,Jan23_Paidperiod, Jan23_Revenue, Feb23_Paidperiod, Feb23_Revenue,d.`customer_status` Dec22_Customer_Status,
e.`customer_status` Jan23_Customer_Status,f.`customer_status` Feb23_Customer_Status
FROM `business_check_unified` a
LEFT JOIN 
(SELECT * 
FROM `activity_log` 
WHERE `month_date` = 'Nov-22') b
ON a.`contract` = b.`contract`
LEFT JOIN
(SELECT * 
FROM `activity_log` 
WHERE `month_date` = 'Oct-22') c
ON a.`contract` = c.`contract`
LEFT JOIN 
(SELECT * 
FROM `activity_log` 
WHERE `month_date` = 'Dec-22') d
ON a.`contract` = d.`contract`
LEFT JOIN 
(SELECT * 
FROM `activity_log` 
WHERE `month_date` = 'Jan-23') e
ON a.`contract` = e.`contract`
LEFT JOIN 
(SELECT * 
FROM `activity_log` 
WHERE `month_date` = 'Feb-23') f
ON a.`contract` = f.`contract`
LEFT JOIN 
(SELECT `contract`, SUM(`charged_amount`) Jan23_Revenue, SUM(payment_duration) Jan23_Paidperiod 
 FROM `daily_transactions` 
 WHERE report_date = '2023-02-01'
 GROUP BY `contract`)g
 ON a.`contract` = g.`contract`
 LEFT JOIN 
(SELECT `contract`, SUM(`charged_amount`) Feb23_Revenue, SUM(payment_duration) Feb23_Paidperiod 
 FROM `daily_transactions` 
 WHERE report_date = '2023-03-01'
 GROUP BY `contract`)h
 ON a.`contract` = h.`contract`
LEFT JOIN 
(SELECT `contract`, MIN(DATE_FORMAT(`transaction_date`,"%Y-%m-%d")) Nov_Activation_date
 FROM `daily_transactions` 
 WHERE report_date = '2022-12-01'
 GROUP BY `contract`)i
ON a.`contract` = i.`contract`
)d WHERE Dec_Annvi BETWEEN '2022-12-01' AND '2022-12-31'
)e



-----------------------------Legacy Customer who are expected to_pay in_dec22 updated till Feb23------------------------------ 
#-----------------Step3- Getting the Payment_status_Grouping, Payment_status, PP_Customer_Status and Rev_Customer_Status
#using case statement )-------------#
SELECT contract,Jul22_Paidperiod,Jul22_Revenue,Aug22_Paidperiod,Aug22_Revenue,Sep22_Paidperiod,Sep22_Revenue,
Oct22_Paidperiod,Oct22_Revenue,Nov22_Paidperiod,Nov22_Revenue,Dec22_Paidperiod,Dec22_Revenue,Jan23_Paidperiod,Jan23_Revenue,
Feb23_Paidperiod,Feb23_Revenue,Avg_Jul_Oct_PP,
Avg_Jul_Oct_Rev,Nov_Annvi,Nov_Activation_date,Dec_Annvi,customer_status,
CASE 
WHEN Dec22_Revenue = 0 THEN 'No_Payment_in_Dec'
WHEN Avg_Jul_Oct_PP < Dec22_Paidperiod THEN 'Paid_higher_in_Dec'
WHEN Avg_Jul_Oct_PP = Dec22_Paidperiod THEN 'Made_Same_payment_in_Dec'
ELSE 'Paid_less_in_Dec'
END Payment_status_Grouping,
CASE 
WHEN Dec22_Revenue = 0 THEN 'No_Payment_in_Dec'
ELSE 'Paid_in_Dec'
END Payment_status,
CASE
WHEN Avg_Jul_Oct_PP < Dec22_Paidperiod THEN 'Positive'
WHEN Avg_Jul_Oct_PP = Dec22_Paidperiod THEN 'Neutral'
ELSE 'Negative'
END PP_Customer_Status,
CASE
WHEN Avg_Jul_Oct_Rev < Dec22_Revenue THEN 'Positive'
WHEN Avg_Jul_Oct_Rev = Dec22_Revenue THEN 'Neutral'
ELSE 'Negative'
END Rev_Customer_Status, 1st_Nov22_Seg,1st_Jan23_Seg, Dec22_Customer_Status, Jan23_Customer_Status,
Feb23_Customer_Status, Feb_23_Inlight_Status
FROM
(#-----------------Step2-Getting the AVG of PaidPeriod Jul to Oct and 
#manipulating the Nov_Activation_date by fixing the blank space with last_payment_date )-------------#
SELECT contract,Jul22_Paidperiod,Jul22_Revenue,Aug22_Paidperiod,Aug22_Revenue,Sep22_Paidperiod,Sep22_Revenue,
Oct22_Paidperiod,Oct22_Revenue,Nov22_Paidperiod,Nov22_Revenue,Dec22_Paidperiod,Dec22_Revenue,Jan23_Paidperiod,Jan23_Revenue,
Feb23_Paidperiod,Feb23_Revenue,(Jul22_Paidperiod + Aug22_Paidperiod + Sep22_Paidperiod + Oct22_Paidperiod)/4 Avg_Jul_Oct_PP,
(Jul22_Revenue + Aug22_Revenue + Sep22_Revenue + Oct22_Revenue)/4 Avg_Jul_Oct_Rev,Nov_Annvi,
CASE
WHEN Nov_Activation_date IS NULL THEN payment_date
ELSE Nov_Activation_date
END Nov_Activation_date, Dec_Annvi,customer_status, 1st_Nov22_Seg,1st_Jan23_Seg, Dec22_Customer_Status, Jan23_Customer_Status,
Feb23_Customer_Status,Feb_23_Inlight_Status
FROM
(#-----------------Step1-Getting on the necessary header from the below two table 
#(Activity Log month Dec to Oct) and (daily_transactions)-------------#
SELECT a.* ,c.`ref_activation_end` Nov_Annvi, i.Nov_Activation_date,b.`last_payment_date` payment_date,
b.`ref_activation_end` Dec_Annvi,d.`customer_status`,c.`segmentation_status` 1st_Nov22_Seg, d.`segmentation_status` 1st_Jan23_Seg
,Jan23_Paidperiod, Jan23_Revenue, Feb23_Paidperiod, Feb23_Revenue,d.`customer_status` Dec22_Customer_Status,
e.`customer_status` Jan23_Customer_Status,f.`customer_status` Feb23_Customer_Status,f.`light_status` Feb_23_Inlight_Status
FROM `business_check_legacy` a
LEFT JOIN 
(SELECT * 
FROM `activity_log` 
WHERE `month_date` = 'Nov-22') b
ON a.`contract` = b.`contract`
LEFT JOIN
(SELECT * 
FROM `activity_log` 
WHERE `month_date` = 'Oct-22') c
ON a.`contract` = c.`contract`
LEFT JOIN 
(SELECT * 
FROM `activity_log` 
WHERE `month_date` = 'Dec-22') d
ON a.`contract` = d.`contract`
LEFT JOIN 
(SELECT * 
FROM `activity_log` 
WHERE `month_date` = 'Jan-23') e
ON a.`contract` = e.`contract`
LEFT JOIN 
(SELECT * 
FROM `activity_log` 
WHERE `month_date` = 'Feb-23') f
ON a.`contract` = f.`contract`
LEFT JOIN 
(SELECT `contract`, SUM(`charged_amount`) Jan23_Revenue, SUM(payment_duration) Jan23_Paidperiod 
 FROM `daily_transactions` 
 WHERE report_date = '2023-02-01'
 GROUP BY `contract`)g
 ON a.`contract` = g.`contract`
 LEFT JOIN 
(SELECT `contract`, SUM(`charged_amount`) Feb23_Revenue, SUM(payment_duration) Feb23_Paidperiod 
 FROM `daily_transactions` 
 WHERE report_date = '2023-03-01'
 GROUP BY `contract`)h
 ON a.`contract` = h.`contract`
LEFT JOIN 
(SELECT `contract`, MIN(DATE_FORMAT(`transaction_date`,"%Y-%m-%d")) Nov_Activation_date
 FROM `daily_transactions` 
 WHERE report_date = '2022-12-01'
 GROUP BY `contract`)i
ON a.`contract` = i.`contract`
)d WHERE Dec_Annvi BETWEEN '2022-12-01' AND '2022-12-31'
)e


/* update activity_log
set 
`customer_status` = 'Retrieval', `old_active_status` = 'Churn'
where `crmcontract` = '65701' and `month_date` = 'Mar-23'*/
 
/*INSERT INTO activity_log (sn, contract, reportdate, sales_channel, generation, type, 
ltoperiod, contract_creation, spsid, activation_start, paidperiod, crmcontract, last_payment_date, 
product_name, ref_activation_end, outage_days, old_active_status, light_status, age, segmentation_score, 
lto_segment, segmentation_status, lcp_status,age_segment, customer_status, month_date)

VALUES ('0','a0Db000000Zo7ygEAB', '2023-05-01', 'MTN_NG', 'LEGACY', 'LTO', 
'1500', '2017-04-02','1908344', '2021-06-04', '1500', '21554', '2020-09-26', 
'CLASSIC - Unit - (LTO 1500D) - MTN-NG', '2040-10-11', '6374', 'Owner', 'InLight', '2219', '68.5244', 
'Outside_LTO', 'Challenging', 'Non-LCP', 'Pre-Existing', 'Owner', 'Apr-23');*/

SELECT DISTINCT`contract`,`outage_days`,`customer_status`
FROM `activity_log` 
WHERE `month_date` = 'Jan-23'

SELECT *
FROM `activity_log` 
WHERE `month_date` = 'Mar-23' AND contract IN ('a0Db000000bdpt9EAA','a0Db000000beAHIEA2','a0Db000000Zo7ygEAB')

/*INSERT INTO activity (sn, contract, reportdate, sales_channel, generation, TYPE, 
ltoperiod, contract_creation, spsid, activation_start, paidperiod, crmcontract, last_payment_date, 
product_name, ref_activation_end, outage_days, old_active_status, light_status, age, segmentation_score, 
lto_segment, segmentation_status, lcp_status,age_segment, customer_status)

VALUES ('0','a0Db000000Zo7ygEAB', '2023-05-01', 'MTN_NG', 'LEGACY', 'LTO', 
'1500', '2017-04-02','1908344', '2021-06-04', '1500', '21554', '2020-09-26', 
'CLASSIC - Unit - (LTO 1500D) - MTN-NG', '2040-10-11', '6374', 'Owner', 'InLight', '2219', '68.5244', 
'Outside_LTO', 'Challenging', 'Non-LCP', 'Pre-Existing', 'Owner');*/


/*TRUNCATE TABLE `transfers`

/insert into `transfers`(`contract`,`contract_id`,`last_payment_date`,`retrieval_date`)
VALUE('a0D6700001Ce46SEAR','295040','2022-10-19','2022-11-27'),
('a0D6700001C4hFNEAZ','293922','2022-09-06','2022-12-10'),
('a0D6700001DDf9zEAD','296199','2022-09-16','2023-03-12'),
('a0D6700001EUIoJEAX','298703','2022-09-28','2022-12-19'),
('a0D6700001CoeSqEAJ','295473','2022-10-17','2022-12-25'),
('a0D6700001HOTAwEAP','301664','2023-01-08','2023-02-09'),
('a0D6700001DaIvIEAV','297491','2022-11-28','2023-02-10'),
('a0D6700001Gw4VdEAJ','300678','2023-01-07','2023-02-12'),
('a0D6700001HOe9PEAT','301746','2023-01-12','2023-02-16'),
('a0D6700001DBsZiEAL','296105','2023-01-12','2023-02-17'),
('a0D6700001H4mCgEAJ','301006','2022-12-18','2023-02-18'),
('a0D6700001D6xecEAB','295950','2022-10-06','2023-03-08'),
('a0D6700001HydVwEAJ','302624','2023-02-12','2023-03-08'),
('a0D6700001DBUDpEAP','296082','2022-11-19','2023-03-14'),
('a0D67000018ichSEAQ','299028','2022-12-22','2023-03-16'),
('a0D6700001GSecfEAD','300226','2023-02-21','2023-03-29'),
('a0D6700001HC3s7EAD','301347','2023-02-28','2023-04-03'),
('a0D6700001FEBnMEAX','299238','2023-02-07','2023-04-22'),
('a0D6700001IB10WEAT','303047','2023-03-01','2023-05-11'),
('a0D6700001C4hOAEAZ','293924','2022-12-11','2023-05-13'),
('a0D6700001HOOcZEAX','301636','2023-03-07','2023-05-11'),
('a0D6700001HizljEAB','302276','2023-02-26','2023-05-16'),
('a0D6700001HYGZOEA5','301863','2023-04-16','2023-05-18'),
('a0D6700001H4jIxEAJ','300998','2023-04-17','2023-05-19'),
('a0D6700001EtCv3EAF','299041','2023-01-23','2023-05-19'),
('a0D6700001D77abEAB','296013','2022-12-09','2023-05-23'),
('a0D6700001C1KGVEA3','293894','2022-12-07','2023-05-24'),
('a0D6700001Hp5XaEAJ','303305','2023-03-15','2023-05-24'),
('a0D6700001HYJErEAP','301905','2023-02-17','2023-05-24'),
('a0D6700001Hiv2REAR','302221','2023-04-24','2023-05-24'),
('a0D6700001IAutBEAT','303013','2023-05-01','2023-05-25'),
('a0D6700001IMBfmEAH','311209','2023-05-14','2023-05-26'),
('a0D6700001HznT3EAJ','302719','2023-03-17','2023-05-27'),
('a0D6700001HFK8cEAH','301547','2023-03-03','2023-05-29'),
('a0D6700001C0HBBEA3','293849','2022-12-18','2023-04-09'),
('a0D6700001DktsGEAR','297768','2023-01-12','2023-05-30'),
('a0D6700001HZNqyEAH','302084','2023-02-21','2023-05-30'),
('a0D6700001ImMSfEAN','310656','2023-05-16','2023-05-30')
*/
SELECT * FROM `transfers`


SELECT c.`contract`,`crmcontract`,`lcp_status`,`customer_status`,c.`generation`,Days_left_for_Ownership,Status_Required,
b.`customer_signed_phone`,Product_status
FROM
(
SELECT `contract`,`crmcontract`,`lcp_status`,`customer_status`,`generation`,
CASE WHEN `generation` ='LEGACY' THEN (Remaining_days_to_pay_to_ownership/30.4)
ELSE Remaining_days_to_pay_to_ownership END 'Days_left_for_Ownership',Product_status,
CASE WHEN `generation` ='LEGACY' AND (Remaining_days_to_pay_to_ownership/30.4)<=6 THEN '6months_below'
WHEN `generation` ='UNIFIED' AND (Remaining_days_to_pay_to_ownership)<=6 THEN '6months_below'
ELSE 'Above_6months' END 'Status_Required'
FROM
(
SELECT `contract`,`crmcontract`,`lcp_status`,`customer_status`,`generation`,`ltoperiod`,`paidperiod`,`outage_days`,
CASE WHEN `type` = 'RENTAL' THEN (48-`paidperiod`) ELSE (`ltoperiod`-`paidperiod`) END Remaining_days_to_pay_to_ownership,
CASE 
     WHEN product_name LIKE 'PRIME%' THEN 'Prime'
     WHEN product_name LIKE 'ECO%' THEN 'Eco'
     ELSE 'Classic' END 'Product_status'
     FROM `activity` 
     WHERE `customer_status` ='Retrieval' AND `lcp_status` !='LCP'
)a)c
LEFT JOIN
`customer_big_table` b
ON c.contract = b.`full_sfid`
WHERE Status_Required ='6months_below'

SELECT * FROM `activity`
WHERE `generation` ='UNIFIED'

SELECT `contract_id`,`current_tm`,`current_lcp`,`billing_state`,`community`,`created_date`
FROM `lcp_base_use`
WHERE created_date < '2023-05-01'

#-------------------Data requirement for Customer base excluding Community----------------------#
SELECT `contract`,`crmcontract`,`lcp_status`,`customer_status`,`generation`, ltoperiod, paidperiod,
`warranty_end_date`,Warranty_Expiry_Months,
CASE WHEN `customer_status`='Owner' AND Warranty_Expiry_Months_Status ='Expired' THEN 'Owner'
     WHEN `customer_status`='Owner' AND Warranty_Expiry_Months_Status !='Expired' THEN Warranty_Expiry_Months_Status 
     ELSE Ownership_remainiing_Months_Status END Ownership_remainiing_Months_Status,Warranty_Expiry_Months_Status
	
FROM
(
SELECT `contract`,`crmcontract`,`lcp_status`,`customer_status`,`generation`, ltoperiod, paidperiod,
`warranty_end_date`,Warranty_Expiry_Months,
CASE WHEN Ownership_remainiing_Months <1 THEN '<1_Month' 
     WHEN Ownership_remainiing_Months >=1 AND Ownership_remainiing_Months <2 THEN '1_Month' 
     WHEN Ownership_remainiing_Months >=2 AND Ownership_remainiing_Months <3 THEN '2_Months' 
     WHEN Ownership_remainiing_Months >=3 AND Ownership_remainiing_Months <4 THEN '3_Months' 
     ELSE 'Above 3_Months' END 	Ownership_remainiing_Months_Status,
     CASE WHEN Warranty_Expiry_Months <=0 THEN 'Expired' 
     WHEN Warranty_Expiry_Months <1 THEN 'Expires_<1_Month' 
     WHEN Warranty_Expiry_Months >=1  AND Warranty_Expiry_Months <2 THEN 'Expires_in_1_Month'
     WHEN Warranty_Expiry_Months >=2  AND Warranty_Expiry_Months <3 THEN 'Expires_in_2_Months'  
     WHEN Warranty_Expiry_Months >=3  AND Warranty_Expiry_Months <4 THEN 'Expires_in_3_Months' 
     ELSE 'Expires_Above 3_Months' END 	Warranty_Expiry_Months_Status	
FROM
(
SELECT a.`contract`,`crmcontract`,`lcp_status`,`customer_status`,a.`generation`,a.`ltoperiod`,
a.`paidperiod`,`outage_days`,b.warranty_end_date,
CASE WHEN a.`type` = 'RENTAL' THEN (48-a.`paidperiod`)
     WHEN a.`generation` ='LEGACY' THEN (a.`ltoperiod`-a.`paidperiod`)/30.4
     ELSE (a.`ltoperiod`-a.`paidperiod`) END Ownership_remainiing_Months,
DATEDIFF(b.warranty_end_date,DATE_SUB(CURDATE(),INTERVAL 2 DAY))/30.4 Warranty_Expiry_Months,
CASE 
     WHEN a.product_name LIKE 'PRIME%' THEN 'Prime'
     WHEN a.product_name LIKE 'ECO%' THEN 'Eco'
     ELSE 'Classic' END 'Product_status'
     FROM (SELECT * FROM `activity` 
     WHERE `lcp_status` !='LCP' AND `customer_status` IN('Paid','Recovery','Owner','Retrieval')
     )a
     LEFT JOIN
     `customer_big_table` b
     ON a.`crmcontract` = b.`contract_id`
     )c
)d


SELECT `month_date`,`customer_status`,`lcp_status`,COUNT(`contract`) COUNT
FROM `activity_log`
GROUP BY `month_date`,`customer_status`,`lcp_status`


----------Outright Q1-------------------Request
SELECT full_sfid,contract_id,generation,customer_signed_full_name,price_book_name,initial_rate_plan,created_date
FROM `customer_big_table`
WHERE initial_rate_plan IN ('1 OUTRIGHT','48 MONTHS','2 OUTRIGHT') AND created_date BETWEEN '2023-01-01' AND '2023-03-31'


SELECT `contract_creation`
FROM `activity`