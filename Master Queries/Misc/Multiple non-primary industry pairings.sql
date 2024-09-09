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
        WHERE customer_party_unique_reference_number IS NOT NULL
            AND source = 'ACBS'
    ),
    customer_classificiations
    AS
    (
        SELECT
            customer.source,
            customer_ods_key,
            customer_name,
            customer_x_classification__relationship.ods_key,
            classification_group_description,
            -- classification_code,
            classification_description
        FROM customer
            JOIN customer_x_classification__relationship
            ON customer_x_classification__relationship.customer_ods_key = customer.ods_key
            JOIN customer_classification
            ON customer_x_classification__relationship.classification_ods_key = customer_classification.ods_key
    ),
    distinct_inds
    AS
    (
        SELECT customer_classificiations.source,
            customer_ods_key,
            customer_name,
            classification_group_description,
            classification_description
        FROM customer_classificiations
        WHERE ods_key LIKE 'IND#%'
        GROUP BY
        customer_classificiations.source,
        customer_ods_key,
        customer_name,
        -- customer_classificiations.ods_key,
        classification_group_description,
        -- classification_code,
        classification_description
    ),
    distinct_priminds
    AS
    (
        SELECT customer_classificiations.source,
            customer_ods_key,
            customer_name,
            classification_group_description,
            classification_description
        FROM customer_classificiations
        WHERE ods_key LIKE 'PRIMIND#%'
        GROUP BY
        customer_classificiations.source,
        customer_ods_key,
        customer_name,
        -- customer_classificiations.ods_key,
        classification_group_description,
        -- classification_code,
        classification_description
    )

SELECT customer.customer_name,
    STRING_AGG(CAST(distinct_inds.classification_group_description AS NVARCHAR(MAX)), CHAR(10)) AS 'Industry Group',
    STRING_AGG(CAST(distinct_inds.classification_description AS NVARCHAR(MAX)), CHAR(10)) AS 'Industry',
    STRING_AGG(CAST(distinct_priminds.classification_group_description AS NVARCHAR(MAX)), CHAR(10)) AS 'Primary Industry Group',
    STRING_AGG(CAST(distinct_priminds.classification_description AS NVARCHAR(MAX)), CHAR(10)) AS 'Primary Industry'
-- distinct_inds.classification_group_description,
-- distinct_inds.classification_description,
-- distinct_priminds.classification_group_description,
-- distinct_priminds.classification_description

FROM customer

    JOIN distinct_priminds
    ON customer.source = distinct_priminds.source
        AND customer.ods_key = distinct_priminds.customer_ods_key
    JOIN distinct_inds
    ON customer.source = distinct_inds.source
        AND customer.ods_key = distinct_inds.customer_ods_key
    WHERE NOT EXISTS (
    SELECT 1
    FROM distinct_inds di_sub
    JOIN distinct_priminds dp_sub ON di_sub.customer_ods_key = dp_sub.customer_ods_key
    WHERE di_sub.customer_ods_key = customer.ods_key
      AND di_sub.classification_description = dp_sub.classification_description
      AND di_sub.classification_group_description = dp_sub.classification_group_description
)

GROUP BY customer.source,
customer.ods_key,
customer.customer_name
HAVING COUNT(distinct_inds.classification_group_description) > 1
    OR COUNT(distinct_inds.classification_description) > 1
    OR COUNT(distinct_priminds.classification_group_description) > 1
    OR COUNT(distinct_priminds.classification_description) > 1



ORDER BY customer.customer_name