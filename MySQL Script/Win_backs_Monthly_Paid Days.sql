
#.............Old Definition_Win_back_Monthly_paid_days............................................#
SELECT lcp_status,generation,
COUNT(CASE WHEN payment_duration >= 30 THEN contract END) '≥_30_days',
COUNT(CASE WHEN payment_duration BETWEEN 20 AND 29 THEN contract END) '20–29_days',
COUNT(CASE WHEN payment_duration BETWEEN 10 AND 19 THEN contract END) '10–19_days',
COUNT(CASE WHEN payment_duration BETWEEN 5 AND 9 THEN contract END) '5–9_days',
COUNT(CASE WHEN payment_duration BETWEEN 1 AND 4 THEN contract END) '1–4_days',
COUNT(CASE WHEN payment_duration IS NULL THEN contract END) 'No_payment'
FROM
(
SELECT contract,lcp_status,`type`,generation,
CASE
WHEN P_Status = 'Owner' AND L_Status = 'Owner' THEN 'Owner_to_Owner'
WHEN P_Status = 'Active' AND L_Status = 'Active' THEN 'Active_to_Active'
WHEN P_Status = 'Churn' AND L_Status = 'Churn' THEN 'Churn_to_Churn'
WHEN P_Status = 'Cancelled' AND L_Status = 'Cancelled' THEN 'Cancelled_to_Cancelled'
WHEN P_Status = 'Owner' AND L_Status = 'Active' THEN 'Owner_to_Active'
WHEN P_Status = 'Active' AND L_Status = 'Owner' THEN 'Active_to_Owner'
WHEN P_Status = 'Churn' AND L_Status = 'Cancelled' THEN 'Churn_to_Cancelled'
WHEN P_Status = 'Cancelled' AND L_Status = 'Churn' THEN 'Cancelled_to_Churn'
WHEN P_Status = 'Active' AND L_Status = 'Cancelled' THEN 'Active_to_Inactive'
WHEN P_Status = 'Active' AND L_Status = 'Churn' THEN 'Active_to_Inactive'
WHEN P_Status = 'Owner' AND L_Status = 'Cancelled' THEN 'Active_to_Inactive'
WHEN P_Status = 'Owner' AND L_Status = 'Churn' THEN 'Active_to_Inactive'
ELSE 'Inactive_to_Active'
END Status_Movement, 
CASE WHEN generation = 'UNIFIED' THEN (payment_duration*30) ELSE payment_duration END 'payment_duration' 
FROM
(
SELECT a.contract,a.lcp_status,a.type,a.generation,a.old_active_status P_Status,b.old_active_status L_Status,SUM(c.payment_duration)payment_duration 
FROM (SELECT * FROM activity_log WHERE `month_date` = 'Jun-22') a
LEFT OUTER JOIN activity b
ON a.contract = b.contract
LEFT OUTER JOIN (SELECT * FROM`daily_transactions` WHERE `report_date` = '2022-08-01') c
ON a.contract = c.contract
GROUP BY contract,lcp_status,`type`,generation,P_Status,L_Status
)d 
)e WHERE Status_Movement = 'Inactive_to_Active'
GROUP BY lcp_status,generation




#.............New Definition Win_back_Monthly_paid_days...........................................#
SELECT lcp_status, generation,
COUNT(CASE WHEN payment_duration >= 30 THEN contract END) '≥_30_days',
COUNT(CASE WHEN payment_duration BETWEEN 20 AND 29 THEN contract END) '20–29_days',
COUNT(CASE WHEN payment_duration BETWEEN 10 AND 19 THEN contract END) '10–19_days',
COUNT(CASE WHEN payment_duration BETWEEN 5 AND 9 THEN contract END) '5–9_days',
COUNT(CASE WHEN payment_duration BETWEEN 1 AND 4 THEN contract END) '1–4_days',
COUNT(CASE WHEN payment_duration IS NULL OR payment_duration = 0 THEN contract END) 'No_payment'
FROM
(
SELECT contract,lcp_status,`type`,generation,
CASE
WHEN P_New_Status = 'Owner' AND L_New_Status = 'Owner' THEN 'Owner_to_Owner'
WHEN P_New_Status = 'paid' AND L_New_Status = 'paid' THEN 'paid_to_paid'
WHEN P_New_Status = 'Recovery' AND L_New_Status = 'Recovery' THEN 'Recovery_to_Recovery'
WHEN P_New_Status = 'Retrieval' AND L_New_Status = 'Retrieval' THEN 'Retrieval_to_Retrieval'
WHEN P_New_Status = 'Cancelled' AND L_New_Status = 'Cancelled' THEN 'Cancelled_to_Cancelled'
WHEN P_New_Status = 'Owner' AND L_New_Status = 'paid' THEN 'Owner_to_paid'
WHEN P_New_Status = 'paid' AND L_New_Status = 'Owner' THEN 'paid_to_Owner'
WHEN P_New_Status = 'Retrieval' AND L_New_Status = 'Recovery' THEN 'Retrieval_to_Recovery'
WHEN P_New_Status = 'Recovery' AND L_New_Status = 'Retrieval' THEN 'Recovery_to_Retrieval'
WHEN P_New_Status = 'Recovery' AND L_New_Status = 'Cancelled' THEN 'Recovery_to_Cancelled'
WHEN P_New_Status = 'Retrieval' AND L_New_Status = 'Cancelled' THEN 'Retrieval_to_Cancelled'
WHEN P_New_Status = 'Cancelled' AND L_New_Status = 'Recovery' THEN 'Cancelled_to_Recovery'
WHEN P_New_Status = 'Cancelled' AND L_New_Status = 'Retrieval' THEN 'Cancelled_to_Retrieval'
WHEN P_New_Status = 'paid' AND L_New_Status = 'Retrieval' THEN 'paid_to_Retrieval'
WHEN P_New_Status = 'paid' AND L_New_Status = 'Cancelled' THEN 'paid_to_Cancelled'
WHEN P_New_Status = 'Recovery' AND L_New_Status = 'paid' THEN 'Recovery_to_paid'
WHEN P_New_Status = 'Recovery' AND L_New_Status = 'Owner' THEN 'Recovery_to_Owner'
WHEN P_New_Status = 'Retrieval' AND L_New_Status = 'paid' THEN 'Retrieval_to_paid'
WHEN P_New_Status = 'Retrieval' AND L_New_Status = 'Owner' THEN 'Retrieval_to_Owner'
WHEN P_New_Status = 'Owner' AND L_New_Status = 'Recovery' THEN 'Owner_to_Recovery'
WHEN P_New_Status = 'Owner' AND L_New_Status = 'Cancelled' THEN 'Owner_to_Cancelled'
WHEN P_New_Status = 'Owner' AND L_New_Status = 'Retrieval' THEN 'Owner_to_Retrieval'
ELSE 'Inactive_to_Active'
END Status_Movement,
CASE WHEN generation = 'UNIFIED' THEN (payment_duration*30) ELSE payment_duration END 'payment_duration' 
FROM
(
SELECT a.contract,a.lcp_status,a.type,a.`customer_status` P_New_Status,b.`customer_status` L_New_Status,
c.contract_id,c.generation,SUM(d.payment_duration)payment_duration 
FROM (SELECT * FROM activity_log WHERE `month_date` = 'Mar-23') a
LEFT OUTER JOIN activity b
ON a.contract = b.contract
LEFT OUTER JOIN customer_big_table c
ON a.contract = c.full_sfid
LEFT OUTER JOIN `daily_transactions_curr_MTD` d
ON a.contract = d.contract
GROUP BY contract, lcp_status,`type`,contract_id, generation, P_New_Status, L_New_Status
)e
)f 
WHERE Status_Movement ='Retrieval_to_paid' OR Status_Movement = 'Retrieval_to_Owner'
GROUP BY lcp_status,generation


`daily_transactions` WHERE `report_date` = '2022-08-01'
`daily_transactions_curr_MTD` d