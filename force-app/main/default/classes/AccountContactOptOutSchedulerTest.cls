/**
 * @description       : Test class for AccountContactOptOutScheduler
 * @author            : ?? @ Cognizant
 * @group             : 
 * @last modified on  : 07-22-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   07-29-2020   ?? @ Cognizant              Initial Version
 * 1.1   03-21-2022   Ethan Hirsch @ Zoetis Inc   Fix Unit Test failures due to Validation Rules and Flow overwriting a value
 * 1.2   07-22-2022   Ethan Hirsch @ Zoetis Inc   Fix Unit Test failures due to Interface Email Opt Out being reset by setting Portal Email Opt Out
**/
@IsTest
public class AccountContactOptOutSchedulerTest {
    
    @isTest 
    static void testEmailOptOut(){
        Account a = new Account(name='Test1',Email__c='test@email.com',ZTS_US_NARC_ID__c='1234', ZTS_EU_Market__c  = 'United States', BillingPostalCode = '00000', BillingCity = 'testCity', BillingState = 'testState', BillingStreet = 'testStreet');
        insert a;
        
        Contact c = ZTS_EU_DataUtilityTest.createContactRecord(1)[0];
        c.AccountId = a.Id;
        c.Interface_Email__c='test@email.com';
        c.Interface_Email_Opt_Out__c = false;
        c.ZTS_EU_Market__c  = 'United States';
        insert c;

        c.Interface_Email_Opt_Out__c = true;
        // Set Portal Email Opt Out to true to create the NARC Opt Out
        c.ZTS_US_Portal_Email_Opt_Out__c = true;
        update c;

        // Setting Interface_Email_Opt_Out__c to true will overwrite ZTS_US_Email_Opt_Out__c.
        // Set it back to false to kick off the batch job again.
        a.ZTS_US_Email_Opt_Out__c = false;
        update a;

        //setting custom setting value
        NARC_Team_Email__c custSetting = new NARC_Team_Email__c();
        custSetting.To_Emails__c = 'test3232323@testxyasdf.com';        
        insert custSetting; 
        
        Test.startTest();
            Database.executebatch(new AccountContactOptOutScheduler(),5);    
        Test.stopTest();
        
        List<NARC_Opt_Outs__c> narcsOO = [Select Id from NARC_Opt_Outs__c];

        System.assertEquals(1, narcsOO.size(), 'A narc opt out should be created');
    }
}