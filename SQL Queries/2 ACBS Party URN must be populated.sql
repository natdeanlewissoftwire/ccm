SELECT COUNT(*) as 'ACBS records with null Party URN'
FROM [ODS].[dbo].[customer]
WHERE source ='ACBS'
    AND customer_party_unique_reference_number IS NULL