
SELECT a.contract, system_id, contract_id, created_date, product_name, TSM, lcp_name, customer_name, billing_street, community,
local_government, billing_state, Expected_PaidPeriod, Current_PaidPeriod, prev_activation_end, current_activation_end, prev_payment_date,
Actual_Repayment_Date, Recent_Payment_Duration, Monthly_Sum_Payment,
CASE WHEN Current_PaidPeriod >= Expected_PaidPeriod AND Actual_Repayment_Date <= prev_activation_end THEN 'Ontime Repayment'
              WHEN Current_PaidPeriod >= Expected_PaidPeriod AND Actual_Repayment_Date > prev_activation_end THEN 'Delayed Repayment'
              WHEN Current_PaidPeriod >= Expected_PaidPeriod AND prev_payment_date < current_activation_end THEN 'Ontime Repayment'
              WHEN Current_PaidPeriod < Expected_PaidPeriod AND current_activation_end >= CURDATE() THEN 'Revised Anniversary'
              WHEN Current_PaidPeriod < Expected_PaidPeriod THEN 'Defaulter' 
              ELSE 'Not Yet Considered' END Repayment_Status
FROM (
(SELECT contract, system_id, contract_id, created_date, product_name, TSM, lcp_name, customer_name,  billing_street, community, local_government, billing_state, FLOOR((DATEDIFF(CURDATE(), created_date)/30.4)+1) Expected_PaidPeriod
FROM lcp_base
WHERE created_date <= '2022-03-31'
AND product_name NOT LIKE '%Outright%'
AND DAY(created_date) <= 24
) a

LEFT OUTER JOIN

(SELECT contract, last_payment_date prev_payment_date, ref_activation_end prev_activation_end
FROM activity) b
ON a.contract = b.contract

LEFT OUTER JOIN

(SELECT contract, paidperiod Current_PaidPeriod, ref_activation_end current_activation_end,last_payment_date
FROM activity) c
ON a.contract = c.contract

LEFT OUTER JOIN

(SELECT contract, SUM(payment_duration) Recent_Payment_Duration, SUM(charged_amount) Monthly_Sum_Payment, MIN(DATE(transaction_date)) Actual_Repayment_Date
FROM daily_transactions_curr_MTD
GROUP BY contract) d
ON a.contract = d.contract
     )
