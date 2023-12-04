/********************************************************************************************************************
* Class Name   : ZTS_EU_ContrTemplateController_test
* Description  : Test class for ZTS_EU_ContractTemplate__c Controller  
* Created By   : Slalom/Art Smorodin
* Created Date : 08 June 2020
*
* Modification Log:
* -------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description
* -------------------------------------------------------------------------------------------------------------------
* Art Smorodin(Slalom)     06/08/2020          Created.
*********************************************************************************************************************/
@isTest
public with sharing class ZTS_EU_ContrTemplateController_test {
    
    @testSetup 
    static void setup() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            ZTS_EU_Species_Product__c testHierarchy = new ZTS_EU_Species_Product__c(
                Name = 'this is test hierrchy',
                ZTS_EU_Type__c = 'Business Unit',
                ZTS_EU_Is_Active__c = true,
                ZTS_EU_Market__c = 'United Kingdom',
                ZTS_EU_Business_Unit_Abbr__c = 'EQ');
            
            insert testHierarchy;
            
            ZTS_EU_ContractTemplate__c testTemplate = new ZTS_EU_ContractTemplate__c(
                Name = 'this is test template 001',
                ZTS_EU_CTBusiness_Unit__c = testHierarchy.Id,
                ZTS_EU_Discount_Type__c = 'Fixed Discount',
                ZTS_EU_Discount__c = 20,
                ZTS_EU_Fiscal_Year__c = '2020');
            
            insert  testTemplate;   
        }
        
    }
    
    private static testMethod void doAssignTest() {
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            ZTS_EU_ContractTemplate__c template = [SELECT Id 
                                                   FROM ZTS_EU_ContractTemplate__c
                                                   WHERE Name = 'this is test template 001' LIMIT 1];
            
            ApexPages.StandardController stdController = new ApexPages.StandardController(template);
            ZTS_EU_ContrTemplateController controller = new ZTS_EU_ContrTemplateController(stdController);
            PageReference TestPage = Page.ContractemplateAssignBtnVF;
            test.setCurrentPage(TestPage);
            PageReference result = controller.doAssign();
            System.assertNotEquals(null,result);
        }
    }
    
    @isTest static void getObjectsTest() {
        // Get the first test account by using a SOQL query
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            ZTS_EU_ContractTemplate__c template = [SELECT Id 
                                                   FROM ZTS_EU_ContractTemplate__c
                                                   WHERE Name = 'this is test template 001' LIMIT 1];
            ZTS_EU_ContractTemplate__c result = ZTS_EU_ContrTemplateController.getObjects(String.valueOf(template.Id));
            System.assertNotEquals(null, result);
        }
    }
}