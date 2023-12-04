/*******************************************************************************************************************************************
* File Name     :  ZTS_US_Mass_Add_Account_ExTest
* Description   :           
* @author       :  Deloitte consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/14         Vidya             Created the Class.
*****************************************************************************************************************************************/

@isTest
public class ZTS_US_Mass_Add_Contact_ExTest 
{   
    static List<ZTS_Events__c> listEvents;
    
    public static void createTestData(){
        listEvents = createEvents(1);
        insert listEvents;
    }
    
    static testMethod void constructorTest(){
        test.startTest();
        createTestData();
        system.debug('-----------------event id---'+ listEvents[0].Id);
        ApexPAges.StandardController sc = new ApexPages.StandardController(listEvents[0]);
        PageReference massAddAccPage = Page.ZTS_EU_Mass_Add_Contacts;
        Test.setCurrentPage(massAddAccPage);
        ApexPages.currentPage().getParameters().put('id', listEvents[0].Id);
        
        ZTS_US_Mass_Add_Contact_Ext massContact = new ZTS_US_Mass_Add_Contact_Ext(sc);
     
        test.stopTest();
    }
    
    /*-------------insert ZTS_Events__c objects---------------*/
    public static List<ZTS_Events__c> createEvents(Integer counter){ // 6/14
        List<ZTS_Events__c> listEvents1 = new List<ZTS_Events__c>();
        for(Integer i=0; i< counter; i++){
            ZTS_Events__c event = new ZTS_Events__c();
            event.ZTS_US_Will_Firearms_be_Present__c = true;
            event.ZTS_US_Type__c = 'Cattle General';
            event.Total_Number_of_Invitees__c = i;
            event.ZTS_US_Status__c = 'New';
            event.ZTS_US_Start_Date__c = system.now();
            event.ZTS_US_Is_Event_Private__c = false;
            event.ZTS_US_Name__c = 'Test Event'+i;
            //event.ZTS_US_End_Date__c = system.today().addDays(i);
             event.ZTS_US_End_Date__c = system.now().addDays(i);
            event.ZTS_US_Compliance_Status__c = 'Acceptable';
            event.ZTS_US_Event_Category__c = 'Educational Meeting';
            event.ZTS_US_Location__c = 'Test street, Test Town, Test Country';
            event.ZTS_US_Number_of_Attendees__c = i+2;
            //event.ZTS_US_Purpose_Agenda__c = 'Test purpose';
            event.Purpose_Agenda__c = 'Test purpose';
            event.ZTS_EU_Market__c = 'United Kingdom';
            listEvents1.add(event);
        }
        return listEvents1;
    }
    
}