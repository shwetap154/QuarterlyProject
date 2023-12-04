/**
 * @description       : Test class for ItemsToApproveController
 * @author            : Kristen Owens @ ATG
 * @group             : 
 * @last modified on  : 07-22-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-17-2020   Kristen Owens @ ATG         Initial Version
 * 1.1   03-23-2022   Ethan Hirsch @ Zoetis Inc   Fix Unit Test errors due to Validation failures
 * 1.2   07-22-2022   Ethan Hirsch @ Zoetis Inc   Move Test.startTest to avoid too many SOQL exceptions
 * 1.3   07-26-2022   Ethan Hirsch @ Zoetis Inc   Remove Quote Updates and disable triggers to avoid limit issues
**/
@isTest
private class ItemsToApproveControllerTest {
  @isTest
  static void testDataInit() {
    // Bypass triggers used for setting up CPQ data.
    DispatchTriggerHandler.bypass('UserTriggerHandler');
    DispatchTriggerHandler.bypass('AccountTriggerHandler');
    DispatchTriggerHandler.bypass('ContactTriggerHandler');
    DispatchTriggerHandler.bypass('OpportunityTriggerHandler');
    DispatchTriggerHandler.bypass('AddressTriggerHandler');

    Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

    User testUser = new User(
      Alias = 'test',
      Email = 'testUser1@test.com',
      ZTS_EU_Market__c = 'United States',
      EmailEncodingKey = 'UTF-8',
      LastName = 'TestLastName',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = testProfile.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'userEmail4306@test.com'
    );
    insert testUser;

    //add user to a group
    Group testGroup = new Group(Name = 'testGroup');
    insert testGroup;

    GroupMember testMember = new GroupMember(GroupId = testGroup.Id, UserOrGroupId = testUser.Id);
    insert testMember;

    System.runAs(testUser) {
      Product2 testProduct = new Product2(Name = 'Test Product');
      insert testProduct;

      Account testAccount = CPQ_TestDataFactory.createAccount(true);

      Market__c market = new Market__c(
        Name = 'United States',
        CurrencyIsoCode = 'USD',
        Distribution_Channel__c = '10',
        Division__c = '00',
        Price_Book__c = Test.getStandardPricebookId(),
        Sales_Org__c = '1436',
        Vistex_Order_Type__c = 'ZC01',
        Vistex_Pricing_Procedure__c = 'YSTC01'
      );
      insert market;

      Contact testContact = CPQ_TestDataFactory.createContact(false);
      testContact.FirstName = 'Test First Name';
      testContact.LastName = 'Test Last Name';
      testContact.AccountId = testAccount.Id;
      insert testContact;

      Opportunity testOppty = new Opportunity(
        AccountId = testAccount.Id,
        Name = 'Test CPQOpp',
        CloseDate = Date.Today(),
        Country1__c = 'United States',
        Customer_Language__c = 'English',
        Market__c = market.Id,
        CurrencyIsoCode = 'USD',
        Pricebook2Id = Test.getStandardPricebookId(),
        Probability = 10,
        TotalOpportunityQuantity = 0,
        Sales_Org1__c = '1436 United States',
        StageName = 'Qualified'
      );
      insert testOppty;

      testOppty.Market__c = market.Id;
      update testOppty;

      // Create Address record
      Address__c address = CPQ_TestDataFactory.createAddress(testAccount, true);

      // Crete an empty quote
      SBQQ__Quote__c testQuote = CPQ_TestDataFactory.createQuote(testOppty, testAccount, testContact, address, false);
      SBQQ__Quote__c testQuote2 = CPQ_TestDataFactory.createQuote(testOppty, testAccount, testContact, address, false);

      //JD - 7/2/19: adding updates to set the Vistex Pricing flag to true to bypass validation rules
      testQuote.Vistex_Price_In_Sync__c = true;
      testQuote2.Vistex_Price_In_Sync__c = true;

      // Due to a bug with CPQ, Quotes for the same Account must be inserted separately
      insert testQuote;
      insert testQuote2;

      /*SBQQ__Quote__c testQuote = new SBQQ__Quote__c(SBQQ__Account__c = testAccount.Id,
                                                    SBQQ__Opportunity2__c = testOppty.Id,
                                                    SBQQ__StartDate__c = Date.today(),
                                                    SBQQ__EndDate__c =Date.today()+365,
                                                    Vistex_Price_In_Sync__c = true);
            insert testQuote;*/

      SBQQ__Quote__c insertedQuote = [SELECT Id, Vistex_Price_In_Sync__c FROM SBQQ__Quote__c WHERE Id = :testQuote.Id];
      System.debug('1. Price in sync? ------> ' + insertedQuote.Vistex_Price_In_Sync__c);


      /*SBQQ__Quote__c testQuote2 = new SBQQ__Quote__c(SBQQ__Account__c = testAccount.Id,
                                                    SBQQ__Opportunity2__c = testOppty.Id,
                                                    SBQQ__StartDate__c = Date.today(),
                                                    SBQQ__EndDate__c =Date.today()+365);
      insert testQuote2;*/

      SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(
        SBQQ__StartDate__c = Date.today(),
        SBQQ__EndDate__c = Date.today() + 365,
        SBQQ__Product__c = testProduct.Id,
        SBQQ__Quote__c = testQuote.Id
      );
      insert testQuoteLine;

      Test.startTest();
      //JD - 7/2/19: end of updates

      SBAA__ApprovalRule__c testApprovalRuleQuote = new SBAA__ApprovalRule__c(
        Name = 'Test Approval Rule',
        SBAA__TargetObject__c = 'SBQQ__Quote__c'
      );
      insert testApprovalRuleQuote;

      SBAA__Approver__c testApprover = new SBAA__Approver__c(Name = UserInfo.getUserName(), SBAA__User__c = UserInfo.getUserId());
      insert testApprover;

      insertedQuote = [SELECT Id, Vistex_Price_In_Sync__c FROM SBQQ__Quote__c WHERE Id = :testQuote.Id];
      System.debug('2. Price in sync? ------> ' + insertedQuote.Vistex_Price_In_Sync__c);

      SBAA__Approval__c testQuoteApproval = new SBAA__Approval__c(
        SBAA__Status__c = 'Requested',
        SBAA__RecordField__c = 'Quote__c',
        SBAA__ApprovalStep__c = 10,
        SBAA__Rule__c = testApprovalRuleQuote.Id,
        SBAA__AssignedTo__c = UserInfo.getUserId(),
        Quote__c = testQuote.Id
      );

      SBAA__Approval__c testQuoteApproval2 = new SBAA__Approval__c(
        SBAA__Status__c = 'Approved',
        SBAA__RecordField__c = 'Quote__c',
        SBAA__ApprovalStep__c = 10,
        SBAA__Rule__c = testApprovalRuleQuote.Id,
        SBAA__AssignedTo__c = UserInfo.getUserId(),
        Quote__c = testQuote2.Id
      );

      insert new List<SBAA__Approval__c> {testQuoteApproval, testQuoteApproval2};

      // Clear bypasses before running the controller to be safe
      DispatchTriggerHandler.clearAllBypasses();
      //Approval.ProcessSubmitRequest submitApproval = new Approval.ProcessSubmitRequest();
      //  submitApproval.setObjectId(testQuote2.id);
      //  submitApproval.setSubmitterId(testUser.Id);
      //  Approval.ProcessResult result = Approval.process(submitApproval);
      
      ItemsToApproveController testController = new ItemsToApproveController();
      //System.assert(result.isSuccess());
      Test.stopTest();
    }
  }
}