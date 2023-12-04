/*******************************************************************************************************************************************
* File Name     :  USZTS_US_Mass_Add_Account_Ext_Test
* Description   :           
* @author       :  Deloitte consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/14         Sonali             Created the Class.
*****************************************************************************************************************************************/

@isTest
public class USZTS_US_Mass_Add_Account_Ext_Test 
{   
    static List<ZTS_Events__c> listEvents;
    
    public static void createTestData(){
        listEvents = ZTS_DataUtilityTest.createEvents(1);
        insert listEvents;
    }
    
    static testMethod void constructorTest(){
        test.startTest();
        createTestData();
        system.debug('-----------------event id---'+ listEvents[0].Id);
        ApexPAges.StandardController sc = new ApexPages.StandardController(listEvents[0]);
        PageReference massAddAccPage = Page.USZTS_US_Mass_Add_Account;
        Test.setCurrentPage(massAddAccPage);
        ApexPages.currentPage().getParameters().put('eventId', listEvents[0].Id);
        ApexPages.currentPage().getParameters().put('id', listEvents[0].Id);
        ApexPages.currentPage().getParameters().put('isError','false');
        USZTS_US_Mass_Add_Account_Ext massAccount = new USZTS_US_Mass_Add_Account_Ext(sc);
        test.stopTest();
    }
    

}