WITH
    sf_cleaned_names
    AS
    (
        SELECT
            source,
            customer_name,
            customer_party_unique_reference_number,
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(customer_name), ' ', ''), '.', ''), ',', ''), '''', ''), '-', ''), '/', ''), '(', ''), ')', ''), 'LIMITED', ''), 'LTD', ''), 'PLC', ''), 'INCORPORATED', ''), 'INC', ''), 'LLC', ''), 'COMPANY', ''), 'CORPORATION', ''), 'CORP', ''), 'CO', ''), 'GMBH', ''), 'UK', ''), '&', 'AND'), 'AND', ''), 'THE', '')
                AS cleaned_name
        FROM [ODS].[dbo].[customer]
        WHERE source IN ('SalesForce','SalesforceLegacy')
            AND customer_party_unique_reference_number IS NOT NULL
    ),
    acbs_cleaned_names
    AS
    (
        SELECT
            source,
            customer_name,
            customer_party_unique_reference_number,
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(customer_name), ' ', ''), '.', ''), ',', ''), '''', ''), '-', ''), '/', ''), '(', ''), ')', ''), 'LIMITED', ''), 'LTD', ''), 'PLC', ''), 'INCORPORATED', ''), 'INC', ''), 'LLC', ''), 'COMPANY', ''), 'CORPORATION', ''), 'CORP', ''), 'CO', ''), 'GMBH', ''), 'UK', ''), '&', 'AND'), 'AND', ''), 'THE', '')
                AS cleaned_name
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
            WHERE customer.source ='ACBS'
                AND facility.facility_status_description = 'ACTIVE ACCOUNT'
                -- Excludes UKEF
                AND customer.customer_code <> '00000000'
                -- Remove deleted records
                AND customer.change_type <> 'D'
                AND facility_party.change_type <> 'D'
                AND facility.change_type <> 'D'
        ) as acbs_customers
        WHERE customer_party_unique_reference_number IS NOT NULL
    )
SELECT
    COUNT(*) AS 'Party URN matches with non matching names between ACBS and SF'
    -- acbs_customers.source AS acbs_source,
    -- acbs_customers.customer_name AS acbs_customer_name,
    -- sf_customers.source AS sf_source,
    -- sf_customers.customer_name AS sf_customer_name
-- acbs_customers.cleaned_name AS acbs_cleaned_name,
-- sf_customers.cleaned_name AS sf_cleaned_name
FROM acbs_cleaned_names acbs_customers
    JOIN sf_cleaned_names sf_customers
    ON acbs_customers.customer_party_unique_reference_number = sf_customers.customer_party_unique_reference_number
WHERE acbs_customers.source = 'ACBS'
    AND sf_customers.source IN ('SalesForce', 'SalesforceLegacy')
    -- cleaned names different:
    AND acbs_customers.cleaned_name <> sf_customers.cleaned_name

    -- cleaned names not substrings of each other:
    AND CHARINDEX(acbs_customers.cleaned_name, sf_customers.cleaned_name) + CHARINDEX(sf_customers.cleaned_name, acbs_customers.cleaned_name) = 0


-- SELECT acbs_customers.source, acbs_customers.customer_name, sf_customers.source, sf_customers.customer_name,replaced_acbs_record.cleaned_name,
-- REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(acbs_customers.customer_name)
-- , ' ', ''), '.', ''), ',', ''), '-', ''), '/', ''), '(', ''), ')', ''), 'LIMITED', ''), 'LTD', ''), 'PLC', ''), 'INCORPORATED', ''), 'INC', ''), 'LLC', ''), 'COMPANY', ''), 'CORPORATION', ''), 'CORP', ''), 'CO', ''), 'GMBH', ''), 'UK', ''), '&', 'AND'), 'AND', ''), 'THE', ''),
-- REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(sf_customers.customer_name)
-- , ' ', ''), '.', ''), ',', ''), '-', ''), '/', ''), '(', ''), ')', ''), 'LIMITED', ''), 'LTD', ''), 'PLC', ''), 'INCORPORATED', ''), 'INC', ''), 'LLC', ''), 'COMPANY', ''), 'CORPORATION', ''), 'CORP', ''), 'CO', ''), 'GMBH', ''), 'UK', ''), '&', 'AND'), 'AND', ''), 'THE', '')
-- FROM [ODS].[dbo].[customer] acbs_customers
-- JOIN [ODS].[dbo].[customer] sf_customers
-- ON acbs_customers.customer_party_unique_reference_number = sf_customers.customer_party_unique_reference_number
-- WHERE acbs_customers.source = 'ACBS'
-- AND acbs_customers.customer_party_unique_reference_number IS NOT NULL
-- AND sf_customers.source IN ('SalesForce', 'SalesforceLegacy')
-- AND sf_customers.customer_party_unique_reference_number IS NOT NULL
-- AND 
-- REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(acbs_customers.customer_name)
-- , ' ', ''), '.', ''), ',', ''), '-', ''), '/', ''), '(', ''), ')', ''), 'LIMITED', ''), 'LTD', ''), 'PLC', ''), 'INCORPORATED', ''), 'INC', ''), 'LLC', ''), 'COMPANY', ''), 'CORPORATION', ''), 'CORP', ''), 'CO', ''), 'GMBH', ''), 'UK', ''), '&', 'AND'), 'AND', ''), 'THE', '')
-- <> 
-- REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(sf_customers.customer_name)
-- , ' ', ''), '.', ''), ',', ''), '-', ''), '/', ''), '(', ''), ')', ''), 'LIMITED', ''), 'LTD', ''), 'PLC', ''), 'INCORPORATED', ''), 'INC', ''), 'LLC', ''), 'COMPANY', ''), 'CORPORATION', ''), 'CORP', ''), 'CO', ''), 'GMBH', ''), 'UK', ''), '&', 'AND'), 'AND', ''), 'THE', '')



-- should we also compare entities that differ in other fields?

-- comparing substrings in both dirs:

-- AND CHARINDEX(
-- REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(acbs_customers.customer_name)
-- , ' ', ''), '.', ''), ',', ''), '-', ''), '/', ''), '(', ''), ')', ''), 'LIMITED', ''), 'LTD', ''), 'PLC', ''), 'INCORPORATED', ''), 'INC', ''), 'LLC', ''), 'COMPANY', ''), 'CORPORATION', ''), 'CORP', ''), 'CO', ''), 'GMBH', ''), 'UK', ''), '&', 'AND'), 'AND', ''), 'THE', '')
-- ,  
-- REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(sf_customers.customer_name)
-- , ' ', ''), '.', ''), ',', ''), '-', ''), '/', ''), '(', ''), ')', ''), 'LIMITED', ''), 'LTD', ''), 'PLC', ''), 'INCORPORATED', ''), 'INC', ''), 'LLC', ''), 'COMPANY', ''), 'CORPORATION', ''), 'CORP', ''), 'CO', ''), 'GMBH', ''), 'UK', ''), '&', 'AND'), 'AND', ''), 'THE', '')
-- ) = 0 
-- AND CHARINDEX(
-- REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(sf_customers.customer_name)
-- , ' ', ''), '.', ''), ',', ''), '-', ''), '/', ''), '(', ''), ')', ''), 'LIMITED', ''), 'LTD', ''), 'PLC', ''), 'INCORPORATED', ''), 'INC', ''), 'LLC', ''), 'COMPANY', ''), 'CORPORATION', ''), 'CORP', ''), 'CO', ''), 'GMBH', ''), 'UK', ''), '&', 'AND'), 'AND', ''), 'THE', '')
-- ,  
-- REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(acbs_customers.customer_name)
-- , ' ', ''), '.', ''), ',', ''), '-', ''), '/', ''), '(', ''), ')', ''), 'LIMITED', ''), 'LTD', ''), 'PLC', ''), 'INCORPORATED', ''), 'INC', ''), 'LLC', ''), 'COMPANY', ''), 'CORPORATION', ''), 'CORP', ''), 'CO', ''), 'GMBH', ''), 'UK', ''), '&', 'AND'), 'AND', ''), 'THE', '')
-- ) = 0 