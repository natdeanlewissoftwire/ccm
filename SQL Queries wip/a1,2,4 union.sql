
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
    acbs_active
    AS
    (
        SELECT DISTINCT
            customer.source,
            customer.customer_code,
            customer.customer_party_unique_reference_number,
            customer.customer_name
        FROM [ODS].[dbo].[customer] customer
            JOIN [ODS].[dbo].[facility_party] facility_party
            ON customer.source = facility_party.source
                AND customer.ods_key = facility_party.customer_ods_key
            JOIN [ODS].[dbo].[facility] facility
            ON facility_party.source = facility.source
                AND facility_party.facility_ods_key = facility.ods_key
        WHERE customer.source = 'ACBS'
            AND facility.facility_status_description = 'ACTIVE ACCOUNT'
            --  exclude UKEF records
            AND customer.customer_code <> '00000000'
            --  exclude deleted records
            AND customer.change_type <> 'D'
            AND facility_party.change_type <> 'D'
            AND facility.change_type <> 'D'
    ),
    not_sf_account
    AS
    (
        SELECT *
        FROM (
    SELECT DISTINCT
                customer.source,
                customer.customer_code,
                customer.customer_party_unique_reference_number,
                customer.customer_name
            FROM [ODS].[dbo].[customer] customer
                JOIN [ODS].[dbo].[facility_party] facility_party
                ON customer.source = facility_party.source
                    AND customer.ods_key = facility_party.customer_ods_key
                JOIN [ODS].[dbo].[facility] facility
                ON facility_party.source = facility.source
                    AND facility_party.facility_ods_key = facility.ods_key
            WHERE customer.source = 'ACBS'
                AND facility.facility_status_description = 'ACTIVE ACCOUNT'
                --  exclude UKEF records
                AND customer.customer_code <> '00000000'
                --  exclude deleted records
                AND customer.change_type <> 'D'
                AND facility_party.change_type <> 'D'
                AND facility.change_type <> 'D'
) AS acbs_customers
        WHERE acbs_customers.customer_party_unique_reference_number IS NOT NULL
            AND NOT EXISTS (
    SELECT *
            FROM [ODS].[dbo].[customer] sf_customers
            WHERE sf_customers.source = 'SalesForce'
                AND sf_customers.customer_party_unique_reference_number = acbs_customers.customer_party_unique_reference_number
)
    )
-- acbs_active_cleaned_names
-- AS
-- (
--     SELECT
--         source,
--         customer_name,
--         customer_party_unique_reference_number,
--         cleaned_name,
--         customer_code
--     FROM (
--         SELECT DISTINCT
--             cleaned_names.source,
--             cleaned_names.customer_code,
--             cleaned_names.customer_party_unique_reference_number,
--             cleaned_names.customer_name,
--             cleaned_names.cleaned_name
--         FROM cleaned_names
--             JOIN [ODS].[dbo].[facility_party] facility_party
--             ON cleaned_names.source = facility_party.source
--                 AND cleaned_names.ods_key = facility_party.customer_ods_key
--             JOIN [ODS].[dbo].[facility] facility
--             ON facility_party.source = facility.source
--                 AND facility_party.facility_ods_key = facility.ods_key
--         WHERE cleaned_names.source = 'ACBS'
--             AND facility.facility_status_description = 'ACTIVE ACCOUNT'
--             --  exclude UKEF records
--             AND cleaned_names.customer_code <> '00000000'
--             --  exclude deleted records
--             AND cleaned_names.change_type <> 'D'
--             AND facility_party.change_type <> 'D'
--             AND facility.change_type <> 'D'
-- ) AS acbs_customers
-- ),
-- disctinct_urns
-- AS
-- (
--     SELECT DISTINCT
--         -- acbs_cleaned_names_1.customer_name,
--         -- acbs_cleaned_names_2.customer_name,
--         -- acbs_cleaned_names_1.cleaned_name,
--         -- acbs_cleaned_names_2.cleaned_name,
--         acbs_cleaned_names_1.customer_code
--     -- acbs_cleaned_names_2.customer_code
--     FROM acbs_cleaned_names acbs_cleaned_names_1
--         JOIN acbs_cleaned_names acbs_cleaned_names_2
--         ON acbs_cleaned_names_1.cleaned_name = acbs_cleaned_names_2.cleaned_name
--     WHERE acbs_cleaned_names_1.customer_code <> acbs_cleaned_names_2.customer_code
--     -- cleaned_name FROM acbs_cleaned_names
--     -- WHERE cleaned_name LIKE '%  %'
-- ),
-- distinct_cleaned_names
-- AS
-- (
--     SELECT DISTINCT
--         acbs_cleaned_names_1.cleaned_name
--     FROM acbs_cleaned_names acbs_cleaned_names_1
--         JOIN acbs_cleaned_names acbs_cleaned_names_2
--         ON acbs_cleaned_names_1.cleaned_name = acbs_cleaned_names_2.cleaned_name
--     WHERE acbs_cleaned_names_1.customer_party_unique_reference_number <> acbs_cleaned_names_2.customer_party_unique_reference_number
--     )

-- SELECT
--     customer_name,
--     customer_party_unique_reference_number
-- FROM acbs_cleaned_names
--     JOIN distinct_cleaned_names
--     ON distinct_cleaned_names.cleaned_name = acbs_cleaned_names.cleaned_name

-- SELECT
--     customer.customer_name,
--     customer.customer_code
-- FROM customer
--     JOIN disctinct_urns
--     ON customer.customer_code = disctinct_urns.customer_code
SELECT
    acbs_active.customer_name,
    acbs_active.customer_party_unique_reference_number
FROM acbs_active
    LEFT JOIN not_sf_account
    ON acbs_active.customer_party_unique_reference_number = not_sf_account.customer_party_unique_reference_number
