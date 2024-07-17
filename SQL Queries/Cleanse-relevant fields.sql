SELECT [source]
      ,[ods_key]
      ,[customer_code]
      ,[customer_party_unique_reference_number]
      ,[customer_companies_house_number]
      ,[customer_duns_number]
      ,[customer_name]
      ,[customer_short_name]
      ,[customer_type_description]
      ,[customer_status_description]
      ,[customer_last_modified_datetime]
      ,[change_datetime]
      ,[create_datetime]
  FROM [ODS].[dbo].[customer]
  WHERE source IN ('ACBS','SalesForce','SalesforceLegacy')