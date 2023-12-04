/****************************************************************************************************************************************** 
 * Class Name   : CSE_AssessmentTriggerHandler_Test
 * Description  : This testc class will handle all CSE_AssessmentTriggerHandler unit tests
 * Created By   : Slalom Consulting/Neil Kapoor
 * Created Date : September 14th 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                			Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Neil Kapoor(Slalom)     			   09/14/2021          Created 
*****************************************************************************************************************************************/
@isTest
public with sharing class CSE_AssessmentTriggerHandler_Test
{
    @testSetup
    public static void setupData(){
    String RECORDTYPE_CASE_ANIMAL_SUPPORT_STR = 'Animal_Support';
    String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId(); 
    String localRecordtypeId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get('ZTS_US_Local_Assessment').getRecordTypeId(); 
    String productRecordtypeId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get('ZTS_US_Product_Assessment').getRecordTypeId();

        Case testCase = new Case(Subject = 'Test Case',
        Status = 'New',
        Origin = 'Phone',
        Type = 'Animal Complaint',
        RecordTypeId = animalRecordtypeId,
        Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_SUCCESS
        );
        insert testCase;
        
        ZTS_US_Assessment__c localAssessment = new ZTS_US_Assessment__c
        (    
            ZTS_US_Local_Assessment__c = 'EPA',
            RecordTypeId=localRecordtypeId,
            ZTS_US_Case__c = testCase.id
        );
        ZTS_US_Assessment__c productAssessment = new ZTS_US_Assessment__c
        (    
            ZTS_US_Dechallenge_PA__c = 'Abated',
            ZTS_US_Expected_PA__c = 'Yes',
            RecordTypeId=productRecordtypeId,
            ZTS_US_Case__c = testCase.id
        );
        insert new ZTS_US_Assessment__c[]{localAssessment,productAssessment};
    }

    @isTest
    private static void test_CSE_AssessmentTriggerHandler_Positive(){
        
        final String EXCEPTION_MESSAGE = 'cannot be set to null';
        ZTS_US_Assessment__c[] assessments = [  SELECT ID, ZTS_US_Dechallenge_PA__c, ZTS_US_Expected_PA__c,ZTS_US_Local_Assessment__c,RecordType.Name 
                                                FROM ZTS_US_Assessment__c];
        test.startTest();
        system.assertEquals(2,assessments.size());
        for(ZTS_US_Assessment__c assessment : assessments){
            if(assessment.RecordType.Name == 'Local Assessment'){
                assessment.ZTS_US_Local_Assessment__c = 'FDA';
            }
            else if(assessment.RecordType.Name == 'Product Assessment'){
                assessment.ZTS_US_Expected_PA__c = 'No';
            }
        }
        try{
            update assessments;
        }catch(Exception ex){
            System.Assert(false, 'the test should never throw an error');
        }
        test.stopTest();
        ZTS_US_Assessment__c[] updatedAssessments = [ SELECT ID, ZTS_US_Local_Assessment__c,ZTS_US_Dechallenge_PA__c, ZTS_US_Expected_PA__c,RecordType.Name 
                                                    FROM ZTS_US_Assessment__c];
        for(ZTS_US_Assessment__c assessment : updatedAssessments){
            if(assessment.RecordType.Name == 'Local Assessment'){
                System.Assert(assessment.ZTS_US_Local_Assessment__c == 'FDA', 'the field should have successfully been changed to no');
            }
            else if(assessment.RecordType.Name == 'Product Assessment'){
                System.Assert(assessment.ZTS_US_Expected_PA__c == 'No', 'the field should have successfully been changed to no');
            }
        }
        

    }

    @isTest
    private static void test_CSE_AssessmentTriggerHandler_Negative(){
        final String EXCEPTION_MESSAGE = 'cannot be set to null';
        ZTS_US_Assessment__c[] assessments = [  SELECT ID, ZTS_US_Dechallenge_PA__c, ZTS_US_Expected_PA__c,ZTS_US_Local_Assessment__c,RecordType.Name 
                                                FROM ZTS_US_Assessment__c];
        Boolean exceptionThrownMessage =false;
        test.startTest();
        system.assertEquals(2,assessments.size());
        for(ZTS_US_Assessment__c assessment : assessments){
            if(assessment.RecordType.Name == 'Local Assessment'){
                assessment.ZTS_US_Local_Assessment__c = null;
            }
            else if(assessment.RecordType.Name == 'Product Assessment'){
                assessment.ZTS_US_Expected_PA__c = null;
            }
        }
        
        try{
            update assessments;
        } catch(Exception ex){
            exceptionThrownMessage =  ex.getMessage().contains(EXCEPTION_MESSAGE) ? true : false;
            System.assertEquals(true, exceptionThrownMessage, 'We expect that there will be a validation error on the related Assessment record due to one of its fields on its approval field set becoming a null value');
            System.debug('error message'+exceptionThrownMessage);
        }
        test.stopTest();
        ZTS_US_Assessment__c[] updatedAssessments = [SELECT ID,ZTS_US_Expected_PA__c,ZTS_US_Local_Assessment__c,RecordType.Name
                                               FROM ZTS_US_Assessment__c];
        for(ZTS_US_Assessment__c assessment : updatedAssessments){
            if(assessment.RecordType.Name == 'Local Assessment'){
                System.assertNotEquals(null,assessment.ZTS_US_Local_Assessment__c , 'The update should have thrown an error due to the required field being set to null');
            }
            else if(assessment.RecordType.Name == 'Product Assessment'){
                System.assertNotEquals(null,assessment.ZTS_US_Expected_PA__c , 'The update should have thrown an error due to the required field being set to null');
            }
        }
        
    }
    
    //test method to only acheive test coverage for unused trigger events beforedelete, afterdelete, afterundelete.
    @isTest
    private static void test_CSE_AssessmentTriggerHandler_Delete(){      

        ZTS_US_Assessment__c assessmentTest = [SELECT ID, ZTS_US_Dechallenge_PA__c, ZTS_US_Expected_PA__c FROM ZTS_US_Assessment__c WHERE ZTS_US_Dechallenge_PA__c = 'Abated' LIMIT 1];
        delete assessmentTest;
        undelete assessmentTest;
    }
    
}