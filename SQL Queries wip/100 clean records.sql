SELECT TOP 100 *
FROM [ODS].[dbo].[customer] acbs_customers
WHERE customer_name IS NOT NULL
AND customer_type_code IS NOT NULL
AND customer_type_description IS NOT NULL
AND customer_watch_monitor_flag IS NOT NULL
AND customer_watch_monitor_reason IS NOT NULL
AND customer_watch_monitor_datetime IS NOT NULL
AND customer_party_unique_reference_number IS NOT NULL
AND EXISTS (
    SELECT *
    FROM customer sf_customers
    WHERE source = 'SalesForce'
    AND sf_customers.customer_party_unique_reference_number = acbs_customers.customer_party_unique_reference_number
)
