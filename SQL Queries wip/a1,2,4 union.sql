
WITH
    cleaned_names
    AS
    (
        SELECT
            source,
            customer_name,
            customer_code,
            ods_key,
            change_type,
            customer_party_unique_reference_number,
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
            -- surround with spaces for CHARINDEX substring checks later on
            ' ' + 
            UPPER(customer_name)
            + ' '
            -- replace common punctuation with spaces
            , '.', ' '), ',', ' '), '''', ' '), '-', ' '), '/', ' '), '(', ' '), ')', ' ')
            -- remove common terms
            , ' LIMITED', ''), ' LTD', ''), ' PLC', ''), ' INCORPORATED', ''), ' INC', ''), ' LLC', ''), ' COMPANY', ''), ' CORPORATION', ''), ' CORP', ''), 'THE ', '')
            -- standardise &
            , ' & ', ' AND ')
            -- turn multiple spaces (up to 32 consecutive) into a single space
            ,'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' ')
            AS cleaned_name
        FROM [ODS].[dbo].[customer]
    ),
    acbs_cleaned_names
    AS
    (
        SELECT
            source,
            customer_name,
            customer_party_unique_reference_number,
            cleaned_name,
            customer_code
        FROM (
            SELECT DISTINCT
                cleaned_names.source,
                cleaned_names.customer_code,
                cleaned_names.customer_party_unique_reference_number,
                cleaned_names.customer_name,
                cleaned_names.cleaned_name
            FROM cleaned_names
            WHERE cleaned_names.source IN ('ACBS')
                AND cleaned_names.customer_code <> '00000000'
                AND cleaned_names.change_type <> 'D'
    ) AS acbs_customers
    WHERE customer_code IN ('00000352',
'00227814',
'00224708',
'00222465',
'00206972',
'00232461',
'00000348',
'00291482',
'00240504',
'00271245',
'00240324',
'00236724')
    ),
    disctinct_urns
    AS
    (
        SELECT DISTINCT
            -- acbs_cleaned_names_1.customer_name,
            -- acbs_cleaned_names_2.customer_name,
            -- acbs_cleaned_names_1.cleaned_name,
            -- acbs_cleaned_names_2.cleaned_name,
            acbs_cleaned_names_1.customer_code
        -- acbs_cleaned_names_2.customer_code
        FROM acbs_cleaned_names acbs_cleaned_names_1
            JOIN acbs_cleaned_names acbs_cleaned_names_2
            ON (acbs_cleaned_names_1.cleaned_name = acbs_cleaned_names_2.cleaned_name
                OR CHARINDEX(acbs_cleaned_names_1.cleaned_name, acbs_cleaned_names_2.cleaned_name) + CHARINDEX(acbs_cleaned_names_2.cleaned_name, acbs_cleaned_names_1.cleaned_name) > 0)
        WHERE acbs_cleaned_names_1.customer_code <> acbs_cleaned_names_2.customer_code
        -- cleaned_name FROM acbs_cleaned_names
        -- WHERE cleaned_name LIKE '%  %'
    )
SELECT
    customer.customer_name,
    customer.customer_code
FROM customer
    JOIN disctinct_urns
    ON customer.customer_code = disctinct_urns.customer_code;
