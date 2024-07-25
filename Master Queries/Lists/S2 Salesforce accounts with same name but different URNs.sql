WITH
    sf_cleaned_names
    AS
    (
        SELECT
            source,
            customer_name,
            customer_party_unique_reference_number,
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
            -- surround with spaces for CHARINDEX substring checks later on
            ' ' + 
            UPPER(customer_name)
            + ' '
            -- replace common punctuation with spaces
            , '.', ' '), ',', ' '), '''', ' '), '-', ' '), '/', ' '), '(', ' '), ')', ' ')
            -- remove common terms
            , ' LIMITED', ''), ' LTD', ''), ' PLC', ''), ' INCORPORATED', ''), ' INC', ''), ' LLC', ''), ' COMPANY', ''), ' CORPORATION', ''), ' CORP', '')
            -- standardise &
            , ' & ', ' AND ')
            -- turn multiple spaces (up to 32 consecutive) into a single space
            ,'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' ')
            AS cleaned_name
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
        WHERE customer_party_unique_reference_number IS NOT NULL
    )
SELECT
    sf_customers_1.customer_name AS customer_name_1, 
    sf_customers_1.customer_party_unique_reference_number AS customer_party_unique_reference_number_1,
    sf_customers_2.customer_name AS customer_name_2,
    sf_customers_2.customer_party_unique_reference_number AS customer_party_unique_reference_number_2

FROM sf_cleaned_names sf_customers_1
    JOIN sf_cleaned_names sf_customers_2
    ON sf_customers_1.cleaned_name = sf_customers_2.cleaned_name
WHERE sf_customers_1.customer_party_unique_reference_number < sf_customers_2.customer_party_unique_reference_number;