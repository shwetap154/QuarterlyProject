/**
 * @description       : Test class for CEEventUpdateAttendeeStatus class.
 * @author            : Unknown (Migrated file)
 * @group             : 
 * @last modified on  : 03-22-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   07-29-2020   Unknown                     Initial Version (Migration)
 * 1.1   03-22-2022   Ethan Hirsch @ Zoetis Inc   Fix Unit Test failures due to Validation Rule
**/
@isTest
private class CEEventUpdateAttendeeStatusTest {

    static Contact makeContact() {
        Contact c= ZTS_EU_DataUtilityTest.createContactRecord(1)[0];
        insert c;

        return c;
    }

    static ZTS_Events__c makeZTSEvent() {
        //create ZTS_Events__c record, please include if any mandatory fields are missing 
        ZTS_Events__c ztsEvent = new ZTS_Events__c(ZTS_US_Location__c = 'Test Location',
                    //ZTS_US_Type__c is dependent picklist on ZTS_US_Event_Category__c field. So assign the correct values accordingly to these fields.
                                                   ZTS_US_Event_Category__c = 'Test Category', 
                                                   ZTS_US_Type__c = 'Test Category',
                                                   ZTS_US_Number_of_Attendees__c = 4, 
                                                   ZTS_US_Name__c   = 'Alex',
                                                   ZTS_EU_Market__c = 'United States'
                                                   //ZTS_US_Contact__c= 'Test'
                                                );
        insert ztsEvent;

        return ztsEvent;
    }

    @IsTest
    static void performUpdateTest() {
        ZTS_Events__c ztsEvent = makeZTSEvent();
        Contact c = makeContact();

        //create some ZTS_US_Event_Invitee__c records with ztsEvent as paernt, please include if any mandatory field are missing 
        List<ZTS_US_Event_Invitee__c> inviteeList = new List<ZTS_US_Event_Invitee__c>();
        for(Integer i = 0, j = 4; i < j; i++) {
            inviteeList.add(new ZTS_US_Event_Invitee__c(ZTS_US_Event__c=ztsEvent.Id,ZTS_US_Contact__c=c.Id));
        }
        insert inviteeList;
        
        ApexPages.StandardController stdZtsEvent = new ApexPages.StandardController(ztsEvent);  

        CEEventUpdateAttendeeStatus ceUpdateController = new CEEventUpdateAttendeeStatus(stdZtsEvent);
        ceUpdateController.wrpConList[0].isSelected = true;
        ceUpdateController.selectAllVar = true;

        Integer testDmls;

        Test.startTest();
        ceUpdateController.selectAll();
        ceUpdateController.updateStatus();
        ceUpdateController.cancelAction();

        testDmls = Limits.getDMLStatements();
        Test.stopTest();

        System.assert(testDmls > 0, 'An expected dml did not occur');
    }

    @IsTest
    static void performUpdateTestSelectAllFalse() {
        ZTS_Events__c ztsEvent = makeZTSEvent();
        Contact c = makeContact();

        //create some ZTS_US_Event_Invitee__c records with ztsEvent as paernt, please include if any mandatory field are missing 
        List<ZTS_US_Event_Invitee__c> inviteeList = new List<ZTS_US_Event_Invitee__c>();
        for(Integer i = 0, j = 4; i < j; i++) {
            inviteeList.add(new ZTS_US_Event_Invitee__c(ZTS_US_Event__c=ztsEvent.Id,ZTS_US_Contact__c=c.Id));
        }
        insert inviteeList;
        
        ApexPages.StandardController stdZtsEvent = new ApexPages.StandardController(ztsEvent);

        CEEventUpdateAttendeeStatus ceUpdateController = new CEEventUpdateAttendeeStatus(stdZtsEvent);
        ceUpdateController.wrpConList[0].isSelected = true;
        ceUpdateController.selectAllVar = false;

        Integer testDmls;

        Test.startTest();
        ceUpdateController.selectAll();
        ceUpdateController.updateStatus();

        testDmls = Limits.getDMLStatements();
        Test.stopTest();

        System.assert(testDmls == 0, 'There was an unexpected dml');
    }
    
    @IsTest
    static void performUpdateTestNegetive(){
        ZTS_Events__c ztsEvent = makeZTSEvent();
        Contact c = makeContact();

        Integer dmls = Limits.getDMLStatements();
        ApexPages.StandardController stdZtsEvent = new ApexPages.StandardController(ztsEvent);          
        CEEventUpdateAttendeeStatus ceUpdateController = new CEEventUpdateAttendeeStatus(stdZtsEvent);
        
        Integer testDmls;

        Test.startTest();
        ceUpdateController.selectAll();
        ceUpdateController.updateStatus();
        ceUpdateController.cancelAction();

        testDmls = Limits.getDMLStatements();
        Test.stopTest();

        System.assert(testDmls == 0, 'There was an unexpected dml');
    }
}