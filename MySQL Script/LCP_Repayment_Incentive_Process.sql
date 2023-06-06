
#DROP TABLE Min_Date_Nov22


CREATE TABLE Min_Date_Feb23
AS
(SELECT DISTINCT contract, MIN(transaction_date) min_payment_date, SUM(`payment_duration`) payment_count,
SUM(`charged_amount`) total_charged_amount, MAX(activation_end) max_activation_end
FROM `daily_transactions`
WHERE `report_date` = '2023-03-01'
GROUP BY contract
);

SELECT *
FROM `daily_transactions`
WHERE `report_date` = '2022-12-01'
AND contract = 'a0D6700001EBsoSEAT'

SELECT * FROM Min_Date_Nov22
WHERE contract = 'a0D6700001EBsoSEAT'


SELECT SUM(total_charged_amount) FROM Min_Date_Nov22


CREATE TABLE first_payment_feb23
AS
SELECT `report_date`,a.contract,`contract_num`,`sps_id`,`transaction_date`,`charged_amount`,`tenant_name`,`entry_type`,
`charging_event_type`,`payment_type`,`provider_transaction_id`,`generation`,`payment_time_units`,`payer_id`,`offer_id`,
`seq_num_in_offer`,`product_description`,`payment_duration`,`payment_start_time`,`payment_end_time`,`activation_start`,`activation_end`,
`contract_creation_date`,`weekday`,`repayment_status`,`min_payment_date`,`payment_count`,`total_charged_amount`,`max_activation_end`
FROM (
(SELECT * FROM `daily_transactions`
WHERE `report_date` = '2023-03-01') a
INNER JOIN
(SELECT * FROM `Min_Date_Feb23`) b
ON a.transaction_date = b.min_payment_date
AND a.contract = b.contract
      );



/*IF(previous_paidperiod = paidperiod, 0 IF(AND(previous_paidperiod > prev_exp_paidperiod,paidperiod > previous_paidperiod),paidperiod - previous_paidperiod, paidperiod - expected_paidperiod)) Current_Advance
FROM(*/



##### LCP REPAYMENT INCENTIVE AUTOMATED SCRIPTING....RESULT FOR OLD REPAYMENT STRUCTURE transitioning into NEW REPAYMENT STRUCTURE 
/*SELECT *,
prev_collection_curr_month+Overdue_Payment+curr_month_collection Total_Incentive_Collection,
Cur_Advance_Count*monthly_repayment_amount Current_for_Advance,
CASE WHEN actual_collection = 'Ontime' THEN 'Ontime'
	WHEN actual_collection BETWEEN 1 AND 5 THEN '1-5 Days'
	  WHEN actual_collection > 5 THEN '>5 Days' END actual_collection_status
FROM (
SELECT *, CASE WHEN paidperiod > expected_paidperiod THEN advanced_status*monthly_repayment_amount 
	  ELSE 0 END Total_Advance,
	  CASE WHEN prev_exp_pp > previous_paidperiod AND expected_paidperiod > paidperiod THEN 0 ELSE
	  CASE 
	    WHEN previous_paidperiod = paidperiod THEN 0 ELSE CASE
							WHEN previous_paidperiod > prev_exp_pp AND paidperiod > previous_paidperiod
							THEN paidperiod - previous_paidperiod ELSE paidperiod - expected_paidperiod
							END
	    END
	  END Cur_Advance_Count,
	CASE WHEN Payment_Status = 'Yes' AND `payment_count` > 0 THEN monthly_repayment_amount ELSE 0 END curr_month_collection,
	CASE WHEN previous_paidperiod >= expected_paidperiod THEN monthly_repayment_amount ELSE 0 END prev_collection_curr_month,
	CASE WHEN prev_exp_pp > previous_paidperiod AND paidperiod >= expected_paidperiod
		THEN (prev_exp_pp - previous_paidperiod)*monthly_repayment_amount ELSE 
		CASE WHEN prev_exp_pp > previous_paidperiod AND paidperiod < expected_paidperiod THEN payment_count*monthly_repayment_amount
		ELSE 0
		END
	END Overdue_Payment,
	ABS(CASE WHEN current_payment_status = 'Ontime Repayment' THEN 'Ontime' 
	ELSE TIMESTAMPDIFF(DAY, last_anniversary_date, payment_date) END) actual_collection
FROM(	  
SELECT `community`, lcp_name, a.contract, customer_name, contract_id, system_id sps_id, full_initial_payment, initial_rate_plan, device_type,
ltoperiod, entry_date, prev_exp_pp, expected_paidperiod, previous_paidperiod, paidperiod, Last_Anniversary_Date,
IFNULL(`min_payment_date`,`last_payment_date`) payment_date,
CASE WHEN device_type = 'PRIME' AND ltoperiod = 24 THEN 12500
WHEN device_type = 'ECO' AND ltoperiod = 24 THEN 9500
WHEN device_type = 'PRIME' AND ltoperiod = 12 THEN 16750
WHEN device_type = 'ECO' AND ltoperiod = 12 THEN 12000 END monthly_repayment_amount,
IFNULL(`max_activation_end`,`next_payment_date`) Next_Payment_Date,
CASE WHEN paidperiod >= expected_paidperiod THEN 'Yes' ELSE 'No' END Payment_Status,
CASE WHEN paidperiod >= expected_paidperiod AND min_payment_date <= last_anniversary_date THEN 'Ontime Repayment'
	WHEN paidperiod >= expected_paidperiod AND min_payment_date > last_anniversary_date THEN 'Delayed Repayment'
	WHEN paidperiod >= expected_paidperiod AND prev_payment_date < next_payment_date THEN 'Ontime Repayment'
	WHEN paidperiod < expected_paidperiod AND next_payment_date <= '2022-06-30' THEN 'Defaulter'
	WHEN paidperiod < expected_paidperiod AND next_payment_date > '2022-06-30' THEN 'Revised Anniversary'
	ELSE 'Not Yet Considered' END current_payment_status,`payment_count`,`total_charged_amount`,
paidperiod - expected_paidperiod advanced_status, expected_paidperiod - paidperiod owed_period
FROM (
(
SELECT *, expected_paidperiod - 1 prev_exp_pp
FROM(
SELECT DISTINCT contract, `community`, lcp_name, customer_name, contract_id, system_id, full_initial_payment, initial_rate_plan, 
CASE WHEN SUBSTR(product_name, 1,5) = 'PRIME' THEN 'PRIME' ELSE 'ECO' END device_type,
created_date entry_date, DAY(created_date) created_day, CASE WHEN DAY(created_date) = 31 THEN (TIMESTAMPDIFF(MONTH, created_date, '2022-06-30'))+2
							ELSE (TIMESTAMPDIFF(MONTH, created_date, '2022-06-30'))+1 END expected_paidperiod
FROM `lcp_base`
WHERE product_name NOT LIKE '%Outright%'
AND created_date <= '2022-05-31') a
) a

LEFT OUTER JOIN

(SELECT contract, `paidperiod` previous_paidperiod, last_payment_date prev_payment_date, ref_activation_end last_anniversary_date
FROM `activity_log`
WHERE `month_date` = 'May-22') b
ON a.contract = b.contract

LEFT OUTER JOIN

(SELECT `contract`,`ltoperiod`,`paidperiod`,`last_payment_date`,`ref_activation_end` next_payment_date
FROM `activity_log`
WHERE `month_date` = 'Jun-22') c
ON a.contract = c.contract

LEFT OUTER JOIN

(SELECT `contract`,`payment_count`, DATE(`min_payment_date`)`min_payment_date`,`total_charged_amount`,`max_activation_end`
FROM `min_date_jun22`) d
ON a.contract = d.contract
     )
 ) e
) f*/



DROP TABLE lcp_incentive_table1;

#### THIS ORIGINATES FROM THE OLD MODEL. IT CREATES THE INITIAL TABLE TO BE USED IN CALCULATING JUN'22 REVENUE & INCENTIVE
CREATE TABLE lcp_incentive_table1
AS
(SELECT *,
prev_collection_curr_month+Overdue_Payment+curr_month_collection Total_Incentive_Collection,
Cur_Advance_Count*monthly_repayment_amount Current_for_Advance,
CASE WHEN actual_collection = 0 THEN 'Ontime'
	 WHEN actual_collection BETWEEN 1 AND 5 THEN '1-5 Days' #and owed_period > 0
	   WHEN actual_collection > 5 THEN '>5 Days' END actual_collection_status
FROM (
SELECT *, CASE WHEN paidperiod > expected_paidperiod THEN advanced_status*monthly_repayment_amount 
	  ELSE 0 END Total_Advance,
	  CASE WHEN prev_exp_pp > previous_paidperiod AND expected_paidperiod > paidperiod THEN 0 ELSE
	  CASE 
	    WHEN previous_paidperiod = paidperiod THEN 0 ELSE CASE
							WHEN previous_paidperiod > prev_exp_pp AND paidperiod > previous_paidperiod
							THEN paidperiod - previous_paidperiod ELSE paidperiod - expected_paidperiod
							END
	    END
	  END Cur_Advance_Count,
	CASE WHEN Payment_Status = 'Yes' AND `payment_count` > 0 THEN monthly_repayment_amount ELSE 0 END curr_month_collection,
	CASE WHEN previous_paidperiod >= expected_paidperiod THEN monthly_repayment_amount ELSE 0 END prev_collection_curr_month,
	CASE WHEN prev_exp_pp > previous_paidperiod AND paidperiod >= expected_paidperiod
		THEN (prev_exp_pp - previous_paidperiod)*monthly_repayment_amount ELSE 
		CASE WHEN prev_exp_pp > previous_paidperiod AND paidperiod < expected_paidperiod THEN payment_count*monthly_repayment_amount
		ELSE 0
		END
	END Overdue_Payment,
	ABS(CASE WHEN current_payment_status = 'Ontime Repayment' THEN 0
		#when current_payment_status = 'Revised Anniversary' and month(payment_date) = (MONTH(CURDATE()- INTERVAL 1 MONTH)) and payment_date < last_anniversary_date THEN 0
	ELSE TIMESTAMPDIFF(DAY, last_anniversary_date, payment_date) END) actual_collection
FROM(	  
SELECT `community`, `current_tm`, `current_lcp`, a.contract, customer_name, contract_id, system_id sps_id, full_initial_payment, initial_rate_plan, device_type,
ltoperiod, entry_date, prev_exp_pp, expected_paidperiod, previous_paidperiod, paidperiod, Last_Anniversary_Date,
IFNULL(`min_payment_date`,`last_payment_date`) payment_date,
CASE WHEN device_type = 'PRIME' AND ltoperiod = 24 THEN 12500
WHEN device_type = 'PRIME' AND ltoperiod = 28 THEN 12500
WHEN device_type = 'ECO' AND ltoperiod = 24 THEN 9500
WHEN device_type = 'ECO' AND ltoperiod = 28 THEN 9000
WHEN device_type = 'PRIME' AND ltoperiod = 12 THEN 16750
WHEN device_type = 'ECO' AND ltoperiod = 12 THEN 12000 END monthly_repayment_amount,
IFNULL(`max_activation_end`,`next_payment_date`) Next_Payment_Date,
CASE WHEN paidperiod >= expected_paidperiod THEN 'Yes' ELSE 'No' END Payment_Status,
CASE WHEN paidperiod >= expected_paidperiod AND min_payment_date <= last_anniversary_date THEN 'Ontime Repayment'
	WHEN paidperiod >= expected_paidperiod AND min_payment_date > last_anniversary_date THEN 'Delayed Repayment'
	WHEN paidperiod >= expected_paidperiod AND prev_payment_date < next_payment_date THEN 'Ontime Repayment'
	WHEN paidperiod < expected_paidperiod AND next_payment_date <= '2023-02-28' THEN 'Defaulter'
	WHEN paidperiod < expected_paidperiod AND next_payment_date > '2023-02-28' THEN 'Revised Anniversary'
	ELSE 'Not Yet Considered' END current_payment_status,`payment_count`,`total_charged_amount`,
paidperiod - expected_paidperiod advanced_status, expected_paidperiod - paidperiod owed_period
FROM (
(
SELECT *, expected_paidperiod - 1 prev_exp_pp
FROM(
SELECT DISTINCT contract, `community`, `current_tm`, `current_lcp`, customer_name, contract_id, system_id, full_initial_payment, initial_rate_plan, 
CASE WHEN SUBSTR(product_name, 1,5) = 'PRIME' THEN 'PRIME' ELSE 'ECO' END device_type,
created_date entry_date, DAY(created_date) created_day, CASE WHEN DAY(created_date) >= 29 THEN (TIMESTAMPDIFF(MONTH, created_date, '2023-02-28'))+2
							ELSE (TIMESTAMPDIFF(MONTH, created_date, '2023-02-28'))+1 END expected_paidperiod
FROM `lcp_base_use`
WHERE product_name NOT LIKE '%Outright%'
AND created_date <= '2023-01-31') a
) a

LEFT OUTER JOIN

(SELECT contract, `paidperiod` previous_paidperiod, last_payment_date prev_payment_date, ref_activation_end last_anniversary_date
FROM `activity_log`
WHERE `month_date` = 'Jan-23') b
ON a.contract = b.contract

LEFT OUTER JOIN

(SELECT `contract`,`ltoperiod`,`paidperiod`,`last_payment_date`,`ref_activation_end` next_payment_date
FROM `activity_log`
WHERE `month_date` = 'Feb-23') c
ON a.contract = c.contract

LEFT OUTER JOIN

(SELECT `contract`,`payment_count`, DATE(`min_payment_date`)`min_payment_date`,`total_charged_amount`,`max_activation_end`
FROM `Min_Date_Feb23`) d
ON a.contract = d.contract
     )
 ) e
) f
);


TRUNCATE TABLE defaulters_check;

/*SELECT * FROM `defaulters_check`
limit 50*/


####### Create the Defaulters Table using excel download as at 5th of the new month (Goto the Contracts Per Paidperiod Sheet, Goto Transaction MTD Page, Sort with the Created Date Column in asc order, do an Xlookup with the contracts per Paidperiod Sheet, Upload on the DB) 

#### THIS CREATES A TABLE WHICH CAPTURES PAYMENT STATUS FROM WITHIN 1st - 5th OF THE NEXT MONTH TO CHECK FOR UPDATED PAYMENT STATUS OF DEFAULTERS
/*CREATE TABLE defaulters_check
AS 
(
SELECT `contract`,`paidperiod`,`last_payment_date` `payment_date`
FROM `activity`
WHERE 0=1
);*/


#### TABLE IS LOADED

SELECT COUNT(1) FROM defaulters_check;

SELECT * FROM defaulters_check
LIMIT 50;

DROP TABLE `lcp_incentive_table2`;


/*update `defaulters_check`
set `payment_date` = null
where `payment_date` = 0000-00-00*/


#### HERE, TABLE1 IS JOINED WITH defaulters_check TABLE
CREATE TABLE `lcp_incentive_table2`
AS(
SELECT a.*, paidperiod_mar23, payment_date_mar23
FROM (
(SELECT * FROM `lcp_incentive_table1`) a

LEFT OUTER JOIN

(SELECT `contract`, `paidperiod` paidperiod_mar23, payment_date payment_date_mar23
FROM `defaulters_check`) b

ON a.`contract` = b.`contract`
      )
  )
 
#Select * from `lcp_incentive_table2`
  
#### THIS IS THE LAST PART,
/*SELECT *, CASE WHEN current_payment_status = 'Revised Anniversary' AND payment_count IS NULL AND payment_date_jan23 IS NOT NULL
		AND TIMESTAMPDIFF(DAY, Next_Payment_Date, payment_date_jan23) <= 5 THEN '1-5 Days'
		ELSE final_collection_status END final_collection_statusii
FROM (
SELECT *, CASE
	      WHEN current_payment_status != 'Defaulter' THEN actual_collection_status
		ELSE
		   (CASE 
		     WHEN current_payment_status = 'Defaulter' AND payment_date_jan23 > paidperiod 
		     AND TIMESTAMPDIFF(DAY, last_anniversary_date, payment_date_jan23) <= 5 THEN '1-5 Days'
		     ELSE actual_collection_status
		   END)
	  END final_collection_status
FROM `lcp_incentive_table2`
	) b
;*/


#..........### Creates the Transfer Table
/*Create table transfers
as
Select `contract`, `crmcontract` contract_id, `last_payment_date`, `last_payment_date` retrieval_date
from `activity`
where 0 = 1


TRUNCATE TABLE `transfers`;
*/

DROP TABLE ag_ageing;

##### This is for AG Ageing Rates & New Report
CREATE TABLE ag_ageing AS

(WITH CTE
AS
(SELECT *, CASE 
		WHEN `current_payment_status` = 'Defaulter' AND `paidperiod_mar23` < `expected_paidperiod` THEN '>5 Days Unpaid'
ELSE final_collection_statusii END final_collection_statusiii, 
	  CASE
		WHEN paidperiod_mar23 >= `ltoperiod` THEN 'Owner'
ELSE 'LTO' END own_status
FROM (
SELECT *, CASE WHEN current_payment_status = 'Revised Anniversary' AND payment_count IS NULL AND payment_date_mar23 IS NOT NULL
		AND TIMESTAMPDIFF(DAY, Next_Payment_Date, payment_date_mar23) <= 5 THEN '1-5 Days'
		ELSE final_collection_status END final_collection_statusii
FROM (
SELECT *, CASE
	      WHEN current_payment_status != 'Defaulter' THEN actual_collection_status
		ELSE
		   (CASE 
		     WHEN current_payment_status = 'Defaulter' AND payment_date_mar23 > paidperiod 
		     AND TIMESTAMPDIFF(DAY, last_anniversary_date, payment_date_mar23) <= 5 THEN '1-5 Days'
		     ELSE actual_collection_status
		   END)
	  END final_collection_status
FROM `lcp_incentive_table2`
	) b
     ) c
)


SELECT a.*, CASE
		WHEN a.`contract` = b.`contract` THEN 1 ELSE 0 END transfer_check, b.`last_payment_date` transfer_last_payment, `retrieval_date`
FROM (
(SELECT * FROM CTE) a

LEFT OUTER JOIN

(SELECT * FROM `transfers`) b
ON a.`contract` = b.`contract`
) 
 );
 

##### This is for AG Ageing Rates & New Report.... To spool out the report
SELECT DATE_FORMAT(`entry_date`, "%b-%y") AS Service_Joined_Month, COUNT(DISTINCT `contract`) Original_Count,
AVG(`expected_paidperiod`) Monthly_Payment_Due,
COUNT(CASE WHEN `paidperiod_mar23` >= `ltoperiod` THEN `contract` END) Owners,
COUNT(CASE WHEN `paidperiod_mar23` < `ltoperiod` THEN `contract` END) Current_Count,
COUNT(CASE WHEN `paidperiod_mar23` >= `expected_paidperiod` AND own_status = 'LTO' AND transfer_check = 0 THEN `contract` END)
+
COUNT(CASE WHEN `paidperiod_mar23` < `expected_paidperiod` AND own_status = 'LTO' AND final_collection_statusiii != '>5 Days Unpaid' THEN `contract` END) Current_Paid,
SUM(CASE WHEN own_status = 'Owner' THEN `ltoperiod` ELSE `expected_paidperiod` END) Target_Current_Paid_Months,
SUM(CASE WHEN own_status = 'Owner' THEN `ltoperiod` ELSE CASE WHEN `paidperiod_mar23` > `expected_paidperiod` THEN `expected_paidperiod` ELSE `paidperiod_mar23` END END) Actual_Current_Paid_Months,
SUM(CASE WHEN transfer_check = 0 AND own_status = 'LTO' AND `current_payment_status` = 'Revised Anniversary' THEN `expected_paidperiod`-`paidperiod_mar23` END) Delayed_Payment_Months,
SUM(CASE WHEN transfer_check = 0 AND final_collection_statusiii = '>5 Days Unpaid' AND own_status = 'LTO' THEN `expected_paidperiod`-`paidperiod_mar23` ELSE 
CASE WHEN transfer_check = 1 THEN `expected_paidperiod`-`paidperiod_mar23` END END) Unpaid_Months
FROM `ag_ageing`
GROUP BY `entry_date`;



#### This is for the monthly repayment incentive.
SELECT `community`, `current_tm`, `current_lcp`, `contract`, `customer_name`, `contract_id`, `sps_id`, `full_initial_payment`, `initial_rate_plan`, `device_type`, `ltoperiod`, `entry_date`,
`prev_exp_pp`, `expected_paidperiod`, `previous_paidperiod`, `paidperiod`, `last_anniversary_date`, `payment_date`, `monthly_repayment_amount`, `Next_Payment_Date`, `Payment_Status`,
`current_payment_status`, `payment_count`, `total_charged_amount`, `advanced_status`, `owed_period`, `Total_Advance`, `Cur_Advance_Count`, `curr_month_collection`, `prev_collection_curr_month`,
`Overdue_Payment`, `actual_collection`, `Total_Incentive_Collection`, `Current_for_Advance`, `actual_collection_status`, `payment_date_mar23`, `paidperiod_mar23`, `final_collection_status`,
CASE WHEN `final_collection_statusiii` = '>5 Days Unpaid' AND `total_charged_amount` > 0 THEN '>5 Days Paid' ELSE `final_collection_statusiii` END AS `final_collection_statusiii` 
FROM `ag_ageing`;


##### This is for Owners Report and Overtime Payment
SELECT DATE_FORMAT(`entry_date`, "%b-%y") AS Service_Joined_Month, SUM(Owners_Count) Owners_Count, SUM(Target_Owner_Payment_Months) Target_Owner_Payment_Months, SUM(Actual_Owner_Payment_Months) Actual_Owner_Payment_Months
FROM (
SELECT `entry_date`, COUNT(CASE WHEN `own_status` = 'Owner' THEN `contract` END) Owners_Count,
SUM(CASE WHEN own_status = 'Owner' THEN `ltoperiod` END) Target_Owner_Payment_Months,
SUM(CASE WHEN own_status = 'Owner' AND DAY(`entry_date`) >= 29 THEN TIMESTAMPDIFF(MONTH, `entry_date`, COALESCE(`payment_date_mar23`,`payment_date`))+2
ELSE TIMESTAMPDIFF(MONTH, `entry_date`, COALESCE(`payment_date_mar23`,`payment_date`))+1 END) Actual_Owner_Payment_Months
FROM `ag_ageing`
WHERE own_status = 'Owner'
AND `entry_date` <= '2022-02-28'
GROUP BY `entry_date`
	) a
GROUP BY Service_Joined_Month;



SELECT `entry_date`, COALESCE(`payment_date_mar23`,`payment_date`), TIMESTAMPDIFF(MONTH, `entry_date`, COALESCE(`payment_date_mar23`,`payment_date`))
FROM `ag_ageing`
WHERE own_status = 'Owner'
LIMIT 10


SELECT CASE WHEN DAY(created_date) >= 29 THEN (TIMESTAMPDIFF(MONTH, created_date, '2023-02-28'))+2
ELSE (TIMESTAMPDIFF(MONTH, created_date, '2023-02-28'))+1 END expected_paidperiod
  
  
  
  #------------31 month script-----------------
  ##### This is for AG Ageing Rates & New Report.... To spool out the report

SELECT DATE_FORMAT(`entry_date`, "%b-%y") AS Service_Joined_Month, COUNT(DISTINCT `contract`) Original_Count,

AVG(`expected_paidperiod`) Monthly_Payment_Due,

COUNT(CASE WHEN `paidperiod_apr23` >= `ltoperiod` THEN `contract` END) Owners,

COUNT(CASE WHEN `paidperiod_apr23` < `ltoperiod` THEN `contract` END) Current_Count,

COUNT(CASE WHEN `paidperiod_apr23` >= `expected_paidperiod` AND own_status = 'LTO' AND transfer_check = 0 THEN `contract` END)

+

COUNT(CASE WHEN `paidperiod_apr23` < `expected_paidperiod` AND own_status = 'LTO' AND final_collection_statusiii != '>5 Days Unpaid' THEN `contract` END) Current_Paid,

SUM(CASE WHEN own_status = 'Owner' THEN `ltoperiod` ELSE `expected_paidperiod` END) Target_Current_Paid_Months,

SUM(CASE WHEN own_status = 'Owner' THEN `ltoperiod` ELSE CASE WHEN `paidperiod_apr23` > `expected_paidperiod` THEN `expected_paidperiod` ELSE `paidperiod_apr23` END END) Actual_Current_Paid_Months,

SUM(CASE WHEN transfer_check = 0 AND own_status = 'LTO' AND `current_payment_status` = 'Revised Anniversary' THEN `expected_paidperiod`-`paidperiod_apr23` END) Delayed_Payment_Months,

SUM(CASE WHEN transfer_check = 0 AND final_collection_statusiii = '>5 Days Unpaid' AND own_status = 'LTO' THEN `expected_paidperiod`-`paidperiod_apr23` ELSE

CASE WHEN transfer_check = 1 THEN `expected_paidperiod`-`paidperiod_apr23` END END) Unpaid_Months

FROM `ag_ageing`

GROUP BY `entry_date`;

 

 

 

#### This is for the monthly repayment incentive.

/*SELECT `community`, `current_tm`, `current_lcp`, `contract`, `customer_name`, `contract_id`, `sps_id`, `full_initial_payment`, `initial_rate_plan`, `device_type`, `ltoperiod`, `entry_date`,

`prev_exp_pp`, `expected_paidperiod`, `previous_paidperiod`, `paidperiod`, `last_anniversary_date`, `payment_date`, `monthly_repayment_amount`, `Next_Payment_Date`, `Payment_Status`,

`current_payment_status`, `payment_count`, `total_charged_amount`, `advanced_status`, `owed_period`, `Total_Advance`, `Cur_Advance_Count`, `curr_month_collection`, `prev_collection_curr_month`,

`Overdue_Payment`, `actual_collection`, `Total_Incentive_Collection`, `Current_for_Advance`, `actual_collection_status`, `payment_date_mar23`, `paidperiod_mar23`, `final_collection_status`,

CASE WHEN `final_collection_statusiii` = '>5 Days Unpaid' AND `total_charged_amount` > 0 THEN '>5 Days Paid' ELSE `final_collection_statusiii` END AS `final_collection_statusiii`

FROM `ag_ageing`;*/

 

 

##### This is for Owners Report and Overtime Payment

SELECT DATE_FORMAT(`entry_date`, "%b-%y") AS Service_Joined_Month, SUM(Owners_Count) Owners_Count, SUM(Target_Owner_Payment_Months) Target_Owner_Payment_Months, SUM(Actual_Owner_Payment_Months) Actual_Owner_Payment_Months

FROM (

SELECT `entry_date`, COUNT(CASE WHEN `own_status` = 'Owner' THEN `contract` END) Owners_Count,

SUM(CASE WHEN own_status = 'Owner' THEN `ltoperiod` END) Target_Owner_Payment_Months,

SUM(CASE WHEN own_status = 'Owner' AND DAY(`entry_date`) = 31 THEN TIMESTAMPDIFF(MONTH, `entry_date`, COALESCE(`payment_date_apr23`,`payment_date`))+1

ELSE TIMESTAMPDIFF(MONTH, `entry_date`, COALESCE(`payment_date_apr23`,`payment_date`))+1 END) Actual_Owner_Payment_Months

FROM `ag_ageing`

WHERE own_status = 'Owner'

AND `entry_date` <= '2022-03-31'

GROUP BY `entry_date`

              ) a

GROUP BY Service_Joined_Month;

