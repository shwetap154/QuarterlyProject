/**
* File Name     :  MarketEnableTriggerHandlerTest
* @description  :  Test Class for MarketEnableTriggerHandler
* @author       :  Rahul Kumar
* Modification Log
---------------------------------------------------------------------------------------------------
* Ver.    Date          Author              	Modification
* 1.0	 06-13-2023     Rahul Kumar @Deloitte   Created the Test Class
---------------------------------------------------------------------------------------------------
**/
@IsTest
public class MarketEnableTriggerHandlerTest {
    @TestSetup
    static void makeData() {
        //create test users
        List<user> userList = new List<user>();
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        User adminUser = TestDataFactory.createUser(adminProfileId, false);
        userList.add(adminUser);
        insert userList;
        System.assert(userList.size() == 1);
        
        // Retrieve the PermissionSetLicense record for the Salesforce CPQ License
        PermissionSetLicense cpqLicense = [SELECT Id FROM PermissionSetLicense WHERE MasterLabel = 'Salesforce CPQ License' LIMIT 1];
        system.assert(cpqLicense.id != null);
        
        // Assign the permission set license to the user
        PermissionSetLicenseAssign permissionSetLicenseAssign = new PermissionSetLicenseAssign();
        permissionSetLicenseAssign.PermissionSetLicenseId = cpqLicense.Id;      
        permissionSetLicenseAssign.AssigneeId = userList[0].Id;
        insert permissionSetLicenseAssign;
        system.assert(permissionSetLicenseAssign.id != null);
        
        
        System.runAs(userList[0])
        {
            // Create Markets and Market Countries
            List<Market__c> markets = CPQ_TestDataFactory.createMarkets(true);
            CPQ_TestDataFactory.createMarketCountrys(markets, true);
                        
            List<Market__c> rebateEnabledMarket = [select id , name , Is_Rebate_Calculator_Enabled__c from Market__c where name = 'United States'];
            
            for(Market__c marketObj : rebateEnabledMarket)
            {
                marketObj.Is_Rebate_Calculator_Enabled__c = true;
            }
            update rebateEnabledMarket;
            System.assertEquals(true, rebateEnabledMarket[0].Is_Rebate_Calculator_Enabled__c);
                                  
            List<Rebate_Amount__c> rebList = new  List<Rebate_Amount__c>();
            
            for(Integer i=0; i<50; i++) {
                rebList.add( new Rebate_Amount__c(
                    Description__c = 'Test Product' + i,               
                    market__c = rebateEnabledMarket[0].id,               
                    Rebate_Amount__c = 23.20 + i ));
            }
            insert rebList; 
            System.assertEquals(50, rebList.size());
        }
        
    }
    
    @IsTest
    static void testInsertRebateAmount() {
        // Retrieve test data
        List<Market__c> markets = [SELECT Id, Name, Is_Rebate_Calculator_Enabled__c FROM Market__c where Name = 'Canada'];
        System.assertEquals(1, markets.size());
        
        List<Rebate_Amount__c> canadaRebateAmount = [Select id from Rebate_Amount__c where market__c =: markets[0].id];
        System.assertEquals(0, canadaRebateAmount.size());
        
        User adminUser = [Select id from user where profile.name = 'System Administrator' and lastName = 'TestUserLast' limit 1];
        system.assert(adminUser.Id != null);
        
        System.runAs(adminUser)
        {
            Test.startTest();            
            for(market__c obj : markets)
            {
                obj.Is_Rebate_Calculator_Enabled__c = true;
            }
            update markets;           
            Test.stopTest();
        }
        
        List<Rebate_Amount__c> canadaRebateAmountUpdated = [Select id from Rebate_Amount__c where market__c =: markets[0].id];
        System.assertEquals(50, canadaRebateAmountUpdated.size());
        
        
    }
    
}