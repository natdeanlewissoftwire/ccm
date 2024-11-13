SELECT DISTINCT customer_code
FROM customer
JOIN [ODS].[dbo].[facility_party] facility_party
ON customer.source = facility_party.source
    AND customer.ods_key = facility_party.customer_ods_key
JOIN [ODS].[dbo].[facility] facility
ON facility_party.source = facility.source
    AND facility_party.facility_ods_key = facility.ods_key
WHERE customer.source = 'ACBS'
AND customer.customer_code != '00000000'
AND customer.change_type != 'D'
AND facility.facility_status_description = 'ACTIVE ACCOUNT'
AND facility_party.change_type != 'D'
AND facility.change_type != 'D'
