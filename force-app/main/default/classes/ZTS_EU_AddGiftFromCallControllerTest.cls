/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_AddGiftFromCallControllerTest
* Description   :  This is the test class for the class: ZTS_EU_AddGiftFromCallController.                          

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     31th-Dec-14   Shreyas             Created the class.

********************************************************************************************************************************************/
@isTest
Public class ZTS_EU_AddGiftFromCallControllerTest{
    
    public static testMethod void testMethod1(){
        
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;
        System.runAs(intlUsr) {
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
   
            List<Contact> contList = ZTS_EU_DataUtilityTest1.createContactRecord(1);
            insert contList;
            
            Test.startTest();
            List<Call__c> callList = ZTS_EU_DataUtilityTest1.createCallRecord(1); 
            insert callList;
            List<ZTS_EU_Species_Product__c> skuList = ZTS_EU_DataUtilityTest1.createProductSKURecord(2);
            
            skuList[0].ZTS_EU_is_Gift__c = true;
            skuList[0].ZTS_EU_Gift_Value__c = 2;
            
            skuList[1].ZTS_EU_is_Gift__c = true;
            skuList[1].ZTS_EU_Gift_Value__c = 4;
            
            insert skuList;
            
            List<ZTS_EU_Gift__c> giftList = ZTS_EU_DataUtilityTest1.createGiftRecord(1, contList[0].Id, callList[0].Id, skuList[0].Id);
            insert giftList;
            Test.stopTest();
            
            ZTS_EU_Gift__c g = new ZTS_EU_Gift__c();
            g = [Select Id, ZTS_EU_Year__c, ZTS_EU_Product_Hierarchy__c from ZTS_EU_Gift__c where Id =: giftList[0].Id];
            g.ZTS_EU_Year__c = '2018';
            g.ZTS_EU_Product_Hierarchy__c = skuList[1].Id;
            update g;
            
            PageReference pageRef = Page.ZTS_EU_AddGiftFromCall;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('callId', callList[0].Id);
            ApexPages.currentPage().getParameters().put('contactId', contList[0].Id);
            
            ZTS_EU_AddGiftFromCallController obj1 = new ZTS_EU_AddGiftFromCallController();
            obj1.getExistingGifts();
            obj1.showNewGift();
            obj1.saveNewGift();
            obj1.cancelNewGift();
            obj1.giftId = giftList[0].Id;
            obj1.deleteGift();
            
            List<ZTS_EU_Gift__c> giftList2 = ZTS_EU_DataUtilityTest1.createGiftRecord(1, contList[0].Id, callList[0].Id, skuList[0].Id);
            insert giftList2;
            delete giftList2;
            undelete giftList2;
        }
        
    }
    
    
}