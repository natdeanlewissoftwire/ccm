SELECT COUNT(*) as 'ACBS records with Party URN present in a SalesforceLegacy record'
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
    WHERE customer.source = 'ACBS'
        AND facility.facility_status_description = 'ACTIVE ACCOUNT'
        --  exclude UKEF records
        AND customer.customer_code <> '00000000'
        --  exclude deleted records
        AND customer.change_type <> 'D'
        AND facility_party.change_type <> 'D'
        AND facility.change_type <> 'D'
) as acbs_customers
WHERE acbs_customers.customer_party_unique_reference_number IS NOT NULL
    AND EXISTS (
    SELECT *
    FROM [ODS].[dbo].[customer] sf_customers
    WHERE sf_customers.source = 'SalesforceLegacy'
        AND sf_customers.customer_party_unique_reference_number = acbs_customers.customer_party_unique_reference_number
)

SELECT COUNT(*) as 'ACBS records with Party URN present in a SalesforceLegacy record but not a SalesForce record'
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
    WHERE customer.source = 'ACBS'
        AND facility.facility_status_description = 'ACTIVE ACCOUNT'
        --  exclude UKEF records
        AND customer.customer_code <> '00000000'
        --  exclude deleted records
        AND customer.change_type <> 'D'
        AND facility_party.change_type <> 'D'
        AND facility.change_type <> 'D'
) as acbs_customers
WHERE acbs_customers.customer_party_unique_reference_number IS NOT NULL
    AND EXISTS (
    SELECT *
    FROM [ODS].[dbo].[customer] sf_customers
    WHERE sf_customers.source = 'SalesforceLegacy'
        AND sf_customers.customer_party_unique_reference_number = acbs_customers.customer_party_unique_reference_number
)
    AND NOT EXISTS (
    SELECT *
    FROM [ODS].[dbo].[customer] sf_customers
    WHERE sf_customers.source = 'SalesForce'
        AND sf_customers.customer_party_unique_reference_number = acbs_customers.customer_party_unique_reference_number
);


-- don't care about this, we're just treating SF and SF legacy as both valid sources

-- do we want there to only be one record rather than there being one in both?

-- if there's an active record in legacy, we want to convert that to a latest sf account


