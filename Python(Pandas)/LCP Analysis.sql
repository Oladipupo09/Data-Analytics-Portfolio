Select count(1) from `ng_location`

Select * from `ng_lcp_base`
where contract = 'a0D6700001D37HXEAZ'
or system_id = 3481661

Select * from `ng_lcp_base`
where lcp_name in ('Gaza Godiya','Gabriel Modigie')



Select max(created_date) from ng_lcp_base

Select * from ng_lcp_base
where community = 'Naze-Nekede'
and lcp_name = 'Raphael Ikechukwu Chukwunonyere'


Select community, lcp_name, case
								when product_name like '%PRIME- Unit (Outright NWO)%' then 'Prime Outright'
                                when product_name like '%ECO- Unit (Outright NWO)%' then 'Eco Outright'
                                when product_name like '%ECO-Unit (24M NWO)%' or product_name like '%ECO-Unit (12M NWO)%' then 'Eco LTO'
                                when product_name like '%PRIME-Unit (24M NWO)%' or product_name like '%PRIME-Unit (12M NWO)%' then 'Prime LTO'
                                end Base_Classification,
count(contract) contracts
from `ng_lcp_base`
group by community, lcp_name, case
								when product_name like '%PRIME- Unit (Outright NWO)%' then 'Prime Outright'
                                when product_name like '%ECO- Unit (Outright NWO)%' then 'Eco Outright'
                                when product_name like '%ECO-Unit (24M NWO)%' or product_name like '%ECO-Unit (12M NWO)'then 'Eco LTO'
                                when product_name like '%PRIME-Unit (24M NWO)%' or product_name like '%PRIME-Unit (12M NWO)'then 'Prime LTO'
                                end
 ;                               
 
 
Select lcp_name, a.contract, contract_id, ltoperiod, created_date entry_date, paidperiod, ref_activation_end, last_payment_date
from (
(Select lcp_name, contract_id, contract, created_date
from `ng_lcp_base`
where created_date between '2022-02-01' and '2022-02-28'
and product_name not like '%Outright%') a
left outer join
(Select contract, ltoperiod, paidperiod, ref_activation_end, last_payment_date
from `activity_mar22`) b
on a.contract = b.contract
	  )