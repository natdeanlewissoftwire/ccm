SELECT customer.customer_code, customer.customer_name, deal_code, deal_name, deal.country_ods_key as 'deal.country_ods_key', facility_code, borrower.customer_code as 'borrower.customer_code', borrower.customer_name as 'borrower.customer_name', borrower_address.customer_address_country as 'borrower country'
FROM customer
LEFT JOIN deal
ON deal.customer_ods_key = customer.ods_key
LEFT JOIN facility
ON facility.customer_ods_key = customer.ods_key
LEFT JOIN customer borrower
ON borrower.customer_party_unique_reference_number = customer.customer_party_unique_reference_number
AND borrower.ods_key LIKE 'BORROW#%'
LEFT JOIN customer_address borrower_address
ON borrower.ods_key = borrower_address.customer_ods_key

WHERE customer.customer_code IN ('001b000000Hy6n1AAB','00167000055uKuHAAU','001b000000Hy74iAAB','0014K00000WdMbAQAV','0010X00004uuzGWQAY','001b000000jvWQwAAM','001b000000d6jMyAAI','001b000000jvWp6AAE','001b000000NQBuGAAX','0010X0000538wctQAA')
AND customer.source = 'SalesForce'

ORDER BY customer.customer_party_unique_reference_number, customer.customer_name