/**
 * @description       : Test Class for USAttendeeTriggerService
 * @author            : David Stern @ Slalom
 * @group             : 
 * @last modified on  : 07-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   02-10-2020   David Stern @ Slalom         Initial version
 * 1.1   12-09-2021   Namrata Patane @ Zoetis Inc  Fix Errors in USAttendeeTriggerService
 * 1.1   07-07-2022   Ethan Hirsch @ Zoetis Inc    Fix issues with inserting Contacts that caused Unit Test failures
**/
@isTest
public with sharing class USAttendeeTriggerService_test {
    
    static final String US_USER_FN = 'usUser';
    
    @testSetup static void setup() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = US_USER_FN;
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            // Create common test accounts
            List<Account> testAccts = new List<Account>();
            for(Integer i=0;i<2;i++) {
                testAccts.add(new Account(
                    Name = 'TestAcct'+i,
                    ZTS_EU_Market__c = 'United States',
                    ZTS_US_NARC_ID__c = 'TestNID'+i,
                    Type = 'Vet Practice',
                    BillingPostalCode = '00000',
                    BillingCity = 'testCity',
                    BillingState = 'testState',
                    BillingStreet = 'testStreet'
                ));
            }
            insert testAccts;       
            
            User u = ZTS_DataUtilityTest.createcoacherUser()[0];
            u.ZTS_EU_Market__c = 'United States';
            insert u;
            
            Call__c call = new Call__c();         
            call.ZTS_EU_Account__c = testAccts[0].Id;
            call.ZTS_EU_Start_Date_Time__c = datetime.newInstance(2020, 8, 8, 12, 30, 2);        
            call.ZTS_EU_End_Date_Time__c = datetime.newInstance(2020, 8, 8, 12, 30, 2).addHours(1);
            call.ZTS_EU_Sub_Type__c = 'Account Call';   
            call.ZTS_EU_Call_Owner__c = u.Id;   
            insert call;
            
            // List<Contact> contList = ZTS_DataUtilityTest.createContactRecord(4);
            // for(Contact c : contList){
            //     c.AccountId = accList[0].Id;
            // }
            // insert contList;
        }
    }
    
    static testMethod void testBeforeInst() {
        
        User usr = [SELECT Id FROM User WHERE FirstName = :US_USER_FN];
        
        System.runAs(usr)
        {
            // Get the first test account by using a SOQL query
            Account acct = [SELECT Id, Name, ZTS_US_NARC_ID__c, Type
                            FROM Account 
                            WHERE Name='TestAcct0' AND ZTS_US_NARC_ID__c = 'TestNID0' AND Type = 'Vet Practice'
                            LIMIT 1];
            
            System.assertNotEquals(null, acct);
            
            Call__c call = [SELECT Id, ZTS_EU_Sub_Type__c, ZTS_EU_Account__c
                            FROM Call__c 
                            WHERE ZTS_EU_Account__c =: acct.Id  AND ZTS_EU_Sub_Type__c = 'Account Call'
                            LIMIT 1];
            
            System.assertNotEquals(null, call);
            
            Attendee__c attendee = new Attendee__c();
            attendee.Name = 'Test Attendee this is';
            attendee.ZTS_EU_call__c = call.Id;
            insert attendee;
            
            Attendee__c att = [SELECT Id, ZTS_EU_call__c, Name, ZTS_EU_Represents_Account__c
                               FROM Attendee__c 
                               WHERE Name = 'Test Attendee this is' AND ZTS_EU_call__c =: call.Id
                               LIMIT 1];
            // Test that the trigger correctly updated the price
            System.assertEquals(acct.Id, att.ZTS_EU_Represents_Account__c);
        }
    }
    
    static testMethod void testAfterInst() {
        
        User usr = [SELECT Id FROM User WHERE FirstName = :US_USER_FN];
        
        System.runAs(usr)
        {
            // Get the first test account by using a SOQL query
            Account acct = [SELECT Id, Name, ZTS_US_NARC_ID__c, Type
                            FROM Account 
                            WHERE Name='TestAcct0' AND ZTS_US_NARC_ID__c = 'TestNID0' AND Type = 'Vet Practice'
                            LIMIT 1];
            
            System.assertNotEquals(null, acct);
            
            Call__c call = [SELECT Id, ZTS_EU_Sub_Type__c, ZTS_EU_Account__c
                            FROM Call__c 
                            WHERE ZTS_EU_Account__c =: acct.Id  AND ZTS_EU_Sub_Type__c = 'Account Call'
                            LIMIT 1];
            
            System.assertNotEquals(null, call);
            
            Contact cont  = ZTS_DataUtilityTest.createContactRecord(1)[0];
            cont.AccountId = acct.Id;
            cont.ZTS_EU_Market__c = 'United States';
            insert cont;
            
            
            Attendee__c attendee = new Attendee__c();
            attendee.Name = 'Test Attendee this is';
            attendee.ZTS_EU_call__c = call.Id;
            attendee.ZTS_EU_Contact__c = cont.Id;
            insert attendee;
            
            Attendee__c att = [SELECT Id, ZTS_EU_call__c, Name, ZTS_EU_Represents_Account__c,ZTS_EU_Contact__c
                               FROM Attendee__c 
                               WHERE Name = 'Test Attendee this is' AND ZTS_EU_call__c =: call.Id
                               LIMIT 1];
            
            // Call
            
            Call__c afterCall = [SELECT Id, ZTS_EU_Call_Owner__r.Name
                                 FROM Call__c 
                                 WHERE ZTS_EU_Account__c =: acct.Id  AND ZTS_EU_Sub_Type__c = 'Account Call'
                                 LIMIT 1];
            
            // Contact 
            
            Contact afterCont = [SELECT Id, Last_Call_Created_by__c
                                 FROM Contact 
                                 WHERE Id =: att.ZTS_EU_Contact__c
                                 LIMIT 1];
            
            //con.Last_Call_Created_by__c = call.ZTS_EU_Call_Owner__r.Name
            // Test that the trigger correctly updated the price
            System.assertEquals(afterCont.Last_Call_Created_by__c, afterCall.ZTS_EU_Call_Owner__r.Name);
        }
    }  
    
    static testMethod void testAfterDelete() {
        
        User usr = [SELECT Id FROM User WHERE FirstName = :US_USER_FN];
        
        System.runAs(usr)
        {
            
            // Get the first test account by using a SOQL query
            Account acct = [SELECT Id, Name, ZTS_US_NARC_ID__c, Type
                            FROM Account 
                            WHERE Name='TestAcct0' AND ZTS_US_NARC_ID__c = 'TestNID0' AND Type = 'Vet Practice'
                            LIMIT 1];
            
            System.assertNotEquals(null, acct);
            
            Call__c call = [SELECT Id, ZTS_EU_Sub_Type__c, ZTS_EU_Account__c
                            FROM Call__c 
                            WHERE ZTS_EU_Account__c =: acct.Id  AND ZTS_EU_Sub_Type__c = 'Account Call'
                            LIMIT 1];
            
            System.assertNotEquals(null, call);
            
            Attendee__c attendee = new Attendee__c();
            attendee.Name = 'Test Attendee this is';
            attendee.ZTS_EU_call__c = call.Id;
            insert attendee;
            
            Attendee__c att = [SELECT Id, ZTS_EU_call__c, Name, ZTS_EU_Represents_Account__c
                               FROM Attendee__c 
                               WHERE Name = 'Test Attendee this is' AND ZTS_EU_call__c =: call.Id
                               LIMIT 1];
            // Test that the trigger correctly updated the price
            System.assertEquals(acct.Id, att.ZTS_EU_Represents_Account__c);
            
            delete attendee;
            
            List<Attendee__c> attList = [SELECT Id, ZTS_EU_call__c, Name, ZTS_EU_Represents_Account__c
                                         FROM Attendee__c 
                                         WHERE Name = 'Test Attendee this is' AND ZTS_EU_call__c =: call.Id];
            
            System.assertEquals(0, attList.size());
        }
    }  
}