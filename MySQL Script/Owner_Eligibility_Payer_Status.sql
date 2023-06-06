
#--------------------------Owner_Eligiblity_Payer_Status------------------------------------------------#
SELECT lcp_status,
COUNT(CASE WHEN Owner_Payer_Status = 'OUTRIGHT' THEN contract END) 'OUTRIGHT',
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
WHEN ltoperiod = '28' AND last_payment_date > ADDDATE(created_date,INTERVAL 851 DAY) AND `type` != 'OUTRIGHT' THEN 'Late_Payer_to_Owner'
WHEN ltoperiod = '28' AND last_payment_date <= ADDDATE(created_date,INTERVAL 851 DAY) AND `type` != 'OUTRIGHT' THEN 'Early_Payer_to_Owner'
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
GROUP BY lcp_status