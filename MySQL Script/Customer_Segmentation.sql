#-----------Comparison between Prev. & Current Month for Old Customer Status-----------------------------------------------#
SELECT Prev_Month_seg_status,Curr_Month_seg_status,lcp_status,COUNT(contract) Counts
FROM
(
SELECT a.contract,a.segmentation_status Prev_Month_seg_status,b.segmentation_status Curr_Month_seg_status,
a.lto_segment,c.age_segment,a.lcp_status
FROM
(
(SELECT contract,segmentation_status,lto_segment,lcp_status	
FROM `customer_status`
WHERE old_active_status = 'Active' AND `month_date`='Jun-22')a
LEFT OUTER JOIN (SELECT * FROM `customer_status`
WHERE `month_date`='Jul-22')b
ON a.contract = b.contract
LEFT OUTER JOIN `activity` c
ON a.contract = c.contract
)
)d
GROUP BY Curr_Month_seg_status,Prev_Month_seg_status,lcp_status

#................old Status Customer segmentation status monthly trend.............#
SELECT segmentation_status,lcp_status,
COUNT(CASE WHEN month_date ='Jan-22' THEN contract END) 'Jan-22',
COUNT(CASE WHEN month_date ='Feb-22' THEN contract END) 'Feb-22',
COUNT(CASE WHEN month_date ='Mar-22' THEN contract END) 'Mar-22',
COUNT(CASE WHEN month_date ='Apr-22' THEN contract END) 'Apr-22',
COUNT(CASE WHEN month_date ='May-22' THEN contract END) 'May-22',
COUNT(CASE WHEN month_date ='Jun-22' THEN contract END) 'Jun-22',
COUNT(CASE WHEN month_date ='Jul-22' THEN contract END) 'Jul-22',
COUNT(CASE WHEN month_date ='Aug-22' THEN contract END) 'Aug-22'
FROM customer_status
WHERE old_active_status = 'Active'
GROUP BY segmentation_status,lcp_status



#-----------Comparison between Mar & Apr for New Customer Status-----------------------------------------------#
SELECT seg_status_PM,seg_status_CM,lcp_status,COUNT(contract) Counts
FROM
(
SELECT a.contract,a.segmentation_status seg_status_PM,b.segmentation_status seg_status_CM,
a.lto_segment,c.age_segment,a.lcp_status
FROM
(
(SELECT contract,segmentation_status,lto_segment,lcp_status
FROM `activity_log`
WHERE customer_status IN ('Paid','Recovery') AND `month_date`='Nov-22')a
LEFT OUTER JOIN (SELECT * FROM `activity_log`
WHERE `month_date`='Dec-22')b
ON a.contract = b.contract
LEFT OUTER JOIN (SELECT * FROM activity_log WHERE `month_date` = 'Dec-22') c
ON a.contract = c.contract
)
)d
GROUP BY seg_status_CM,seg_status_PM,lcp_status



#................New Status Customer segmentation status monthly trend.............#
SELECT segmentation_status,lcp_status,
COUNT(CASE WHEN month_date ='Jan-22' THEN contract END) 'Jan-22',
COUNT(CASE WHEN month_date ='Feb-22' THEN contract END) 'Feb-22',
COUNT(CASE WHEN month_date ='Mar-22' THEN contract END) 'Mar-22',
COUNT(CASE WHEN month_date ='Apr-22' THEN contract END) 'Apr-22',
COUNT(CASE WHEN month_date ='May-22' THEN contract END) 'May-22',
COUNT(CASE WHEN month_date ='Jun-22' THEN contract END) 'Jun-22',
COUNT(CASE WHEN month_date ='Jul-22' THEN contract END) 'Jul-22',
COUNT(CASE WHEN month_date ='Aug-22' THEN contract END) 'Aug-22',
COUNT(CASE WHEN month_date ='Sep-22' THEN contract END) 'Sep-22',
COUNT(CASE WHEN month_date ='Oct-22' THEN contract END) 'Oct22',
COUNT(CASE WHEN month_date ='Nov-22' THEN contract END) 'Nov22',
COUNT(CASE WHEN month_date ='Dec-22' THEN contract END) 'Dec22'
FROM activity_log
WHERE customer_status IN ('Paid','Recovery')
GROUP BY segmentation_status,lcp_status


#--Current Month Customer Segmentation for Old Customer Status--------#
SELECT lcp_status,segmentation_status,COUNT(contract) Counts
FROM activity
WHERE old_active_status = 'Active'
GROUP BY segmentation_status,lcp_status


#--Current Month Customer Segmentation for New Customer Status--------#
SELECT lcp_status,segmentation_status,COUNT(contract) Counts
FROM activity
WHERE customer_status IN ('paid','Recovery')
GROUP BY segmentation_status,lcp_status

SELECT `crmcontract`,segmentation_status,`old_active_status`
FROM activity





#SELECT contract, DATE_FORMAT(reportdate,'%e-%b-%y') Month_Year,segmentation_score,segmentation_status,lto_segment,age_segment,lcp_status,customer_status
#FROM activity
#WHERE old_active_status = 'Active'
#Limit 10