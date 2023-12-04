/**
* @description       : Test class for GetPreInstallCheckListController
* @author            : Grant Weldon @ Cognizant
* @group             : 
* @last modified on  : 03-22-2022
* @last modified by  : Ethan Hirsch @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   06-25-2021   Grant Weldon @ Cognizant    Initial Version
* 1.1   03-22-2022   Ethan Hirsch @ Zoetis Inc   Add File Header
* 1.2   06-09-2023	 Rahul Kumar @Deloitte       Refactored the whole test class and added getPreInstallCheckListOpp_NonCPQ method
**/
@istest
public class GetPreInstallCheckListControllerTest {
    
    @TestSetup
    static void makeData() {
        //create test users
        List<user> userList = new List<user>();
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        User adminUser = TestDataFactory.createUser(adminProfileId, false);
        userList.add(adminUser);
        
        User devNonCPQUser = TestDataFactory.createUser(adminProfileId, false);
        devNonCPQUser.lastName = 'NonCPQUserLastName';
        userList.add(devNonCPQUser);
        insert userList;
        System.assert(userList.size() == 2);
        
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
            
            // Get US market
            Market__c usMarket = CPQ_TestDataFactory.getMarketByName(markets, 'United States');
            
            // Create an account and a contact
            Account account = CPQ_TestDataFactory.createAccount(true);
            Address__c soldToAddress = CPQ_TestDataFactory.createAddress(account, true);
            account.ZTS_EU_Primary_Address__c = soldToAddress.Id;
            update account;
            
            Contact contact = CPQ_TestDataFactory.createContact(false);
            contact.AccountId = account.Id;
            insert contact;
            System.Assert(contact.id != null);
            
            // Create an opportunity for the account in the US Market
            Opportunity oppty = CPQ_TestDataFactory.createOppty(account, usMarket, false);
            oppty.Purchasing_Contact__c = contact.Id; // 05242021 - Fix
            insert oppty;
            System.Assert(oppty.id != null);
            
            // Create Address record
            Address__c address = CPQ_TestDataFactory.createAddress(account, true);
            system.debug('line 69');
            // Crete an empty quote
            SBQQ__Quote__c quote = CPQ_TestDataFactory.createQuote(oppty, account, contact, address, false);
            quote.Address__c = soldToAddress.Id;
            quote.Ship_To_Address__c = soldToAddress.Id;
            quote.Sales_Org_Market__c = usMarket.Id;
            
            insert quote;
            System.Assert(quote.id != null);
            
            // Create SAP materials
            List<SAP_Material__c> materials = new List<SAP_Material__c>{
                CPQ_TestDataFactory.createSAPMaterial('VL', '000000000010001498', 'NORM', 'ZFER', '', false),
                    CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000043', 'DIEN', 'DIEN', '', false),
                    CPQ_TestDataFactory.createSAPMaterial('ST', '000000000016001285', 'ZANC', 'ZFER', '', false)
                    };
                        insert materials;
            
            // Create product
            Product2 product = CPQ_TestDataFactory.createProduct(false);
            product.SAP_Material__c = materials[0].Id;
            
            Product2 productWarranty = CPQ_TestDataFactory.createProduct(false);
            productWarranty.SAP_Material__c = materials[1].Id;
            
            Product2 productAncillary = CPQ_TestDataFactory.createProduct(false);
            productWarranty.SAP_Material__c = materials[2].Id;
            
            Product2 productParent = CPQ_TestDataFactory.createProduct(false);
            productParent.Name = 'Bundle parent';
            productParent.Program_Eligibility_Filter__c = 'FREEDOM';
            
            // Insert products
            insert new List<Product2>{ productParent, product, productWarranty, productAncillary };  
                
                // Create PBEs
                insert new List<PricebookEntry>{
                    CPQ_TestDataFactory.createPriceBookEntry(productParent, false),
                        CPQ_TestDataFactory.createPriceBookEntry(productWarranty, false),
                        CPQ_TestDataFactory.createPriceBookEntry(product, false),
                        CPQ_TestDataFactory.createPriceBookEntry(productAncillary, false)
                        };
                            
			 // Insert bundle parent line
            SBQQ__QuoteLine__c parentLine = CPQ_TestDataFactory.createQuoteLine(quote, productParent, false);
            parentLine.SBQQ__Bundle__c = true;
            
            insert parentLine; 
            System.assert(parentLine.id != null);
            
            // Insert child line
            SBQQ__QuoteLine__c childLine1 = CPQ_TestDataFactory.createQuoteLine(quote, product, false);
            childLine1.SBQQ__RequiredBy__c = parentLine.Id;
            
            // Insert child line
            SBQQ__QuoteLine__c childLine2 = CPQ_TestDataFactory.createQuoteLine(quote, productAncillary, false);
            childLine2.SBQQ__RequiredBy__c = parentLine.Id;
            childLine2.CPQ_Material_Type__c = 'Ancillary';
            
            List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>{ childLine1, childLine2 };
            insert lines; 
            system.assert(lines[0].id != null);
            
        }
    }
    
    @istest
    public static void getPreInstallCheckListGet_test() {
        User adminUser = [Select id from user where profile.name = 'System Administrator' and lastName = 'TestUserLast' limit 1];
        system.assert(adminUser.Id != null);
        
        System.runAs(adminUser)
        {
            SBQQ__Quote__c quoteObj = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
            system.Assert(quoteObj.id != null);
            
            test.startTest();
            List<PreInstallCheckList__c> preInstallList = new List<PreInstallCheckList__c> ();
            preInstallList.add(GetPreInstallCheckListController.getQuestionRecord(quoteObj.Id));  
            test.stopTest();
        } 
        
    }
    
    @istest
    public static void getPreInstallCheckListOpp_test() {
        
        User devUser = [Select id from user where profile.name = 'System Administrator' and lastName = 'TestUserLast' limit 1];
        system.assert(devUser.Id != null);
        
        System.runAs(devUser)
        {
            Opportunity oppty = [SELECT Id FROM Opportunity LIMIT 1];
            system.Assert(oppty.id != null);
            
            test.startTest();
            List<PreInstallCheckList__c> preInstallList = new List<PreInstallCheckList__c> ();
            preInstallList.add(GetPreInstallCheckListController.getQuestionRecord(oppty.Id));
            test.stopTest();
        }  
        
    }
    
    @istest
    public static void getPreInstallCheckListOpp_NonCPQ() {
        
        User adminUser = [Select id from user where profile.name = 'System Administrator' and lastName = 'NonCPQUserLastName' limit 1];
        system.assert(adminUser.Id != null);
        
        System.runAs(adminUser)
        {
            Opportunity oppty = [SELECT Id FROM Opportunity LIMIT 1];
            system.Assert(oppty.id != null);
            
            test.startTest();            
            List<PreInstallCheckList__c> preInstallList = new List<PreInstallCheckList__c> ();
            preInstallList.add(GetPreInstallCheckListController.getQuestionRecord(oppty.Id));
            test.stopTest();
        }  
        
    }
    
    
}