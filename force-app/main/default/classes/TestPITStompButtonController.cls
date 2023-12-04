/****************************************************************************************************************************************** 
* CLass Name : TestPITStompButtonController
* Description  : Controller test for new buttons (that used to be JS) on Lead object
* Created By   : Slalom(David Stern) 
* Created Date : 4th June, 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* David Stern            06/04/2020          Created 
*****************************************************************************************************************************************/
@isTest
public class TestPITStompButtonController 
{
    @testSetup
    public static void testSetup()
    {        
        Account acct = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];
        acct.ZTS_EU_Market__c = 'United States';
        acct.BillingPostalCode = '00000';
    	acct.BillingCity = 'testCity';
    	acct.BillingState = 'testState';
    	acct.BillingStreet = 'testStreet';
        insert acct;   
        
        PIT_TestSTOMPtrigger.createStomp(acct.Id, true);
    }
    
    @isTest
    public static void doCompleteFollowUp()
    {
        PIT_Stomp__c pit = [
            SELECT Id, Follow_Up_Notes__c, Date_Follow_Up_Completed__c, Outcome__c
            FROM PIT_Stomp__c
            LIMIT 1
        ];
        
        
        PageReference PITStompFollowUpCompleted = Page.PITStompFollowUpCompleted;
        Test.setCurrentPage(PITStompFollowUpCompleted);
        
        // Case: must have approved status.
        ApexPages.StandardController sc = new ApexPages.StandardController(pit);
        PITStompButtonController controller = new PITStompButtonController(sc);
        
        controller.doCompleteFollowUp();
        System.assert(controller.response.contains('STOMP must have Approved status to be updated to Follow Up Completed.'));
        controller.response = '';
        
        // Case: must have appropriate fields filled.
        pit.PIT_Status__c = 'Approved';
        update pit;
        
        sc = new ApexPages.StandardController(pit);
        controller = new PITStompButtonController(sc);
        
        controller.doCompleteFollowUp();
        System.assertEquals(controller.response.countMatches('.'), 3);
        controller.response = '';
        
        // Case: throw an exception.
        pit.Follow_Up_Notes__c = 'notes';
        pit.Date_Follow_Up_Completed__c = System.today();
        pit.Outcome__c = 'notes';
        update pit;
        
        sc = new ApexPages.StandardController(pit);
        controller = new PITStompButtonController(sc);
        
        controller.failTest = true;
        controller.doCompleteFollowUp();
        System.assert(controller.response.contains('An Error has Occurred. Error:'));
        controller.response = '';
        
        // Case: update successfully.
        sc = new ApexPages.StandardController(pit);
        controller = new PITStompButtonController(sc);
                
        controller.doCompleteFollowUp();
        System.assertEquals([SELECT Id, PIT_Status__c FROM PIT_Stomp__c LIMIT 1].PIT_Status__c, 'Follow Up Completed');
        System.assertEquals(controller.response, 'STOMP successfully updated.');
        controller.response = '';
        
        // Case: update was already successful.
        sc = new ApexPages.StandardController(pit);
        controller = new PITStompButtonController(sc);
                
        controller.doCompleteFollowUp();
        System.assertEquals(controller.response, 'STOMP is already in Follow Up Completed state. Thank You!');
        
        // Case: go back to STOMP.
        PageReference pg = controller.goBackToPITStomp();
        System.assertEquals(pg.getUrl(), '/' + pit.Id);
    }
    
    public class MyException extends Exception{}
}