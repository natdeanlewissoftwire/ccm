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
    )
SELECT TOP 100
    customer.customer_name AS 'Name 1',
    customer.customer_party_unique_reference_number AS 'URN',
    sf_customer.customer_code AS 'Salesforce ID',
    customer.customer_type_description AS 'Customer Type',
    CASE 
        WHEN customer.customer_watch_monitor_flag = 1
        THEN 'Watch'
        WHEN customer.customer_watch_monitor_flag = 0
        THEN 'Good'
        ELSE NULL
        END
    AS 'Customer Watch Status',
    customer_risk_rating.customer_credit_risk_rating_description AS 'Credit Risk Rating',
    CAST(customer_risk_rating.customer_risk_rating_type_datetime AS DATE) AS 'Credit Risk Rating Date',
    CAST(customer_risk_rating.customer_credit_risk_rating_datetime AS DATE) AS 'Assigned Risk Rating Date',
    customer_classification.classification_description AS 'Primary Industry Classification',
    customer_risk_rating.customer_risk_rating_type_description AS 'Assigned Rating/ECGD Status',
    customer_risk_parameter_value AS "Loss Given Default"
FROM [ODS].[dbo].[customer] customer
    JOIN [ODS].[dbo].[facility_party] facility_party
    ON customer.source = facility_party.source
        AND customer.ods_key = facility_party.customer_ods_key
    JOIN [ODS].[dbo].[facility] facility
    ON facility_party.source = facility.source
        AND facility_party.facility_ods_key = facility.ods_key
    JOIN [ODS].[dbo].[customer_x_classification__relationship] customer_x_classification__relationship
        ON customer_x_classification__relationship.customer_ods_key = customer.ods_key
    JOIN [ODS].[dbo].[customer_classification] customer_classification
        ON customer_x_classification__relationship.classification_ods_key = customer_classification.ods_key
    JOIN [ODS].[dbo].[customer_risk_rating]
    ON customer_risk_rating.customer_ods_key = customer.ods_key
    JOIN [ODS].[dbo].[customer_address]
    ON customer_address.customer_ods_key = customer.ods_key
    JOIN cleaned_names
    ON customer.source = cleaned_names.source
        AND customer.ods_key = cleaned_names.ods_key
    JOIN customer_risk_parameter
    ON customer.ods_key = customer_risk_parameter.customer_ods_key
        AND customer_risk_parameter.source = 'ACBS'
        AND customer_risk_parameter_code = 'LGD'
        AND customer_risk_source_type_code = 'I'
    JOIN [ODS].[dbo].[customer] sf_customer
    ON sf_customer.source = 'SalesForce'
        AND sf_customer.customer_party_unique_reference_number = customer.customer_party_unique_reference_number
WHERE customer.source = 'ACBS'
    AND sf_customer.source = 'SalesForce'
    AND facility.facility_status_description = 'ACTIVE ACCOUNT'
    --  exclude UKEF records
    AND customer.customer_code != '00000000'
    --  exclude deleted records
    AND customer.change_type != 'D'
    AND facility_party.change_type != 'D'
    AND facility.change_type != 'D'
    AND EXISTS (
    SELECT 1
    FROM [ODS].[dbo].[customer] sf_customer
    WHERE source = 'SalesForce'
        AND sf_customer.customer_party_unique_reference_number = customer.customer_party_unique_reference_number
    GROUP BY sf_customer.customer_party_unique_reference_number
    HAVING COUNT(*) = 1
)
    AND customer.customer_party_unique_reference_number IS NOT NULL
    AND customer.customer_name IS NOT NULL
    AND sf_customer.customer_code IS NOT NULL
    AND customer.customer_party_unique_reference_number IS NOT NULL
    AND customer.customer_type_description IS NOT NULL
    AND customer.customer_watch_monitor_flag IS NOT NULL
    AND customer_x_classification__relationship.ods_key LIKE 'PRIMIND#%'
    AND customer_risk_rating.customer_credit_risk_rating_description IS NOT NULL
    AND customer_x_classification__relationship.customer_classification_relationship_type IS NOT NULL
    AND customer_risk_rating.customer_risk_rating_type_description IS NOT NULL
GROUP BY
    customer.customer_name,
    sf_customer.customer_code,
    customer.customer_party_unique_reference_number,
    customer.customer_type_description,
    customer.customer_watch_monitor_flag,
    customer_classification.classification_description,
    customer_risk_rating.customer_credit_risk_rating_description,
    customer_risk_rating.customer_risk_rating_type_datetime,
    customer_risk_rating.customer_credit_risk_rating_datetime,
    customer_x_classification__relationship.customer_classification_relationship_type,
    customer_risk_rating.customer_risk_rating_type_description,
    cleaned_names.cleaned_name,
    customer_risk_parameter_value
HAVING COUNT(cleaned_names.cleaned_name) = 1
