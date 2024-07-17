SELECT COUNT(*) as 'ACBS records with Party URN present in a SalesforceLegacy record'
FROM [ODS].[dbo].[customer] acbs_customers
WHERE acbs_customers.source = 'ACBS'
    AND acbs_customers.customer_party_unique_reference_number IS NOT NULL
    AND EXISTS (
    SELECT *
    FROM [ODS].[dbo].[customer] sf_customers
    WHERE sf_customers.source = 'SalesforceLegacy'
        AND sf_customers.customer_party_unique_reference_number = acbs_customers.customer_party_unique_reference_number
)

SELECT COUNT(*) as 'ACBS records with Party URN present in a SalesforceLegacy record but not a SalesForce record'
FROM [ODS].[dbo].[customer] acbs_customers
WHERE acbs_customers.source = 'ACBS'
    AND acbs_customers.customer_party_unique_reference_number IS NOT NULL
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


-- don't care about this, we're just treating SF and SF legacy as both valid sources

-- do we want there to only be one record rather than there being one in both?

-- if there's an active record in legacy, we want to convert that to a latest sf account


