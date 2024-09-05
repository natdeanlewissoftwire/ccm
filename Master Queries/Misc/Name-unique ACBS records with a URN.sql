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
    active_acbs_customers
    AS
    (
        SELECT cleaned_names.*
        FROM cleaned_names
            JOIN [ODS].[dbo].[facility_party] facility_party
            ON cleaned_names.source = facility_party.source
                AND cleaned_names.ods_key = facility_party.customer_ods_key
            JOIN [ODS].[dbo].[facility] facility
            ON facility_party.source = facility.source
                AND facility_party.facility_ods_key = facility.ods_key
        WHERE cleaned_names.source = 'ACBS'
            AND facility.facility_status_description = 'ACTIVE ACCOUNT'
            --  exclude UKEF records
            AND cleaned_names.customer_code != '00000000'
            --  exclude deleted records
            AND cleaned_names.change_type != 'D'
            AND facility_party.change_type != 'D'
            AND facility.change_type != 'D'
    ),
    fuzzy_unique_acbs_customer_names
    AS
    (
        SELECT
            cleaned_name
        FROM active_acbs_customers
        GROUP BY cleaned_name
        HAVING COUNT(cleaned_name) = 1
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
                active_acbs_customers.ods_key,
                active_acbs_customers.source,
                active_acbs_customers.customer_code,
                active_acbs_customers.customer_party_unique_reference_number,
                active_acbs_customers.customer_name,
                facility.facility_type_description,
                facility_party.facility_party_role_type_description
            FROM active_acbs_customers
                JOIN [ODS].[dbo].[facility_party] facility_party
                ON active_acbs_customers.source = facility_party.source
                    AND active_acbs_customers.ods_key = facility_party.customer_ods_key
                JOIN [ODS].[dbo].[facility] facility
                ON facility_party.source = facility.source
                    AND facility_party.facility_ods_key = facility.ods_key
            GROUP BY 
        active_acbs_customers.ods_key, 
        active_acbs_customers.source, 
        active_acbs_customers.customer_code, 
        active_acbs_customers.customer_party_unique_reference_number, 
        active_acbs_customers.customer_name, 
        facility.facility_type_description,
        facility_party.facility_party_role_type_description
        ) AS all_facility_and_party_types
        GROUP BY 
            ods_key,
            source, 
            customer_code, 
            customer_party_unique_reference_number, 
            customer_name
    )

SELECT *
FROM fuzzy_unique_acbs_customer_names
    JOIN active_acbs_customers
    ON fuzzy_unique_acbs_customer_names.cleaned_name = active_acbs_customers.cleaned_name
    LEFT JOIN cleaned_names AS sf_cleaned_names
    ON sf_cleaned_names.customer_party_unique_reference_number = active_acbs_customers.customer_party_unique_reference_number
        AND sf_cleaned_names.source IN ('SalesForce')
    JOIN distinct_facility_and_party_types
    ON active_acbs_customers.ods_key = distinct_facility_and_party_types.ods_key
    WHERE active_acbs_customers.customer_party_unique_reference_number IS NOT NULL
ORDER BY active_acbs_customers.ods_key