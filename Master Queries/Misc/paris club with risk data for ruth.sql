WITH
    cleaned_names
    AS
    (
        SELECT DISTINCT
            source,
            customer_name,
            customer_code,
            ods_key,
            customer_watch_monitor_flag,
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
            ods_key,
            customer_watch_monitor_flag
        FROM (
            SELECT DISTINCT
                cleaned_names.source,
                cleaned_names.customer_code,
                cleaned_names.customer_party_unique_reference_number,
                cleaned_names.customer_name,
                cleaned_names.cleaned_name,
                ods_key,
                customer_watch_monitor_flag
            FROM cleaned_names
            WHERE cleaned_names.source = 'ACBS'
                AND cleaned_names.customer_code != '00000000'
                AND cleaned_names.change_type != 'D'
                AND cleaned_names.customer_party_unique_reference_number IN (
'00301565',
'00301565',
'00303847',
'00303847',
'00309198',
'00309198',
'00308993',
'00308993',
'00302336',
'00302336',
'00302336',
'00302336',
'00302421',
'00302421',
'00309023',
'00309023',
'00310647',
'00310647',
'00300561',
'00300561',
'00303114',
'00303114',
'00307191',
'00307191',
'00304579',
'00302092',
'00300174',
'00300174',
'00301438',
'00301438',
'00310366',
'00310366',
'00309163',
'00309163',
'00303741',
'00303741',
'00300188',
'00300188',
'00306965',
'00306965',
'00303207',
'00303207',
'00312239',
'00312239',
'00301842',
'00301842',
'00302340',
'00302340',
'00304157',
'00304157',
'00300221',
'00300221',
'00308644',
'00308644',
'00308007',
'00308007',
'00302430',
'00302430',
'00302271',
'00302271',
'00302564',
'00302564',
'00301680',
'00301680',
'00301545',
'00301545',
'00304717',
'00304717',
'00311760',
'00311760',
'00300460',
'00300460',
'00301603',
'00301603',
'00304809',
'00304809',
'00303451',
'00303451',
'00301853',
'00301853',
'00302167',
'00302167',
'00300474',
'00300474',
'00300208',
'00300208',
'00309152',
'00309152',
'00304246',
'00304246',
'00301168',
'00301168',
'00300299',
'00300299',
'00301213',
'00301213',
'00309595',
'00309595',
'00303843',
'00303843',
'00311219',
'00311219',
'00300801',
'00300801',
'00305924',
'00305924',
'00305707',
'00305707',
'00312014',
'00312014',
'00308324',
'00308324',
'00303950',
'00303950',
'00303384',
'00303384',
'00311745',
'00311745',
'00302547',
'00302547',
'00300114',
'00300114',
'00301735',
'00301735',
'00302909',
'00302909',
'00313054',
'00313054',
'00302318',
'00302318',
'00303902',
'00303902',
'00313325',
'00313325',
'00300348',
'00300348',
'00303875',
'00303875',
'00300315',
'00300315',
'00309773',
'00309773',
'00302869',
'00302869',
'00301637',
'00301637',
'00308784',
'00308784',
'00303319',
'00303319',
'00302215',
'00302215',
'00306710',
'00306710',
'00305104',
'00305104',
'00306710',
'00306710',
'00312093',
'00312093',
'00301587',
'00301587',
'00313488',
'00308739',
'00300190',
'00300190',
'00302373',
'00302373',
'00301601',
'00301601',
'00301078',
'00301078',
'00307669',
'00307565',
'00304023',
'00304023',
'00304187',
'00304187',
'00300408',
'00300408',
'00300409',
'00300409',
'00306636',
'00306636',
'00302316',
'00302316',
'00302768',
'00302768',
'00302550',
'00302550',
'00301158',
'00301158',
'00300526',
'00300526',
'00303353',
'00303353',
'00300240',
'00300240',
'00309564',
'00309564',
'00308978',
'00308978',
'00302258',
'00302258',
'00303969',
'00303969',
'00301676',
'00301676',
'00301753',
'00301753',
'00300866',
'00306524',
'00304169',
'00304169',
'00301414',
'00301414',
'00300863',
'00300863',
'00308429',
'00308429',
'00303983',
'00303983',
'00301651',
'00301651',
'00302255',
'00302255',
'00300456',
'00300456',
'00301406',
'00301406',
'00310938',
'00310938',
'00300386',
'00300386'
)

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
            STRING_AGG(CAST(facility_type_code AS NVARCHAR(MAX)), CHAR(10)) AS customer_facility_codes,
            STRING_AGG(CAST(facility_type_description AS NVARCHAR(MAX)), CHAR(10)) AS customer_facility_types,
            COUNT(facility_type_description) AS facility_count,
            SUM(CASE WHEN facility_type_description LIKE '%PARIS CLUB%' THEN 1 ELSE 0 END) AS paris_club_facility_count,
            STRING_AGG(CAST(facility_party_role_type_description AS NVARCHAR(MAX)), CHAR(10)) AS customer_facility_party_role_types
        FROM (
            SELECT
                acbs_cleaned_names_linked_to_active_facilities.ods_key,
                acbs_cleaned_names_linked_to_active_facilities.source,
                acbs_cleaned_names_linked_to_active_facilities.customer_code,
                acbs_cleaned_names_linked_to_active_facilities.customer_party_unique_reference_number,
                acbs_cleaned_names_linked_to_active_facilities.customer_name,
                facility.country_ods_key,
                country.country_name,
                facility.facility_type_code,
                facility.facility_type_description,
                facility_party.facility_party_role_type_description
            FROM acbs_cleaned_names_linked_to_active_facilities
                JOIN [ODS].[dbo].[facility_party] facility_party
                ON acbs_cleaned_names_linked_to_active_facilities.source = facility_party.source
                    AND acbs_cleaned_names_linked_to_active_facilities.ods_key = facility_party.customer_ods_key
                JOIN [ODS].[dbo].[facility] facility
                ON facility_party.source = facility.source
                    AND facility_party.facility_ods_key = facility.ods_key
                JOIN [ODS].[dbo].[country] country
                ON country.ods_key = facility.country_ods_key
            GROUP BY 
        acbs_cleaned_names_linked_to_active_facilities.ods_key, 
        acbs_cleaned_names_linked_to_active_facilities.source, 
        acbs_cleaned_names_linked_to_active_facilities.customer_code, 
        acbs_cleaned_names_linked_to_active_facilities.customer_party_unique_reference_number, 
        acbs_cleaned_names_linked_to_active_facilities.customer_name, 
        facility.country_ods_key,
        country.country_name,
        facility.facility_type_code,
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
    distinct_facility_and_party_types.customer_facility_codes AS 'Customer facility codes',
    distinct_facility_and_party_types.customer_facility_types AS 'Customer facility types',
    distinct_facility_and_party_types.customer_facility_party_role_types AS 'Customer facility party role types',
    customer_address_country AS 'Customer address country',
    customer_risk_rating.customer_credit_risk_rating_description AS 'Credit Risk Rating',
    customer_risk_parameter_lgd.customer_risk_parameter_value AS 'Loss Given Default',
    CASE 
        WHEN acbs_cleaned_names.customer_watch_monitor_flag = 1
        THEN 'Watch'
        WHEN acbs_cleaned_names.customer_watch_monitor_flag = 0
        THEN 'Good'
        ELSE NULL
        END
    AS 'Customer Watch Status'



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
    LEFT JOIN [ODS].[dbo].[customer_risk_rating]
    ON customer_risk_rating.customer_ods_key = acbs_cleaned_names.ods_key
    LEFT JOIN customer_risk_parameter customer_risk_parameter_lgd
    ON acbs_cleaned_names.ods_key = customer_risk_parameter_lgd.customer_ods_key
        AND customer_risk_parameter_lgd.source = 'ACBS'
        AND customer_risk_parameter_lgd.customer_risk_parameter_code = 'LGD'
        AND customer_risk_parameter_lgd.customer_risk_source_type_code = 'I'


-- append credit rating and lgd and wathclist

-- ONLY Paris club:
WHERE facility_count = paris_club_facility_count

ORDER BY distinct_acbs_cleaned_names_linked_to_active_facilities.cleaned_name

