Select * from `customer_status`
limit 10

Create Table customer_status
AS
(Select DATE_FORMAT(reportdate, "%b-%y") month_date, contract, segmentation_status, 
ROUND(segmentation_score, 2) segmentation_score, lto_segment, lcp_status, old_active_status, customer_status
from activity)


Create Table customer_status
AS

INSERT INTO customer_status (month_date, contract, segmentation_status, segmentation_score, lto_segment, lcp_status, old_active_status, customer_status)
Select DATE_FORMAT(reportdate, "%b-%y") month_date, contract, segmentation_status, 
ROUND(segmentation_score, 2) segmentation_score, lto_segment, lcp_status, old_active_status, customer_status
from `activity_Feb22`;


Drop Table Status_Movement;

#-------------Status Movement Query-----------
Select customer_status, count(distinct contract) Contracts
from customer_status
where month_date = 'Feb-22'
and `lcp_status` = 'LCP'
group by customer_status;


#-------------Status Movement Query-----------
Create Table Status_Movement
AS
(Select a.contract, a.lcp_status, a.customer_status Jan_Status, b.customer_status Feb_Status
from (
(Select distinct contract, customer_status, lcp_status
from customer_status
where month_date = 'Feb-22') a
left outer join
(Select distinct contract, customer_status
from customer_status
where month_date = 'Mar-22') b
on a.contract = b.contract
	  )
);

#-------------Status Movement Query-----------
Select Jan_Status, Feb_Status, count(contract) as Counts
from Status_Movement
where lcp_status = 'LCP'
group by Jan_Status, Feb_Status;

#------------- MOM Status Count Non-LCP -----------
Select month_date, customer_status, count(distinct contract) Contracts
from customer_status
#where month_date = 'Feb-22'
where `lcp_status` = 'Non-LCP'
group by month_date, customer_status;

#-------------MOM Status Count Non-LCP-----------
Select month_date, customer_status, count(distinct contract) Contracts
from customer_status
#where month_date = 'Feb-22'
where `lcp_status` = 'LCP'
group by month_date, customer_status;


#-------------Status Movement Query Old Status LCP-----------
Select old_active_status, count(distinct contract) Contracts
from customer_status
where month_date = 'Feb-22'
and `lcp_status` = 'LCP'
group by old_active_status;
#-------------Status Movement Query Old Status Non-LCP-----------
Select old_active_status, count(distinct contract) Contracts
from customer_status
where month_date = 'Feb-22'
and `lcp_status` = 'Non-LCP'
group by old_active_status;

#-------------Status Movement Query Old Status-----------
Create Table Status_Movement_Old
AS
(Select a.contract, a.lcp_status, a.old_active_status Jan_Status, b.old_active_status Feb_Status
from (
(Select distinct contract, old_active_status, lcp_status
from customer_status
where month_date = 'Feb-22') a
left outer join
(Select distinct contract, old_active_status
from customer_status
where month_date = 'Mar-22') b
on a.contract = b.contract
	  )
);

#-------------Status Movement Query Old Status LCP-----------
Select Jan_Status, Feb_Status, count(contract) as Counts
from Status_Movement_Old
where lcp_status = 'LCP'
group by Jan_Status, Feb_Status;

#-------------Status Movement Query Old Status Non-LCP-----------
Select Jan_Status, Feb_Status, count(contract) as Counts
from Status_Movement_Old
where lcp_status = 'Non-LCP'
group by Jan_Status, Feb_Status;

#------------- MOM Status Count Non-LCP Old Status -----------
Select month_date, old_active_status, count(distinct contract) Contracts
from customer_status
where `lcp_status` = 'Non-LCP'
group by month_date, old_active_status;

#------------- MOM Status Count LCP Old Status -----------
Select month_date, old_active_status, count(distinct contract) Contracts
from customer_status
where `lcp_status` = 'LCP'
group by month_date, old_active_status;