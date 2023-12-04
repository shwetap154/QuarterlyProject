/**
* @ClassName    : AnimalSupportAlignedReps
* @SystemChange : SC-009661
* @CreatedOn    : 15/012023
* @CreatedBy    : Prasun Dubey (Cognizant)
* @Description  : Test class for AnimalSupportAlignedReps class
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   04-04-2023   Harvinder Kaur @ Zoetis Inc Removed Deactivated picklist values from ZTS_US_Interval_Unit__c
**/
@isTest
public class AnimalSupportAlignedReps_Test {
    
    private static final String vmipsBaseCaseSubject = 'VMIPS Base Case';
    private static final String vmipsAnestheticCaseSubject = 'VMIPS Anesthetic Case';
    
    @testSetup static void setup(){
        Allow_VMIPS_SIB_Email_Flag__c emailFlag = Allow_VMIPS_SIB_Email_Flag__c.getOrgDefaults();
        emailFlag.Is_Notification_Enabled__c = true;
        upsert emailFlag;
        
        User newuser = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        newuser.FirstName = 'davidsUser';
        newuser.ZTS_EU_Market__c = 'United States';
        newuser.Sharing_Business_Unit__c = 'Equine';
        insert newuser;
        
        System.runAs(newuser){
            List<Account> acclist=ZTS_DataUtilityTest.createAccountRecord(1);
            insert acclist;
            
            List<ZTS_EU_Territory__c> customterrList=ZTS_DataUtilityTest.createCustomTerritory(1);
            insert customterrList;
            
            List<ZTS_EU_Position__c> userterrlist= ZTS_DataUtilityTest.createUserTerritory(customterrList);
            insert userterrlist;
            
            
            List<ZTS_AccountTerritory__c> accterr=ZTS_DataUtilityTest.createAccountTerritory(acclist, customterrList);
            accterr[0].ZTS_SIB_Flag__c = true;
            insert accterr;
            
            List<ZTS_EU_Account_Position__c> accountPositions = [Select Id,ZTS_EU_Employee__c,ZTS_SIB_Flag__c,ZTS_EU_Account__c,
                                                                 Account_Market__c,ZTS_AccountTerritory__r.ZTS_EU_Territory__r.ZTS_EU_Type__c From ZTS_EU_Account_Position__c];
            setBypasses();
            
            Id vmipsRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Animal_Support').getRecordTypeId();
        
            Case vmipsBaseCase = ZTS_DataUtilityTest.createCases(1, vmipsRecordTypeId)[0];
            vmipsBaseCase.Subject = vmipsBaseCaseSubject;
            vmipsBaseCase.Type = 'Animal Complaint';
            vmipsBaseCase.AccountId = acclist[0].Id;
    
            Case anestheticsCase = ZTS_DataUtilityTest.createCases(1, vmipsRecordTypeId)[0];
            anestheticsCase.Subject = vmipsAnestheticCaseSubject;
            anestheticsCase.Type = 'Animal Complaint';
            anestheticsCase.AccountId = acclist[0].Id;
    
            insert new List<Case> {vmipsBaseCase, anestheticsCase};
    
            List<ZTS_US_PVW_Product__c> pvwProducts = ZTS_DataUtilityTest.createPvwProducts(2);
            
            pvwProducts[1].ZTS_US_Product_Line__c = [
                SELECT Product_Line__c
                FROM PVW_Product_Line_Type_Grouping__mdt
                WHERE Product_Type__c = 'Anesthetic'
                LIMIT 1].Product_Line__c.toLowerCase();
    
            insert pvwProducts;
    
            Id zoetisProductRecordTypeId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get('Zoetis_Product').getRecordTypeId();
            ZTS_US_Case_Product__c baseCaseProduct = ZTS_DataUtilityTest.createCaseProducts(1, zoetisProductRecordTypeId, vmipsBaseCase.Id, pvwProducts[0].Id)[0];
            baseCaseProduct.ZTS_US_Product_Role__c = 'Suspect Product';
    
            ZTS_US_Case_Product__c anestheticCaseProduct = ZTS_DataUtilityTest.createCaseProducts(1, zoetisProductRecordTypeId, anestheticsCase.Id, pvwProducts[1].Id)[0];
            
            insert new List<ZTS_US_Case_Product__c> {baseCaseProduct, anestheticCaseProduct};
    
            ZTS_US_Event_Narrative__c eventNarrative = ZTS_DataUtilityTest.createEventNarratives(1, vmipsBaseCase.Id)[0];
            insert eventNarrative;
    
            ZTS_US_VedDra_Coding__c vedraCoding = ZTS_DataUtilityTest.createVeddraCodings(1)[0];
            insert vedraCoding;
    
            ZTS_US_VedDRA_Event__c veddraEvent = ZTS_DataUtilityTest.createVeddraEvent(eventNarrative.Id, vedraCoding.Id);
            insert veddraEvent;
    
            Id localAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get('ZTS_US_Local_Assessment').getRecordTypeId();
            ZTS_US_Assessment__c assessment = ZTS_DataUtilityTest.createAssessments(1, vmipsBaseCase.Id, localAssessmentRTId)[0];
            insert assessment;
            
            vmipsBaseCase.ZTS_US_Event_Narrative__c = eventNarrative.Id;
            update vmipsBaseCase;
            
            // Insert Breed
            ZTS_US_Breed__c Breed1 = (ZTS_US_Breed__c) SL_TestDataFactory.createSObject(ZTS_DataUtilityTest.createBreeds(1, 'Equine')[0], true);
            
            //Insert Animal
            ZTS_US_Animal__c testUSAnimal = ZTS_DataUtilityTest.createAnimals(1, System.today().addDays(-10))[0];
            testUSAnimal.Name = 'Tessy';
            testUSAnimal.ZTS_US_Species__c = 'Equine';
            testUSAnimal.ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID';
            testUSAnimal.ZTS_US_Breed__c = Breed1.Id;
            testUSAnimal = (ZTS_US_Animal__c) SL_TestDataFactory.createSObject(testUSAnimal, true);

        	//Insert case Animal
        	ZTS_US_Case_Animal__c caseAnimal = (ZTS_US_Case_Animal__c) SL_TestDataFactory.createSObject( new ZTS_US_Case_Animal__c( ZTS_US_Case__c = vmipsBaseCase.Id, ZTS_US_Animal__c = testUSAnimal.Id, ZTS_US_Animal_condition_prior_treatment__c='Good' ), true);
            
            clearBypasses();
        }
    }
    
    @isTest static void checkSyncStatusChange(){
        Case newCase = [Select Id,Sync_Status__c From Case limit 1];
        Test.startTest();
        newCase.Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_READY;
        update newCase;
        Test.stopTest(); 
        Case updatedCase = [SELECT Id, Sync_Status__c FROM Case WHERE Id = :newCase.Id];
        System.assertEquals(VmipsCaseSyncStatusHandler.SYNC_READY, updatedCase.Sync_Status__c, 'Sync Status shows Ready when case has all the required validations.');
    }
    
    @isTest static void testAlignedUserIdsBasedOnCaseSpecies(){
        List<ZTS_US_Case_Animal__c> casePatients = new List<ZTS_US_Case_Animal__c>();
        casePatients = [Select Id,ZTS_US_Case__c,ZTS_US_Case__r.AccountId,ZTS_US_Animal__c,ZTS_US_Animal__r.ZTS_US_Species__c 
                      From ZTS_US_Case_Animal__c];
        Test.startTest();
        AnimalSupportAlignedReps.CaseToAlignedRepsObject[] caseToAlignedReps = new List<AnimalSupportAlignedReps.CaseToAlignedRepsObject>();
        caseToAlignedReps = AnimalSupportAlignedReps.sentRepNotification(new List<Id>{casePatients[0].ZTS_US_Case__c});
        Test.stopTest(); 
        ZTS_EU_Position__c position = [Select Id,ZTS_EU_Employee__c From ZTS_EU_Position__c limit 1];
        System.assert(caseToAlignedReps[0].userIds.contains(position.ZTS_EU_Employee__c), 'Aligned user should be in return list.'); 
    }
    
    private static void setBypasses(){
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('ContactTriggerHandler');
        DispatchTriggerHandler.bypass('AddressTriggerHandler');
        DispatchTriggerHandler.bypass('BatchDetailTriggerHandler');
        DispatchTriggerHandler.bypass('CSE_CaseContactTriggerHandler');
        DispatchTriggerHandler.bypass('CSE_CaseProductTriggerHandler');
        DispatchTriggerHandler.bypass('CSE_AnimalTriggerHandler');
        DispatchTriggerHandler.bypass('CSE_CaseAnimalTriggerHandler');
        DispatchTriggerHandler.bypass('CSE_AssessmentTriggerHandler');
        DispatchTriggerHandler.bypass('CSE_EventNarrativeTriggerHandler');
        DispatchTriggerHandler.bypass('CSE_VedDraEventTriggerHandler');
        CustomSettingService.setTriggerBypass('ZTS_EU_ServiceRequest', true);
    }
    private static void clearBypasses(){
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        DispatchTriggerHandler.clearBypass('ContactTriggerHandler');
        DispatchTriggerHandler.clearBypass('AddressTriggerHandler');
        DispatchTriggerHandler.clearBypass('BatchDetailTriggerHandler');
        DispatchTriggerHandler.clearBypass('CSE_CaseContactTriggerHandler');
        DispatchTriggerHandler.clearBypass('CSE_CaseProductTriggerHandler');
        DispatchTriggerHandler.clearBypass('CSE_AnimalTriggerHandler');
        DispatchTriggerHandler.clearBypass('CSE_CaseAnimalTriggerHandler');
        DispatchTriggerHandler.clearBypass('CSE_AssessmentTriggerHandler');
        DispatchTriggerHandler.clearBypass('CSE_EventNarrativeTriggerHandler');
        DispatchTriggerHandler.clearBypass('CSE_VedDraEventTriggerHandler');
        CustomSettingService.setTriggerBypass('ZTS_EU_ServiceRequest', false);
    }
}