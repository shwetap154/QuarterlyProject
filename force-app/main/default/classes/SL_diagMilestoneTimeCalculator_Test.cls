/**
 * @description       : Test class for SL_diagnosticsMilestoneTimeCalculator
 * @author            : Unknown
 * @group             : 
 * @last modified on  : 07-25-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-08-2020   Unknown                     Initial Version
 * 1.1   07-25-2022   Ethan Hirsch @ Zoetis Inc   Add Test.startTest and Test.stopTest to avoid SOQL limits
**/
@isTest
public with sharing class SL_diagMilestoneTimeCalculator_Test {
    
    @isTest
    public static void testHandler() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr){

            Id idRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Diagnostics').getRecordTypeId();
    
            Service_Cloud_Settings__mdt cusMdtRecord = [SELECT Id, Diagnostics_L1_Milestone_Type_Id__c, Diagnostics_L1_SLA__c, 
                                                        Diagnostics_L2_Milestone_Type_Id__c, Diagnostics_L2_SLA__c,
                                                        Diagnostics_L3_Milestone_Type_Id__c, Diagnostics_L3_SLA__c,
                                                        Diagnostics_Case_Milestone_Type_Id__c, Diagnostics_Case_SLA__c
                                                        FROM Service_Cloud_Settings__mdt
                                                        WHERE MasterLabel = 'DEFAULT'];
    
            Account objAcc = (Account)SL_TestDataFactory.createSObject(new Account(Name='Test for Milestone',
                                                                                    ZTS_EU_Zip_Postal_Code__c = '12345',
                                                                                    BillingPostalCode = '12345',
                                                                                    BillingCity = 'Boca Raton',
                                                                                    BillingState = 'Florida',
                                                                                    BillingStreet = 'Elm Lane',
                                                                                    ZTS_EU_Market__c = 'Italy'
                                                                                    ), true);
            //insert objAcc;
    
            SlaProcess ep = [Select id from SlaProcess Where Name='Diagnostics' AND IsActive = true AND IsVersionDefault = true ];
            
            Entitlement entl = (Entitlement)SL_TestDataFactory.createSObject(new entitlement(   name='Test Entilement',
                                                                                                AccountId=objAcc.id,
                                                                                                type='Phone Support',
                                                                                                SlaProcessId = ep.Id,
                                                                                                StartDate=Date.valueof(System.now().addDays(-2)), 
                                                                                                EndDate=Date.valueof(System.now().addDays(30))), true);
            //insert entl;
            Asset objAsset = (Asset)SL_TestDataFactory.createSObject(new Asset(Name= 'Test Asset' ), true);
    
            Case objCase = (case)SL_TestDataFactory.createSObject(new Case( Subject='Test Milestone Case',
                                                                            Type='Complaint',
                                                                            AssetId = objAsset.Id,
                                                                            Status='In Progress',
                                                                            RecordTypeId = idRecordTypeId,
                                                                            EntitlementId = entl.Id), true);
    
            List<MilestoneType> lstmt = null;
            Integer t = 0; 
            
            lstmt = [SELECT Id, Name FROM MilestoneType WHERE Name ='Diagnostics Case' LIMIT 1];
            if(lstmt != null && !lstmt.isEmpty()) {
                t = new SL_diagnosticsMilestoneTimeCalculator().calculateMilestoneTriggerTime(objCase.Id, lstmt[0].Id);
                System.assertEquals(cusMdtRecord.Diagnostics_Case_SLA__c, t, 'Get the time as '+cusMdtRecord.Diagnostics_Case_SLA__c+' for Diagnostics Case');
            }
            
            lstmt = [SELECT Id, Name FROM MilestoneType WHERE Name ='Diagnostics L1' LIMIT 1];
            if(lstmt != null && !lstmt.isEmpty()) {
                t = new SL_diagnosticsMilestoneTimeCalculator().calculateMilestoneTriggerTime(objCase.Id, lstmt[0].Id);
                System.assertEquals(cusMdtRecord.Diagnostics_L1_SLA__c, t, 'Get the time as '+cusMdtRecord.Diagnostics_L1_SLA__c+' for Diagnostics L1');
            }
            // For CaseMilestone code coverage
            List<CaseMilestone> lstcms = [SELECT Id, IsCompleted FROM CaseMilestone WHERE CaseId = :objCase.Id ];
            lstcms[0].CompletionDate = System.now().addDays(5);
            update lstcms;
            
            // Start Test here to avoid SOQL Limits
            Test.startTest();
                objCase.L1_SLA_Breach_Time__c = System.now().addDays(1);
                objCase.Overall_SLA_Breach_Time__c = System.now().addDays(1);
                update objCase;
                
                t = new SL_diagnosticsMilestoneTimeCalculator().calculateMilestoneTriggerTime(objCase.Id, lstmt[0].Id);
                
                lstmt = [SELECT Id, Name FROM MilestoneType WHERE Name ='Diagnostics L2' LIMIT 1];
                if(lstmt != null && !lstmt.isEmpty()) {
                    t = new SL_diagnosticsMilestoneTimeCalculator().calculateMilestoneTriggerTime(objCase.Id, lstmt[0].Id);
                    System.assertEquals(cusMdtRecord.Diagnostics_L2_SLA__c, t, 'Get the time as '+cusMdtRecord.Diagnostics_L2_SLA__c+' for Diagnostics L2');
                }
                
                // For CaseMilestone code coverage
                lstcms = [SELECT Id, IsCompleted FROM CaseMilestone WHERE CaseId = :objCase.Id ];
                lstcms[0].CompletionDate = System.now();
                update lstcms;
                t = new SL_diagnosticsMilestoneTimeCalculator().calculateMilestoneTriggerTime(objCase.Id, lstmt[0].Id);
                
                lstmt = [SELECT Id, Name FROM MilestoneType WHERE Name ='Diagnostics L3' LIMIT 1];
                if(lstmt != null && !lstmt.isEmpty()) {
                    t = new SL_diagnosticsMilestoneTimeCalculator().calculateMilestoneTriggerTime(objCase.Id, lstmt[0].Id);
                    System.assertEquals(cusMdtRecord.Diagnostics_L3_SLA__c, t, 'Get the time as '+cusMdtRecord.Diagnostics_L3_SLA__c+' for Diagnostics L3');
                }
                lstmt = [SELECT Id, Name FROM MilestoneType WHERE Name ='Diagnostics Case' LIMIT 1];
                if(lstmt != null && !lstmt.isEmpty())       
                    t = new SL_diagnosticsMilestoneTimeCalculator().calculateMilestoneTriggerTime(objCase.Id, lstmt[0].Id);
            Test.stopTest();
        }
    }
    
}