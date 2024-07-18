SELECT COUNT(*) as 'Salesforce accounts with no URN'
FROM (
    SELECT DISTINCT
        customer.source,
        customer.customer_code,
        customer.customer_party_unique_reference_number,
        customer.customer_name
    FROM [ODS].[dbo].[customer] customer
    WHERE customer.source IN ('SalesForce')
        AND customer.customer_code <> '00000000'
        AND customer.change_type <> 'D'
) as sf_customers
WHERE customer_party_unique_reference_number IS NULL;