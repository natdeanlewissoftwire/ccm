WITH
    cleaned_names
    AS
    (
        SELECT DISTINCT
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
        SELECT DISTINCT
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
                AND cleaned_names.customer_code != '00000000'
                AND cleaned_names.change_type != 'D'
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
            AND facility_party.change_type != 'D'
            AND facility.change_type != 'D'
    ),
    distinct_acbs_cleaned_names_linked_to_active_facilities
    AS
    (
        SELECT DISTINCT cleaned_name
        FROM acbs_cleaned_names_linked_to_active_facilities
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
            AND customer.customer_code != '00000000'
            --  exclude deleted records
            AND customer.change_type != 'D'
    ),
    distinct_facility_and_party_types
    AS
    (
        SELECT
            all_facility_and_party_types.ods_key,
            STRING_AGG(CAST(country_ods_key AS NVARCHAR(MAX)), CHAR(10)) AS customer_facility_country_ods_keys,
            STRING_AGG(CAST(country_name AS NVARCHAR(MAX)), CHAR(10)) AS customer_facility_country_names,
            STRING_AGG(CAST(facility_code AS NVARCHAR(MAX)), CHAR(10)) AS facility_codes,
            STRING_AGG(CAST(facility_type_code AS NVARCHAR(MAX)), CHAR(10)) AS customer_facility_type_codes,
            STRING_AGG(CAST(facility_type_description AS NVARCHAR(MAX)), CHAR(10)) AS customer_facility_types,
            COUNT(facility_type_description) AS facility_count,
            SUM(CASE WHEN facility_type_description LIKE '%PARIS CLUB%' THEN 1 ELSE 0 END) AS paris_club_facility_count,
            STRING_AGG(CAST(facility_party_role_type_description AS NVARCHAR(MAX)), CHAR(10)) AS customer_facility_party_role_types,
            STRING_AGG(CAST(classification_group_description AS NVARCHAR(MAX)), CHAR(10)) AS customer_facility_classification_group_descriptions,
            STRING_AGG(CAST(classification_description AS NVARCHAR(MAX)), CHAR(10)) AS customer_facility_classification_descriptions
        FROM (
            SELECT
                acbs_cleaned_names_linked_to_active_facilities.ods_key,
                acbs_cleaned_names_linked_to_active_facilities.source,
                acbs_cleaned_names_linked_to_active_facilities.customer_code,
                acbs_cleaned_names_linked_to_active_facilities.customer_party_unique_reference_number,
                acbs_cleaned_names_linked_to_active_facilities.customer_name,
                facility.country_ods_key,
                country.country_name,
                facility.facility_code,
                facility.facility_type_code,
                facility.facility_type_description,
                facility_party.facility_party_role_type_description,
                facility_classification.classification_group_description,
                facility_classification.classification_description
            FROM acbs_cleaned_names_linked_to_active_facilities
                JOIN [ODS].[dbo].[facility_party] facility_party
                ON acbs_cleaned_names_linked_to_active_facilities.source = facility_party.source
                    AND acbs_cleaned_names_linked_to_active_facilities.ods_key = facility_party.customer_ods_key
                JOIN [ODS].[dbo].[facility] facility
                ON facility_party.source = facility.source
                    AND facility_party.facility_ods_key = facility.ods_key
                LEFT JOIN [ODS].[dbo].[country] country
                ON country.ods_key = facility.country_ods_key
                LEFT JOIN facility_x_classification__relationship
                ON facility_x_classification__relationship.facility_ods_key = facility.ods_key
                LEFT JOIN facility_classification
                ON facility_x_classification__relationship.classification_ods_key = facility_classification.ods_key
            WHERE facility.facility_status_description = 'ACTIVE ACCOUNT'
                AND facility_party.change_type != 'D'
                AND facility.change_type != 'D'
            GROUP BY 
        acbs_cleaned_names_linked_to_active_facilities.ods_key, 
        acbs_cleaned_names_linked_to_active_facilities.source, 
        acbs_cleaned_names_linked_to_active_facilities.customer_code, 
        acbs_cleaned_names_linked_to_active_facilities.customer_party_unique_reference_number, 
        acbs_cleaned_names_linked_to_active_facilities.customer_name, 
        facility.country_ods_key,
        country.country_name,
        facility.facility_code,
        facility.facility_type_code,
        facility.facility_type_description,
        facility_party.facility_party_role_type_description,
        facility_classification.classification_group_description,
        facility_classification.classification_description
    ) AS all_facility_and_party_types
        GROUP BY 
            ods_key,
            source, 
            customer_code, 
            customer_party_unique_reference_number, 
            customer_name
    )

SELECT distinct_acbs_cleaned_names_linked_to_active_facilities.cleaned_name AS 'Fuzzy group',
    acbs_cleaned_names.customer_name AS 'ACBS Customer Name',
    CASE
    WHEN EXISTS (
        SELECT *
    FROM acbs_cleaned_names_linked_to_active_facilities
    WHERE acbs_cleaned_names_linked_to_active_facilities.ods_key = acbs_cleaned_names.ods_key
    ) THEN 'Yes'
    ELSE 'No'
    END
    AS 'ACBS record linked to active facilities?',
    acbs_cleaned_names.customer_code  AS 'ACBS Customer Code',
    acbs_cleaned_names.customer_party_unique_reference_number  AS 'ACBS Customer URN (A1)',
    CASE
    WHEN acbs_cleaned_names.customer_party_unique_reference_number IS NOT NULL
        AND EXISTS (
    SELECT *
        FROM [ODS].[dbo].[customer] salesforce
        WHERE salesforce.source = 'SalesForce'
            AND salesforce.customer_party_unique_reference_number = acbs_cleaned_names.customer_party_unique_reference_number
    ) THEN 'Yes'
    ELSE 'No'
    END
    AS 'URN present in SalesForce (A2)',
    CASE
        WHEN acbs_cleaned_names.customer_party_unique_reference_number IS NOT NULL
        AND EXISTS (
    SELECT *
        FROM [ODS].[dbo].[customer] salesforce_legacy
        WHERE salesforce_legacy.source = 'SalesforceLegacy'
            AND salesforce_legacy.customer_party_unique_reference_number = acbs_cleaned_names.customer_party_unique_reference_number
)
        AND NOT EXISTS (
    SELECT *
        FROM [ODS].[dbo].[customer] salesforce
        WHERE salesforce.source = 'SalesForce'
            AND salesforce.customer_party_unique_reference_number = acbs_cleaned_names.customer_party_unique_reference_number
) THEN 'Yes'
ELSE 'No'
    END
    AS 'ACBS URN is only present in Salesforce Legacy Data (A4)',
    -- acbs_cleaned_names.customer_name AS 'Fuzzy-Matching ACBS Customer Name',
    -- acbs_cleaned_names.customer_code AS 'Fuzzy-Matching ACBS Customer Code',
    -- acbs_cleaned_names.customer_party_unique_reference_number  AS 'Fuzzy-Matching ACBS Customer URN'
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
    distinct_facility_and_party_types.customer_facility_country_ods_keys AS 'Customer facility country ods keys',
    distinct_facility_and_party_types.customer_facility_country_names AS 'Customer facility country names',
    distinct_facility_and_party_types.customer_facility_type_codes AS 'Customer facility type codes',
    distinct_facility_and_party_types.customer_facility_types AS 'Customer facility types',
    distinct_facility_and_party_types.customer_facility_party_role_types AS 'Customer facility party role types',
    customer_address_country AS 'Customer address country',
    customer_facility_classification_group_descriptions AS 'Customer facility classification group descriptions',
    customer_facility_classification_descriptions AS 'Customer facility classification descriptions',
    distinct_facility_and_party_types.facility_codes AS 'Facility codes'

FROM distinct_acbs_cleaned_names_linked_to_active_facilities
    -- JOIN acbs_cleaned_names_linked_to_active_facilities
    -- ON distinct_acbs_cleaned_names_linked_to_active_facilities.cleaned_name = acbs_cleaned_names_linked_to_active_facilities.cleaned_name
    LEFT JOIN acbs_cleaned_names
    ON distinct_acbs_cleaned_names_linked_to_active_facilities.cleaned_name = acbs_cleaned_names.cleaned_name
    LEFT JOIN sf_customers
    ON acbs_cleaned_names.customer_party_unique_reference_number = sf_customers.customer_party_unique_reference_number
    LEFT JOIN distinct_facility_and_party_types
    ON acbs_cleaned_names.ods_key = distinct_facility_and_party_types.ods_key
    LEFT JOIN customer_address
    ON customer_address.customer_ods_key = acbs_cleaned_names.ods_key

WHERE distinct_acbs_cleaned_names_linked_to_active_facilities.cleaned_name IN (
 ' CLASSIC FASHION APPAREL INDUSTRY ',
 ' COLAS AFRIQUE SA ',
 ' CREDIT INDUSTRIEL ET COMMERCIAL ',
 ' DNEX DAGANG NEXCHANGE BHD ',
 ' DOTT SERVICES ',
 ' FLUOR ',
 ' JAGUAR LAND ROVER AUTOMOTIVE ',
 ' JFD ',
 ' JOHNSON MATTHEY ',
 ' MAN TRUCK AND BUS UK ',
 ' NORTHSTAR TRADE FINANCE ',
 ' PUBLIC INVESTMENT FUND ',
 ' RAIFFEISEN BANK INTERNATIONAL AG ',
 ' RAMDASS TRANSPORT ',
 ' RAUTOMEAD ',
 ' ROYAL IHC ',
 ' SADARA CHEMICAL ',
 ' SANTANDER FINANCIAL SERVICES ',
 ' SANTANDER UK ',
 ' SEASIA NECTAR PORT SERVICES ',
 ' SKANDINAVISKA ENSKILDA BANKEN AB ',
 ' SUBSEA 7 INTERNATIONAL CONTRACTING ',
 ' VITOL UPSTREAM GHANA ')

ORDER BY distinct_acbs_cleaned_names_linked_to_active_facilities.cleaned_name
