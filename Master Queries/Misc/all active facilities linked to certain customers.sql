SELECT customer.customer_name, customer.customer_code, customer.ods_key, facility.*
    FROM customer
        JOIN [ODS].[dbo].[facility_party] facility_party
        ON customer.source = facility_party.source
            AND customer.ods_key = facility_party.customer_ods_key
        JOIN [ODS].[dbo].[facility] facility
        ON facility_party.source = facility.source
            AND facility_party.facility_ods_key = facility.ods_key
    WHERE facility.facility_status_description = 'ACTIVE ACCOUNT'
        AND facility_party.change_type != 'D'
        AND facility.change_type != 'D'
        AND (facility.facility_expiration_datetime >= GETDATE() OR facility.facility_expiration_datetime IS NULL)
        AND customer.source = 'ACBS'
        AND customer.customer_code != '00000000'
        AND customer.change_type != 'D'

    AND customer_code IN ('00206963',
    '00000329',
    '00234014',
    '00003813',
    '00000992',
    '00295195')