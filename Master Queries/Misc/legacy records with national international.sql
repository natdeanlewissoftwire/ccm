SELECT sf_customers.customer_name AS 'Account Name', sf_customers.customer_party_unique_reference_number AS 'Party URN', sf_customers.customer_duns_number AS 'D&B Number', customer_address_country AS 'Trading Country',
CASE
WHEN customer_address_country IS NULL THEN NULL
WHEN customer_address_country = 'UNITED KINGDOM' THEN 'National'
ELSE 'International'
END
AS 'National/International',
CASE
WHEN customer_address_country IS NULL THEN NULL
WHEN customer_address_country != 'UNITED KINGDOM' THEN customer_address_country
END
AS 'Sub-Region',
NULL AS 'Party Validated',
sf_customers.ods_key AS 'LDP ID'
FROM (
SELECT DISTINCT 
    -- customer.source,
    -- customer.customer_code,
    customer.customer_name,
    customer.customer_party_unique_reference_number,
    customer.customer_duns_number,
    customer_address_country,
    customer_address_postcode
FROM [ODS].[dbo].[customer] customer
    JOIN [ODS].[dbo].[facility_party] facility_party
    ON customer.source = facility_party.source
        AND customer.ods_key = facility_party.customer_ods_key
    JOIN [ODS].[dbo].[facility] facility
    ON facility_party.source = facility.source
        AND facility_party.facility_ods_key = facility.ods_key
    LEFT JOIN customer_address
        ON customer_address.customer_ods_key = customer.ods_key
        AND customer_address.source = customer.source
WHERE customer.source = 'ACBS'
    AND facility.facility_status_description = 'ACTIVE ACCOUNT'
    --  exclude UKEF records
    AND customer.customer_code != '00000000'
    --  exclude deleted records
    AND customer.change_type != 'D'
    AND facility_party.change_type != 'D'
    AND facility.change_type != 'D'
) AS acbs_customers
JOIN customer sf_customers
ON sf_customers.customer_party_unique_reference_number = acbs_customers.customer_party_unique_reference_number
AND sf_customers.source = 'SalesforceLegacy'

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
)
