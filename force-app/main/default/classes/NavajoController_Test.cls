/**
 * @description       : Test class for NavajoController
 * @author            : Rajnikanth 
 * @group             : 
 * @last modified on  : 06-13-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   07-21-2020   Rajnikanth                  Initial Version
 * 1.1   06-13-2022   Ethan Hirsch @ Zoetis Inc   Remove creation of Case Trigger Activation as 
 *                                                Case has been migrated to use the Metadata Trigger Framework.
 * 1.2   07-25-2022   Ethan Hirsch @ Zoetis Inc   Fix test_CancellationTranslation to capture error message for 
 *                                                assertion by Type and Bit Position.
**/
@isTest
public class NavajoController_Test {
    /***********************************************************
    @method     	setupData
    @brief      	Generates test data for Account, Diagnostic Error Codes, Material, Product, Rotor Lot objects

    ***********************************************************/
    @testSetup
    public static void setupData()
    {
        List<TriggerActivation__c> triggerActiveList = new List<TriggerActivation__c>();
        TriggerActivation__c tr = new TriggerActivation__c(Name = 'ZTS_EU_ServiceRequest',ZTS_EU_Bypass__c = true);
        triggerActiveList.add(tr);
        insert triggerActiveList;

        User u = getUserRecord('System Administrator','Canada');
        Account objAcc;
        System.runAs(u){
            objAcc = (Account)SL_TestDataFactory.createSObject(new Account( Name = 'Test Company for Case', 
                                                                                   ZTS_EU_Market__c = 'Baltics', 
                                                                                   ZTS_EU_VAT_Code__c='00011',
                                                                                   ZTS_EU_Account_Status__c='Active',
                                                                                   ZTS_EU_Zip_Postal_Code__c ='07306'), true);        
        }
        // diagnostic error code for suppression ; SXN-XXXXXXX
        Diagnostics_Error_Codes__c sxnCode = (Diagnostics_Error_Codes__c)SL_TestDataFactory.createSObject(
            													new Diagnostics_Error_Codes__c(Name = 'SXN-0000190', Active__c = true), true);
        // diagnostic error code for cancellation ; ERR-XXXXXXX
        Diagnostics_Error_Codes__c errCode = (Diagnostics_Error_Codes__c)SL_TestDataFactory.createSObject(
            													new Diagnostics_Error_Codes__c(Name = 'ERR-0000190', Active__c = true), true);
        // SAP Material for product creation
        SAP_Material__c objSAPM = (SAP_Material__c)SL_TestDataFactory.createSObject(new SAP_Material__c(SAP_Item_Category_Group__c = 'NORM',
                                                                                                        SAP_Product_Number__c = 'TestProductID132'),
                                                                                    true);
        // Product record creation for lot record
        Product2 objProd = (Product2)SL_TestDataFactory.createSObject(new Product2(Name = 'Test Product',
                                                                                   IsActive = true,
                                                                                   ProductCode = '123456',
                                                                                   Product_External_ID__c = '10023208',
                                                                                   Chemistries__c = 'ALB;GLOB;NA+;MG',
                                                                                   SAP_Material__c = objSAPM.Id), true);
        // Rotor Lot record.
        Rotor_Lot__c lotRecord = new Rotor_Lot__c(Product__c = objProd.id,Manufactured_Date__c = date.today(),
                                                 Lot__c = '9512AA2', Expiry_Date__c = date.today().addDays(365));
        insert lotRecord;
        List<Case> caseRecords = new List<Case>();
        String diagRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Diagnostics').getRecordTypeId();
        // Diagnostic Case with SXN;
        Case sxnCase = new Case(AccountId = objAcc.Id,
                                  RecordTypeId = diagRecordTypeId,
                                  Status = 'New',
                                  Origin = 'Email',
                                  Specimen__c = 'Dog',
                                  Type = 'Other',
                                  Subject = 'Test Navajo 1',
                                  Description = 'Test',
                               	  Primary_Error_Code__c = sxnCode.Id,
                                  Primary_Lot_Num__c = '9512AA2'
                               );
        caseRecords.add(sxnCase);
        // Diagnostic Case with ERR
        Case errCase = new Case(AccountId = objAcc.Id,
                                  RecordTypeId = diagRecordTypeId,
                                  Status = 'New',
                                  Origin = 'Email',
                                  Specimen__c = 'Dog',
                                  Type = 'Other',
                                  Subject = 'Test Navajo 1',
                                  Description = 'Test',
                               	  Primary_Error_Code__c = errCode.Id,
                                  Primary_Lot_Num__c = '9512AA2'
                               );
        caseRecords.add(errCase);
        // Diagnostic case with no lot#
        Case noLotCase = new Case(AccountId = objAcc.Id,
                                  RecordTypeId = diagRecordTypeId,
                                  Status = 'New',
                                  Origin = 'Email',
                                  Specimen__c = 'Dog',
                                  Type = 'Other',
                                  Subject = 'Test Navajo 1',
                                  Description = 'Test',
                               	  Primary_Error_Code__c = sxnCode.Id
                               );
        caseRecords.add(noLotCase);
        insert caseRecords;
    }

    /***********************************************************
    @method     	test_CaseDetails
    @brief      	Test method for case record details 
                    Retrieve case records; invokes NavajoController method; asserts for case record details.

    ***********************************************************/
    @isTest
    public static void test_CaseDetails(){
        String diagRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Diagnostics').getRecordTypeId();
        List<Case> allCases = new List<Case>( [SELECT Id,AccountId,Specimen__c,Status,Origin,Subject,Description,Primary_Error_Code__r.Name,Primary_Lot_Num__c
                                               FROM Case ] );
        String translationMessage = 'The temperature of the rotor either varied too much or was not in the proper range during the run. ';
        translationMessage += 'If symptom continues, contact Technical Service.';
        Test.startTest();                          
        Case c = NavajoController.getCaseDetails(allCases[0].Id);
        //update case with translated message
        NavajoController.updateCaseWithErrorDetails(c.Id, translationMessage, 'A123456');
        Test.stopTest();

        Case updatedCase = [Select id, Error_Translation_Results__c, Primary_Lot_Num__c from Case where id = :c.Id LIMIT 1];
        //assert that case record is updated with translation results
        System.assertEquals(translationMessage, updatedCase.Error_Translation_Results__c, 'Assertion Failed. Case not updated with translation results.');
        //assert that case record is updated with lot number
        System.assertEquals('A123456', updatedCase.Primary_Lot_Num__c, 'Assertion Failed. Case not updated with lot number.');
        CaseComment comment = [Select CommentBody from CaseComment where ParentId = :updatedCase.Id LIMIT 1];
        //assert that case comment record is created
        System.assertEquals('Error Translation Results \n'+translationMessage, comment.CommentBody,'Assertion Failed. Case comment record not created/ incorrect.');
        
        
    }
    
    /***********************************************************
    @method     	test_lotDetails
    @brief      	Test method for  rotor lot details
                    Retrieve case records; invokes NavajoController method; asserts for lot details.

    ***********************************************************/
    @isTest
    public static void test_LotDetails(){
        List<Case> allCases = new List<Case>( [SELECT Id,AccountId,Specimen__c,Status,Origin,Subject,Description,Primary_Error_Code__r.Name,Primary_Lot_Num__c
                                               FROM Case ] );
        Case c = allCases[0];
        NavajoController.LotDetails lot_details = new NavajoController.LotDetails();
        Test.startTest();
        lot_details = NavajoController.getLotDetails(c.Primary_Lot_Num__c,'10023208');
        Test.stopTest();
        //assert that lot number is not expired
        System.assert(!lot_details.isLotExpired, 'Assertion Failed. Lot number is Expired');
    }

    /***********************************************************
    @method     	test_lotDetails
    @brief      	Test method for  rotor lot details for cancellation
                    Retrieve case records; invokes NavajoController method; asserts for lot details.

    ***********************************************************/
    @isTest
    public static void test_LotDetails_cancellation(){
        List<Case> allCases = new List<Case>( [SELECT Id,AccountId,Specimen__c,Status,Origin,Subject,Description,Primary_Error_Code__r.Name,
                                               Primary_Lot_Num__c FROM Case ] );
        Case errCase ;
        for(Case cs : allCases){
            if(cs.Primary_Error_Code__r.Name.contains('ERR')){
                errCase = cs;
                break;
            }
        }
        NavajoController.LotDetails lot_details2 = new NavajoController.LotDetails();
        Test.startTest();
        lot_details2 = NavajoController.getLotDetails(errCase.id,'');
        Test.stopTest();
        //assert that no rotor found
        system.assert(lot_details2.noRotorFound,'Assertion Failed. Rotor found .');
    }

    /***********************************************************
    @method     	test_ChemistryTranslation
    @brief      	Test method for chemistry error code translation (suppression mode)
                    Creates chemistry error codes; invokes NavajoController Method; asserts for translated messages.

    ***********************************************************/
    @isTest
    public static void test_ChemistryTranslation(){
        //load chemistry error codes
        List<String> errorCodes = new List<String>();
        String errorCode1 = '{"chemistry":"ALB_BCG","errorCode1":"ACDc","errorCode2":"82"}' ;
        String errorCode2 = '{"chemistry":"GLOB","errorCode1":"CDCd","errorCode2":"91"}' ;
        errorCodes.add(errorCode1);
        errorCodes.add(errorCode2);
        // invoke navajocontroller method
        NavajoController.SingleErrorTranslation se = new NavajoController.SingleErrorTranslation();
        Test.startTest();
        se = NavajoController.getTranslationDetails(errorCodes);
        Test.stopTest();
        // Assert for below display labels and error messages
        /*
        Display Label
         * Globulin Flags 

		Specific Error Message
        * GLOB suppressed due to ALB, follow instructions from ALB flag message. // GLOB :bit position=7

		Generic Error Message
        General Chemistry Flags :
        "Concentration > High System Limit,dilute and rerun."               // bit position=19

		Display Label
        Albumin BCG Flags :

		Specific Error Message
        * ALB/TP Comparison Check, possible incorrect species entered    // ALB_BCG : bit position 7

		Generic Error Message
        General Chemistry Flags :
        Hemolysis Limit Error; Rerun NEW sample(serum);rerun           // bit position 27
        */
        // query for metadata records
        List<Navajo_Suppression_Message__mdt> suppresionMessages = [Select Chemistry_Label__c, Error_Message__c,Bit_Position__c from Navajo_Suppression_Message__mdt
                                                                    WHERE Chemistry_Label__c in ('GLOB','ALB_BCG') ];    
        List<Navajo_Suppression_Message__mdt> genericMessages =    [Select Chemistry_Label__c, Error_Message__c,Bit_Position__c from Navajo_Suppression_Message__mdt
                                                                    WHERE Bit_Position__c in (19,27) ];    
                                                                     
        String glob_specificMessage ='';
        String glob_genericMessage = '';
        String albbcg_specificMessage = '';
        String albbcg_genericMessage = '';

        for(Navajo_Suppression_Message__mdt sem : suppresionMessages){ 
            if(sem.Chemistry_Label__c=='GLOB' && sem.Bit_Position__c== 7) glob_specificMessage = '* '+sem.Error_Message__c.replace('"','');
            if(sem.Chemistry_Label__c=='ALB_BCG' && sem.Bit_Position__c== 7) albbcg_specificMessage = '* '+sem.Error_Message__c.replace('"','');            
        }
        for(Navajo_Suppression_Message__mdt sem : genericMessages){ 
            if(sem.Bit_Position__c== 19) glob_genericMessage = sem.Error_Message__c.replace('"','');
            if(sem.Bit_Position__c== 27) albbcg_genericMessage = sem.Error_Message__c.replace('"','');            
        }
        // assertion for display labels
        List<String> displayLabels = se.displayLabels;
        system.assertEquals(2, displayLabels.size(),'Assertion Failed. Display Labels size > 2');
        // assertion for specific error messages
        Map<String,List<String>> labelToSpecificMessagesMap = se.labeltoSpecificMessages ;
        System.assertEquals(glob_specificMessage, labelToSpecificMessagesMap.get('Globulin Flags')[0],'Assertion Failed. Glob Flag message mismatch');
        System.assertEquals(albbcg_specificMessage, labelToSpecificMessagesMap.get('Albumin BCG Flags')[0],'Assertion Failed. BCG Flag message mismatch');
        // assertion for generic error messages
        Map<String,String> labelToGenericMessagesMap = se.labeltoGenericMessages ;
        System.assertEquals(glob_genericMessage, labelToGenericMessagesMap.get('Globulin Flags'),'Assertion Failed. GLOB Flag generic message mismatch');
        System.assertEquals(albbcg_genericMessage, labelToGenericMessagesMap.get('Albumin BCG Flags'),'Assertion Failed. BCG Flag generic message mismatch');


    }

    /***********************************************************
    @method     	test_CancellationTranslation
    @brief      	Test method for system error code translation (cancellation mode).
                    Creates system error codes; invokes NavajoController Method; asserts for translated messages.

    ***********************************************************/
    @isTest
    public static void test_CancellationTranslation(){
        // fetch cancellation labels
        List<Navajo_Error_Flag_Label__mdt> errorFlagLabels = NavajoController.fetchCancellationLabels();
        // assert that labels are fetched
        System.assertNotEquals(0, errorFlagLabels.size());
        // Load cancellation error inputs
        List<String> errorCodes = new List<String>();
        String errorCode1 = '{"label":"Run Count","singleValue":"","firstValue":"ACDc","secondValue":"","errorCodeValue":"","QCFlagValue":"","mergeValues":true}';
        String errorCode2 = '{"label":"errorcode","singleValue":"","firstValue":"","secondValue":"","errorCodeValue":"404f","QCFlagValue":"","mergeValues":false}';
        String errorCode3 = '{"label":"QC Flags","singleValue":"","firstValue":"","secondValue":"","errorCodeValue":"","QCFlagValue":"00Ac","mergeValues":false}';
        String errorCode4 = '{"label":"Wavelength CV","singleValue":"00CF","firstValue":"","secondValue":"","errorCodeValue":"","QCFlagValue":"","mergeValues":false}';
        String errorCode5 = '{"label":"Bead Check 2","singleValue":"","firstValue":"CD01","secondValue":"","errorCodeValue":"","QCFlagValue":"","mergeValues":true}';
        String errorCode6 = '{"label":"System Flags","singleValue":"","firstValue":"ADCd","secondValue":"","errorCodeValue":"","QCFlagValue":"","mergeValues":true}';
        errorCodes.add(errorCode1);
        errorCodes.add(errorCode2);
        errorCodes.add(errorCode3);
        errorCodes.add(errorCode4);
        errorCodes.add(errorCode5);
        errorCodes.add(errorCode6);
        NavajoController.cancellationErrorDetails ced = new NavajoController.cancellationErrorDetails();
        //invoke cancellation translation method
        Test.startTest();
        ced = NavajoController.getCancellationErrorDetails(errorCodes);
        Test.stopTest();
        /*
         DAC Readings CVs too high :

		 467nm,405nm,600nm,630nm,850nm,515nm,

		 Run Count :

        4294914614
        Reagent QC Flags :

        * IQC Illegal Log 10 Paramater (Math Error/Opaque). Rerun. //3
        * IQC Flash Range Error (probably beads not dissolved). Rerun.
        * IQC Div/0 in Calc (Math Error/Opaque). Rerun.
        * Reagent QC time ignored. check and reset the instrument clock. Rerun.

        General System Flags :

        * Short Sample Error. rotor dilution wrong. Rerun.
        * Illegal bar code date. set instrument to appropriate time and date.
        * Cuvette Mark Bad. Rerun.
        * Lamp not flashing. Rerun.
        * Wavelength saturation. Rerun.
        * No Sample Diluted   // 31
        * Illegal LOG Parameter (Math Error). Rerun.
        * Disc has expired. obtain new lot of rotors.

		Error Code :

        404f
        "The temperature of the rotor either varied too much or was not in the proper range during the run. If symptom continues, contact Technical Service."
		*/
        String QCMessage ='';
        String SystemMessage ='';
        // query relevant metadata and capture expected error messages by type and Bit Position
        List<Navajo_Cancellation_Message__mdt> cancellatiomMessages = [Select Vet_Message__c,Message__c,Bit_Position__c,Type__c
                                                                      from Navajo_Cancellation_Message__mdt where Bit_Position__c in (3,31)];
        for(Navajo_Cancellation_Message__mdt cem : cancellatiomMessages){
            if(cem.Type__c=='QC' && cem.Bit_Position__c == 3) QCMessage = '* '+cem.Message__c;
            if(cem.Type__c=='System' && cem.Bit_Position__c == 31) SystemMessage = '* '+cem.Message__c;                
        }
            
        
        // assert for above labels and messages
        System.assertEquals('Reagent QC Flags', ced.QCLabel,'Assertion Failed. QC label does not match');
        System.assertEquals('General System Flags', ced.SysLabel,'Assertion Failed. System Flag does not match');
        //assert for system and QC messages
        System.assert(ced.SystemMessages.contains(SystemMessage),'Assertion Failed. System Messages do not contain "No Sample Diluted"');
        System.assert(ced.QCMessages.contains(QCMessage),'Assertion Failed. QC Messages do not contain "Illegal Log 10 Parameter"');
        // assert count values
        System.assertEquals('4294914614', ced.labelToMessage.get('Run Count'),'Assertion Failed. Run Count does not match');
        // assert error code translation
        System.assertEquals('404f       Temperature Error', ced.inputErrorCode, 'Assertion Failed. Error Code is not 404f');
    }
    static User getUserRecord(String profileName,String market){
        Profile pf= [Select Id from profile where Name= :profileName];         
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');        
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId;         
        User uu=new User(firstname = 'test11', 
                         lastName = 'McCarthy1', 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id,
                         ZTS_EU_Market__c = market); 
        return uu;
    }
}