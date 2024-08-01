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
    ),
    distinct_facility_and_party_types
    AS
    (
        SELECT
            all_facility_and_party_types.ods_key,
            STRING_AGG(CAST(facility_type_description AS NVARCHAR(MAX)), CHAR(10)) AS customer_facility_types,
            STRING_AGG(CAST(facility_party_role_type_description AS NVARCHAR(MAX)), CHAR(10)) AS customer_facility_party_role_types
        FROM (
            SELECT
                acbs_cleaned_names_linked_to_active_facilities.ods_key,
                acbs_cleaned_names_linked_to_active_facilities.source,
                acbs_cleaned_names_linked_to_active_facilities.customer_code,
                acbs_cleaned_names_linked_to_active_facilities.customer_party_unique_reference_number,
                acbs_cleaned_names_linked_to_active_facilities.customer_name,
                facility.facility_type_description,
                facility_party.facility_party_role_type_description
            FROM acbs_cleaned_names_linked_to_active_facilities
                JOIN [ODS].[dbo].[facility_party] facility_party
                ON acbs_cleaned_names_linked_to_active_facilities.source = facility_party.source
                    AND acbs_cleaned_names_linked_to_active_facilities.ods_key = facility_party.customer_ods_key
                JOIN [ODS].[dbo].[facility] facility
                ON facility_party.source = facility.source
                    AND facility_party.facility_ods_key = facility.ods_key
            GROUP BY 
        acbs_cleaned_names_linked_to_active_facilities.ods_key, 
        acbs_cleaned_names_linked_to_active_facilities.source, 
        acbs_cleaned_names_linked_to_active_facilities.customer_code, 
        acbs_cleaned_names_linked_to_active_facilities.customer_party_unique_reference_number, 
        acbs_cleaned_names_linked_to_active_facilities.customer_name, 
        facility.facility_type_description,
        facility_party.facility_party_role_type_description
        ) as all_facility_and_party_types
        GROUP BY 
            ods_key,
            source, 
            customer_code, 
            customer_party_unique_reference_number, 
            customer_name
    )

SELECT
    acbs_cleaned_names_linked_to_active_facilities.customer_name AS 'Active ACBS Customer Name',
    acbs_cleaned_names_linked_to_active_facilities.customer_code  AS 'Active ACBS Customer Code',
    acbs_cleaned_names_linked_to_active_facilities.customer_party_unique_reference_number  AS 'Active ACBS Customer URN (A1)',
    CASE
    WHEN acbs_cleaned_names_linked_to_active_facilities.customer_party_unique_reference_number IS NOT NULL
        AND EXISTS (
    SELECT *
        FROM [ODS].[dbo].[customer] salesforce
        WHERE salesforce.source = 'SalesForce'
            AND salesforce.customer_party_unique_reference_number = acbs_cleaned_names_linked_to_active_facilities.customer_party_unique_reference_number
    ) THEN 'Yes'
    ELSE 'No'
    END
    AS 'URN present in SalesForce (A2)',
    CASE
        WHEN acbs_cleaned_names_linked_to_active_facilities.customer_party_unique_reference_number IS NOT NULL
        AND EXISTS (
    SELECT *
        FROM [ODS].[dbo].[customer] salesforce_legacy
        WHERE salesforce_legacy.source = 'SalesforceLegacy'
            AND salesforce_legacy.customer_party_unique_reference_number = acbs_cleaned_names_linked_to_active_facilities.customer_party_unique_reference_number
)
        AND NOT EXISTS (
    SELECT *
        FROM [ODS].[dbo].[customer] salesforce
        WHERE salesforce.source = 'SalesForce'
            AND salesforce.customer_party_unique_reference_number = acbs_cleaned_names_linked_to_active_facilities.customer_party_unique_reference_number
) THEN 'Yes'
ELSE 'No'
    END
    AS 'ACBS URN is only present in Salesforce Legacy Data (A4)',
    acbs_cleaned_names.customer_name AS 'Fuzzy-Matching ACBS Customer Name',
    acbs_cleaned_names.customer_code AS 'Fuzzy-Matching ACBS Customer Code',
    acbs_cleaned_names.customer_party_unique_reference_number  AS 'Fuzzy-Matching ACBS Customer URN',
    sf_customers.customer_party_unique_reference_number AS 'URN-Matching Salesforce Customer URN',
    sf_customers.customer_name AS 'URN-Matching Salesforce Customer Name',
    sf_customers.customer_code AS 'URN-Matching Salesforce Customer Code',
    CASE
        WHEN sf_customers.customer_party_unique_reference_number IS NOT NULL
        AND EXISTS (
    SELECT *
        FROM [ODS].[dbo].[customer] salesforce_legacy
        WHERE salesforce_legacy.source = 'SalesforceLegacy'
            AND salesforce_legacy.customer_party_unique_reference_number = sf_customers.customer_party_unique_reference_number
)
        AND NOT EXISTS (
    SELECT *
        FROM [ODS].[dbo].[customer] salesforce
        WHERE salesforce.source = 'SalesForce'
            AND salesforce.customer_party_unique_reference_number = sf_customers.customer_party_unique_reference_number
) THEN 'Yes'
ELSE 'No'
    END
    AS 'URN-Matching Salesforce URN is only present in Salesforce Legacy Data',
    distinct_facility_and_party_types.customer_facility_types as 'Customer facility types',
    distinct_facility_and_party_types.customer_facility_party_role_types as 'Customer facility party role types'

FROM acbs_cleaned_names_linked_to_active_facilities
    LEFT JOIN acbs_cleaned_names
    ON acbs_cleaned_names_linked_to_active_facilities.cleaned_name = acbs_cleaned_names.cleaned_name
    LEFT JOIN sf_customers
    ON acbs_cleaned_names.customer_party_unique_reference_number = sf_customers.customer_party_unique_reference_number
    LEFT JOIN distinct_facility_and_party_types
    ON acbs_cleaned_names_linked_to_active_facilities.ods_key = distinct_facility_and_party_types.ods_key

ORDER BY acbs_cleaned_names_linked_to_active_facilities.customer_code
