#-----------------------DPN-------------------------------------#

SELECT  contract_id, Contract, ReportDate, generation, `type`, ltoperiod, contract_creation,
paidperiod, old_active_status, dpn_date, sales_channel, IFNULL(initial_down_payment,0)initial_down_payment, 
contract_end_date, `Set-Up_without_VAT`, IFNULL(dpn_rate,0)dpn_rate, pos, IFNULL(dpn_amount,0) dpn_amount, point_of_sale,
rev_share,`year`, IFNULL(rev_share * dpn_amount,0) amount_after_rev_share
FROM 
(
SELECT  contract_id, Contract, ReportDate, generation, TYPE, ltoperiod, contract_creation,
paidperiod, old_active_status, dpn_date, sales_channel, initial_down_payment, 
contract_end_date, `Set-Up_without_VAT`, dpn_rate, pos, dpn_amount, point_of_sale,
CASE WHEN f.point_of_sale = 'store' AND contract_creation >= '2020-02-01' THEN 0.8
WHEN f.point_of_sale = 'store' AND contract_creation < '2020-02-01' THEN 0.91
ELSE 1 END rev_share, YEAR( contract_creation ) `year`
FROM 
(
SELECT contract_id, Contract, ReportDate, generation, TYPE, ltoperiod, contract_creation,
paidperiod, old_active_status, dpn_date, sales_channel, initial_down_payment, 
contract_end_date, `Set-Up_without_VAT`, dpn_rate, pos, dpn_rate * `Set-Up_without_VAT` dpn_amount,
CASE WHEN sales_channel = 'MTN_NG' THEN pos 
WHEN ltoperiod IN ('12','24','28') THEN 'LCP'
ELSE sales_channel END point_of_sale
FROM
(
SELECT c.contract_id, Contract,ReportDate, generation, `TYPE`, ltoperiod,
paidperiod, old_active_status, sales_channel, initial_down_payment, contract_creation, contract_end_date,dpn_date,`Set-Up_without_VAT`,
CASE 
WHEN dpn_rate >= 1 THEN 1
ELSE dpn_rate END dpn_rate, POS
FROM
(
SELECT a.Contract, a.ReportDate, a.sales_channel, a.generation, a.TYPE, a.ltoperiod, a.contract_creation, a.crmcontract,
a.paidperiod, a.old_active_status,a.dpn_date, b.contract_id, IFNULL(b.initial_down_payment,0) initial_down_payment, b.contract_end_date, 
CASE WHEN a.contract_creation >= '2020-02-01' THEN IFNULL((b.initial_down_payment/1.075),0)
ELSE IFNULL((b.initial_down_payment/1.05),0) END `Set-Up_without_VAT`,
CASE WHEN a.old_active_status IN ('Cancelled','Owner') THEN 1
ELSE ROUND(IFNULL(DATEDIFF(a.dpn_date,a.contract_creation),0)/(CASE WHEN `type` = 'RENTAL' THEN 48 * 30.4
WHEN a.generation = 'UNIFIED' THEN a.ltoperiod * 30.4 ELSE a.ltoperiod END),2) END AS `dpn_rate`
FROM 
(
SELECT Contract, ReportDate, sales_channel, generation, `type`, ltoperiod, contract_creation, crmcontract,
paidperiod, old_active_status,'2022-12-31' dpn_date
FROM `activity_log` 
WHERE `month_date` = 'Dec-22' AND TYPE <> 'Outright' 
)a
LEFT JOIN (
SELECT contract_id,sales_channel,initial_down_payment,warranty_end_date contract_end_date
FROM customer_big_table) b
ON a.crmcontract = b.contract_id
)c
LEFT OUTER JOIN
(SELECT contract_id, POS 
FROM mtn_pos_ii
) d
ON c.contract_id = d.contract_id
)e 
)f
)g

