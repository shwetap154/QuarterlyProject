@isTest 
public class SL_CaseTriggerHelper_Test {
    
    static final String RECORDTYPE_CASE_ANIMAL_SUPPORT_STR = 'Animal_Support';
    static final String CASEPRODUCT_RT_ID = 'Zoetis_Product'; 

    @testSetup
    public static void setupData()
    {

        Id animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        //Case
        Case testCase = new Case(Status = 'Open',
                            Origin = 'Email',
                            Type = 'Animal Complaint',
                            RecordTypeId = animalRecordtypeId);
        insert testCase;
        //Product
        ZTS_US_PVW_Product__c prod = new ZTS_US_PVW_Product__c(Name = 'Simparica Test',
                                                               CurrencyIsoCode='USD',
                                                               ZTS_US_MAH_Country__c = 'US',
                                                               ZTS_US_Active_Product__c = 'Yes');
      
        insert prod;      
        
        //Case Product
        ZTS_US_Case_Product__c caseProduct = new ZTS_US_Case_Product__c(ZTS_US_Case__c = testCase.Id,
                                                                        ZTS_US_PVW_Product__c = prod.Id,
                                                                        ZTS_US_Product_problem_type__c = 'Adverse Reaction',
                                                                        ZTS_US_Product_Used_Correctly__c='Yes',
                                                                        RecordTypeId = CaseProductRTId);
        
        insert caseProduct;
        
        //event Narrative
        ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
                                                                                    ZTS_US_Outcome_of_Reaction__c = 'Died',
                                                                                    ZTS_US_Duration_text__c = '30',
                                                                                    ZTS_US_Reaction_Treated__c ='Yes',
                                                                                    ZTS_US_Treatment__c = 'Test treatment',
                                                                                    ZTS_US_Case__c = testCase.Id);
        
        insert eventNarrative;
        
        ZTS_US_VedDRA_Coding__c vedraCoding = new ZTS_US_VedDRA_Coding__c(Name='Fever',
                                                                            ZTS_US_VEDDRA_Class__c = 'A',
                                                                            ZTS_US_VEDDRA_Status__c = 'Official',
                                                                            Version__c = 9,
                                                                            ZTS_US_Veddra_Display__c = 'Y',
                                                                            VedDRA_Version__c = Label.Veddra_Version_For_Tests);
        insert vedraCoding;
        
        ZTS_US_VedDRA_Event__c vedDRAEvent =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id,
                                                                        Duration_Units__c = 'Hour(s)', 
                                                                        ZTS_US_Number_of_pts_affected__c = 1, 
                                                                        ZTS_US_Start_Date__c = date.today(),
                                                                        ZTS_US_VedDRA_Coding__c =vedraCoding.Id,
                                                                        ZTS_US_Ongoing__c = 'Yes') ;
        insert vedDRAEvent;
        
        
        
      
    }
    
    @isTest
    static void testValidateRelatedRecords(){
        Case testCase = [select Id,Status,origin,type from Case limit 1];
        ZTS_US_Case_Product__c caseProduct = [select ZTS_US_Case__c,ZTS_US_PVW_Product__c,ZTS_US_Product_Role__c,ZTS_US_Product_Used_Correctly__c,ZTS_US_Product_problem_type__c 
                                              from ZTS_US_Case_Product__c where ZTS_US_Case__c =:testCase.Id];
        system.debug('##'+caseProduct.ZTS_US_Product_problem_type__c);
        testCase.Type='Human Exposure';
        Boolean didThrowException=false;
        try{
            update testCase;
        }
        catch (exception e )
        {
            didThrowException = true;
        }
        
    }
    @IsTest
    static void testValidateProductsUsedCorrectly2(){
        Id animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        //Case
        Case testCase = new Case(Status = 'Open',
                            Origin = 'Email',
                            Type = 'Animal Complaint',
                            RecordTypeId = animalRecordtypeId);
        Case testCase2 = new Case(Status = 'Open',
                            Origin = 'Email',
                            Type = 'Human Exposure'
                             );
        insert testCase;
        insert testCase2;
        //Product
        ZTS_US_PVW_Product__c prod = new ZTS_US_PVW_Product__c(Name = 'Simparica Test',
                                                               CurrencyIsoCode='USD',
                                                               ZTS_US_MAH_Country__c = 'US',
                                                               ZTS_US_Active_Product__c = 'Yes');
      
        insert prod;      
        
        //Case Product
        ZTS_US_Case_Product__c caseProduct = new ZTS_US_Case_Product__c(ZTS_US_Case__c = testCase.Id,
                                                                        ZTS_US_PVW_Product__c = prod.Id,
                                                                        ZTS_US_Product_problem_type__c = '(Associated) Product Defect',
                                                                        ZTS_US_Product_Used_Correctly__c= 'Yes',
                                                                        ZTS_US_Start_Date__c = date.today() - 5,
                                                                        RecordTypeId = CaseProductRTId,
                                                                        ZTS_US_Filling_Packaging__c='Appearance',
                                                                        ZTS_US_End_Date__c = Date.Today() -2
                                                                        );
        
        insert caseProduct;
        //beta-changes
       List<ZTS_US_Case_Product__c> caseprodlol = new List<ZTS_US_Case_Product__c>();
        caseprodlol.add(caseProduct);
        SL_CaseTriggerHelper.validateRelatedCaseProductsForApproval(testCase,caseprodlol,new Map<Id,List<String>>());
 
        SL_CaseTriggerHelper.validateRelatedCaseProductsForApproval(testCase2,caseprodlol,new Map<Id,List<String>>());    
            
        ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
                                                                                    ZTS_US_Outcome_of_Reaction__c = 'Died',
                                                                                    ZTS_US_Duration_text__c = '30',
                                                                                    ZTS_US_Reaction_Treated__c ='Yes',
                                                                                    ZTS_US_Treatment__c = 'Test treatment',
                                                                                    ZTS_US_Case__c = testCase.Id);
        
        insert eventNarrative;
        
        ZTS_US_VedDRA_Coding__c vedraCoding = new ZTS_US_VedDRA_Coding__c(Name='Fever',
                                                                            ZTS_US_VEDDRA_Class__c = 'C',
                                                                            ZTS_US_VEDDRA_Status__c = 'Official',
                                                                            ZTS_US_Veddra_Display__c = 'Y',
                                                                            Version__c = 9,
                                                                            VedDRA_Version__c = Label.Veddra_Version_For_Tests);
        insert vedraCoding;
        
        ZTS_US_VedDRA_Event__c vedDRAEvent =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id,
                                                                        Duration_Units__c = 'Hour(s)', 
                                                                        ZTS_US_Number_of_pts_affected__c = 1, 
                                                                        ZTS_US_Start_Date__c = date.today(),
                                                                        ZTS_US_VedDRA_Coding__c =vedraCoding.Id,
                                                                        ZTS_US_Ongoing__c = 'Yes') ;
        insert vedDRAEvent;

        testCase.Type='Human Exposure';
        Boolean didThrowException=false;
        try{
            update testCase;
        }
        catch (exception e )
        {
            didThrowException = true;
        }
    }
@istest
   static void testCaseMerge(){

        Account testAccount = new Account(Name='Test Account'
        ,   BillingPostalCode = '12345'
        ,   BillingCity = 'testTown'
        ,   BillingState = 'NY'
        ,   BillingStreet = '123 Test');
        insert testAccount;
        Contact testContact = new Contact(FirstName='Test',LastName='Contact',
                                            AccountId=testAccount.Id,ZTS_US_Profession__c='Dealer',
                                            ZTS_US_Job_Function__c='Student',
                                            MailingStreet='123 Test',MailingCity='testTown',MailingState='NY',MailingPostalCode='12345',MailingCountry='USA');
        insert testContact;
        
        Id vmipsCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get( 'Animal_Support' ).getRecordTypeId();
        Case case1 = new Case(AccountId=testAccount.Id,ContactId=testContact.Id,Subject='Test Merge 1',RecordTypeId=vmipsCaseRecordTypeId, Type='Animal Complaint');
     //   Case case2 = new Case(AccountId=testAccount.Id,ContactId=testContact.Id,Subject='Test Merge 2',RecordTypeId=vmipsCaseRecordTypeId, Type='Animal Complaint',Sync_Status__c=VmipsCaseSyncStatusHandler.SYNC_SUCCESS);
        Case case3 = new Case(AccountId=testAccount.Id,ContactId=testContact.Id,Subject='Test Merge 3',RecordTypeId=vmipsCaseRecordTypeId, Type='Animal Complaint');

        Case[] cases = new Case[]{case1,case3};
        insert cases;
        
    /*    ZTS_US_Event_Narrative__c EventNarrative1 = New ZTS_US_Event_Narrative__c(ZTS_US_Case__c = case1.Id);
        Insert EventNarrative1; */
       
        
        ZTS_US_Event_Narrative__c[] existingENs =  [    SELECT      Id, ZTS_US_Case__c,ZTS_US_Case__r.ZTS_US_Event_Narrative__c
                                                        FROM        ZTS_US_Event_Narrative__c 
                                                        WHERE       ZTS_US_Case__c = :case1.Id OR ZTS_US_Case__c = :case3.Id];
        system.assertEquals(2,existingENs.size());
        
        Case_Contact__c caseContact1 = new Case_Contact__c(Contact__c=testContact.Id,Case__c=case1.Id,
                                                            ZTS_US_Primary_Reporter__c=true,
                                                            Primary__c=true);
      /*  Case_Contact__c caseContact2 = new Case_Contact__c(Contact__c=testContact.Id,Case__c=case2.Id,
                                                            ZTS_US_Primary_Reporter__c=true,
                                                            Primary__c=true); */
        Case_Contact__c caseContact3 = new Case_Contact__c(Contact__c=testContact.Id,Case__c=case3.Id,
                                                            ZTS_US_Primary_Reporter__c=true,
                                                            Primary__c=true);                                                  
        Case_Contact__c[] caseContacts = new Case_Contact__c[]{caseContact1,caseContact3};
            
        Test.startTest();
        insert caseContacts;
 //       Test.stopTest();

        ZTS_US_CCPR__c ccpr1 = new ZTS_US_CCPR__c(ZTS_US_Case__c=case1.Id,ZTS_US_Amount__c=5,ZTS_US_Reason__c='Goodwill Product',
                                                    ZTS_US_Currency__c='US Dollars',CurrencyIsoCode='USD');
        ZTS_US_CCPR__c ccpr2 = new ZTS_US_CCPR__c(ZTS_US_Case__c=case3.Id,ZTS_US_Amount__c=5,ZTS_US_Reason__c='Goodwill Product',
                                                    ZTS_US_Currency__c='Euro',CurrencyIsoCode='EUR');

        ZTS_US_CCPR__c[] ccprs = new ZTS_US_CCPR__c[]{ccpr1,ccpr2};
        insert ccprs;

        insert new TriggerActivation__c(Name = 'ZTS_EU_ServiceRequest',ZTS_EU_Bypass__c = true);
   //     Test.startTest();
        String mergeError;
  /*      try{
            Database.Merge(case1,case2);
        }
        catch(Exception e){
            mergeError=e.getMessage();
        }
        system.assert(String.isNotBlank(mergeError) && mergeError.contains('PV Works'));  */
       
        Database.Merge(case1,case3);

        Test.stopTest();  

        ZTS_US_CCPR__c[] updatedCCPRs = [   SELECT Id,ZTS_US_Amount__c,ZTS_US_Currency__c,CurrencyIsoCode
                                            FROM ZTS_US_CCPR__c
                                            WHERE Id in: ccprs
                                        ];
        for(ZTS_US_CCPR__c ccpr : updatedCCPRs){
            system.assertEquals('US Dollars',ccpr.ZTS_US_Currency__c);
            system.assertEquals('USD',ccpr.CurrencyIsoCode);
        }
        
        Case_Contact__c[] updatedCaseContacts = [   SELECT Id,Case__c,ZTS_US_Primary_Reporter__c,Primary__c
                                                    FROM Case_Contact__c
                                                    WHERE Id in: caseContacts
                                                ];
        for(Case_Contact__c caseContact : updatedCaseContacts){
            if(caseContact.Id == caseContact1.Id){
                system.assertEquals(true,caseContact.ZTS_US_Primary_Reporter__c);
                system.assertEquals(true,caseContact.Primary__c);
            }
            else if(caseContact.Id == caseContact3.Id){
                system.assertEquals(false,caseContact.ZTS_US_Primary_Reporter__c);
                system.assertEquals(false,caseContact.Primary__c);
            }
        }
        
     /*   ZTS_US_Event_Narrative__c EventNarrative2 = New ZTS_US_Event_Narrative__c(ZTS_US_Case__c = case3.Id);
        Insert EventNarrative2; */

        
        ZTS_US_Event_Narrative__c[] survivingENs =  [   SELECT      Id, ZTS_US_Case__c,ZTS_US_Case__r.ZTS_US_Event_Narrative__c
                                                        FROM        ZTS_US_Event_Narrative__c 
                                                        WHERE       ZTS_US_Case__c = :case1.Id OR ZTS_US_Case__c = :case3.Id];
        system.assertEquals(1,survivingENs.size());
        system.assertEquals(case1.Id,survivingENs[0].ZTS_US_Case__c);
        
    }  

@isTest
    static void testCaseMerge1(){

        Account testAccount = new Account(Name='Test Account'
        ,   BillingPostalCode = '12345'
        ,   BillingCity = 'testTown'
        ,   BillingState = 'NY'
        ,   BillingStreet = '123 Test');
        insert testAccount;
        Contact testContact = new Contact(FirstName='Test',LastName='Contact',
                                            AccountId=testAccount.Id,ZTS_US_Profession__c='Dealer',
                                            ZTS_US_Job_Function__c='Student',
                                            MailingStreet='123 Test',MailingCity='testTown',MailingState='NY',MailingPostalCode='12345',MailingCountry='USA');
        insert testContact;
        
        Id vmipsCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get( 'Animal_Support' ).getRecordTypeId();
        Case case1 = new Case(AccountId=testAccount.Id,ContactId=testContact.Id,Subject='Test Merge 1',RecordTypeId=vmipsCaseRecordTypeId, Type='Animal Complaint');
        Case case2 = new Case(AccountId=testAccount.Id,ContactId=testContact.Id,Subject='Test Merge 2',RecordTypeId=vmipsCaseRecordTypeId, Type='Animal Complaint',Sync_Status__c=VmipsCaseSyncStatusHandler.SYNC_SUCCESS);
      //  Case case3 = new Case(AccountId=testAccount.Id,ContactId=testContact.Id,Subject='Test Merge 3',RecordTypeId=vmipsCaseRecordTypeId, Type='Animal Complaint');

        Case[] cases = new Case[]{case1,case2};
        insert cases;
        
      
        
        Case_Contact__c caseContact1 = new Case_Contact__c(Contact__c=testContact.Id,Case__c=case1.Id,
                                                            ZTS_US_Primary_Reporter__c=true,
                                                            Primary__c=true);
        Case_Contact__c caseContact2 = new Case_Contact__c(Contact__c=testContact.Id,Case__c=case2.Id,
                                                            ZTS_US_Primary_Reporter__c=true,
                                                            Primary__c=true);
     //   Case_Contact__c caseContact3 = new Case_Contact__c(Contact__c=testContact.Id,Case__c=case3.Id,
     //                                                       ZTS_US_Primary_Reporter__c=true,
     //                                                       Primary__c=true);                                                    
        Case_Contact__c[] caseContacts = new Case_Contact__c[]{caseContact1,caseContact2};
        Test.startTest();
            
        insert caseContacts;   
    //    Test.stopTest();


        insert new TriggerActivation__c(Name = 'ZTS_EU_ServiceRequest',ZTS_EU_Bypass__c = true);
  //      Test.startTest();
        String mergeError;
        try{
            Database.Merge(case1,case2);
        }
        catch(Exception e){
            mergeError=e.getMessage();
        }
        system.assert(String.isNotBlank(mergeError) && mergeError.contains('PV Works'));

        Test.stopTest();
        Case_Contact__c[] updatedCaseContacts = [   SELECT Id,Case__c,ZTS_US_Primary_Reporter__c,Primary__c
                                                    FROM Case_Contact__c
                                                    WHERE Id in: caseContacts
                                                ];
        for(Case_Contact__c caseContact : updatedCaseContacts){
            if(caseContact.Id == caseContact1.Id){
                system.assertEquals(true,caseContact.ZTS_US_Primary_Reporter__c);
                system.assertEquals(true,caseContact.Primary__c);
            }
            else if(caseContact.Id == caseContact2.Id){
                system.assertEquals(true,caseContact.ZTS_US_Primary_Reporter__c);
                system.assertEquals(true,caseContact.Primary__c);
            }
        }

        
        
    }    
    @isTest
    static void testRetrieveApprovalFieldsFromMetadata(){
        
        VMIPS_Validation_Helper__mdt metaDataRecord = [ SELECT  Id,Object_Name__c 
                                                        FROM    VMIPS_Validation_Helper__mdt  
                                                        WHERE   AC_Validation_Check__c = TRUE
                                                        AND     HE_Validation_Check__c = TRUE
                                                        AND     PD_Validation_Check__c = TRUE
                                                        LIMIT   1];
        EntityDefinition objectDefinition = [   SELECT  Id,QualifiedAPIName 
                                                FROM    EntityDefinition 
                                                WHERE   DurableId = :metaDataRecord.Object_Name__c 
                                                LIMIT   1];
        Test.startTest();
        Map<String, Set<String>> acMetadata = SL_CaseTriggerHelper.retrieveApprovalFieldsFromMetadata('Animal Complaint',null);
        system.assert(acMetadata!=null && acMetadata.containsKey(objectDefinition.QualifiedAPIName));
        Map<String, Set<String>> heMetadata = SL_CaseTriggerHelper.retrieveApprovalFieldsFromMetadata('Human Exposure',null);
        system.assert(heMetadata!=null && heMetadata.containsKey(objectDefinition.QualifiedAPIName));
        Map<String, Set<String>> pdMetadata = SL_CaseTriggerHelper.retrieveApprovalFieldsFromMetadata('Product Defect',null);
        system.assert(pdMetadata!=null && pdMetadata.containsKey(objectDefinition.QualifiedAPIName));
        //betachanges
       
        
        Test.stopTest();
    }
    @isTest
    static void testCaseErr(){

        Account testAccount = new Account(Name='Test Account'
        ,   BillingPostalCode = '12345'
        ,   BillingCity = 'testTown'
        ,   BillingState = 'NY'
        ,   BillingStreet = '123 Test');
        insert testAccount;
        Contact testContact = new Contact(FirstName='Test',LastName='Contact',
                                            AccountId=testAccount.Id,ZTS_US_Profession__c='Dealer',
                                            ZTS_US_Job_Function__c='Student',
                                            MailingStreet='123 Test',MailingCity='testTown',MailingState='NY',MailingPostalCode='12345',MailingCountry='USA');
        insert testContact;
        
        Id vmipsCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get( 'Animal_Support' ).getRecordTypeId();
        Case case1 = new Case(AccountId=testAccount.Id,ContactId=testContact.Id,Subject='Test Err 1',RecordTypeId=vmipsCaseRecordTypeId);
        Case case2 = new Case(AccountId=testAccount.Id,ContactId=testContact.Id,Subject='Test Err 2',RecordTypeId=vmipsCaseRecordTypeId, ZTS_EU_PV_Works__c='12345');
        Case[] cases = new Case[]{case1,case2};
        insert cases;
        list<case> lool = SL_CaseTriggerHelper.filterNewCasesForEventNarratives(cases);
        ZTS_US_Case_Agency_Submission__c agencyRec = new ZTS_US_Case_Agency_Submission__c(Case__c=case2.Id,Agency_Name__c='fda');
        insert agencyRec;

        insert new TriggerActivation__c(Name = 'ZTS_EU_ServiceRequest',ZTS_EU_Bypass__c = true);
        Test.startTest();
        case1.status = 'Cancelled';
        update case1;

        String saveError;
        try{
            case2.status = 'Cancelled';
            update case2;
        }
        catch(Exception e){
            saveError=e.getMessage();
        }
        system.assert(String.isNotBlank(saveError) && saveError.contains('Cases Sent to PVWorks that have agency submissions'));

        Test.stopTest();

        Case uCase1 = [SELECT Id,Status,ZTS_US_Information_Type__c FROM Case WHERE Id=:case1.Id];
        system.assertEquals(uCase1.Status,'Cancelled');
        system.assertEquals(uCase1.ZTS_US_Information_Type__c,'Erred');
        
        
    }
    @isTest
    static void testCheckForSpecialCharactersAndOddQuotes(){
        String goodVal = '"Test 123"';
        String badCharVal = 'Test 12¿3';
        String badTabVal = 'Test    test';
        String badQuoteVal = 'T"est';
        
        String returnVal = SL_CaseTriggerHelper.checkForSpecialCharactersAndOddQuotes('test object', new Map<String, String>{'test field' => goodVal});
        system.assertEquals('',returnVal);
        
        returnVal = SL_CaseTriggerHelper.checkForSpecialCharactersAndOddQuotes('test object', new Map<String, String>{'test field' => badCharVal});
        system.assert(returnVal.contains('cannot contain special characters'));

        returnVal = SL_CaseTriggerHelper.checkForSpecialCharactersAndOddQuotes('test object', new Map<String, String>{'test field' => badTabVal});
        //system.assert(returnVal.contains('cannot contain special characters'));

        returnVal = SL_CaseTriggerHelper.checkForSpecialCharactersAndOddQuotes('test object', new Map<String, String>{'test field' => badQuoteVal});
        system.assert(returnVal.contains('is missing "'));
    }
    //beta-changes
   //beta-changes
//setAuditTrailLock method
  @isTest
     static void testSetAuditTrailLock() {
        
        // Create test Case records
        Case[] cases = new List<Case>{
            new Case(Subject = 'Test Case 1', Description = 'Test Case 1 Description'),
            new Case(Subject = 'Test Case 2', Description = 'Test Case 2 Description')
        };
        insert cases;
        
        // Create test Audit Trail records related to the test Cases
        ZTS_US_CSE_Audit_Trail__c[] auditTrails = new List<ZTS_US_CSE_Audit_Trail__c>{
            new ZTS_US_CSE_Audit_Trail__c(Case__c = cases[0].Id),
            new ZTS_US_CSE_Audit_Trail__c(Case__c = cases[1].Id)
        };
        insert auditTrails;
        
        // Call the setAuditTrailLock method with the test Case Ids
        Test.startTest();
        SL_CaseTriggerHelper.setAuditTrailLock(new List<Id>{cases[0].Id, cases[1].Id});
        Test.stopTest();
        
        // Verify that the Sequence_Lock__c field is updated to true for the test Audit Trail records
        List<ZTS_US_CSE_Audit_Trail__c> updatedAuditTrails = [SELECT Sequence_Lock__c FROM ZTS_US_CSE_Audit_Trail__c WHERE Case__c in :new List<Id>{cases[0].Id, cases[1].Id}];
        System.assertEquals(true, updatedAuditTrails[0].Sequence_Lock__c);
        System.assertEquals(true, updatedAuditTrails[1].Sequence_Lock__c);
         
         //    null testing 
     Set<String> bd3 = new set<String>();      
     bd3 = SL_CaseTriggerHelper.getAllRelevantCaseProductFields();
     Set<Id> bd4 = new set<id>();
     Map<Id, Case> bd5 = new Map<id,Case>();
     SL_CaseTriggerHelper.validateRelatedRecordsOnTypeChange(bd4,bd5);
     }
    
    
    //
   
    
  /* @isTest
    static void testSetAuditTrailLockException() {
        // Create some test data
        Case testCase = new Case(Subject='Test Case');
        insert testCase;
        ZTS_US_CSE_Audit_Trail__c testAuditTrail = new ZTS_US_CSE_Audit_Trail__c(Case__c = testCase.Id);
        insert testAuditTrail;
        
        // Simulate a failure during update
        Test.startTest();
        SL_CaseTriggerHelper.setAuditTrailLock(new Id[]{testCase.Id});
         String saveError;
        try{
        if(Test.isRunningTest()) {
            // Cause a failure
            testAuditTrail.Sequence_Lock__c = false;
            update testAuditTrail;
        }}
            catch(Exception e){
            saveError=e.getMessage();
        }
         system.assert(String.isNotBlank(saveError) && saveError.contains('Error updating Audit Trails'));
         Test.stopTest();
        
    }*/
    
    //
    
   @isTest
    static void validateRelatedRecordsOnTypeChange(){
        Id animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        //Case
        Case testCase = new Case(Status = 'Open',
                            Origin = 'Email',
                            Type = 'Animal Complaint',
                            RecordTypeId = animalRecordtypeId);
        Case testCase2 = new Case(Status = 'Open',
                            Origin = 'Email',
                            Type = 'Human Exposure'
                             );
        insert testCase;
        insert testCase2;
        //Product
        ZTS_US_PVW_Product__c prod = new ZTS_US_PVW_Product__c(Name = 'Simparica Test',
                                                               CurrencyIsoCode='USD',
                                                               ZTS_US_MAH_Country__c = 'US',
                                                               ZTS_US_Active_Product__c = 'Yes');
      
        insert prod;      
        
        //Case Product
        ZTS_US_Case_Product__c caseProduct = new ZTS_US_Case_Product__c(ZTS_US_Case__c = testCase.Id,
                                                                        ZTS_US_PVW_Product__c = prod.Id,
                                                                        ZTS_US_Product_problem_type__c = '(Associated) Product Defect',
                                                                        ZTS_US_Product_Used_Correctly__c= 'Yes',
                                                           
                                                                        ZTS_US_Start_Date__c = date.today() - 5,
                                                                        RecordTypeId = CaseProductRTId,
                                                                        ZTS_US_Filling_Packaging__c='Appearance',
                                                                        ZTS_US_End_Date__c = Date.Today() -2
                                                                        );
        
        insert caseProduct;
        List<ZTS_US_Case_Product__c> caseprodlol = new List<ZTS_US_Case_Product__c>();
        caseprodlol.add(caseProduct);
        SL_CaseTriggerHelper.validateRelatedCaseProductsForApproval(testCase,caseprodlol,new Map<Id,List<String>>());
        SL_CaseTriggerHelper.validateRelatedCaseProductsForApproval(testCase2,caseprodlol, new Map<Id,List<String>>());    
          
        
        Set<Id> cd1 = new set<id>();
       Map<Id, Case> cd2Cases = new Map<id,Case>(); 
       cd2Cases.put(testCase.Id, testCase);
         cd2Cases.put(testCase2.Id, testCase2);
        cd1.add(testCase.Id);
         cd1.add(testCase2.Id);
          
        
        ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
                                                                                    ZTS_US_Outcome_of_Reaction__c = 'Died',
                                                                                    ZTS_US_Duration_text__c = '30',
                                                                                    ZTS_US_Reaction_Treated__c ='Yes',
                                                                                    ZTS_US_Treatment__c = 'Test treatment',
                                                                                    ZTS_US_Case__c = testCase.Id);
        
        insert eventNarrative;
        
        ZTS_US_VedDRA_Coding__c vedraCoding = new ZTS_US_VedDRA_Coding__c(Name='Fever',
                                                                            ZTS_US_VEDDRA_Class__c = 'C',
                                                                            ZTS_US_VEDDRA_Status__c = 'Official',
                                                                            ZTS_US_Veddra_Display__c = 'Y',
                                                                            Version__c = 9,
                                                                            VedDRA_Version__c = Label.Veddra_Version_For_Tests);
        insert vedraCoding;
        
        ZTS_US_VedDRA_Event__c vedDRAEvent =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id,
                                                                        Duration_Units__c = 'Hour(s)', 
                                                                        ZTS_US_Number_of_pts_affected__c = 1, 
                                                                        ZTS_US_Start_Date__c = date.today(),
                                                                        ZTS_US_VedDRA_Coding__c =vedraCoding.Id,
                                                                        ZTS_US_Ongoing__c = 'Yes') ;
        insert vedDRAEvent;
         SL_CaseTriggerHelper.validateRelatedRecordsOnTypeChange(cd1,cd2Cases);

        testCase.Type='Human Exposure';
        Boolean didThrowException=false;
        try{
            update testCase;
        }
        catch (exception e )
        {
            didThrowException = true;
        }
    }
    
}
  
    /*public static Case createPVWSyncedCase(Boolean createTriggerActivation){
        if(createTriggerActivation){
            TriggerActivation__c tr = new TriggerActivation__c(Name = 'ZTS_EU_ServiceRequest',ZTS_EU_Bypass__c = true);
            insert tr;
        }
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('RingLeadTrigger');
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case newCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Email',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Erred',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c='Synced Successfully with PV Works');
        insert newCase;
        
        Contact contact = new Contact(LastName = 'Doe', FirstName = 'Testone',ZTS_US_Job_Function__c = 'CFO', ZTS_US_Profession__c= 'Consultant');
        insert contact;
        
        Case_Contact__c caseContact = new Case_Contact__c(Contact__c = contact.Id, ZTS_US_Contact_Role__c = 'Pharmacist', Case__c = newCase.Id);
        insert caseContact;

        
        ZTS_US_PVW_Product__c prod = new ZTS_US_PVW_Product__c(Name = 'VANGUARD PLUS 5/L',ZTS_US_MAH_Country__c = 'US',ZTS_US_Active_Product__c = 'Yes');
        insert prod;
        ZTS_US_Case_Product__c caseProduct = new ZTS_US_Case_Product__c(ZTS_US_Case__c = newcase.Id,
                                                                        ZTS_US_PVW_Product__c = prod.Id,
                                                                        ZTS_US_Product_problem_type__c='Adverse Reaction',
                                                                        ZTS_US_Product_Role__c = 'Suspect Product',
                                                                        ZTS_US_Product_Used_Correctly__c = 'Yes');
        insert caseProduct;

        // Insert Breed
        ZTS_US_Breed__c Breed1 = new ZTS_US_Breed__c (Name = 'Terrier', 
                                                     ZTS_US_Species__c = 'Feline');
        insert Breed1;
        //Insert Animal
        ZTS_US_Animal__c testUSAnimal = new ZTS_US_Animal__c(Name = 'Tessjyyy', 
                                                            ZTS_US_Species__c='Feline', 
                                                            ZTS_US_Weight_units__c= 'Grams',
                                                            ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
                                                            ZTS_US_Sex__c = 'Male',
                                                            ZTS_US_Reproductive_Status__c = 'Neutered', 
                                                            ZTS_US_Breed__c = Breed1.id,
                                                            ZTS_US_Age_unit_to__c ='Minutes',
                                                            ZTS_US_Age_unit_from__c ='Minutes',
                                                            ZTS_US_Age_to__c = 6.1,
                                                            ZTS_US_Age_from__c = 6.1,
                                                            ZTS_US_Weight__c = 9,
                                                            ZTS_US_Animal_condition_prior_treatment__c = 'Good',
                                                            ZTS_US_Unknown__c = 1,
                                                            ZTS_US_Reacted__c = 1,
                                                            ZTS_US_Total__c = 1,
                                                            ZTS_US_Exposed__c =1
                                                            );
        insert testUSAnimal;

        Map<Id,ZTS_US_Animal__c> animalMap = new Map<Id,ZTS_US_Animal__c>();
        animalMap.put(testUSAnimal.Id,testUSAnimal);

        //Insert Case Animal
        ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = newCase.Id, ZTS_US_Animal__c = testUSAnimal.Id,
        ZTS_US_Total__c = 1,  ZTS_US_Exposed__c = 1,ZTS_US_Reacted__c = 1, ZTS_US_Alive_with_Sequela__c = 1);
        insert caseAnimal;
        //Insert Event Narrative record
        ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
        ZTS_US_Outcome_of_Reaction__c = 'Euthanized',
        ZTS_US_Duration_text__c = '30',
        ZTS_US_Reaction_Treated__c ='Yes',
        ZTS_US_Treatment__c = 'Test treatment',
        ZTS_US_Case__c = newCase.Id);
        insert eventNarrative;
        Map<Id,ZTS_US_Event_Narrative__c> eventNarrativeMap = new Map<Id,ZTS_US_Event_Narrative__c>();
        eventNarrativeMap.put(eventNarrative.Id,eventNarrative);

        ZTS_US_VedDRA_Event__c testVedDRA =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id, 
                                                                                                    Duration_Units__c = 'Hour(s)', 
                                                                                                    ZTS_US_Number_of_pts_affected__c = 1, 
                                                                                                    ZTS_US_Start_Date__c = date.today()-1, 
                                                                                                    ZTS_US_Ongoing__c ='Yes');
        insert testVedDRA;

        newCase.ZTS_US_Event_Narrative__c = eventNarrative.Id;
        update newCase;
        return newCase;
    }*/