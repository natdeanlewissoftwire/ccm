WITH
    cleaned_names
    AS
    (
        SELECT
            source,
            customer_name,
            customer_party_unique_reference_number,
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(customer_name), ' ', ''), '.', ''), ',', ''), '''', ''), '-', ''), '/', ''), '(', ''), ')', ''), 'LIMITED', ''), 'LTD', ''), 'PLC', ''), 'INCORPORATED', ''), 'INC', ''), 'LLC', ''), 'COMPANY', ''), 'CORPORATION', ''), 'CORP', ''), 'CO', ''), 'GMBH', ''), 'UK', ''), '&', 'AND'), 'AND', ''), 'THE', '')
                AS cleaned_name
        FROM [ODS].[dbo].[customer]
        WHERE customer_party_unique_reference_number IS NOT NULL
    )
SELECT
    COUNT(*) AS 'Entity matches with non matching Party URNs between ACBS and SF'
-- acbs_customers.source AS acbs_source,
-- acbs_customers.customer_name AS acbs_customer_name,
-- sf_customers.source AS sf_source,
-- sf_customers.customer_name AS sf_customer_name
-- acbs_customers.cleaned_name AS acbs_cleaned_name,
-- sf_customers.cleaned_name AS sf_cleaned_name
FROM cleaned_names acbs_customers
    JOIN cleaned_names sf_customers
    ON acbs_customers.cleaned_name = sf_customers.cleaned_name
    -- VERY slow:
    -- ON (
    -- -- cleaned names same:
    --     acbs_customers.cleaned_name = sf_customers.cleaned_name
    -- -- or one cleaned name substring of the other:
    --     OR
    --     CHARINDEX(acbs_customers.cleaned_name, sf_customers.cleaned_name) + CHARINDEX(sf_customers.cleaned_name, acbs_customers.cleaned_name) > 0
    -- )
WHERE acbs_customers.source = 'ACBS'
    AND sf_customers.source IN ('SalesForce', 'SalesforceLegacy')
    AND acbs_customers.customer_party_unique_reference_number != sf_customers.customer_party_unique_reference_number;




-- SELECT acbs_customers.source, acbs_customers.customer_name, acbs_customers.customer_party_unique_reference_number, sf_customers.source, sf_customers.customer_name, sf_customers.customer_party_unique_reference_number
-- FROM [ODS].[dbo].[customer] acbs_customers
--     JOIN [ODS].[dbo].[customer] sf_customers
--     ON REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(acbs_customers.customer_name)
-- , ' ', ''), '.', ''), ',', ''), '-', ''), '/', ''), '(', ''), ')', ''), 'LIMITED', ''), 'LTD', ''), 'PLC', ''), 'INCORPORATED', ''), 'INC', ''), 'LLC', ''), 'COMPANY', ''), 'CORPORATION', ''), 'CORP', ''), 'CO', ''), 'GMBH', ''), 'UK', ''), '&', 'AND'), 'AND', ''), 'THE', '')
-- = 
-- REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(sf_customers.customer_name)
-- , ' ', ''), '.', ''), ',', ''), '-', ''), '/', ''), '(', ''), ')', ''), 'LIMITED', ''), 'LTD', ''), 'PLC', ''), 'INCORPORATED', ''), 'INC', ''), 'LLC', ''), 'COMPANY', ''), 'CORPORATION', ''), 'CORP', ''), 'CO', ''), 'GMBH', ''), 'UK', ''), '&', 'AND'), 'AND', ''), 'THE', '')
-- WHERE acbs_customers.source = 'ACBS'
--     AND acbs_customers.customer_party_unique_reference_number IS NOT NULL
--     AND sf_customers.source IN ('SalesForce', 'SalesforceLegacy')
--     AND sf_customers.customer_party_unique_reference_number IS NOT NULL
--     AND acbs_customers.customer_party_unique_reference_number != sf_customers.customer_party_unique_reference_number

-- decide same entity based on more than just name?


-- the slow command failes after ~21 mins with:
-- Msg 10053, Level 20, State 0, Line 0
-- A transport-level error has occurred when receiving results from the server. (provider: TCP Provider, error: 0 - An established connection was aborted by the software in your host machine.)
