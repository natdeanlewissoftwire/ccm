WITH
    acbs_records
    AS
    (
        SELECT *
        FROM customer
        WHERE source = 'ACBS'
            AND customer_code != '00000000'
            AND change_type != 'D'
    ),
    acbs_records_linked_to_NOT_EXPIRED_active_facilities
    AS
    (
        SELECT acbs_records.*, facility_ods_key, facility_expiration_datetime, facility_type_description
        FROM acbs_records
            JOIN [ODS].[dbo].[facility_party] facility_party
            ON acbs_records.source = facility_party.source
                AND acbs_records.ods_key = facility_party.customer_ods_key
            JOIN [ODS].[dbo].[facility] facility
            ON facility_party.source = facility.source
                AND facility_party.facility_ods_key = facility.ods_key
        WHERE facility.facility_status_description = 'ACTIVE ACCOUNT'
            AND facility_party.change_type != 'D'
            AND facility.change_type != 'D'
            AND (facility.facility_expiration_datetime >= GETDATE() OR facility.facility_expiration_datetime IS NULL)
    )

-- SELECT source, ods_key, customer_code, customer_name, customer_party_unique_reference_number, STRING_AGG(CAST(facility_type_description as nvarchar(MAX)), ', ') AS 'facility type_descriptions', STRING_AGG(CAST(facility_expiration_datetime as nvarchar(MAX)), ', ') AS 'null or future non-expired facility_expiration_dates'
-- FROM acbs_records_linked_to_NOT_EXPIRED_active_facilities
-- GROUP BY source, ods_key, customer_code, customer_name, customer_party_unique_reference_number

SELECT *
FROM acbs_records_linked_to_NOT_EXPIRED_active_facilities
WHERE customer_name IN ('TAIT TECHNOLOGIES UK LIMITED', 'DAIRY CONSULTING LIMITED', 'INDONESIA, MINISTRY OF DEFENCE')