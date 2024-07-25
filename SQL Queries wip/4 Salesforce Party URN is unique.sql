-- SELECT SUM(number_of_records) AS 'Non-unique Salesforce records by Party URN'
-- FROM ( 
-- SELECT customer_party_unique_reference_number, COUNT(customer_party_unique_reference_number) AS 'number_of_records'
--     FROM [ODS].[dbo].[customer]
--     WHERE source IN ('SalesForce')
--     GROUP BY customer_party_unique_reference_number
--     HAVING COUNT(customer_party_unique_reference_number) > 1
-- ) AS groups


SELECT COUNT(*) AS 'Non-unique Salesforce Party URNs'
FROM ( 
SELECT customer_party_unique_reference_number, COUNT(customer_party_unique_reference_number) AS 'number_of_records'
    FROM [ODS].[dbo].[customer]
    WHERE source IN ('SalesForce')
    GROUP BY customer_party_unique_reference_number
    HAVING COUNT(customer_party_unique_reference_number) > 1
) AS groups;

-- order desc:
--   ORDER BY COUNT(customer_party_unique_reference_number) DESC

-- most duplicates: 11 for 00307510