SELECT COUNT(*) as 'Salesforce records with null Party URN'
FROM [ODS].[dbo].[customer]
WHERE source IN ('SalesForce','SalesforceLegacy')
    AND customer_party_unique_reference_number IS NULL