#------------------------Net Churn Rate for Old Customer Status----------------------------------#
SELECT lcp_status, AIB_P_Month,Active_to_Owner,Gross_Churn,Win_Back,(Gross_Churn-Win_Back) Net_Churn,
(((Gross_Churn-Win_Back)/AIB_P_Month)*100) Net_Churn_Rate
FROM
(
SELECT lcp_status,
COUNT(CASE WHEN P_Status = 'Active' THEN contract END) 'AIB_P_Month',
COUNT(CASE WHEN Status_Movement = 'Active_to_Owner' THEN contract END) 'Active_to_Owner',
COUNT(CASE WHEN Status_Movement = 'Active_to_Inactive' THEN contract END) 'Gross_Churn',
COUNT(CASE WHEN Status_Movement = 'Inactive_to_Active' THEN contract END) 'Win_Back'
FROM
(
SELECT contract,lcp_status,`type`,P_Status,L_Status, 
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
END Status_Movement
FROM
(
SELECT a.contract,a.lcp_status,a.type,a.old_active_status P_Status,b.old_active_status L_Status
FROM (SELECT * FROM activity_log WHERE `month_date` = 'Nov-22') a
LEFT OUTER JOIN activity b
ON a.contract = b.contract
)c
)d
GROUP BY lcp_status
)e
GROUP BY lcp_status

#activity 
#-----------------Active New Sales------------------------------------------#

SELECT lcp_status,old_active_status,COUNT(contract)Counts
FROM `activity`
WHERE contract_creation > (CURDATE() - INTERVAL 29 DAY) AND old_active_status IN ('Active','Owner')
GROUP BY lcp_status,old_active_status


SELECT lcp_status, old_active_status,COUNT(contract)Counts 
FROM activity
#WHERE `month_date` = 'May-22'
GROUP BY lcp_status,old_active_status


#---------------Net Churn Rate for New Customer Status----------------------------------#

	SELECT lcp_status,(Paid_P_Month + Recovery_P_Month) Paid_Recovery_P_Month, paid_to_Owner, Recovery_to_Owner, Churn,Win_back,(Churn - Win_back) Net_Churn, 
	(((Churn - Win_back)/(Paid_P_Month + Recovery_P_Month))*100) Net_Churn_Rate 
	FROM
	(
	SELECT lcp_status,
	COUNT(CASE WHEN P_New_Status = 'paid' THEN contract END) 'Paid_P_Month',
	COUNT(CASE WHEN P_New_Status = 'Recovery' THEN contract END) 'Recovery_P_Month',
	COUNT(CASE WHEN Status_Movement = 'paid_to_Owner' THEN contract END) 'paid_to_Owner',
	COUNT(CASE WHEN Status_Movement = 'Recovery_to_Owner' THEN contract END) 'Recovery_to_Owner',
	COUNT(CASE WHEN Status_Movement = 'Recovery_to_Retrieval' THEN contract END) 'Churn',
	COUNT(CASE WHEN Status_Movement = 'Retrieval_to_paid' 
	OR Status_Movement = 'Retrieval_to_Owner' THEN contract END) 'Win_back'
	FROM
	(
	SELECT contract,lcp_status,`type`,P_New_Status,
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
	END Status_Movement
	FROM
	(
	SELECT a.contract,a.lcp_status,a.type,a.customer_status P_New_Status,b.customer_status L_New_Status
	FROM (SELECT * FROM activity_log WHERE `month_date` = 'Apr-23') a
	LEFT OUTER JOIN activity b
	ON a.contract = b.contract
	)c
	)d
	GROUP BY lcp_status
	)e
	GROUP BY lcp_status


#GROUP BY Paid_Apr22, paid_to_Owner, Recovery_to_Owner, Churn,Win_back

#GROUP BY lcp_status,lcp_status

SELECT (CURDATE() - INTERVAL CURDATE() DAY)

SELECT INTERVAL CURDATE() DAY