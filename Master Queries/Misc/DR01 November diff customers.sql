SELECT customer.source, customer.customer_name, customer.customer_code, facility.facility_code
FROM facility_party
JOIN facility
ON facility.ods_key = facility_party.facility_ods_key
AND facility.source = facility_party.source
JOIN customer
ON customer.ods_key = facility_party.customer_ods_key
AND customer.source = facility_party.source

WHERE facility_code IN (
    '0020019637', '0020020148', '0020020159', '0020020192', '0020020220', '0020020263', '0020020282', '0020020284', '0020020285', '0020020286', '0020020287', '0020020288', '0020020291', '0020020293', '0020020304', '0020020308', '0020020310', '0020020312', '0020020314', '0020020316', '0020020320', '0020020322', '0020020328', '0020020335', '0020020343', '0020020351', '0020020352', '0020020356', '0020020358', '0020020364', '0020020366', '0020020372', '0020020373', '0020020376', '0020020379', '0020020381', '0020020382', '0020020384', '0020020390', '0020020392', '0020020393', '0020020395', '0020020398', '0020020399', '0020020401', '0020020403', '0020020404', '0020020406', '0020020409', '0020020411', '0020020413', '0020020415', '0020020416', '0020020422', '0020020424', '0020020435', '0020020437', '0020020439', '0020020441', '0020020442', '0020020443', '0020020484', '0020020487', '0020020493', '0020020495', '0020020318', '0020020420', '0020020482', '0020016881'
)
AND customer.source = 'ACBS'