SELECT COUNT(*) as 'ACBS records with Party URN not present in any SF record'
FROM [ODS].[dbo].[customer] acbs_customers
WHERE acbs_customers.source = 'ACBS'
    AND acbs_customers.customer_party_unique_reference_number IS NOT NULL
    AND NOT EXISTS (
    SELECT *
    FROM [ODS].[dbo].[customer] sf_customers
    WHERE sf_customers.source IN ('SalesForce', 'SalesforceLegacy')
        AND sf_customers.customer_party_unique_reference_number = acbs_customers.customer_party_unique_reference_number
)


-- should this be a name comparison as well?