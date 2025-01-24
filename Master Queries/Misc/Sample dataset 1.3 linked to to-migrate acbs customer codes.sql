WITH
    cleaned_names
    AS
    (
        SELECT DISTINCT
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
    ),
    acbs_cleaned_names
    AS
    (
        SELECT DISTINCT
            source,
            customer_name,
            customer_party_unique_reference_number,
            cleaned_name,
            customer_code,
            ods_key
        FROM (
            SELECT DISTINCT
                cleaned_names.source,
                cleaned_names.customer_code,
                cleaned_names.customer_party_unique_reference_number,
                cleaned_names.customer_name,
                cleaned_names.cleaned_name,
                ods_key
            FROM cleaned_names
            WHERE cleaned_names.source = 'ACBS'
                -- AND cleaned_names.customer_code != '00000000'
                -- AND cleaned_names.change_type != 'D'
                AND cleaned_names.customer_code IN (
                    '00000329', '00000335', '00000336', '00000345', '00000347', '00000354', '00000365', '00000366', '00000367', '00000369', '00000370', '00000372', '00000374', '00000375', '00000376', '00000378', '00000380', '00000386', '00000388', '00000397', '00000402', '00000412', '00000414', '00000430', '00000431', '00000432', '00000444', '00000464', '00000467', '00000472', '00000475', '00000507', '00000508', '00000511', '00000513', '00000514', '00000516', '00000520', '00000529', '00000539', '00000557', '00000596', '00000613', '00000672', '00000693', '00000694', '00000725', '00000726', '00000727', '00000740', '00000742', '00000743', '00000744', '00000745', '00000746', '00000748', '00000749', '00000750', '00000751', '00000752', '00000753', '00000764', '00000765', '00000767', '00000768', '00000772', '00000775', '00000776', '00000777', '00000779', '00000782', '00000787', '00000793', '00000797', '00000802', '00000803', '00000814', '00000816', '00000818', '00000819', '00000824', '00000831', '00000836', '00000850', '00000863', '00000866', '00000867', '00000870', '00000871', '00000873', '00000874', '00000876', '00000890', '00000900', '00000907', '00000990', '00000991', '00000992', '00001003', '00001008', '00001011', '00001013', '00001015', '00001018', '00001134', '00001137', '00001143', '00001149', '00001151', '00001164', '00001173', '00001189', '00001200', '00001213', '00001231', '00001244', '00001255', '00001319', '00001345', '00001377', '00001438', '00001454', '00001478', '00001493', '00001524', '00001539', '00001586', '00001614', '00001668', '00001688', '00001702', '00001703', '00001705', '00001728', '00001734', '00001736', '00001755', '00001771', '00001793', '00001820', '00001824', '00001838', '00001872', '00001873', '00001877', '00001881', '00001889', '00001890', '00001892', '00001895', '00001896', '00001901', '00001902', '00001910', '00001913', '00001919', '00001920', '00001921', '00001923', '00001924', '00001926', '00001927', '00001932', '00001941', '00001942', '00001944', '00001951', '00001956', '00001957', '00001958', '00001959', '00001963', '00001975', '00001976', '00001984', '00001985', '00001986', '00001987', '00001991', '00001992', '00001993', '00001995', '00001996', '00001997', '00001998', '00002000', '00002001', '00002003', '00002004', '00002005', '00002012', '00002018', '00002022', '00002026', '00002029', '00002049', '00002056', '00002066', '00002068', '00002088', '00002094', '00002096', '00002102', '00002104', '00002107', '00002111', '00002113', '00002116', '00002118', '00002120', '00002135', '00002137', '00002138', '00002141', '00002142', '00002152', '00002158', '00002159', '00002165', '00002166', '00002167', '00002168', '00002172', '00002174', '00002183', '00002194', '00002211', '00002219', '00002220', '00002223', '00002225', '00002238', '00002239', '00002241', '00002255', '00002256', '00002265', '00002268', '00002270', '00002271', '00002278', '00002280', '00002281', '00002283', '00002285', '00002288', '00002291', '00002293', '00002353', '00002357', '00002371', '00002373', '00002376', '00002378', '00002386', '00002388', '00002389', '00002390', '00002391', '00002468', '00002485', '00002491', '00002494', '00002495', '00002502', '00002517', '00002519', '00002532', '00002538', '00002552', '00002581', '00002582', '00002586', '00002587', '00002590', '00002593', '00002596', '00002603', '00002605', '00002612', '00002613', '00002632', '00002634', '00002641', '00002690', '00002700', '00002704', '00002711', '00002712', '00002716', '00002719', '00002721', '00002747', '00002758', '00002759', '00002760', '00002761', '00002765', '00002781', '00002800', '00002801', '00002803', '00002806', '00002813', '00002817', '00002819', '00002825', '00002827', '00002833', '00002839', '00002843', '00002845', '00002847', '00002856', '00002857', '00002859', '00002860', '00002861', '00002868', '00002869', '00002870', '00002908', '00002920', '00002923', '00002926', '00002929', '00002932', '00002935', '00002937', '00002942', '00002944', '00002947', '00002948', '00002949', '00002956', '00002958', '00002961', '00002962', '00002964', '00002966', '00002979', '00002983', '00002988', '00002989', '00002991', '00002994', '00003035', '00003040', '00003044', '00003046', '00003047', '00003053', '00003054', '00003059', '00003068', '00003077', '00003086', '00003088', '00003092', '00003106', '00003127', '00003134', '00003148', '00003150', '00003155', '00003157', '00003165', '00003166', '00003168', '00003170', '00003172', '00003175', '00003179', '00003183', '00003185', '00003193', '00003209', '00003210', '00003216', '00003217', '00003218', '00003220', '00003221', '00003222', '00003223', '00003239', '00003246', '00003257', '00003258', '00003260', '00003263', '00003279', '00003280', '00003282', '00003284', '00003293', '00003296', '00003301', '00003317', '00003318', '00003320', '00003321', '00003323', '00003324', '00003325', '00003326', '00003327', '00003328', '00003329', '00003330', '00003331', '00003345', '00003346', '00003347', '00003348', '00003361', '00003364', '00003365', '00003367', '00003368', '00003369', '00003370', '00003372', '00003375', '00003376', '00003378', '00003383', '00003387', '00003389', '00003393', '00003397', '00003404', '00003409', '00003412', '00003415', '00003418', '00003433', '00003456', '00003459', '00003465', '00003470', '00003472', '00003478', '00003479', '00003484', '00003485', '00003488', '00003495', '00003497', '00003498', '00003505', '00003509', '00003510', '00003511', '00003512', '00003516', '00003517', '00003518', '00003521', '00003523', '00003559', '00003561', '00003582', '00003585', '00003590', '00003593', '00003599', '00003606', '00003607', '00003620', '00003648', '00003671', '00003672', '00003675', '00003677', '00003681', '00003682', '00003684', '00003687', '00003691', '00003692', '00003694', '00003696', '00003700', '00003702', '00003704', '00003722', '00003726', '00003732', '00003733', '00003748', '00003759', '00003761', '00003764', '00003774', '00003781', '00003808', '00003813', '00003816', '00003819', '00003847', '00003849', '00003850', '00003851', '00003852', '00003853', '00003854', '00003856', '00003857', '00003861', '00003866', '00003868', '00003874', '00003877', '00003892', '00003894', '00003895', '00003902', '00003925', '00003936', '00003947', '00003964', '00003968', '00003969', '00003972', '00003983', '00003984', '00003986', '00003988', '00003995', '00004021', '00004028', '00004029', '00004030', '00004031', '00004035', '00004040', '00004052', '00004054', '00004055', '00004056', '00004057', '00004059', '00004060', '00004061', '00004066', '00004079', '00004084', '00004088', '00004102', '00004109', '00004112', '00004113', '00004122', '00004130', '00004136', '00004140', '00004143', '00004146', '00004163', '00004175', '00004178', '00004179', '00004202', '00004211', '00004212', '00004213', '00004215', '00004220', '00004235', '00004237', '00004242', '00004250', '00004266', '00004268', '00004285', '00004287', '00004296', '00004297', '00004300', '00004301', '00004328', '00004329', '00004332', '00004333', '00004334', '00004343', '00004344', '00004345', '00004363', '00004370', '00004375', '00004377', '00004378', '00004385', '00004391', '00004393', '00004399', '00004401', '00004402', '00004403', '00004404', '00004407', '00004409', '00004410', '00004411', '00004412', '00004416', '00004419', '00004427', '00004434', '00004445', '00004450', '00004452', '00004453', '00004457', '00004459', '00004461', '00004462', '00004464', '00004465', '00004470', '00004471', '00004474', '00004479', '00004486', '00004489', '00004492', '00004506', '00004515', '00004516', '00004517', '00004527', '00004529', '00004537', '00004543', '00004544', '00004549', '00004551', '00004553', '00004554', '00004555', '00004566', '00004567', '00004570', '00004574', '00004576', '00004580', '00004581', '00004583', '00004586', '00004594', '00004598', '00004599', '00004601', '00005599', '00005600', '00005601', '00005603', '00005604', '00005605', '00005606', '00005608', '00005609', '00005610', '00005611', '00005613', '00005614', '00005616', '00005617', '00005618', '00005619', '00005622', '00005623', '00005625', '00005626', '00005630', '00005631', '00005634', '00005635', '00005637', '00005640', '00005641', '00005643', '00005646', '00005647', '00005648', '00005649', '00005652', '00005653', '00005654', '00005655', '00005657', '00005659', '00005661', '00005663', '00005664', '00005666', '00005668', '00005669', '00005670', '00005672', '00005675', '00005707', '00005714', '00005715', '00005716', '00005717', '00005718', '00005719', '00005720', '00005721', '00005722', '00005723', '00005724', '00005725', '00005726', '00005727', '00005728', '00005729', '00005730', '00005731', '00005732', '00005733', '00005734', '00005735', '00005736', '00005737', '00005738', '00005739', '00005740', '00005741', '00005742', '00005743', '00005745', '00005746', '00005747', '00005748', '00005749', '00005750', '00005754', '00005756', '00005763', '00005766', '00005770', '00005773', '00005774', '00005776', '00005786', '00201221', '00201419', '00204314', '00204831', '00205545', '00205551', '00206528', '00206901', '00206963', '00206972', '00207165', '00207872', '00208027', '00208071', '00208328', '00208554', '00208636', '00209598', '00209837', '00210156', '00210344', '00210614', '00210848', '00211121', '00211478', '00211524', '00211537', '00211552', '00211568', '00211575', '00211599', '00212617', '00212632', '00213005', '00213011', '00213784', '00214461', '00214584', '00214774', '00215175', '00215584', '00215631', '00216497', '00216978', '00217245', '00217521', '00217629', '00217891', '00220319', '00220434', '00220665', '00221295', '00221316', '00221324', '00221443', '00221481', '00221738', '00221769', '00221931', '00222067', '00223252', '00223404', '00223603', '00223864', '00224233', '00224271', '00224348', '00224355', '00224535', '00224708', '00224854', '00225556', '00225744', '00225909', '00225947', '00226194', '00226374', '00226546', '00226795', '00226853', '00227259', '00227297', '00227302', '00227791', '00227814', '00228264', '00228473', '00229585', '00229789', '00230406', '00230424', '00230514', '00230655', '00231253', '00231375', '00231946', '00232019', '00232162', '00232538', '00232545', '00232731', '00232749', '00232764', '00232944', '00233265', '00233618', '00233844', '00233995', '00234014', '00234024', '00234075', '00234171', '00234351', '00234459', '00234466', '00234608', '00234639', '00235027', '00235042', '00235065', '00235303', '00235359', '00235816', '00235885', '00235891', '00236138', '00236145', '00236814', '00236965', '00237038', '00237076', '00237519', '00237544', '00237557', '00237563', '00237678', '00237685', '00237691', '00238495', '00238562', '00238907', '00239108', '00239642', '00239689', '00239732', '00239935', '00239974', '00239997', '00240005', '00240324', '00240458', '00240465', '00240471', '00240504', '00240684', '00241178', '00241268', '00241327', '00241432', '00241494', '00242233', '00242271', '00242348', '00242361', '00242379', '00243593', '00244359', '00244763', '00244795', '00245017', '00245169', '00245483', '00245747', '00246135', '00246184', '00246444', '00247035', '00247174', '00247329', '00247524', '00247652', '00247742', '00247765', '00247771', '00248491', '00248614', '00248627', '00248959', '00248966', '00249198', '00249514', '00249722', '00249738', '00249828', '00250088', '00250206', '00250342', '00250603', '00250659', '00250749', '00250883', '00251332', '00251379', '00251484', '00251777', '00251867', '00251934', '00252403', '00252518', '00252549', '00252593', '00252872', '00253096', '00253117', '00253508', '00254017', '00254138', '00254387', '00254393', '00254505', '00254598', '00254601', '00254881', '00255249', '00255287', '00255411', '00256035', '00256074', '00256553', '00256591', '00256714', '00256727', '00257049', '00257604', '00257689', '00257984', '00258092', '00258105', '00258527', '00258828', '00259067', '00259073', '00259082', '00259098', '00259101', '00259144', '00259622', '00259638', '00259645', '00259908', '00260047', '00260062', '00260175', '00260181', '00260407', '00260413', '00260422', '00260484', '00260559', '00260693', '00261525', '00261677', '00261773', '00262027', '00262213', '00262554', '00262719', '00263086', '00263297', '00263408', '00264084', '00264231', '00264662', '00264752', '00264889', '00264904', '00265012', '00265084', '00265699', '00265938', '00265951', '00266164', '00267234', '00267272', '00267859', '00268082', '00268101', '00268381', '00268442', '00268465', '00269109', '00269365', '00269674', '00269684', '00269846', '00269929', '00270441', '00270857', '00270863', '00270872', '00270888', '00270895', '00270909', '00270916', '00270924', '00270934', '00271027', '00271089', '00271161', '00271207', '00271213', '00271245', '00271682', '00271763', '00271772', '00271788', '00272194', '00272203', '00272212', '00272778', '00272958', '00273346', '00273473', '00273482', '00273498', '00273534', '00273647', '00273653', '00273662', '00273775', '00273858', '00273889', '00273896', '00273932', '00274084', '00274131', '00274254', '00274277', '00274283', '00274292', '00274305', '00274354', '00274398', '00274401', '00274426', '00274614', '00274624', '00274637', '00274714', '00274727', '00274733', '00274742', '00274823', '00274976', '00274984', '00274994', '00275002', '00275154', '00275244', '00275334', '00275357', '00275434', '00275514', '00275614', '00275748', '00275822', '00275903', '00275912', '00275928', '00275935', '00275941', '00275959', '00275966', '00275974', '00275984', '00275997', '00276008', '00276015', '00276021', '00276111', '00276136', '00276288', '00276949', '00276956', '00276974', '00277011', '00277082', '00277216', '00277224', '00277234', '00277433', '00277442', '00277504', '00277517', '00277613', '00277622', '00277645', '00277728', '00277735', '00277774', '00277784', '00277797', '00277802', '00277818', '00277825', '00277831', '00277849', '00277856', '00277864', '00277874', '00277954', '00277964', '00277977', '00278001', '00278019', '00278034', '00278057', '00278063', '00278116', '00278224', '00278268', '00278275', '00278327', '00278507', '00278551', '00278569', '00278756', '00278764', '00278774', '00278808', '00278821', '00279175', '00279355', '00279394', '00279528', '00279602', '00279649', '00279721', '00279777', '00279792', '00279811', '00279829', '00279836', '00279844', '00279854', '00279934', '00279944', '00279957', '00279963', '00279988', '00279995', '00280014', '00280027', '00280033', '00280042', '00280132', '00280148', '00280155', '00280161', '00280238', '00280276', '00280384', '00280397', '00280418', '00280508', '00280611', '00280701', '00281113', '00281415', '00281634', '00281753', '00281762', '00281785', '00281814', '00282264', '00282377', '00282383', '00282392', '00282685', '00282804', '00282986', '00283193', '00283208', '00283215', '00283221', '00283457', '00283463', '00283606', '00283727', '00283789', '00283796', '00283804', '00283817', '00283832', '00283848', '00283879', '00283938', '00283951', '00283969', '00283976', '00284049', '00284093', '00284108', '00284115', '00284177', '00284183', '00284273', '00284334', '00284344', '00284424', '00284447', '00284453', '00284462', '00284575', '00284614', '00284633', '00284665', '00284671', '00284732', '00284755', '00284822', '00285077', '00285136', '00285154', '00285198', '00285201', '00285234', '00285244', '00285263', '00285272', '00285288', '00285353', '00285406', '00285414', '00285437', '00285443', '00285514', '00285533', '00285558', '00285565', '00285596', '00285617', '00285794', '00285812', '00285828', '00285866', '00285987', '00285993', '00286144', '00286157', '00286172', '00286209', '00286234', '00286253', '00286278', '00286291', '00286375', '00286381', '00286399', '00286414', '00286458', '00286517', '00286523', '00286555', '00286613', '00286669', '00286676', '00286694', '00286728', '00286735', '00286741', '00286759', '00286784', '00286825', '00286849', '00286856', '00286864', '00286874', '00286887', '00286893', '00286939', '00287057', '00287095', '00287109', '00287124', '00287178', '00287191', '00287214', '00287224', '00287268', '00287281', '00287304', '00287327', '00287333', '00287342', '00287389', '00287417', '00287432', '00287461', '00287479', '00287507', '00287569', '00287576', '00287584', '00287594', '00287603', '00287635', '00287641', '00287659', '00287697', '00287702', '00287718', '00287749', '00287756', '00287764', '00287787', '00287793', '00287815', '00287854', '00287929', '00287936', '00287944', '00287954', '00287967', '00287998', '00288009', '00288016', '00288062', '00288078', '00288091', '00288106', '00288114', '00288137', '00288143', '00288152', '00288168', '00288175', '00288199', '00288214', '00288227', '00288265', '00288271', '00288289', '00288296', '00288304', '00288323', '00288348', '00288355', '00288386', '00288394', '00288413', '00288422', '00288438', '00288476', '00288512', '00288535', '00288602', '00288618', '00288649', '00288664', '00288693', '00288715', '00288721', '00288739', '00288764', '00288777', '00288783', '00288805', '00288829', '00288844', '00288854', '00288898', '00288919', '00288926', '00288934', '00288944', '00288957', '00288963', '00288972', '00288988', '00289014', '00289024', '00289037', '00289075', '00289099', '00289104', '00289114', '00289142', '00289165', '00289189', '00289204', '00289286', '00289294', '00289313', '00289322', '00289338', '00289345', '00289351', '00289369', '00289376', '00289394', '00289441', '00289466', '00289497', '00289518', '00289549', '00289556', '00289564', '00289574', '00289608', '00289615', '00289639', '00289664', '00289677', '00289683', '00289692', '00289705', '00289801', '00289863', '00289872', '00289978', '00289985', '00289991', '00290004', '00290017', '00290023', '00290055', '00290079', '00290113', '00290169', '00290194', '00290228', '00290235', '00290284', '00290297', '00290302', '00290318', '00290331', '00290356', '00290387', '00290393', '00290464', '00290483', '00290492', '00290511', '00290529', '00290536', '00290544', '00290554', '00290567', '00290573', '00290582', '00290598', '00290601', '00290619', '00290626', '00290634', '00290644', '00290663', '00290672', '00290709', '00290734', '00290747', '00290753', '00290785', '00290824', '00290837', '00290843', '00290852', '00290868', '00290875', '00290881', '00290899', '00290965', '00290989', '00291007', '00291013', '00291051', '00291094', '00291103', '00291141', '00291159', '00291166', '00291174', '00291184', '00291197', '00291202', '00291218', '00291231', '00291249', '00291256', '00291293', '00291308', '00291392', '00291411', '00291429', '00291444', '00291454', '00291467', '00291473', '00291482', '00291526', '00291588', '00291616', '00291634', '00291647', '00291653', '00291662', '00291678', '00291685', '00291691', '00291706', '00291714', '00291743', '00291768', '00291775', '00291799', '00291814', '00291827', '00291833', '00291858', '00291865', '00291871', '00291889', '00291896', '00291904', '00291917', '00291923', '00291948', '00291955', '00291961', '00292156', '00292164', '00292174', '00292187', '00292193', '00292208', '00292215', '00292239', '00292246', '00292254', '00292264', '00292277', '00292283', '00292292', '00292305', '00292336', '00292344', '00292354', '00292367', '00292382', '00292398', '00292401', '00292426', '00292434', '00292444', '00292457', '00292463', '00292472', '00292488', '00292495', '00292509', '00292516', '00292553', '00292578', '00292585', '00292591', '00292614', '00292624', '00292637', '00292643', '00292652', '00292668', '00292681', '00292727', '00292733', '00292758', '00292765', '00292771', '00292789', '00292804', '00292817', '00292823', '00292832', '00292855', '00292861', '00292879', '00292894', '00292907', '00292913', '00292922', '00292938', '00292945', '00292951', '00292969', '00292976', '00292984', '00292994', '00293018', '00293025', '00293056', '00293064', '00293074', '00293087', '00293093', '00293108', '00293115', '00293139', '00293146', '00293154', '00293183', '00293205', '00293236', '00293244', '00293254', '00293267', '00293273', '00293298', '00293301', '00293326', '00293334', '00293344', '00293357', '00293363', '00293372', '00293395', '00293416', '00293424', '00293434', '00293447', '00293506', '00293524', '00293537', '00293543', '00293552', '00293568', '00293581', '00293599', '00293604', '00293614', '00293627', '00293658', '00293665', '00293671', '00293704', '00293717', '00293723', '00293732', '00293748', '00293761', '00293786', '00293794', '00293807', '00293851', '00293869', '00293876', '00293884', '00293894', '00293903', '00293912', '00293928', '00293935', '00293959', '00293966', '00293974', '00293984', '00293997', '00294008', '00294015', '00294021', '00294039', '00294046', '00294054', '00294064', '00294077', '00294083', '00294111', '00294129', '00294136', '00294144', '00294154', '00294182', '00294198', '00294201', '00294219', '00294226', '00294234', '00294244', '00294263', '00294272', '00294288', '00294316', '00294324', '00294347', '00294353', '00294362', '00294378', '00294385', '00294391', '00294406', '00294424', '00294437', '00294443', '00294452', '00294481', '00294499', '00294504', '00294514', '00294623', '00294632', '00294648', '00294655', '00294661', '00294679', '00294686', '00294694', '00294713', '00294722', '00294769', '00294776', '00294784', '00294812', '00294828', '00294841', '00294859', '00294884', '00294902', '00294918', '00294925', '00294931', '00294949', '00294956', '00294964', '00294974', '00294987', '00295005', '00295011', '00295036', '00295044', '00295054', '00295067', '00295073', '00295082', '00295098', '00295101', '00295119', '00295126', '00295134', '00295144', '00295157', '00295163', '00295195', '00295209', '00295216', '00295224', '00295253', '00295262', '00295278', '00295285', '00295291', '00295306', '00295314', '00295337', '00295343', '00295352', '00295368', '00295375', '00295399', '00295404', '00295414', '00295427', '00295442', '00295458', '00295496', '00295504', '00295517', '00295532', '00295548', '00295561', '00295579', '00295607', '00295613', '00295622', '00295638', '00295645', '00295651', '00295669', '00295676', '00295684', '00295703', '00295712', '00295728', '00295735', '00295741', '00295759', '00295766', '00295774', '00295784', '00295818', '00295856', '00295864', '00295874', '00295887', '00295893', '00295908', '00295915', '00295939', '00295954', '00295983', '00295992', '00296001', '00296019', '00296116', '00296124', '00296134', '00296147', '00296153', '00296178', '00296185', '00296191', '00296206', '00296214', '00296224', '00296237', '00296243', '00296252', '00296268', '00296275', '00296281', '00296314', '00296327', '00296333', '00296342', '00296358', '00296365', '00296371', '00296389', '00296396', '00296404', '00296417', '00296423', '00296432', '00296448', '00296461', '00296479', '00296486', '00296494', '00296507', '00296513', '00296522', '00296551', '00296569', '00296576', '00296584', '00296594', '00296603', '00296612', '00296628', '00296635', '00296641', '00296659', '00296666', '00296684', '00296697', '00296702', '00296725', '00296749', '00296764', '00296774', '00296808', '00296815', '00296821', '00296839', '00296854', '00296864', '00296877', '00296883', '00296892', '00296905', '00296911', '00296936', '00296944', '00296967', '00296973', '00296982', '00296998', '00297016', '00297024', '00297034', '00297047', '00297053', '00297062', '00297085', '00297091', '00297114', '00297137', '00297143', '00297168', '00297181', '00297199', '00297204', '00297227', '00297233', '00297242', '00297258', '00297265', '00297271', '00297296', '00297323', '00297332', '00297348', '00297355', '00297361', '00297386', '00297413', '00297422', '00297438', '00297445', '00297469', '00297476', '00297484'
                )
        ) AS acbs_customers
    ),
    acbs_cleaned_names_linked_to_active_facilities
    AS
    (
        SELECT DISTINCT
            acbs_cleaned_names.source,
            acbs_cleaned_names.customer_name,
            acbs_cleaned_names.customer_code,
            acbs_cleaned_names.customer_party_unique_reference_number,
            acbs_cleaned_names.cleaned_name,
            acbs_cleaned_names.ods_key
        FROM acbs_cleaned_names
            JOIN [ODS].[dbo].[facility_party] facility_party
            ON acbs_cleaned_names.source = facility_party.source
                AND acbs_cleaned_names.ods_key = facility_party.customer_ods_key
            JOIN [ODS].[dbo].[facility] facility
            ON facility_party.source = facility.source
                AND facility_party.facility_ods_key = facility.ods_key
        -- WHERE facility.facility_status_description = 'ACTIVE ACCOUNT'
        --     AND facility_party.change_type != 'D'
        --     AND facility.change_type != 'D'
    ),
    distinct_acbs_cleaned_names_linked_to_active_facilities
    AS
    (
        SELECT DISTINCT cleaned_name
        FROM acbs_cleaned_names_linked_to_active_facilities
    ),
    sf_customers
    AS
    (
        SELECT DISTINCT
            customer.source,
            customer.customer_code,
            customer.customer_party_unique_reference_number,
            customer.customer_name
        FROM [ODS].[dbo].[customer] customer
        WHERE customer.source IN ('SalesForce', 'SalesforceLegacy')
            --  exclude UKEF records
            AND customer.customer_code != '00000000'
            --  exclude deleted records
            AND customer.change_type != 'D'
    ),
    distinct_facility_and_party_types
    AS
    (
        SELECT
            all_facility_and_party_types.ods_key,
            STRING_AGG(CAST(facility_type_description AS NVARCHAR(MAX)), CHAR(10)) AS customer_facility_types,
            STRING_AGG(CAST(facility_party_role_type_description AS NVARCHAR(MAX)), CHAR(10)) AS customer_facility_party_role_types
        FROM (
            SELECT
                acbs_cleaned_names_linked_to_active_facilities.ods_key,
                acbs_cleaned_names_linked_to_active_facilities.source,
                acbs_cleaned_names_linked_to_active_facilities.customer_code,
                acbs_cleaned_names_linked_to_active_facilities.customer_party_unique_reference_number,
                acbs_cleaned_names_linked_to_active_facilities.customer_name,
                facility.facility_type_description,
                facility_party.facility_party_role_type_description
            FROM acbs_cleaned_names_linked_to_active_facilities
                JOIN [ODS].[dbo].[facility_party] facility_party
                ON acbs_cleaned_names_linked_to_active_facilities.source = facility_party.source
                    AND acbs_cleaned_names_linked_to_active_facilities.ods_key = facility_party.customer_ods_key
                JOIN [ODS].[dbo].[facility] facility
                ON facility_party.source = facility.source
                    AND facility_party.facility_ods_key = facility.ods_key
            GROUP BY 
        acbs_cleaned_names_linked_to_active_facilities.ods_key, 
        acbs_cleaned_names_linked_to_active_facilities.source, 
        acbs_cleaned_names_linked_to_active_facilities.customer_code, 
        acbs_cleaned_names_linked_to_active_facilities.customer_party_unique_reference_number, 
        acbs_cleaned_names_linked_to_active_facilities.customer_name, 
        facility.facility_type_description,
        facility_party.facility_party_role_type_description
        ) AS all_facility_and_party_types
        GROUP BY 
            ods_key,
            source, 
            customer_code, 
            customer_party_unique_reference_number, 
            customer_name
    )

SELECT distinct_acbs_cleaned_names_linked_to_active_facilities.cleaned_name AS 'Fuzzy group',
    acbs_cleaned_names.customer_name AS 'ACBS Customer Name',
    CASE
    WHEN EXISTS (
        SELECT *
        FROM acbs_cleaned_names_linked_to_active_facilities
        WHERE acbs_cleaned_names_linked_to_active_facilities.ods_key = acbs_cleaned_names.ods_key
    ) THEN 'Yes'
    ELSE 'No'
    END
    AS 'ACBS record linked to active facilities?',
    acbs_cleaned_names.customer_code  AS 'ACBS Customer Code',
    acbs_cleaned_names.customer_party_unique_reference_number  AS 'ACBS Customer URN (A1)',
    CASE
    WHEN acbs_cleaned_names.customer_party_unique_reference_number IS NOT NULL
        AND EXISTS (
    SELECT *
        FROM [ODS].[dbo].[customer] salesforce
        WHERE salesforce.source = 'SalesForce'
            AND salesforce.customer_party_unique_reference_number = acbs_cleaned_names.customer_party_unique_reference_number
    ) THEN 'Yes'
    ELSE 'No'
    END
    AS 'URN present in SalesForce (A2)',
    CASE
        WHEN acbs_cleaned_names.customer_party_unique_reference_number IS NOT NULL
        AND EXISTS (
    SELECT *
        FROM [ODS].[dbo].[customer] salesforce_legacy
        WHERE salesforce_legacy.source = 'SalesforceLegacy'
            AND salesforce_legacy.customer_party_unique_reference_number = acbs_cleaned_names.customer_party_unique_reference_number
)
        AND NOT EXISTS (
    SELECT *
        FROM [ODS].[dbo].[customer] salesforce
        WHERE salesforce.source = 'SalesForce'
            AND salesforce.customer_party_unique_reference_number = acbs_cleaned_names.customer_party_unique_reference_number
) THEN 'Yes'
ELSE 'No'
    END
    AS 'ACBS URN is only present in Salesforce Legacy Data (A4)',
    -- acbs_cleaned_names.customer_name AS 'Fuzzy-Matching ACBS Customer Name',
    -- acbs_cleaned_names.customer_code AS 'Fuzzy-Matching ACBS Customer Code',
    -- acbs_cleaned_names.customer_party_unique_reference_number  AS 'Fuzzy-Matching ACBS Customer URN'
    sf_customers.customer_party_unique_reference_number AS 'URN-Matching Salesforce Customer URN',
    sf_customers.customer_name AS 'URN-Matching Salesforce Customer Name',
    sf_customers.customer_code AS 'URN-Matching Salesforce Customer Code',
    CASE
        WHEN sf_customers.customer_party_unique_reference_number IS NOT NULL
        AND EXISTS (
    SELECT *
        FROM [ODS].[dbo].[customer] salesforce_legacy
        WHERE salesforce_legacy.source = 'SalesforceLegacy'
            AND salesforce_legacy.customer_party_unique_reference_number = sf_customers.customer_party_unique_reference_number
)
        AND NOT EXISTS (
    SELECT *
        FROM [ODS].[dbo].[customer] salesforce
        WHERE salesforce.source = 'SalesForce'
            AND salesforce.customer_party_unique_reference_number = sf_customers.customer_party_unique_reference_number
) THEN 'Yes'
ELSE 'No'
    END
    AS 'URN-Matching Salesforce URN is only present in Salesforce Legacy Data',
    distinct_facility_and_party_types.customer_facility_types AS 'Customer facility types',
    distinct_facility_and_party_types.customer_facility_party_role_types AS 'Customer facility party role types'


FROM distinct_acbs_cleaned_names_linked_to_active_facilities
    -- JOIN acbs_cleaned_names_linked_to_active_facilities
    -- ON distinct_acbs_cleaned_names_linked_to_active_facilities.cleaned_name = acbs_cleaned_names_linked_to_active_facilities.cleaned_name
    LEFT JOIN acbs_cleaned_names
    ON distinct_acbs_cleaned_names_linked_to_active_facilities.cleaned_name = acbs_cleaned_names.cleaned_name
    LEFT JOIN sf_customers
    ON acbs_cleaned_names.customer_party_unique_reference_number = sf_customers.customer_party_unique_reference_number
    LEFT JOIN distinct_facility_and_party_types
    ON acbs_cleaned_names.ods_key = distinct_facility_and_party_types.ods_key

ORDER BY distinct_acbs_cleaned_names_linked_to_active_facilities.cleaned_name

--  2848 active ACBS records -> 3764 total results with dupes for multi SF matches on URN and non-active ACBS records
