SELECT community, `lcp_name`,
COUNT(DISTINCT CASE WHEN product_name NOT LIKE '%Outright%' AND created_date < '2022-10-01' THEN contract END) Total_LTOBase,
COUNT(DISTINCT CASE WHEN product_name LIKE '%Outright%' AND created_date < '2022-10-01' THEN contract END) Outright_Base,
COUNT(DISTINCT CASE WHEN created_date BETWEEN '2022-09-01' AND '2022-09-30' THEN contract END) Sep22_Acquisition
FROM `lcp_base`
GROUP BY community, `lcp_name`;


----------- Community Historical Summary ------------
/*SELECT community,
COUNT(DISTINCT CASE WHEN created_date BETWEEN '2022-09-01' AND '2022-09-30' THEN contract END) Acquisition,
COUNT(DISTINCT CASE WHEN product_name NOT LIKE '%Outright%' AND created_date BETWEEN '2022-09-01' AND '2022-09-30' THEN contract END) LTOBase
FROM `lcp_base`
GROUP BY community;*/



/*SELECT community, DATE_FORMAT(created_date, "%b-%y") Acq_Month,
COUNT(DISTINCT CASE WHEN product_name NOT LIKE '%Outright%' AND created_date < '2022-07-01' THEN contract END) Jun_LTOBase
FROM `lcp_base`
WHERE created_date < '2022-07-01'
AND community IN ('Kwale','Okpanam')
GROUP BY community, Acq_Month;*/




### Acquisition Analysis ###
SELECT CASE
              WHEN `product_name` LIKE '%12M NWO%' THEN '12M LTO'
              WHEN `product_name` LIKE '%28%' THEN '28M LTO'
              WHEN `product_name` LIKE '%24M NWO%' THEN '24M LTO'
              WHEN `product_name` LIKE '%Outright%' THEN 'Outright' END Tenure, COUNT(DISTINCT `contract`) Acq
FROM `lcp_base`
WHERE created_date BETWEEN '2023-02-01' AND '2023-02-28'
GROUP BY Tenure;

SELECT CASE
              WHEN `product_name` LIKE '%ECO%' THEN 'Eco'
              WHEN `product_name` LIKE '%PRIME%' THEN 'Prime' END Product_Type, COUNT(DISTINCT `contract`) Acq
FROM `lcp_base`
WHERE created_date BETWEEN '2023-02-01' AND '2023-02-28'
GROUP BY Product_Type;


SELECT * FROM `lcp_base`
WHERE created_date BETWEEN '2022-09-01' AND '2022-09-30'


#---------------------MTNTotal Sales Per Product Type-----------------------------------------#
SELECT a.`sales_channel`,`customer_status`,
CASE
              WHEN b.product_name LIKE '%ECO%' THEN 'Eco'
              WHEN b.product_name LIKE '%PRIME%' THEN 'Prime' END Product_Type,
              COUNT(a.contract)Overall_count
FROM
(
SELECT contract,`sales_channel`,`customer_status`
FROM `activity_log`
WHERE `month_date` = 'Feb-23' and `contract_creation` BETWEEN '2023-02-01' AND '2023-02-28'
)a
LEFT JOIN
`customer_big_table` b
ON a.contract = b.`full_sfid`
WHERE `price_book_name` != 'Direct-NG - (Re-manufactured Classic Employees 2)'
GROUP BY `sales_channel`,`customer_status`,Product_Type



#------------------Total Outright Sales Summary------------------------------------#
SELECT 
CASE
              WHEN b.product_name LIKE '%BULK' THEN 'Retail'
              WHEN b.product_name LIKE '%Upsell Promo BY Staff' THEN 'Staff Upsell Promo'
              WHEN b.product_name LIKE '%Upsell Promo' THEN 'Upsell Promo' 
              WHEN b.`price_book_name` = 'MTN-NG (New Prices)' THEN 'MTN Service Centers'
              WHEN b.`price_book_name` = 'Direct-NG - (Re-manufactured Classic Employees 2)' THEN 'Staff Remanufacture' END Channel_Type,
            
CASE
              WHEN b.product_name LIKE '%ECO%' THEN 'Eco'
              WHEN b.product_name LIKE '%PRIME%' THEN 'Prime' END Product_Type,
              COUNT(a.contract)Overall_count
FROM
(
SELECT contract,`crmcontract` ,`sales_channel`,`customer_status`
FROM `activity_log`
WHERE `month_date` = 'Feb-23' and `contract_creation` BETWEEN '2023-02-01' AND '2023-02-28'
)a
LEFT JOIN
`customer_big_table` b
ON a.contract = b.`full_sfid`
WHERE `price_book_name` != 'Direct-NG (NWO)'
GROUP BY Channel_Type,Product_Type 






Upsell Promo BY Staff
Upsell Promo
BULK