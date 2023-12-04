/**
 * @description       : This file containes the code needed for testing the ConfigurableRelatedListController
 * @author            : Marshall Lanners @ Slalom
 * @group             : 
 * @last modified on  : 03-22-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-18-2020   Marshall Lanners @ Slalom   Initial Version
 * 1.1   03-22-2022   Ethan Hirsch @ Zoetis Inc   Fix failing Unit Tests due to Validation Rule failure.
**/
@isTest
public class ConfigurableRelatedListControllerTest {

    @testSetup static void setup(){
        
        Account account = ZTS_DataUtilityTest.createAccountRecord(1)[0];
        account.Name = 'test account';
		insert account;
        
        Contact contact = ZTS_EU_DataUtilityTest.createContactRecord(1)[0];
        contact.AccountId = account.Id;
        contact.FirstName = 'test firstname';
        contact.LastName = 'test lastname';
        insert contact;
        
        Opportunity opportunity1 = new Opportunity(
            AccountId  = account.Id,
            Name = 'test opportunity',
            Amount = 30000,
            StageName = 'Prospecting',
            CloseDate = System.today()
        );

        Opportunity opportunity2 = new Opportunity(
            AccountId  = account.Id,
            Name = 'test opportunity2',
            Amount = 30000,
            StageName = 'Prospecting',
            CloseDate = System.today()
        );
        
        Opportunity opportunity3 = new Opportunity(
            AccountId  = account.Id,
            Name = 'test opportunity3',
            Amount = 40000,
            StageName = 'Prospecting',
            CloseDate = System.today()
        );
        
        List<Opportunity> oppList = new List<Opportunity>();
        
        oppList.add(opportunity1);
        oppList.add(opportunity2);
        oppList.add(opportunity3);
        
        insert oppList;
    }
    
    // this is used to test if the admin profile has create and delete on the related list
    @isTest static void testPermissionAdmin(){
        Id id = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id;
        
        User admin = new User(Alias = 'stnt', Email='SystemAdministrator123@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName='SystemAdministrator123@testorg.com', 
        ZTS_EU_Market__c = 'United States');


        Id accountId = [SELECT Id FROM Account WHERE Name = 'test account'].Id;
        
        System.runAs(admin) {

            Test.startTest();
            
            ConfigurableRelatedListController.Wrapper wrapper = ConfigurableRelatedListController.getRelatedList(
                'testdata',
                accountId,
                true
            );

            Test.stopTest();
            
            System.assert(wrapper.recordList.size() == 3);
            System.assert(wrapper.canCreate == true);
            System.assert(wrapper.canDelete == true);
        }
    }
    
    // this is to test that the read only profile cannot create, delete related lit records.
    @isTest static void testPermissionReadOnly(){
        Id id = [SELECT Id FROM Profile WHERE Name='Read Only'].Id;
        
        User readOnly = new User(Alias = 'stnt', Email='ReadOnly12356@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing234', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName='ReadOnly12356@testorg.com',
        ZTS_EU_Market__c = 'United States');
        
        Id accountId = [SELECT Id FROM Account WHERE Name = 'test account'].Id;
        
        System.runAs(readOnly) {

            Test.startTest();

            ConfigurableRelatedListController.Wrapper wrapper = ConfigurableRelatedListController.getRelatedList(
                'testdata',
                accountId,
                true
            );

            Test.StopTest();

            System.assert(wrapper.recordList.size() == 0);
//  In Zoetis production, the "Read Only" profile has CRUD rights on Opportunity.
//          System.assert(wrapper.canCreate == false);
//          System.assert(wrapper.canDelete == false);
        }
    }
    
    // used to make sure code still returns records if no where clause or record type is specified. 
    @isTest static void getRelatedLabelsTest() {
        Id accountId = [SELECT Id FROM Account WHERE Name = 'test account'].Id;
        
        ConfigurableRelatedList__mdt customMetadata = 
        [   SELECT  Create_Fields__c, Display_Fields__c,
                    SObject__c, Parent_Record_Field__c,
                    Where_Clause__c, RecordType_Name__c, Query_Fields__c
            FROM    ConfigurableRelatedList__mdt
            WHERE   Name__c = 'RefLabs_Orders'
            LIMIT 1
        ];
        
        Map<String, Map<String,String>> labels = ConfigurableRelatedListController.getRelatedLabels(
            customMetadata,
            accountId,
            true
        );
        
        Set<String> keys = labels.keySet();
        System.assertEquals(true, keys.contains('Material_Description__c'), 'The wrapper should contain Material_Description__c');
        System.assertEquals(true, keys.contains('Test_Completion_Date__c'), 'The wrapper should contain Test_Completion_Date__c');
    }
}