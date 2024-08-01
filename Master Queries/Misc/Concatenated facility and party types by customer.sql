WITH
    distinct_facility_and_party_types
    AS
    (
        SELECT
            customer.source,
            customer.customer_code,
            customer.customer_party_unique_reference_number,
            customer.customer_name,
            facility.facility_type_description,
            facility_party.facility_party_role_type_description
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
        GROUP BY 
        customer.source, 
        customer.customer_code, 
        customer.customer_party_unique_reference_number, 
        customer.customer_name, 
        facility.facility_type_description,
        facility_party.facility_party_role_type_description
    )
SELECT
    source,
    customer_code,
    customer_party_unique_reference_number,
    customer_name,
    STRING_AGG(CAST(facility_type_description AS NVARCHAR(MAX)), CHAR(10)) AS 'Customer facility types',
    STRING_AGG(CAST(facility_party_role_type_description AS NVARCHAR(MAX)), CHAR(10)) AS 'Customer facility party role types'
FROM distinct_facility_and_party_types
GROUP BY 
    source, 
    customer_code, 
    customer_party_unique_reference_number, 
    customer_name;