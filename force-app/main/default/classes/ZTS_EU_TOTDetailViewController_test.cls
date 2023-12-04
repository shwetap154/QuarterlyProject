/************************************************************************************************************************
 * Class Name   : ZTS_EU_TOTDetailViewController_test
 * Description  : Test class for Time_Out_of_Territory__c Controller  
 * Created By   : Slalom/Art Smorodin
 * Created Date : 08 June 2020
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description
 * -----------------------------------------------------------------------------------------------------------------------
 * Art Smorodin(Slalom)     06/08/2020          Created.
 *************************************************************************************************************************/
@isTest
public with sharing class ZTS_EU_TOTDetailViewController_test {
    
    @testSetup 
    static void setup() {
        // Create common test accounts
        Time_Out_of_Territory__c testTerritory = new Time_Out_of_Territory__c(
                                                        ZTS_EU_Type__c = 'Time On',
                                                        ZTS_EU_Duration__c = 'Full Day = 9 AM - 5 PM',
                                                        ZTS_EU_Start_Date__c = Date.newInstance(2020, 6, 7),
                                                        ZTS_EU_End_Date__c = Date.newInstance(2020, 6, 8),
                                                        ZTS_EU_Description__c = 'this is a test');

        insert  testTerritory;

    }

    private static testMethod void doAddToCaltTest() {

       
        Time_Out_of_Territory__c terr = [SELECT Id 
                                        FROM Time_Out_of_Territory__c
                                        WHERE ZTS_EU_Description__c = 'this is a test' LIMIT 1];

        ApexPages.StandardController stdController = new ApexPages.StandardController(terr);
        ZTS_EU_TOTDetailViewController controller = new ZTS_EU_TOTDetailViewController(stdController);
        PageReference TestPage = Page.ContractPrepDocumentBtn;
        test.setCurrentPage(TestPage);
        PageReference result = controller.doAddToCal();
        System.assertNotEquals(null,result);
    }
}