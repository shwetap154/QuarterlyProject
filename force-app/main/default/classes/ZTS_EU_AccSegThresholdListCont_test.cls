/*********************************************************************************************************************
 * Class Name   : ZTS_EU_AccSegThresholdListCont_test
 * Description  : Test class  for Account_Segmentation_threshold__c controller   
 * Created By   : Slalom/Art Smorodin
 * Created Date : 9 June 2020
 *
 * Modification Log:
 * -------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description
 * -------------------------------------------------------------------------------------------------------------------
 * Art Smorodin(Slalom)     06/09/2020          Created.
 *********************************************************************************************************************/
@isTest
public with sharing class ZTS_EU_AccSegThresholdListCont_test {
    @testSetup 
    static void setup() {
        List<Account_Segmentation_threshold__c> accSegList = new List<Account_Segmentation_threshold__c>();
        
        // Create common test Threshlods 
        Account_Segmentation_threshold__c testAccSegThrsh1 = new Account_Segmentation_threshold__c(
                                                    ZTS_EU_Market__c = 'United States',
                                                    BU_Abbrv__c = 'CA',
                                                    ZTS_EU_Segmentation_Rating__c = 'the Test');

        insert  testAccSegThrsh1;
        accSegList.add(testAccSegThrsh1);

        Account_Segmentation_threshold__c testAccSegThrsh2 = new Account_Segmentation_threshold__c(
                                                    ZTS_EU_Market__c = 'United States',
                                                    BU_Abbrv__c = 'All',
                                                    ZTS_EU_Segmentation_Rating__c = 'the Test');

        insert  testAccSegThrsh2;
        accSegList.add(testAccSegThrsh2);

    }

    private static testMethod void doRecalculateTest() {

        List<Account_Segmentation_threshold__c> accSegList = [SELECT Id 
                                                                FROM Account_Segmentation_threshold__c 
                                                                WHERE ZTS_EU_Segmentation_Rating__c = 'the Test'];

        Test.startTest();
        Test.setCurrentPage(Page.AccSegThreshold_RecalculateRatingsVF);
        ApexPages.CurrentPage().getparameters().put('vfRetURLInSFX','');

        ApexPages.StandardSetController standardController = new ApexPages.StandardSetController(accSegList);
        standardController.setSelected(accSegList);
        ZTS_EU_AccSegThresholdListCont ext = new ZTS_EU_AccSegThresholdListCont(standardController);
        System.assertNotEquals(null,ext.doRecalculate());

        Test.stopTest();

    }
}