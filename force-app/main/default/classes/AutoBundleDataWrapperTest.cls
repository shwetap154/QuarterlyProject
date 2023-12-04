/**
* File Name     :  AutoBundleDataWrapperTest
* @description  :  Test coverage for the debug methods on AutoBundleDataWrapper
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     1/10/2020		Cory Bartholomew @ ATG     Created the Class.
* 2.0     2/5/2020		Cory Bartholomew @ ATG     Added descriptions.

**/

@isTest
public class AutoBundleDataWrapperTest {

    @TestSetup
    static void makeData(){
        Vistex_Deal_Header__c deal = CPQ_TestDataFactory.createVistexDealHeader('4000006474', '1436', true);
        Vistex_Banner_E1EDKT1__c banner = CPQ_TestDataFactory.createVistexBanner(deal, 'text', 'E', true);
    }

    @isTest 
    static void testAutoBundleDataWrapper(){
        AutoBundleDataWrapper wrapper = new AutoBundleDataWrapper([SELECT Id,Is_Third_Party_Lease_Default__c, (SELECT Id FROM Vistex_Banner__r) FROM Vistex_Deal_Header__c LIMIT 1]);
        wrapper.debugDeal();
        wrapper.debugFlexibleGroups();
        wrapper.debugProducts();
        wrapper.debugBannerText();

          AutoBundleDataWrapper wrapper2 = new AutoBundleDataWrapper();
    }
}