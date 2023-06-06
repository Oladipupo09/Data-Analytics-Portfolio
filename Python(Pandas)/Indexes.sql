##Creating indexes on the Activity Tables
Create index activityjan22_contract_index on
`activity_jan22` (contract);

##Creating indexes on the Activity Tables
Create index cust_status_index on
`customer_status` (contract);

Select * from `customer_status`
limit 100

Select * from `activity_jan22`
where contract in
(Select contract from `customer_status`
where month_date = 'Feb-22'
and customer_status = 'Retrieval'
and lcp_status = 'LCP')

Update `activity_jan22`
set activation_start = contract_creation
and last_payment_date = contract_creation
where contract in
(Select contract from `customer_status`
where month_date = 'Feb-22'
and customer_status = 'Retrieval'
and lcp_status = 'LCP')

Select generation, ref_activation_end, count(contract) Counts
from activity
where sales_channel = 'MTN_NG' 
and ref_activation_end in ('2022-04-01','2022-04-02')
group by generation, ref_activation_end

Select * from customer_status
limit 100


##Creating indexes on the Activity Tables
Create index activityjan22_contract_index on
`activity_jan22` (contract);

##Creating indexes on the Activity Tables
Create index activityfeb22_contract_index on
`activity_feb22` (contract);

##Creating indexes on the Activity Tables
Create index activityjan22_contract_index on
`activity_jan22` (contract);

##Creating indexes on the Activity Tables
Create index activitydec21_contract_index on
`activity_dec21` (contract);

##Creating indexes on the Activity Tables
Create index activitynov21_contract_index on
`activity_nov21` (contract);

##Creating indexes on the Activity Tables
Create index activity_contract_index on
`activity` (contract);

##Creating indexes on the Activity Tables
Create index cust_status_index on
`customer_status` (contract);

##Creating indexes on the NG_Location Tables
Create index location_contract_index on
`ng_location` (contract);

##Creating indexes on the NG_Location Tables
Create index location_contract_index on
`daily_payments_mar22` (contract);

##Creating indexes on the NG_Location Tables
Create index febmar_rev_index on
`feb_mar_revenue` (contract);
