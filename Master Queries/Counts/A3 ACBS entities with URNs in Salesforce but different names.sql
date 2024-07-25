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
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(customer_name), ' ', ''), '.', ''), ',', ''), '''', ''), '-', ''), '/', ''), '(', ''), ')', ''), 'LIMITED', ''), 'LTD', ''), 'PLC', ''), 'INCORPORATED', ''), 'INC', ''), 'LLC', ''), 'COMPANY', ''), 'CORPORATION', ''), 'CORP', ''), '&', 'AND')
                AS cleaned_name
        FROM [ODS].[dbo].[customer]
        WHERE customer_party_unique_reference_number IS NOT NULL
    ),
    sf_cleaned_names
    AS
    (
        SELECT
            source,
            customer_name,
            customer_party_unique_reference_number,
            cleaned_name
        FROM (
            SELECT DISTINCT
                cleaned_names.source,
                cleaned_names.customer_code,
                cleaned_names.customer_party_unique_reference_number,
                cleaned_names.customer_name,
                cleaned_names.cleaned_name
            FROM cleaned_names
            WHERE cleaned_names.source IN ('SalesForce')
                AND cleaned_names.customer_code <> '00000000'
                AND cleaned_names.change_type <> 'D'
    ) as sf_customers
    ),
    acbs_cleaned_names
    AS
    (
        SELECT
            source,
            customer_name,
            customer_party_unique_reference_number,
            cleaned_name
        FROM (
            SELECT DISTINCT
                cleaned_names.source,
                cleaned_names.customer_code,
                cleaned_names.customer_party_unique_reference_number,
                cleaned_names.customer_name,
                cleaned_names.cleaned_name
            FROM cleaned_names
                JOIN [ODS].[dbo].[facility_party] facility_party
                ON cleaned_names.source = facility_party.source
                    AND cleaned_names.ods_key = facility_party.customer_ods_key
                JOIN [ODS].[dbo].[facility] facility
                ON facility_party.source = facility.source
                    AND facility_party.facility_ods_key = facility.ods_key
            WHERE cleaned_names.source = 'ACBS'
                AND facility.facility_status_description = 'ACTIVE ACCOUNT'
                AND cleaned_names.customer_code <> '00000000'
                AND cleaned_names.change_type <> 'D'
                AND facility_party.change_type <> 'D'
                AND facility.change_type <> 'D'
        ) as acbs_customers
        WHERE customer_party_unique_reference_number IS NOT NULL
    )
SELECT
    COUNT(*) AS 'ACBS entities with URNs in Salesforce but different names'
FROM acbs_cleaned_names acbs_customers
    JOIN sf_cleaned_names sf_customers
    ON acbs_customers.customer_party_unique_reference_number = sf_customers.customer_party_unique_reference_number
WHERE acbs_customers.cleaned_name <> sf_customers.cleaned_name;