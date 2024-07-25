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
            customer_code,
            ods_key
        FROM (
            SELECT DISTINCT
                cleaned_names.source,
                cleaned_names.customer_code,
                cleaned_names.customer_party_unique_reference_number,
                cleaned_names.customer_name,
                cleaned_names.cleaned_name,
                ods_key
            FROM cleaned_names
            WHERE cleaned_names.source = 'ACBS'
                AND cleaned_names.customer_code <> '00000000'
                AND cleaned_names.change_type <> 'D'
        ) AS acbs_customers
    ),
    acbs_cleaned_names_linked_to_active_facilities
    AS
    (
        SELECT DISTINCT
            acbs_cleaned_names.source,
            acbs_cleaned_names.customer_name,
            acbs_cleaned_names.customer_code,
            acbs_cleaned_names.customer_party_unique_reference_number,
            acbs_cleaned_names.cleaned_name,
            acbs_cleaned_names.ods_key
        FROM acbs_cleaned_names
            JOIN [ODS].[dbo].[facility_party] facility_party
            ON acbs_cleaned_names.source = facility_party.source
                AND acbs_cleaned_names.ods_key = facility_party.customer_ods_key
            JOIN [ODS].[dbo].[facility] facility
            ON facility_party.source = facility.source
                AND facility_party.facility_ods_key = facility.ods_key
        WHERE facility.facility_status_description = 'ACTIVE ACCOUNT'
            AND facility_party.change_type <> 'D'
            AND facility.change_type <> 'D'
    ),
    sf_customers
    AS
    (
        SELECT DISTINCT
            customer.source,
            customer.customer_code,
            customer.customer_party_unique_reference_number,
            customer.customer_name
        FROM [ODS].[dbo].[customer] customer
        WHERE customer.source IN ('SalesForce', 'SalesforceLegacy')
            --  exclude UKEF records
            AND customer.customer_code <> '00000000'
            --  exclude deleted records
            AND customer.change_type <> 'D'
    )
SELECT
    -- STRING_AGG(customer_name, ', ') AS 'Customer Name',
    -- STRING_AGG(customer_code, ', ') AS 'Customer ID',
    -- STRING_AGG(customer_party_unique_reference_number, ', ') as 'URN'
    acbs_cleaned_names_linked_to_active_facilities.customer_name,
    acbs_cleaned_names_linked_to_active_facilities.customer_code,
    acbs_cleaned_names_linked_to_active_facilities.customer_party_unique_reference_number,
    acbs_cleaned_names.customer_name,
    acbs_cleaned_names.customer_code,
    acbs_cleaned_names.customer_party_unique_reference_number,
    sf_customers.customer_name,
    sf_customers.customer_code,
    sf_customers.customer_party_unique_reference_number,
    CASE
        WHEN sf_customers.source = 'SalesforceLegacy' THEN 'TRUE'
        WHEN sf_customers.source = 'SalesForce' THEN 'FALSE'
    END
    AS 'Legacy indicator'
FROM acbs_cleaned_names_linked_to_active_facilities
    JOIN acbs_cleaned_names
    ON acbs_cleaned_names_linked_to_active_facilities.cleaned_name = acbs_cleaned_names.cleaned_name
    LEFT JOIN sf_customers
    ON acbs_cleaned_names.customer_party_unique_reference_number = sf_customers.customer_party_unique_reference_number
WHERE acbs_cleaned_names_linked_to_active_facilities.customer_code <> acbs_cleaned_names.customer_code
    -- AND acbs_cleaned_names_linked_to_active_facilities.customer_code = '00236724'
