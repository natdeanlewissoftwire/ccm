SELECT *
FROM customer
-- JOIN [ODS].[dbo].[facility_party] facility_party
--                 ON customer.source = facility_party.source
--                     AND customer.ods_key = facility_party.customer_ods_key
--                 JOIN [ODS].[dbo].[facility] facility
--                 ON facility_party.source = facility.source
--                     AND facility_party.facility_ods_key = facility.ods_key
--                 LEFT JOIN [ODS].[dbo].[country] country
--                 ON country.ods_key = facility.country_ods_key

WHERE customer_companies_house_number IS NULL
    AND customer_duns_number IS NOT NULL
    -- AND country.country_iso_3a_code NOT IN ('GBR')

    AND customer_type_description NOT IN ('Overseas Government Dept.', 'Corporate Overseas', 'Overseas Government Dept', 'Overseas Public Body', 'Financial Institution Overseas')
    AND source IN ('SalesForce', 'SalesforceLegacy')
