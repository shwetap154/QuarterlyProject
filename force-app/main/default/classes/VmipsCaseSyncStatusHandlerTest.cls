/**
 * @description       : Test Class for VmipsCaseSyncStatusHandler
**/
@isTest
private with sharing class VmipsCaseSyncStatusHandlerTest {
    
    @testVisible static final String RECORDTYPE_CASE_ANIMAL_SUPPORT_STR = 'Animal_Support';
    static final String LOCALASSESSMENT_RT_ID= Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get('ZTS_US_Local_Assessment').getRecordTypeId();
    static final String SYNC_SUCCESS = 'Synced Successfully with PV Works';
    static final String SYNC_UNAPPROVED = 'Unapproved';
    static final String SYNC_REAPPROVAL = 'Re-Approval Needed';

    @isTest
    private static void testCaseStatusCheckCaseContactUpdate(){
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case sentCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_SUCCESS);
        Case unsentCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_UNAPPROVED);
        insert new Case[]{sentCase, unsentCase};
        
        //Insert Contact
		List<contact> contactList = new  List<contact>();
        contactList.add(new Contact(LastName = 'Last1', FirstName = 'First1',ZTS_US_Job_Function__c = 'CFO', ZTS_US_Profession__c= 'Consultant'));   
        contactList.add(new Contact(LastName = 'Last2', FirstName = 'First2',ZTS_US_Job_Function__c = 'CFO', ZTS_US_Profession__c= 'Consultant'));
        insert contactList;
        
        //Insert Case Contact		
        Case_Contact__c caseContact1 = new Case_Contact__c(Contact__c = contactList[0].Id, ZTS_US_Contact_Role__c = 'Pharmacist', Case__c=sentCase.Id);
        Case_Contact__c caseContact2 = new Case_Contact__c(Contact__c = contactList[1].Id, ZTS_US_Contact_Role__c = 'Pharmacist', Case__c=unsentCase.Id);
        Case_Contact__c[] caseContactList = new Case_Contact__c[]{caseContact1,caseContact2};
        insert caseContactList;

        Test.startTest();
        caseContact1.ZTS_US_Contact_Role__c = 'Attending Vet';
        caseContact2.ZTS_US_Contact_Role__c = 'Attending Vet';
        update caseContactList;

        Test.stopTest();
        
        validateCase(SYNC_REAPPROVAL,sentCase.Id);
        validateCase(SYNC_UNAPPROVED,unsentCase.Id);
    }
    
    @isTest
    private static void testCaseStatusCheckCaseProductInsert(){
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case sentCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_SUCCESS);
        Case unsentCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_UNAPPROVED);
        insert new Case[]{sentCase, unsentCase};
        //Create PVW Product record
        ZTS_US_PVW_Product__c prod1 = new ZTS_US_PVW_Product__c(Name = 'VANGUARD PLUS 5/L',ZTS_US_MAH_Country__c = 'US',ZTS_US_Active_Product__c = 'Yes');
        ZTS_US_PVW_Product__c prod2 = new ZTS_US_PVW_Product__c(Name = 'Symparica',ZTS_US_MAH_Country__c = 'US',ZTS_US_Active_Product__c = 'Yes');
        insert new ZTS_US_PVW_Product__c[]{prod1,prod2};        

        Test.startTest();
        //Insert Case Product Record
        ZTS_US_Case_Product__c caseProduct1 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = sentCase.Id,
                                                                        ZTS_US_PVW_Product__c = prod1.Id,ZTS_US_Product_problem_type__c='Adverse Reaction',
                                                                        ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        ZTS_US_Case_Product__c caseProduct2 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = unsentCase.Id,
                                                                        ZTS_US_PVW_Product__c = prod2.Id,ZTS_US_Product_problem_type__c='Adverse Reaction',
                                                                        ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        insert new ZTS_US_Case_Product__c[]{caseProduct1,caseProduct2};

        Test.stopTest();
        
        validateCase(SYNC_REAPPROVAL,sentCase.Id);
        validateCase(SYNC_UNAPPROVED,unsentCase.Id);
    }
    @isTest
    private static void testCaseStatusCheckCaseProductUpdate(){
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case sentCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_SUCCESS);
        Case unsentCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_UNAPPROVED);
        Case[] testCases = new Case[]{sentCase, unsentCase};
        insert testCases;

        //Create PVW Product record
        ZTS_US_PVW_Product__c prod1 = new ZTS_US_PVW_Product__c(Name = 'VANGUARD PLUS 5/L',ZTS_US_MAH_Country__c = 'US',ZTS_US_Active_Product__c = 'Yes');
        ZTS_US_PVW_Product__c prod2 = new ZTS_US_PVW_Product__c(Name = 'Symparica',ZTS_US_MAH_Country__c = 'US',ZTS_US_Active_Product__c = 'Yes');
        insert new ZTS_US_PVW_Product__c[]{prod1,prod2}; 
        
        //Insert Case Product Record
        ZTS_US_Case_Product__c caseProduct1 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = sentCase.Id,
                                                                        ZTS_US_PVW_Product__c = prod1.Id,ZTS_US_Product_problem_type__c='Adverse Reaction',
                                                                        ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        ZTS_US_Case_Product__c caseProduct2 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = unsentCase.Id,
                                                                        ZTS_US_PVW_Product__c = prod2.Id,ZTS_US_Product_problem_type__c='Adverse Reaction',
                                                                        ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        ZTS_US_Case_Product__c[] caseProducts = new ZTS_US_Case_Product__c[]{caseProduct1,caseProduct2};
        insert caseProducts;

        sentCase.Sync_Status__c=SYNC_SUCCESS;
        unsentCase.Sync_Status__c=SYNC_UNAPPROVED;
        update testCases;

        Test.startTest();
        date today = date.today();
        caseProduct1.ZTS_US_Start_Date__c=today.addDays(-2);
        caseProduct1.ZTS_US_End_Date__c=today.addDays(-1);
        caseProduct2.ZTS_US_Start_Date__c=today.addDays(-2);
        caseProduct2.ZTS_US_End_Date__c=today.addDays(-1);
        update caseProducts;

        Test.stopTest();
        
        validateCase(SYNC_REAPPROVAL,sentCase.Id);
        validateCase(SYNC_UNAPPROVED,unsentCase.Id);
    }
    @isTest
    private static void testCaseStatusCheckBatchDetailInsert(){
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case sentCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_SUCCESS);
        Case unsentCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_UNAPPROVED);
        Case[] testCases = new Case[]{sentCase,unsentCase};
        insert testCases;

        //Create PVW Product record
        ZTS_US_PVW_Product__c prod1 = new ZTS_US_PVW_Product__c(Name = 'VANGUARD PLUS 5/L',ZTS_US_MAH_Country__c = 'US',ZTS_US_Active_Product__c = 'Yes');
        ZTS_US_PVW_Product__c prod2 = new ZTS_US_PVW_Product__c(Name = 'Symparica',ZTS_US_MAH_Country__c = 'US',ZTS_US_Active_Product__c = 'Yes');
        insert new ZTS_US_PVW_Product__c[]{prod1,prod2};

        //Insert Case Product Record
        ZTS_US_Case_Product__c caseProduct1 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = sentCase.Id,
                                                                        ZTS_US_PVW_Product__c = prod1.Id,ZTS_US_Product_problem_type__c='Adverse Reaction',
                                                                        ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        ZTS_US_Case_Product__c caseProduct2 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = unsentCase.Id,
                                                                        ZTS_US_PVW_Product__c = prod2.Id,ZTS_US_Product_problem_type__c='Adverse Reaction',
                                                                        ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        insert new ZTS_US_Case_Product__c[]{caseProduct1,caseProduct2};

        sentCase.Sync_Status__c=SYNC_SUCCESS;
        unsentCase.Sync_Status__c=SYNC_UNAPPROVED;
        update testCases;

        Test.startTest();

        Batch_Detail__c bd1 = new Batch_Detail__c(ZTS_US_Case_Product__c=caseProduct1.Id,ZTS_US_Product_Lot__c='56',ZTS_US_Serial_Number__c='12',ZTS_US_Diluent__c='34');
        Batch_Detail__c bd2 = new Batch_Detail__c(ZTS_US_Case_Product__c=caseProduct2.Id,ZTS_US_Product_Lot__c='54',ZTS_US_Serial_Number__c='33',ZTS_US_Diluent__c='77');
        insert new Batch_Detail__c[]{bd1,bd2};

        Test.stopTest();
        
        validateCase(SYNC_REAPPROVAL,sentCase.Id);
        validateCase(SYNC_UNAPPROVED,unsentCase.Id);
    }
    @isTest
    private static void testCaseStatusCheckBatchDetailUpdate(){
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case sentCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_SUCCESS);
        Case unsentCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_UNAPPROVED);
        Case[] testCases = new Case[]{sentCase,unsentCase};
        insert testCases;

        //Create PVW Product record
        ZTS_US_PVW_Product__c prod1 = new ZTS_US_PVW_Product__c(Name = 'VANGUARD PLUS 5/L',ZTS_US_MAH_Country__c = 'US',ZTS_US_Active_Product__c = 'Yes');
        ZTS_US_PVW_Product__c prod2 = new ZTS_US_PVW_Product__c(Name = 'Symparica',ZTS_US_MAH_Country__c = 'US',ZTS_US_Active_Product__c = 'Yes');
        insert new ZTS_US_PVW_Product__c[]{prod1,prod2};

        //Insert Case Product Record
        ZTS_US_Case_Product__c caseProduct1 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = sentCase.Id,
                                                                        ZTS_US_PVW_Product__c = prod1.Id,ZTS_US_Product_problem_type__c='Adverse Reaction',
                                                                        ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        ZTS_US_Case_Product__c caseProduct2 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = unsentCase.Id,
                                                                        ZTS_US_PVW_Product__c = prod2.Id,ZTS_US_Product_problem_type__c='Adverse Reaction',
                                                                        ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        insert new ZTS_US_Case_Product__c[]{caseProduct1,caseProduct2};

        Batch_Detail__c bd1 = new Batch_Detail__c(ZTS_US_Case_Product__c=caseProduct1.Id,ZTS_US_Product_Lot__c='56',ZTS_US_Serial_Number__c='12',ZTS_US_Diluent__c='34');
        Batch_Detail__c bd2 = new Batch_Detail__c(ZTS_US_Case_Product__c=caseProduct2.Id,ZTS_US_Product_Lot__c='54',ZTS_US_Serial_Number__c='33',ZTS_US_Diluent__c='77');
        Batch_Detail__c[] bds = new Batch_Detail__c[]{bd1,bd2};
        insert bds;

        sentCase.Sync_Status__c=SYNC_SUCCESS;
        unsentCase.Sync_Status__c=SYNC_UNAPPROVED;
        update testCases;

        Test.startTest();

        bd1.ZTS_US_Product_Lot__c = '567';
        bd2.ZTS_US_Product_Lot__c = '543';
        update bds;

        Test.stopTest();
        
        validateCase(SYNC_REAPPROVAL,sentCase.Id);
        validateCase(SYNC_UNAPPROVED,unsentCase.Id);
    }
    @isTest
    private static void testCaseStatusCheckProductInvestigationUpdate(){
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case sentCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_SUCCESS);
        Case unsentCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_UNAPPROVED);
        Case[] testCases = new Case[]{sentCase,unsentCase};
        insert testCases;

        //Create PVW Product record
        ZTS_US_PVW_Product__c prod1 = new ZTS_US_PVW_Product__c(Name = 'VANGUARD PLUS 5/L',ZTS_US_MAH_Country__c = 'US',ZTS_US_Active_Product__c = 'Yes');
        ZTS_US_PVW_Product__c prod2 = new ZTS_US_PVW_Product__c(Name = 'Symparica',ZTS_US_MAH_Country__c = 'US',ZTS_US_Active_Product__c = 'Yes');
        insert new ZTS_US_PVW_Product__c[]{prod1,prod2};

        //Insert Case Product Record
        ZTS_US_Case_Product__c caseProduct1 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = sentCase.Id,
                                                                        ZTS_US_PVW_Product__c = prod1.Id,ZTS_US_Product_problem_type__c='Adverse Reaction',
                                                                        ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        ZTS_US_Case_Product__c caseProduct2 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = unsentCase.Id,
                                                                        ZTS_US_PVW_Product__c = prod2.Id,ZTS_US_Product_problem_type__c='Adverse Reaction',
                                                                        ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        insert new ZTS_US_Case_Product__c[]{caseProduct1,caseProduct2};

        Batch_Detail__c bd1 = new Batch_Detail__c(ZTS_US_Case_Product__c=caseProduct1.Id,ZTS_US_Product_Lot__c='56',ZTS_US_Serial_Number__c='12',ZTS_US_Diluent__c='34');
        Batch_Detail__c bd2 = new Batch_Detail__c(ZTS_US_Case_Product__c=caseProduct2.Id,ZTS_US_Product_Lot__c='54',ZTS_US_Serial_Number__c='33',ZTS_US_Diluent__c='77');
        insert new Batch_Detail__c[]{bd1,bd2};

        ZTS_US_Product_Investigation__c investigation1 = new ZTS_US_Product_Investigation__c(ZTS_US_Case__c = sentCase.Id,ZTS_US_Batch_Detail__c=bd1.Id,
                                            ZTS_US_Investigation_Request__c = 'testing1', ZTS_US_Case_Product__c = caseProduct1.Id,
                                            ZTS_US_Investigation_Type__c='Lot',ZTS_US_Investigation_Site__c='PF_QCU',ZTS_US_Investigation_Sample_Type__c='Retention');
        ZTS_US_Product_Investigation__c investigation2 = new ZTS_US_Product_Investigation__c(ZTS_US_Case__c = unsentCase.Id,ZTS_US_Batch_Detail__c=bd2.Id,
                                            ZTS_US_Investigation_Request__c = 'testing1', ZTS_US_Case_Product__c = caseProduct2.Id,
                                            ZTS_US_Investigation_Type__c='Lot',ZTS_US_Investigation_Site__c='PF_QCU',ZTS_US_Investigation_Sample_Type__c='Retention');
        ZTS_US_Product_Investigation__c[] productInvestigations = new ZTS_US_Product_Investigation__c[]{investigation1,investigation2};
        insert productInvestigations;

        sentCase.Sync_Status__c=SYNC_SUCCESS;
        unsentCase.Sync_Status__c=SYNC_UNAPPROVED;
        update testCases;

        Test.startTest();

        investigation1.Send_to_PV_Works__c = true;
        investigation2.Send_to_PV_Works__c = true;
        update productInvestigations;

        Test.stopTest();
        
        validateCase(SYNC_REAPPROVAL,sentCase.Id);
        validateCase(SYNC_UNAPPROVED,unsentCase.Id);
    }
    @isTest
    private static void testCaseStatusCheckAssessmentInsert(){
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case sentCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_SUCCESS);
        Case unsentCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_UNAPPROVED);
        insert new Case[]{sentCase, unsentCase};

        Test.startTest();
        ZTS_US_Assessment__c assessmentLocal1 = new ZTS_US_Assessment__c(RecordTypeId=LOCALASSESSMENT_RT_ID,ZTS_US_Case__c=sentCase.id,ZTS_US_Local_Assessment__c='USDA');
        ZTS_US_Assessment__c assessmentLocal2 = new ZTS_US_Assessment__c(RecordTypeId=LOCALASSESSMENT_RT_ID,ZTS_US_Case__c=unsentCase.id,ZTS_US_Local_Assessment__c='USDA');
        ZTS_US_Assessment__c[] assessments = new ZTS_US_Assessment__c[]{assessmentLocal1,assessmentLocal2};
        insert assessments;

        Test.stopTest();
        
        validateCase(SYNC_REAPPROVAL,sentCase.Id);
        validateCase(SYNC_UNAPPROVED,unsentCase.Id);
    }
    @isTest
    private static void testCaseStatusCheckAssessmentUpdate(){
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case sentCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_SUCCESS);
        Case unsentCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_UNAPPROVED);
        Case[] testCases = new Case[]{sentCase, unsentCase};
        insert testCases;

        ZTS_US_Assessment__c assessmentLocal1 = new ZTS_US_Assessment__c(RecordTypeId=LOCALASSESSMENT_RT_ID,ZTS_US_Case__c=sentCase.id,ZTS_US_Local_Assessment__c='USDA');
        ZTS_US_Assessment__c assessmentLocal2 = new ZTS_US_Assessment__c(RecordTypeId=LOCALASSESSMENT_RT_ID,ZTS_US_Case__c=unsentCase.id,ZTS_US_Local_Assessment__c='USDA');
        ZTS_US_Assessment__c[] assessments = new ZTS_US_Assessment__c[]{assessmentLocal1,assessmentLocal2};
        insert assessments;

        sentCase.Sync_Status__c=SYNC_SUCCESS;
        unsentCase.Sync_Status__c=SYNC_UNAPPROVED;
        update testCases;

        Test.startTest();
        
        assessmentLocal1.ZTS_US_Local_Assessment__c='FDA';
        assessmentLocal2.ZTS_US_Local_Assessment__c='FDA';
        update assessments;

        Test.stopTest();
        
        validateCase(SYNC_REAPPROVAL,sentCase.Id);
        validateCase(SYNC_UNAPPROVED,unsentCase.Id);
    }
    @isTest
    private static void testCaseStatusCheckCasePatientInsert(){
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case sentCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_SUCCESS);
        Case unsentCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_UNAPPROVED);
        insert new Case[]{sentCase, unsentCase};
        
        // Insert Breed
        ZTS_US_Breed__c Breed1 = new ZTS_US_Breed__c (Name = 'Terrier', ZTS_US_Species__c = 'Feline');
        insert Breed1;
        //Insert Animal
        ZTS_US_Animal__c animal = new ZTS_US_Animal__c(Name = 'Tessjyyy', ZTS_US_Species__c='Feline',
                                                       ZTS_US_Breed__c = Breed1.id,ZTS_US_Date_of_Birth__c = date.today()-500,
                                                       ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID');
        insert animal;

        Test.startTest();
        
        ZTS_US_Case_Animal__c caseAnimal1 = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = sentCase.Id, ZTS_US_Animal__c = animal.Id );
        ZTS_US_Case_Animal__c caseAnimal2 = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = unsentCase.Id, ZTS_US_Animal__c = animal.Id );
        insert new ZTS_US_Case_Animal__c[]{caseAnimal1,caseAnimal2};

        Test.stopTest();
        
        validateCase(SYNC_REAPPROVAL,sentCase.Id);
        validateCase(SYNC_UNAPPROVED,unsentCase.Id);
    }
    @isTest
    private static void testCaseStatusCheckCasePatientUpdate(){
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case sentCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_SUCCESS);
        Case unsentCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_UNAPPROVED);
        Case[] testCases = new Case[]{sentCase, unsentCase};
        insert testCases;

        // Insert Breed
        ZTS_US_Breed__c Breed1 = new ZTS_US_Breed__c (Name = 'Terrier', ZTS_US_Species__c = 'Feline');
        insert Breed1;
        //Insert Animal
        ZTS_US_Animal__c animal = new ZTS_US_Animal__c(Name = 'Tessjyyy', ZTS_US_Species__c='Feline',
                                                       ZTS_US_Breed__c = Breed1.id,ZTS_US_Date_of_Birth__c = date.today()-500,
                                                       ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID');
        insert animal;
        
        ZTS_US_Case_Animal__c caseAnimal1 = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = sentCase.Id, ZTS_US_Animal__c = animal.Id );
        ZTS_US_Case_Animal__c caseAnimal2 = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = unsentCase.Id, ZTS_US_Animal__c = animal.Id );
        ZTS_US_Case_Animal__c[] caseAnimals = new ZTS_US_Case_Animal__c[]{caseAnimal1,caseAnimal2};
        insert caseAnimals;

        sentCase.Sync_Status__c=SYNC_SUCCESS;
        unsentCase.Sync_Status__c=SYNC_UNAPPROVED;
        update testCases;

        Test.startTest();
        
        caseAnimal1.ZTS_US_Animal_condition_prior_treatment__c='Poor';
        caseAnimal2.ZTS_US_Animal_condition_prior_treatment__c='Poor';
        update caseAnimals;

        Test.stopTest();
        
        validateCase(SYNC_REAPPROVAL,sentCase.Id);
        validateCase(SYNC_UNAPPROVED,unsentCase.Id);
    }
    @isTest
    private static void testCaseStatusCheckEventNarrativeUpdate(){
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case sentCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_SUCCESS);
        Case unsentCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_UNAPPROVED);
        Case[] testCases = new Case[]{sentCase, unsentCase};
        insert testCases;

        //Create PVW Product record
        ZTS_US_PVW_Product__c prod1 = new ZTS_US_PVW_Product__c(Name = 'VANGUARD PLUS 5/L',ZTS_US_MAH_Country__c = 'US',ZTS_US_Active_Product__c = 'Yes');
        ZTS_US_PVW_Product__c prod2 = new ZTS_US_PVW_Product__c(Name = 'Symparica',ZTS_US_MAH_Country__c = 'US',ZTS_US_Active_Product__c = 'Yes');
        insert new ZTS_US_PVW_Product__c[]{prod1,prod2};

        //Insert Case Product Record
        ZTS_US_Case_Product__c caseProduct1 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = sentCase.Id,
                                                                        ZTS_US_PVW_Product__c = prod1.Id,ZTS_US_Product_problem_type__c='Adverse Reaction',
                                                                        ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        ZTS_US_Case_Product__c caseProduct2 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = unsentCase.Id,
                                                                        ZTS_US_PVW_Product__c = prod2.Id,ZTS_US_Product_problem_type__c='Adverse Reaction',
                                                                        ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        insert new ZTS_US_Case_Product__c[]{caseProduct1,caseProduct2};        
        ZTS_US_Event_Narrative__c eventNarrative1 = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
        ZTS_US_Outcome_of_Reaction__c = 'Died',
        ZTS_US_Duration_text__c = '30',
        ZTS_US_Case__c = sentCase.Id);
        ZTS_US_Event_Narrative__c eventNarrative2 = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'hfsdghthts',
        ZTS_US_Outcome_of_Reaction__c = 'Died',
        ZTS_US_Duration_text__c = '30',
        ZTS_US_Case__c = unsentCase.Id);
        ZTS_US_Event_Narrative__c[] eventNarratives = new ZTS_US_Event_Narrative__c[]{eventNarrative1,eventNarrative2};
        insert eventNarratives;

        sentCase.Sync_Status__c=SYNC_SUCCESS;
        sentCase.ZTS_US_Event_Narrative__c = eventNarrative1.Id; 
        unsentCase.Sync_Status__c=SYNC_UNAPPROVED;
        unsentCase.ZTS_US_Event_Narrative__c = eventNarrative2.Id;
        update testCases;

        Test.startTest();
        CSE_EventNarrativeTriggerHandler enHandler = new CSE_EventNarrativeTriggerHandler();
        DispatchTriggerHandler.setRecursionContexts(enHandler);
        eventNarrative1.ZTS_US_Event_Narrative_Summary_Field__c='sgsgdhsd';
        eventNarrative2.ZTS_US_Event_Narrative_Summary_Field__c='sgsgdhsd';
        update eventNarratives;

        Test.stopTest();
        
        validateCase(SYNC_REAPPROVAL,sentCase.Id);
        validateCase(SYNC_UNAPPROVED,unsentCase.Id);
    }
    @isTest
    private static void testCaseStatusCheckVedDRAEventInsert(){
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case sentCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_SUCCESS);
        Case unsentCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_UNAPPROVED);
        Case[] testCases = new Case[]{sentCase, unsentCase};
        insert testCases;
        //Create PVW Product record
        ZTS_US_PVW_Product__c prod1 = new ZTS_US_PVW_Product__c(Name = 'VANGUARD PLUS 5/L',ZTS_US_MAH_Country__c = 'US',ZTS_US_Active_Product__c = 'Yes');
        ZTS_US_PVW_Product__c prod2 = new ZTS_US_PVW_Product__c(Name = 'Symparica',ZTS_US_MAH_Country__c = 'US',ZTS_US_Active_Product__c = 'Yes');
        insert new ZTS_US_PVW_Product__c[]{prod1,prod2};

        //Insert Case Product Record
        ZTS_US_Case_Product__c caseProduct1 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = sentCase.Id,
                                                                        ZTS_US_PVW_Product__c = prod1.Id,ZTS_US_Product_problem_type__c='Adverse Reaction',
                                                                        ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        ZTS_US_Case_Product__c caseProduct2 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = unsentCase.Id,
                                                                        ZTS_US_PVW_Product__c = prod2.Id,ZTS_US_Product_problem_type__c='Adverse Reaction',
                                                                        ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        insert new ZTS_US_Case_Product__c[]{caseProduct1,caseProduct2};
        
        ZTS_US_Event_Narrative__c eventNarrative1 = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
        ZTS_US_Outcome_of_Reaction__c = 'Died',
        ZTS_US_Duration_text__c = '30',
        ZTS_US_Case__c = sentCase.Id);
        ZTS_US_Event_Narrative__c eventNarrative2 = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'hfsdghthts',
        ZTS_US_Outcome_of_Reaction__c = 'Died',
        ZTS_US_Duration_text__c = '30',
        ZTS_US_Case__c = unsentCase.Id);
        insert new ZTS_US_Event_Narrative__c[]{eventNarrative1,eventNarrative2};

        sentCase.Sync_Status__c=SYNC_SUCCESS;
        sentCase.ZTS_US_Event_Narrative__c = eventNarrative1.Id; 
        unsentCase.Sync_Status__c=SYNC_UNAPPROVED;
        unsentCase.ZTS_US_Event_Narrative__c = eventNarrative2.Id;
        update testCases;

        Test.startTest();
        
        ZTS_US_VedDRA_Event__c veddra1 = new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c=eventNarrative1.id);
        ZTS_US_VedDRA_Event__c veddra2 = new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c=eventNarrative2.id);
        ZTS_US_VedDRA_Event__c[] veddraEvents = new ZTS_US_VedDRA_Event__c[]{veddra1,veddra2};
        insert veddraEvents;

        Test.stopTest();
        
        validateCase(SYNC_REAPPROVAL,sentCase.Id);
        validateCase(SYNC_UNAPPROVED,unsentCase.Id);
    }
    @isTest
    private static void testCaseStatusCheckVedDRAEventUpdate(){
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case sentCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_SUCCESS);
        Case unsentCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_UNAPPROVED);
        Case[] testCases = new Case[]{sentCase, unsentCase};
        insert testCases;

        //Create PVW Product record
        ZTS_US_PVW_Product__c prod1 = new ZTS_US_PVW_Product__c(Name = 'VANGUARD PLUS 5/L',ZTS_US_MAH_Country__c = 'US',ZTS_US_Active_Product__c = 'Yes');
        ZTS_US_PVW_Product__c prod2 = new ZTS_US_PVW_Product__c(Name = 'Symparica',ZTS_US_MAH_Country__c = 'US',ZTS_US_Active_Product__c = 'Yes');
        insert new ZTS_US_PVW_Product__c[]{prod1,prod2};

        //Insert Case Product Record
        ZTS_US_Case_Product__c caseProduct1 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = sentCase.Id,
                                                                        ZTS_US_PVW_Product__c = prod1.Id,ZTS_US_Product_problem_type__c='Adverse Reaction',
                                                                        ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        ZTS_US_Case_Product__c caseProduct2 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = unsentCase.Id,
                                                                        ZTS_US_PVW_Product__c = prod2.Id,ZTS_US_Product_problem_type__c='Adverse Reaction',
                                                                        ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        insert new ZTS_US_Case_Product__c[]{caseProduct1,caseProduct2};        
        ZTS_US_Event_Narrative__c eventNarrative1 = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
        ZTS_US_Outcome_of_Reaction__c = 'Died',
        ZTS_US_Duration_text__c = '30',
        ZTS_US_Case__c = sentCase.Id);
        ZTS_US_Event_Narrative__c eventNarrative2 = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'hfsdghthts',
        ZTS_US_Outcome_of_Reaction__c = 'Died',
        ZTS_US_Duration_text__c = '30',
        ZTS_US_Case__c = unsentCase.Id);
        insert new ZTS_US_Event_Narrative__c[]{eventNarrative1,eventNarrative2};

        ZTS_US_VedDRA_Event__c veddra1 = new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c=eventNarrative1.id);
        ZTS_US_VedDRA_Event__c veddra2 = new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c=eventNarrative2.id);
        ZTS_US_VedDRA_Event__c[] veddraEvents = new ZTS_US_VedDRA_Event__c[]{veddra1,veddra2};
        insert veddraEvents;

        sentCase.Sync_Status__c=SYNC_SUCCESS;
        sentCase.ZTS_US_Event_Narrative__c = eventNarrative1.Id; 
        unsentCase.Sync_Status__c=SYNC_UNAPPROVED;
        unsentCase.ZTS_US_Event_Narrative__c = eventNarrative2.Id;
        update testCases;

        Test.startTest();
        date today = date.today();
        veddra1.ZTS_US_Start_Date__c=today.addDays(-2);
        veddra1.ZTS_US_Start_Date__c=today.addDays(-1);
        veddra2.ZTS_US_Start_Date__c=today.addDays(-2);
        veddra2.ZTS_US_Start_Date__c=today.addDays(-1);
        update veddraEvents;

        Test.stopTest();
        
        validateCase(SYNC_REAPPROVAL,sentCase.Id);
        validateCase(SYNC_UNAPPROVED,unsentCase.Id);
    }
    private static void validateCase(String expectedSyncValue,Id caseId){
        Case updatedCase = [SELECT ID,Sync_Status__c,Case_Updated_Date__c FROM Case WHERE Id =:caseId LIMIT 1];
        system.assertEquals(expectedSyncValue,updatedCase.Sync_Status__c);
        if(expectedSyncValue == SYNC_REAPPROVAL){
            system.assert(updatedCase.Case_Updated_Date__c!=null);
        }
        else{
            system.assert(updatedCase.Case_Updated_Date__c==null);
        }
    }
    @isTest
    private static void testCaseNotAllowedUpdate(){
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case phase1Case = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c='');
        Case phase2Case = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                Sync_Status__c=SYNC_UNAPPROVED);
        insert new Case[]{phase1Case, phase2Case};
        
        //Insert Contact
		List<contact> contactList = new  List<contact>();
        contactList.add(new Contact(LastName = 'Last1', FirstName = 'First1',ZTS_US_Job_Function__c = 'CFO', ZTS_US_Profession__c= 'Consultant'));   
        contactList.add(new Contact(LastName = 'Last2', FirstName = 'First2',ZTS_US_Job_Function__c = 'CFO', ZTS_US_Profession__c= 'Consultant'));
        insert contactList;
        
        //Insert Case Contact		
        Case_Contact__c caseContact1 = new Case_Contact__c(Contact__c = contactList[0].Id, ZTS_US_Contact_Role__c = 'Pharmacist', Case__c=phase1Case.Id);
        Case_Contact__c caseContact2 = new Case_Contact__c(Contact__c = contactList[1].Id, ZTS_US_Contact_Role__c = 'Pharmacist', Case__c=phase2Case.Id);
        Case_Contact__c[] caseContactList = new Case_Contact__c[]{caseContact1,caseContact2};
        insert caseContactList;

        phase1Case.PVW_External_ID__c='12345';
        update phase1Case;

        Test.startTest();
        caseContact1.ZTS_US_Contact_Role__c = 'Attending Vet';
        caseContact2.ZTS_US_Contact_Role__c = 'Attending Vet';
        String errorMessage = '';
        try{
            update caseContact1;
        }
        catch(exception e){
            errorMessage = e.getMessage();
        }
        system.assert(String.isNotBlank(errorMessage) && errorMessage.contains(VmipsCaseSyncStatusHandler.CASE_NOT_ELIGIBLE_FOR_PVW));
        errorMessage = '';
        try{
            update caseContact2;
        }
        catch(exception e){
            errorMessage = e.getMessage();
        }
        system.assert(String.isBlank(errorMessage));
        Test.stopTest();

    } 
    
    
    @isTest
    private static void testCaseStatusCheckWhenCaseProductDelete(){
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case testCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for delete Case products',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(), 
                                Sync_Status__c = SYNC_SUCCESS
                                );
 
        insert new Case[]{testCase};
        //Create PVW Product record
        ZTS_US_PVW_Product__c prod1 = new ZTS_US_PVW_Product__c(Name = 'VANGUARD PLUS 5/L',ZTS_US_MAH_Country__c = 'US',ZTS_US_Active_Product__c = 'Yes');
       
        insert new ZTS_US_PVW_Product__c[]{prod1};        

        Test.startTest();
        //Insert Case Product Record
        ZTS_US_Case_Product__c caseProduct1 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = testCase.Id,
                                                                        ZTS_US_PVW_Product__c = prod1.Id,ZTS_US_Product_problem_type__c='Adverse Reaction',
                                                                        ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        
        List<ZTS_US_Case_Product__c> productList = new List<ZTS_US_Case_Product__c>();
        productList.add(caseProduct1);
        insert productList;
        Test.stopTest();
        VmipsCaseSyncStatusHandler.updateCaseSyncStatus(productList, null , 'ZTS_US_Case_Product__c', 'ZTS_US_Case__c', 'ZTS_US_Case__r', null, Trigger.operationType);
        System.assertEquals([Select id,Sync_Status__c from case where id =: testCase.id][0].Sync_Status__c, SYNC_REAPPROVAL);
       
    }
    
}