SELECT customer_code, customer_name, customer_party_unique_reference_number,
STRING_AGG(CAST(facility_code AS NVARCHAR(MAX)), CHAR(10)) AS 'facility_codes',
STRING_AGG(CAST(facility_party_role_type_description AS NVARCHAR(MAX)), CHAR(10)) AS 'facility_party_role_type_descriptions'
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
AND customer.customer_party_unique_reference_number IS NOT NULL
GROUP BY customer_code, customer_name, customer_party_unique_reference_number
