WITH
    sf_cleaned_names
    AS
    (
        SELECT
            source,
            customer_name,
            customer_party_unique_reference_number,
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(customer_name), ' ', ''), '.', ''), ',', ''), '''', ''), '-', ''), '/', ''), '(', ''), ')', ''), 'LIMITED', ''), 'LTD', ''), 'PLC', ''), 'INCORPORATED', ''), 'INC', ''), 'LLC', ''), 'COMPANY', ''), 'CORPORATION', ''), 'CORP', ''), '&', 'AND')
                AS cleaned_name
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
        WHERE customer_party_unique_reference_number IS NOT NULL
    )
SELECT
    COUNT(*) AS 'Salesforce accounts with same name but different URNs'
FROM sf_cleaned_names sf_customers_1
    JOIN sf_cleaned_names sf_customers_2
    ON sf_customers_1.cleaned_name = sf_customers_2.cleaned_name
WHERE sf_customers_1.customer_party_unique_reference_number <> sf_customers_2.customer_party_unique_reference_number;