SELECT DISTINCT
    customer_name,
    customer_code,
    customer_risk_rating.customer_credit_risk_rating_description AS 'Credit Risk Rating',
    customer_risk_parameter_lgd.customer_risk_parameter_value AS 'Loss Given Default',
    CASE 
        WHEN customer.customer_watch_monitor_flag = 1
        THEN 'Watch'
        WHEN customer.customer_watch_monitor_flag = 0
        THEN 'Good'
        ELSE NULL
        END
    AS 'Customer Watch Status',
    customer_classification.classification_group_description AS 'Classification Group Description',
    customer_risk_rating.customer_risk_rating_type_description AS 'Assigned Rating/ECGD Status'
FROM [ODS].[dbo].[customer] customer
    JOIN [ODS].[dbo].[facility_party] facility_party
    ON customer.source = facility_party.source
        AND customer.ods_key = facility_party.customer_ods_key
    JOIN [ODS].[dbo].[facility] facility
    ON facility_party.source = facility.source
        AND facility_party.facility_ods_key = facility.ods_key
    JOIN [ODS].[dbo].[customer_x_classification__relationship]
    ON customer_x_classification__relationship.customer_ods_key = customer.ods_key
        -- AND customer_x_classification__relationship.ods_key LIKE 'PRIMIND#%'
    JOIN [ODS].[dbo].[customer_classification]
    ON customer_x_classification__relationship.classification_ods_key = customer_classification.ods_key
    JOIN [ODS].[dbo].[customer_risk_rating]
    ON customer_risk_rating.customer_ods_key = customer.ods_key
    JOIN [ODS].[dbo].[customer_address]
    ON customer_address.customer_ods_key = customer.ods_key
    JOIN customer_risk_parameter customer_risk_parameter_lgd
    ON customer.ods_key = customer_risk_parameter_lgd.customer_ods_key
        AND customer_risk_parameter_lgd.source = 'ACBS'
        AND customer_risk_parameter_lgd.customer_risk_parameter_code = 'LGD'
        AND customer_risk_parameter_lgd.customer_risk_source_type_code = 'I'
WHERE customer.source = 'ACBS'
    AND facility.facility_status_description = 'ACTIVE ACCOUNT'
    --  exclude UKEF records
    AND customer.customer_code != '00000000'
    --  exclude deleted records
    AND customer.change_type != 'D'
    AND facility_party.change_type != 'D'
    AND facility.change_type != 'D'

AND  customer_code IN
('00227259',
'00293671',
'00247329',
'00293851',
'00255249',
'00286825')
AND classification_group_description IS NOT NULL