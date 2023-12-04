@isTest
public with sharing class CSE_VedDraEventTriggerHandler_Test {
    static final String RECORDTYPE_CASE_ANIMAL_SUPPORT_STR = 'Animal_Support';

    @testSetup
    public static void  makedata(){
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case testCase = new Case(Subject = 'Test Case',
                           Status = 'New',
                           Origin = 'Email',
                           Type = 'Animal Complaint',
                           RecordTypeId = animalRecordtypeId,                                
                           ZTS_US_Information_Type__c = 'Erred'
                           );
        insert testCase;
        ZTS_US_PVW_Product__c prod1 = new ZTS_US_PVW_Product__c(Name = 'VANGUARD PLUS 5/L',ZTS_US_MAH_Country__c = 'US',ZTS_US_Active_Product__c = 'Yes');
        insert prod1;       

        Test.startTest();
        //Insert Case Product Record
        ZTS_US_Case_Product__c caseProduct1 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = testCase.Id,
                                                                        ZTS_US_PVW_Product__c = prod1.Id,ZTS_US_Product_problem_type__c='Adverse Reaction',
                                                                        ZTS_US_Start_Date__c = Date.newInstance(2022, 10, 09),
                                                                        ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        insert caseProduct1;
      
         //Insert Event Narrative record
         ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
         ZTS_US_Outcome_of_Reaction__c = 'Died',
         ZTS_US_Duration_text__c = '30',
         ZTS_US_Reaction_Treated__c ='Yes',
         ZTS_US_Treatment__c = 'Test treatment',
         ZTS_US_Case__c = testCase.Id);
         insert eventNarrative;
        
        //inserting Veddra Coding records
        List<ZTS_US_VedDRA_Coding__c> veddraCodings = ZTS_DataUtilityTest.createVeddraCodings(2); // Adjust the argument as neede
        insert veddraCodings; 
        
        ZTS_US_VedDRA_Event__c testVedDRA =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id,
                                                                     ZTS_US_VedDRA_Coding__c = veddraCodings[1].Id, // Use one of the generated codings
                                                                     Duration_Units__c = 'Hour(s)',
                                                                     ZTS_US_Number_of_pts_affected__c = 1,
                                                                     ZTS_US_Start_Date__c = date.today()-1,
                                                                     ZTS_US_Ongoing__c = 'Yes');
    insert testVedDRA;
        
    }

    @isTest
    public static void ValidateVedDraEvent_Positive(){

        ZTS_US_VedDRA_Event__c testVedDRA1 = [SELECT ID,ZTS_US_Event_Narrative__c,ZTS_US_Number_of_pts_affected__c,ZTS_US_Notes__c,ZTS_US_Start_Date__c,ZTS_US_Ongoing__c 
                                            from ZTS_US_VedDRA_Event__c 
                                            WHERE ZTS_US_Ongoing__c = 'Yes' LIMIT 1];
        testVedDRA1.ZTS_US_Notes__c = 'Test VedDra Audit';
                                            
        test.startTest();
        update testVedDRA1;
        test.stopTest();

        ZTS_US_CSE_Audit_Trail__c newAuditRec1 = [Select Id, Field_Name__c,New_Value__c,Old_Value__c,Object_Name__c,Record_Id__c from ZTS_US_CSE_Audit_Trail__c WHERE Field_Name__c!=null LIMIT 1];
        System.assertEquals(testVedDRA1.Id,newAuditRec1.Record_Id__c);
        System.assertEquals('ZTS_US_Notes__c',newAuditRec1.Field_Name__c);
        System.assertEquals(null,newAuditRec1.Old_Value__c);
        System.assertEquals('Test VedDra Audit',newAuditRec1.New_Value__c);
        System.assertEquals('ZTS_US_VedDRA_Event__c',newAuditRec1.Object_Name__c);

    }
    @isTest
    public static void ValidateVedDraEvent_Negative(){
        ZTS_US_VedDRA_Event__c testVedDRA2 = [SELECT ID,ZTS_US_Event_Narrative__c,ZTS_US_Number_of_pts_affected__c,ZTS_US_Notes__c,ZTS_US_Start_Date__c,ZTS_US_Ongoing__c 
                                            from ZTS_US_VedDRA_Event__c 
                                            WHERE ZTS_US_Ongoing__c = 'Yes' LIMIT 1];
        
        test.startTest();
        update testVedDRA2;
        test.stopTest();

        List<ZTS_US_CSE_Audit_Trail__c> newAuditRec2 = [Select Id, Field_Name__c,New_Value__c,Old_Value__c,Object_Name__c,Record_Id__c from ZTS_US_CSE_Audit_Trail__c WHERE Field_Name__c!=null LIMIT 1];
        System.assertEquals(0,newAuditRec2.size());
    }
    //test method to only acheive test coverage for unused trigger events beforedelete, afterdelete, afterundelete.
    @isTest
    private static void CSE_VedDraEventTriggerHandler_Delete(){    
        ZTS_US_VedDRA_Event__c testVedDRA3 = [SELECT ID,ZTS_US_Event_Narrative__c,ZTS_US_Number_of_pts_affected__c,ZTS_US_Notes__c,ZTS_US_Start_Date__c,ZTS_US_Ongoing__c 
                                            from ZTS_US_VedDRA_Event__c 
                                            WHERE ZTS_US_Ongoing__c = 'Yes' LIMIT 1];
        delete testVedDRA3;
        undelete testVedDRA3;
        
    }
    
    //test method to validate the veddra event start and end date
    @isTest
    private static void Test_ValidateVeddraEvent(){
        
        List<ZTS_US_VedDRA_Event__c> testVedDRA1 = [SELECT ID,ZTS_US_Event_Narrative__c,ZTS_US_Number_of_pts_affected__c,ZTS_US_Notes__c,ZTS_US_Start_Date__c,ZTS_US_Ongoing__c 
                                              from ZTS_US_VedDRA_Event__c 
                                              WHERE ZTS_US_Ongoing__c = 'Yes' LIMIT 1];
        
        testVedDRA1[0].ZTS_US_Start_Date__c = Date.newInstance(2022,10,07);
        testVedDRA1[0].ZTS_US_End_Date__c = Date.newInstance(2022, 10, 08);
        
        
        try{
           update testVedDRA1;

        }
        catch(Exception e){
            Boolean message = e.getMessage().contains('Veddra Event Start Date/End date should be greater than or equal to the earliest dose start date') ? true : false;
            System.AssertEquals(message, true);

        }
        
    }
    
     //test method to validate the veddra event before insert
    @isTest
    private static void Test_ValidateVeddraEvent1(){
       List<ZTS_US_VedDRA_Coding__c> veddraCode = [SELECT Id, Version__c FROM ZTS_US_VedDRA_Coding__c WHERE Version__c=1];
        List<ZTS_US_Event_Narrative__c> eventNarrative =[SELECT ID FROM ZTS_US_Event_Narrative__c LIMIT 1];
        if (!eventNarrative.isEmpty() && !veddraCode.isEmpty()) {
        ZTS_US_VedDRA_Event__c testVedDRA =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative[0].id,ZTS_US_VedDRA_Coding__c=veddraCode[0].Id, Duration_Units__c = 'Hour(s)', ZTS_US_Number_of_pts_affected__c = 1, ZTS_US_Start_Date__c = date.today()-1, ZTS_US_Ongoing__c = 'Yes');
        test.startTest();
        String errorMessage;
       try{
           insert testVedDRA;

        }
        catch(Exception e){
            errorMessage = e.getMessage();
        }
        Boolean message = errorMessage.contains('The selected VedDRA Code is from a previous dictionary version and is not valid. Please select another code. Selected Version: ' + 
                                           veddraCode[0].Version__c + ', Current Version: ' + 2) ? true : false;
            System.AssertEquals(message, true,errorMessage);
        test.stopTest();
        }
    }

    
    //test method to validate the veddra event before update
    @isTest
private static void Test_ValidateVeddraEvent2(){
    List<ZTS_US_VedDRA_Coding__c> veddraCode = [SELECT Id, Version__c FROM ZTS_US_VedDRA_Coding__c Order By Version__c ASC];
    List<ZTS_US_Event_Narrative__c> eventNarrative =[SELECT ID FROM ZTS_US_Event_Narrative__c LIMIT 1];
    
    ZTS_US_VedDRA_Event__c testVedDRA = new ZTS_US_VedDRA_Event__c(
        ZTS_US_Event_Narrative__c = eventNarrative[0].Id, // Add the necessary value
        ZTS_US_VedDRA_Coding__c = veddraCode[1].Id,
        ZTS_US_Number_of_pts_affected__c = 1,
        ZTS_US_Notes__c = null, // Add the necessary value
        ZTS_US_Start_Date__c = Date.today() - 1,
        ZTS_US_Ongoing__c = 'Yes'
    );
    insert testVedDRA;

    test.startTest();
	String errorMessage;
    try{
        testVedDRA.ZTS_US_VedDRA_Coding__c = veddraCode[0].Id;
        update testVedDRA;

    }
    catch(Exception e){
		errorMessage =  e.getMessage();
    }
    Boolean message = errorMessage.contains('The selected VedDRA Code is from a previous dictionary version and is not valid. Please select another code. Selected Version: ' + 
                                       veddraCode[0].Version__c + ', Current Version: ' + 2) ? true : false;
    System.AssertEquals(message, true,errorMessage);
    test.stopTest();
}
    
    //test method to validate multiple veddra event records being inserted at once
    @isTest
private static void Test_ValidateVeddraEvent3(){
    List<ZTS_US_VedDRA_Coding__c> veddraCode = [SELECT Id, Version__c FROM ZTS_US_VedDRA_Coding__c Order By Version__c ASC];
    List<ZTS_US_Event_Narrative__c> eventNarrative =[SELECT ID FROM ZTS_US_Event_Narrative__c LIMIT 1];
    
    List<ZTS_US_VedDRA_Event__c> listVedDRAEvent = new List<ZTS_US_VedDRA_Event__c>();
    ZTS_US_VedDRA_Event__c testVedDRA1 = new ZTS_US_VedDRA_Event__c(
        ZTS_US_Event_Narrative__c = eventNarrative[0].Id, // Add the necessary value
        ZTS_US_VedDRA_Coding__c = veddraCode[1].Id,
        ZTS_US_Number_of_pts_affected__c = 1,
        ZTS_US_Notes__c = null, // Add the necessary value
        ZTS_US_Start_Date__c = Date.today() - 1,
        ZTS_US_Ongoing__c = 'Yes'
    );
    listVedDRAEvent.add(testVedDRA1);
    ZTS_US_VedDRA_Event__c testVedDRA2 = new ZTS_US_VedDRA_Event__c(
        ZTS_US_Event_Narrative__c = eventNarrative[0].Id, // Add the necessary value
        ZTS_US_VedDRA_Coding__c = veddraCode[0].Id,
        ZTS_US_Number_of_pts_affected__c = 1,
        ZTS_US_Notes__c = null, // Add the necessary value
        ZTS_US_Start_Date__c = Date.today() - 1,
        ZTS_US_Ongoing__c = 'Yes'
    );
    listVedDRAEvent.add(testVedDRA2);
    //insert testVedDRA;

    test.startTest();
	String errorMessage;
    try{
        insert listVedDRAEvent;
    }
    catch(Exception e){
		errorMessage =  e.getMessage();
    }
     Boolean message = errorMessage.contains('The selected VedDRA Code is from a previous dictionary version and is not valid. Please select another code. Selected Version: ' + 
                                       veddraCode[0].Version__c + ', Current Version: ' + 2) ? true : false;
        System.AssertEquals(message, true,errorMessage);
    test.stopTest();
}


}