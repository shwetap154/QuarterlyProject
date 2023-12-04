@isTest
public with sharing class PropelSAPIntegrationAttachErrorFilesTest {
    @isTest public static void PropelSAPIntegrationAttachErrorFilesTest() {
        List<PDLM__Phase__c> phasesToInsert = new List<PDLM__Phase__c>();
        Id userId = [SELECT Id FROM User WHERE Propel_Change_Analyst__c = true and IsActive = true LIMIT 1].Id;

        //ECO Lifecycle and related
        PDLM__Lifecycle__c lifecycle = new PDLM__Lifecycle__c(name='ECO', PDLM__primary_key__c = 'ECO');
        insert lifecycle;

        PDLM__Phase__c pendingPhase = new PDLM__Phase__c(Name='Pending', PDLM__Is_First_Phase__c = true, PDLM__order__c = 1, 
                                                         PDLM__No_Approval__c = true, PDLM__lifecycle__c = lifecycle.id);
        phasesToInsert.add(pendingPhase);

        PDLM__Phase__c CCBPhase = new PDLM__Phase__c(Name='PLM Review', PDLM__order__c = 2, PDLM__Auto_Submit_For_Approval__c = true, 
                                                     PDLM__lifecycle__c = lifecycle.id);
        phasesToInsert.add(CCBPhase);

        PDLM__Phase__c approvedPhase = new PDLM__Phase__c(Name='Approved', PDLM__order__c = 3, 
                                                         PDLM__No_Approval__c = true, PDLM__lifecycle__c = lifecycle.id);
        phasesToInsert.add(approvedPhase);

        //Insert phases
        insert phasesToInsert;

        PDLM__Autonumber__c autonumberChange = new PDLM__Autonumber__c(Name='Autonumber for ECO', PDLM__prefix__c = 'ECO-', 
                                                                       PDLM__Length__c = 5, PDLM__Next_Number__c = 1);
        insert autonumberChange;

        PDLM__Category__c categoryForChange = new PDLM__Category__c(Name='ECO', PDLM__autonumber__c = autonumberChange.id, 
                                                                    PDLM__Type__c = 'Change', PDLM__Lifecycle__c = lifecycle.id);
        insert categoryForChange;

        //Insert Configuration
        PDLM__Configuration__c config = new PDLM__Configuration__c(Name = 'AttachSapErrorFileToChange', PDLM__Value__c = 'true');
        insert config;

        //Insert Change
        PDLM__Change__c change = new PDLM__Change__c(Name = 'ECO-000001', 
                                                     PDLM__Category__c = categoryForChange.id, 
                                                     Change_Analyst__c = userId,
                                                     PDLM__Title__c='Test SAP ECO');
        insert change;

        Test.startTest();
        Integer emailbefore = Limits.getEmailInvocations();

        //ContentVersion
        ContentVersion cv = new ContentVersion();
        String tempTitle =  'ECO-000001_Error_File.txt';
        cv.Title = tempTitle;
        cv.Description = 'PLM-SAP Interface Error Log';
        cv.PathOnClient = tempTitle;
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        insert cv;

        //Check if the file has been attached
        List<ContentDocumentLink> cdls = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :change.Id];
        System.assertEquals(1, cdls.size());

        //Check if an email is sent
        System.assertNotEquals(emailbefore,Limits.getEmailInvocations(),'should have changed');
        Test.stopTest();    
    }
}