SELECT COUNT(*) as 'Salesforce accounts with no URN'
FROM [ODS].[dbo].[customer]
WHERE source IN ('SalesForce')
    AND customer_party_unique_reference_number IS NULL;