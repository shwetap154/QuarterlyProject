/**
* @description       : Test class for CPQ_OneTimeOrderUpdate_B_Zoetis
* @author            : Rahul Kumar @Deloitte

* Modifications Log
* Ver   Date         Author                       Modification
* 1.0   06-22-2023   Rahul Kumar@zoetis           Initial Version
**/

@isTest
public class CPQ_OneTimeOrderUpdate_T_Zoetis {

     @TestSetup
    static void makeData(){
        //create test users
        List<user> userList = new List<user>();
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        Id devUserProfileId = [SELECT Id FROM Profile WHERE Name = 'System Developer' LIMIT 1].Id;
        User adminUser = TestDataFactory.createUser(adminProfileId, false);
        User devUser = TestDataFactory.createUser(devUserProfileId, false);
        userList.add(adminUser);
        userList.add(devUser);
        insert userList;
        System.assert(userList.size() == 2);
        
        // Retrieve the PermissionSetLicense record for the Salesforce CPQ License
        PermissionSetLicense cpqLicense = [SELECT Id FROM PermissionSetLicense WHERE MasterLabel = 'Salesforce CPQ License' LIMIT 1];
        system.assert(cpqLicense.id != null);
        
        // Assign the permission set license to the user
        List<permissionSetLicenseAssign> permSetList = new List<permissionSetLicenseAssign>();        
        for(User obj : userList)
        {
            PermissionSetLicenseAssign perSetLicenseAssign = new PermissionSetLicenseAssign();
            perSetLicenseAssign.PermissionSetLicenseId = cpqLicense.Id;      
            perSetLicenseAssign.AssigneeId = obj.Id;
            permSetList.add(perSetLicenseAssign);
        }        
        insert permSetList;
        system.assertEquals(2 ,permSetList.size());
        
        
        System.runAs(userList[0])
        { 
            // Create Markets and Market Countries
            List<Market__c> markets = CPQ_TestDataFactory.createMarkets(true);
            CPQ_TestDataFactory.createMarketCountrys(markets, true);
            
            // Get US market
            Market__c canMarket = CPQ_TestDataFactory.getMarketByName(markets, 'Canada');
            
            // Create an account and a contact
            Account account = CPQ_TestDataFactory.createAccount(true);
            Contact contact = CPQ_TestDataFactory.createContact(false);
            contact.AccountId = account.Id;
            insert contact;
            System.Assert(contact.id != null);
            
            // Create an opportunity for the account in the US Market
            Opportunity oppty1 = CPQ_TestDataFactory.createOppty(account, canMarket, false);
            oppty1.Purchasing_Contact__c = contact.Id;
            insert oppty1;
            System.Assert(oppty1.id != null);
            
            Opportunity oppty2 = CPQ_TestDataFactory.createOppty(account, canMarket, false);
            oppty2.Purchasing_Contact__c = contact.Id;
            insert oppty2;
            System.Assert(oppty2.id != null);
            List<Opportunity> oppList = new List<Opportunity>{oppty1,oppty2};
                
            // Create Address record
            Address__c address = CPQ_TestDataFactory.createAddress(account, true);
            System.assert(address.id != null);
            
            // Create an quote       
            List<SBQQ__Quote__c> testQuoteList = new List<SBQQ__Quote__c>();
            
            for(integer i =0 ; i<2 ;i++)
            {	
                testQuoteList.add(CPQ_TestDataFactory.createQuote(oppList[i], account, contact, address, false));
            }
            insert testQuoteList;
            System.assert(testQuoteList[0].id != null);
            System.assertEquals(2,testQuoteList.size());
            
            // Create bulk Order            
            List<Order> bulkOrderList = new List<Order>();
            Id cpqOrderNonPinRecordTypeId = SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Order_Without_Pre_Install_Checklist_Layout').getRecordTypeId();
            Id cpqOrderPinRecordTypeId = SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Order_With_Pre_Install_Checklist_Layout').getRecordTypeId();
            
            Order objInstance = CPQ_TestDataFactory.createOrder(account, oppList[0], testQuoteList[0], false);
            objInstance.RecordTypeId = cpqOrderNonPinRecordTypeId;
            objInstance.CPQ_Order_Activation_Email_Sent__c = false;
            insert objInstance;
            System.assert(objInstance.id != null);
            
            Order objInstance2 = CPQ_TestDataFactory.createOrder(account, oppList[1], testQuoteList[1], false);
            objInstance2.RecordTypeId = cpqOrderPinRecordTypeId;
            objInstance2.CPQ_Order_Activation_Email_Sent__c = false;
            insert objInstance2;
			System.Assert(objInstance2.id != null);            
        }
    }
    
    /*method to test field Update*/
    
    @istest
    public static void sendEmailToDraftOrders_test() {
        User adminUser = [Select id from user where profile.name = 'System Administrator' and lastName = 'TestUserLast' limit 1];
        system.assert(adminUser.Id != null);
        
        System.runAs(adminUser)
        {            
            test.startTest();
            CPQ_OneTimeOrderUpdate_B_Zoetis batchObj = new CPQ_OneTimeOrderUpdate_B_Zoetis();
            Database.executeBatch(batchObj);       
            test.stopTest();
            
            List<Order> updatedOrderList = [Select id from Order where CPQ_Order_Activation_Email_Sent__c = True ];
            System.assertEquals(2, updatedOrderList.size());
            
        }         
    }  
    
}