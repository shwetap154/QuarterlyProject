/******************************************************************************************************************************************
* Class Name   : TrackTranscriptVariablesTest
* Description  : This test class tests the tracking of variables from the pre-chat into the bot layer
* Created By   : Slalom Consulting/Christopher Hale
* Created Date : August 26, 2022
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Christopher Hale                    08/26/2022           Created
*****************************************************************************************************************************************/
@isTest
private class TrackTranscriptVariablesTest {
    private static testMethod void testAll(){
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.BillingStreet = '123 Main St';
        testAccount.BillingCity = 'Nowhere';
        testAccount.BillingState = 'Texas';
        testAccount.BillingPostalCode = '12345';
        testAccount.BillingCountry = 'USA';
        
        insert testAccount;

        //create test Contact for happy path
        Contact testCon = new Contact();
        testCon.FirstName = 'Mike';
        testCon.LastName = 'Smith';
        testCon.Email = 'test@test.com';
        testCon.OtherPostalCode = '77429';
        testCon.MailingPostalCode = '77429';
        testCon.ZTS_US_Job_Function__c = 'CFO';
        testCon.ZTS_US_Profession__c = 'Consultant';
        insert testCon;

        //create test chat visitor and chat transcript for happy path
        LiveChatVisitor testVisitor = new LiveChatVisitor();
        insert testVisitor;
        
        LiveChatTranscript testChat = new LiveChatTranscript();
        testChat.LiveChatVisitorId = testVisitor.Id;
        testChat.ContactId = testCon.Id;
        testChat.AccountId = testAccount.Id;
        insert testChat;

        String sessionId = testChat.Id;

        String verifyResponse = TrackTranscriptVariables.updateTranscriptWithContextVariables(sessionId, 'TestParam');

        system.assertEquals(verifyResponse, 'called apex');
    }
}