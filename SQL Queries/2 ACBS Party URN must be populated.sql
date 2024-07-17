SELECT COUNT(*) as 'ACBS records with null Party URN'
FROM (
    SELECT DISTINCT
        customer.source,
        customer.customer_code,
        customer.customer_party_unique_reference_number,
        customer.customer_name
    FROM [ODS].[dbo].[customer] customer
        JOIN [ODS].[dbo].[facility_party] facility_party
        ON customer.source = facility_party.source
            AND customer.ods_key = facility_party.customer_ods_key
        JOIN [ODS].[dbo].[facility] facility
        ON facility_party.source = facility.source
            AND facility_party.facility_ods_key = facility.ods_key
    WHERE customer.source ='ACBS'
        AND facility.facility_status_description = 'ACTIVE ACCOUNT'
        -- Excludes UKEF
        AND customer.customer_code <> '00000000'
        -- Remove deleted records
        AND customer.change_type <> 'D'
        AND facility_party.change_type <> 'D'
        AND facility.change_type <> 'D'
) as acbs_customers
WHERE customer_party_unique_reference_number IS NULL