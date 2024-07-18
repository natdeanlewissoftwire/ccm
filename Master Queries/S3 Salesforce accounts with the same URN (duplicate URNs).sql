SELECT SUM(number_of_records) AS 'Salesforce accounts with the same URN (duplicate URNs)'
FROM ( 
SELECT COUNT(customer_party_unique_reference_number) as 'number_of_records'
    FROM [ODS].[dbo].[customer]
    WHERE source IN ('SalesForce')
    GROUP BY customer_party_unique_reference_number
    HAVING COUNT(customer_party_unique_reference_number) > 1
) as groups;