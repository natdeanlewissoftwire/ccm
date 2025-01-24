WITH
    acbs_customers
    AS
    (
        SELECT DISTINCT
            customer.source,
            customer.customer_code,
            customer.customer_party_unique_reference_number,
            customer.customer_name,
            customer.customer_duns_number,
            customer.customer_companies_house_number,
            customer.ods_key
        FROM [ODS].[dbo].[customer] customer
            JOIN [ODS].[dbo].[facility_party] facility_party
            ON customer.source = facility_party.source
                AND customer.ods_key = facility_party.customer_ods_key
            JOIN [ODS].[dbo].[facility] facility
            ON facility_party.source = facility.source
                AND facility_party.facility_ods_key = facility.ods_key
        WHERE customer.source = 'ACBS'

            -- AND customer_code IN ('00000341', '00000347', '00000369', '00000378', '00000412', '00000452', '00000462', '00000463', '00000526', '00000527', '00000541', '00000599', '00000603', '00000641', '00000665', '00000874', '00001143', '00001164', '00001167', '00001170', '00001322', '00001355', '00001362', '00001369', '00001439', '00001478', '00001639', '00001700', '00001707', '00001769', '00001797', '00002301', '00002440', '00002448', '00002747', '00003026', '00003027', '00003029', '00003157', '00003579', '00003595', '00003597', '00003606', '00003622', '00003643', '00003650', '00003672', '00003687', '00003702', '00003715', '00003734', '00003896', '00003914', '00003956', '00004011', '00004112', '00004113', '00004131', '00004136', '00004178', '00004215', '00004238', '00004321', '00004348', '00004397', '00004419', '00004432', '00004457', '00004474', '00004522', '00004525', '00004531', '00004535', '00004537', '00004543', '00004580', '00004581', '00004584', '00004591', '00209843', '00210102', '00210614', '00213144', '00213766', '00214423', '00217418', '00221391', '00222703', '00224348', '00224988', '00230129', '00235359', '00237159', '00241998', '00244952', '00244968', '00250455', '00257813', '00258105', '00269905', '00269929', '00273737', '00283003', '00286209', '00289615')
            AND customer_code IN ('00259101', '00261525', '00283193', '00260484')
            -- AND customer_party_unique_reference_number IS NOT NULL
            -- AND facility.facility_status_description = 'ACTIVE ACCOUNT'
            -- --  exclude UKEF records
            -- AND customer.customer_code != '00000000'
            -- --  exclude deleted records
            -- AND customer.change_type != 'D'
            -- AND facility_party.change_type != 'D'
            -- AND facility.change_type != 'D'
    ),
    sf_legacy_customers
    AS
    (
        SELECT *
        FROM [ODS].[dbo].[customer] sf_customers
        WHERE sf_customers.source = 'SalesforceLegacy'
    ),
    sf_customers
    AS
    (
        SELECT *
        FROM [ODS].[dbo].[customer] sf_customers
        WHERE sf_customers.source = 'SalesForce'
    )
-- SELECT acbs_customers.source, acbs_customers.customer_code, acbs_customers.customer_party_unique_reference_number, acbs_customers.customer_name, acbs_customers.customer_duns_number, acbs_customers.customer_companies_house_number, acbs_address.customer_address_street, acbs_address.customer_address_city, acbs_address.customer_address_postcode, acbs_address.customer_address_county_state, acbs_address.customer_address_country,
-- sf_legacy_customers.source, sf_legacy_customers.customer_code, sf_legacy_customers.customer_party_unique_reference_number, sf_legacy_customers.customer_name, sf_legacy_customers.customer_duns_number, sf_legacy_customers.customer_companies_house_number
SELECT *
FROM acbs_customers
    -- JOIN sf_legacy_customers
    -- ON sf_legacy_customers.customer_party_unique_reference_number = acbs_customers.customer_party_unique_reference_number
    -- LEFT JOIN customer_address acbs_address
    -- ON acbs_customers.ods_key = acbs_address.customer_ods_key
    LEFT JOIN customer_address sf_legacy_address
    ON acbs_customers.ods_key = sf_legacy_address.ods_key
