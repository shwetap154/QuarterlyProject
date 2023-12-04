/**
* @description       : Test class for GenerateDocumentOneStepController
* @author            : Cesar Sandrigo @ ATG - Advanced Technology Group
* @group             : 
* @last modified on  : 07-22-2022
* @last modified by  : Ethan Hirsch @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   05-19-2020   Cesar Sandrigo @ ATG        Initial Version (based on controller class)
* 1.1   03-22-2022   Ethan Hirsch @ Zoetis Inc   Add file header
* 1.1   07-22-2022   Ethan Hirsch @ Zoetis Inc   Set Pricebook Entries on Quote Lines and move where Test.startTest() 
*                                                is in generateDocument_existing_document_test to fix an error with
*                                                creating an OrderItem and too many SOQL queries exception.
**/
@isTest
public class GenerateDocumentOneStepControllerTest {
    @testSetup
    public static void setup() {
        // Disable Triggers to improve performance and save on limits
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('AddressTriggerHandler');
        DispatchTriggerHandler.bypass('ContactTriggerHandler');
        DispatchTriggerHandler.bypass('OpportunityTriggerHandler');
        SBQQ.TriggerControl.disable();
        
        
        test.startTest();
        
        //create test users
        List<user> userList = new List<user>();
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        Id systemDevProfileId = [SELECT Id from Profile where Name = 'System Developer' LIMIT 1].Id;
        
        User adminUser = TestDataFactory.createUser(adminProfileId, true);
        System.Assert(adminUser.id != null);
        
        User adminManagerUser = TestDataFactory.createUser(systemDevProfileId, true);
        System.Assert(adminManagerUser.id != null);
        
        adminUser.ManagerId = adminManagerUser.Id;
        update adminUser;
        
        User updatedAdmin = [Select id , ManagerId from user where profileId =: adminProfileId AND LastName = 'TestUserLast' LIMIT 1];
        System.assertEquals(adminManagerUser.id ,updatedAdmin.ManagerId);
        
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
        
        Contact contact = CPQ_TestDataFactory.createContact(true);
        
        // Create an opportunity for the account in the US Market
        Opportunity oppty = CPQ_TestDataFactory.createOppty(account, usMarket, true);
        
        SBQQ__QuoteTemplate__c quoteTemplate = new SBQQ__QuoteTemplate__c(
            SBQQ__CompanyCity__c = 'New York',
            SBQQ__CompanyCountry__c = 'United States',
            SBQQ__CompanyEmail__c = 'contact@test.com',
            SBQQ__CompanyFax__c = '555-555-5555',
            SBQQ__CompanyName__c = 'Test Corp',
            SBQQ__CompanyPhone__c = '555-555-5555',
            SBQQ__CompanyPostalCode__c = '07054',
            SBQQ__CompanyState__c = 'NY',
            SBQQ__CompanyStreet__c = '200 5th Av.',
            SBQQ__IntroductionTitle__c = 'Introduction Title'
        );
        insert quoteTemplate;
        
        // Create Address record
        Address__c address = CPQ_TestDataFactory.createAddress(account, true);
        
        // Crete an empty quote
        SBQQ__Quote__c quote = CPQ_TestDataFactory.createQuote(oppty, account, contact, address, false);
        quote.Address__c = soldToAddress.Id;
        quote.SBQQ__QuoteTemplateId__c = quoteTemplate.Id;
        quote.SBQQ__Status__c = 'Approved';
        quote.ApprovalStatus__c = 'Approved';
        quote.SBQQ__SalesRep__c = updatedAdmin.id;
        insert quote;
        
        // Create SAP materials
        List<SAP_Material__c> materials = new List<SAP_Material__c>{
            CPQ_TestDataFactory.createSAPMaterial('VL', '000000000010001498', 'NORM', 'ZFER', '', false),
                CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000043', 'DIEN', 'DIEN', '', false)
                };
                    insert materials;
        
        // Create product
        Product2 product = CPQ_TestDataFactory.createProduct(false);
        product.SAP_Material__c = materials[0].Id;
        
        Product2 productWarranty = CPQ_TestDataFactory.createProduct(false);
        productWarranty.SAP_Material__c = materials[1].Id;
        
        Product2 productParent = CPQ_TestDataFactory.createProduct(false);
        productParent.Name = 'Bundle parent';
        productParent.Program_Eligibility_Filter__c = 'FREEDOM';
        
        // Insert products
        insert new List<Product2>{ productParent, product, productWarranty };
            
            // Create PBEs
            List<PricebookEntry> pbes= new List<PricebookEntry>{
                CPQ_TestDataFactory.createPriceBookEntry(productParent, false),
                    CPQ_TestDataFactory.createPriceBookEntry(productWarranty, false),
                    CPQ_TestDataFactory.createPriceBookEntry(product, false)
                    };
                        insert pbes;
        
        // Insert bundle parent line
        SBQQ__QuoteLine__c parentLine = CPQ_TestDataFactory.createQuoteLine(quote, productParent, false);
        parentLine.SBQQ__Bundle__c = true;
        parentLine.SBQQ__PricebookEntryId__c = pbes[0].Id;
        insert parentLine;
        
        // Insert child line
        SBQQ__QuoteLine__c childLine = CPQ_TestDataFactory.createQuoteLine(quote, product, false);
        childLine.SBQQ__RequiredBy__c = parentLine.Id;
        childLine.SBQQ__PricebookEntryId__c = pbes[2].Id;
        insert childLine;
        
        childLine.SAP_Unit_Of_Measure__c = 'ST';
        update childLine;
        test.stopTest();
    }
    
    @isTest
    public static void generateDocument_test() {
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        Test.startTest();
        GenerateDocumentOneStepController.GenerateDocumentResponse response = GenerateDocumentOneStepController.generateDocument(quote.Id);
        Test.stopTest();
        
        System.assert(response != null);
        System.assert(response.JobId == null);
        System.assertEquals(0, response.ExistingDocuments);
    }
    
    @isTest
    public static void generateDocument_no_quote_test() {
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        Id quoteId = quote.Id;
        delete quote;
        
        Test.startTest();
        GenerateDocumentOneStepController.GenerateDocumentResponse response = GenerateDocumentOneStepController.generateDocument(quoteId);
        Test.stopTest();
        
        System.assert(response == null);
    }
    
    @isTest
    public static void generateDocument_quote_without_template_test() {
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        quote.SBQQ__QuoteTemplateId__c = null;
        update quote;
        
        Test.startTest();
        GenerateDocumentOneStepController.GenerateDocumentResponse response = GenerateDocumentOneStepController.generateDocument(quote.Id);
        Test.stopTest();
        
        System.assert(response == null);
        assertErrorsWereLogged();
    }
    
    @isTest
    public static void generateDocument_existing_document_test() {
        SBQQ__Quote__c quote = [SELECT Id, SBQQ__Opportunity2__c, SBQQ__QuoteTemplateId__c, SBQQ__Primary__c FROM SBQQ__Quote__c LIMIT 1];
        
        Opportunity obj = [Select id, SBQQ__PrimaryQuote__c from Opportunity  Limit 1];
       	obj.SBQQ__PrimaryQuote__c = quote.id;
        update obj;
        System.assert(obj.SBQQ__PrimaryQuote__c != null);
        
        
        
        Test.startTest();
        insert new SBQQ__QuoteDocument__c(
            SBQQ__CustomerAmount__c = 73,
            SBQQ__Key__c = quote.Id + '_1',
            SBQQ__ListAmount__c = 25,
            SBQQ__NetAmount__c = 13,
            SBQQ__Opportunity__c = obj.Id,
            SBQQ__Quote__c = quote.id,
            SBQQ__QuoteTemplate__c = quote.SBQQ__QuoteTemplateId__c,
            SBQQ__SignatureStatus__c = 'Signed',
            SBQQ__Template__c = 'Test Template'
        );
        
        
        
        GenerateDocumentOneStepController.GenerateDocumentResponse response = GenerateDocumentOneStepController.generateDocument(quote.Id);
        Test.stopTest();
        
        System.assert(response != null);
        System.assert(response.JobId == null);
        System.assertEquals(1, response.ExistingDocuments);
    }
    
    @isTest
    public static void getDocumentGenerationStatus_test() {
        SBQQ__Quote__c quote = [SELECT Id, SBQQ__Opportunity2__c, SBQQ__QuoteTemplateId__c FROM SBQQ__Quote__c LIMIT 1];
        
        Test.startTest();
        GenerateDocumentOneStepController.DocGenerationStatusResponse response = GenerateDocumentOneStepController.getDocumentGenerationStatus(
            null,
            quote.Id
        );
        Test.stopTest();
        
        System.assert(response != null);
        System.assertEquals(true, response.Done);
        System.assertEquals(true, response.Error);
        System.assert(!String.isBlank(response.ErrorMessage));
        System.assertEquals(null, response.QuoteDocumentId);
    }
    
    @isTest
    public static void generateAgreement_no_agreement_template_test() {
        SBQQ__Quote__c quote = [SELECT Id, SBQQ__Opportunity2__c, SBQQ__QuoteTemplateId__c FROM SBQQ__Quote__c LIMIT 1];
        
        SBQQ__QuoteDocument__c quoteDocument = new SBQQ__QuoteDocument__c(
            SBQQ__CustomerAmount__c = 73,
            SBQQ__Key__c = quote.Id + '_1',
            SBQQ__ListAmount__c = 25,
            SBQQ__NetAmount__c = 13,
            SBQQ__Opportunity__c = quote.SBQQ__Opportunity2__c,
            SBQQ__Quote__c = quote.Id,
            SBQQ__QuoteTemplate__c = quote.SBQQ__QuoteTemplateId__c,
            SBQQ__SignatureStatus__c = 'Pending',
            SBQQ__Template__c = 'Test Template'
        );
        insert quoteDocument;
        
        Test.startTest();
        String response = GenerateDocumentOneStepController.generateAgreement(quote.Id, quoteDocument.Id);
        Test.stopTest();
        
        System.assert(response == null);
        assertErrorsWereLogged();
    }
    
    @isTest
    public static void generateAgreement_no_document_test() {
        SBQQ__Quote__c quote = [SELECT Id, SBQQ__Opportunity2__c, SBQQ__QuoteTemplateId__c FROM SBQQ__Quote__c LIMIT 1];
        
        Test.startTest();
        String response = GenerateDocumentOneStepController.generateAgreement(quote.Id, null);
        Test.stopTest();
        
        System.assert(response == null);
    }
    
    @isTest
    public static void generateAgreement_test() {
        SBQQ__Quote__c quote = [SELECT Id, SBQQ__Opportunity2__c, SBQQ__QuoteTemplateId__c FROM SBQQ__Quote__c LIMIT 1];
        
        SBQQ__QuoteDocument__c quoteDocument = new SBQQ__QuoteDocument__c(
            SBQQ__CustomerAmount__c = 73,
            SBQQ__Key__c = quote.Id + '_1',
            SBQQ__ListAmount__c = 25,
            SBQQ__NetAmount__c = 13,
            SBQQ__Opportunity__c = quote.SBQQ__Opportunity2__c,
            SBQQ__Quote__c = quote.Id,
            SBQQ__QuoteTemplate__c = quote.SBQQ__QuoteTemplateId__c,
            SBQQ__SignatureStatus__c = 'Pending',
            SBQQ__Template__c = 'Test Template'
        );
        insert quoteDocument;
        
        insert new echosign_dev1__Agreement_Template__c(
            Name = 'ATG Quote Document Agreement Template',
            echosign_dev1__Account__c = '{!SBQQ__Quote__r.SBQQ__Account__c}',
            echosign_dev1__Active__c = true,
            echosign_dev1__Name__c = 'Adobe Sign Agreement Test scron',
            echosign_dev1__Auto_Send__c = false,
            echosign_dev1__Automatic_Reminders__c = 'Never',
            echosign_dev1__Available_Publisher_Actions__c = false,
            echosign_dev1__Default__c = false,
            echosign_dev1__Hosted_Signing__c = false,
            echosign_dev1__Preview_Position__c = false,
            echosign_dev1__Language__c = 'English (United States)',
            echosign_dev1__Master_Object_Type__c = 'SBQQ__QuoteDocument__c',
            echosign_dev1__Opportunity__c = '{!SBQQ__Quote__r.SBQQ__Opportunity2__c}',
            echosign_dev1__View_Password__c = false,
            echosign_dev1__Sign_Password__c = false,
            echosign_dev1__Sender_Signs_Only__c = false,
            echosign_dev1__Signature_Flow__c = 'Recipients sign in order',
            echosign_dev1__Signature_Type__c = 'e-Signature'
        );
        
        Test.startTest();
        String response = GenerateDocumentOneStepController.generateAgreement(quote.Id, quoteDocument.Id);
        Test.stopTest();
        
        System.assert(response != null);
    }
    
    @isTest
    public static void DocGenerationStatusResponse_Constructor() {
        test.startTest();    
        GenerateDocumentOneStepController.DocGenerationStatusResponse response = new GenerateDocumentOneStepController.DocGenerationStatusResponse(true, 'a5Hn0000001ib3HEAQ');
        test.stopTest();
        System.assert(response.Done);
        System.assert(!response.Error);
        System.assert(String.isEmpty(response.ErrorMessage));
        System.assertEquals('a5Hn0000001ib3HEAQ', response.QuoteDocumentId);
        
        response = new GenerateDocumentOneStepController.DocGenerationStatusResponse();
        System.assert(!response.Done);
        System.assert(!response.Error);
        System.assert(String.isEmpty(response.ErrorMessage));
        System.assert(response.QuoteDocumentId == null);
    }
    
    private static void assertErrorsWereLogged() {
        List<Error_Log__c> errors = [SELECT Id FROM Error_Log__c];
        System.assert(!errors.isEmpty());
    }
}