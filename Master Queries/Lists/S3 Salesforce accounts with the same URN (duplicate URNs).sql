SELECT number_of_records AS 'Salesforce accounts with the same URN (duplicate URNs)',
customer_party_unique_reference_number
FROM ( 
    SELECT COUNT(customer_party_unique_reference_number) as 'number_of_records',
    customer_party_unique_reference_number
    FROM (
        SELECT DISTINCT
            customer.source,
            customer.customer_code,
            customer.customer_party_unique_reference_number,
            customer.customer_name
        FROM [ODS].[dbo].[customer] customer
        WHERE customer.source IN ('SalesForce')
            --  exclude UKEF records
        AND customer.customer_code <> '00000000'
            --  exclude deleted records
        AND customer.change_type <> 'D'
        ) as sf_customers
    GROUP BY customer_party_unique_reference_number
    HAVING COUNT(customer_party_unique_reference_number) > 1
) as groups
ORDER BY number_of_records DESC