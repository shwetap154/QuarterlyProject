/**
* File Name     :  CreateLeadFromCallTest
* @description  :  Test coverage for createLeadFromCall
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author                  Modification
---------------------------------------------------------------------------------------------------
* 1.0     9/17/2019     Cory Bartholomew @ ATG     Created the Class.
* 2.0     2/5/2020      Cory Bartholomew @ ATG     Added descriptions.
* 3.0     9/12/2022     Padma Nerella @ Zoetis    Added test case for discussion item "Diagnostics Equipment Lead"
**/
@isTest
public class CreateLeadFromCallTest {

    @testSetup
    public static void setup() { 
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        //Create User.  Needed to get around process builder on Attendee
        User usr = CPQ_TestDataFactory.createUser(
            'LeadFromCall',
            'Create',
            'Cory.bartholomew@atginfo.com',
            'cory.bartholomew@atginfo.com.testing',
            'testUser1',
            'clfctest',
            profile.Id,
            null,
            false
        );
        usr.ZTS_EU_Market__c = 'United States';
        usr.ZTS_EU_Primary_Business_Unit__c = 'CA';
system.debug('user id ====>'+ usr);
        User insideDiagnosticSalesRep = CPQ_TestDataFactory.createUser(
            'Inside',
            'DiagnosticRep',
            'Cory.bartholomew@atginfo.com',
            'insideDiagRep@zoetistest.com',
            'testUser2',
            'diagRep',
            profile.Id,
            null,
            false
        );
        insideDiagnosticSalesRep.ZTS_EU_Market__c = 'United States';
        insideDiagnosticSalesRep.ZTS_EU_Primary_Business_Unit__c = 'CA';
        List<User> users = new List<User>{usr,insideDiagnosticSalesRep};
        insert users;
        system.debug('## Users list is : '+users);

        Test.startTest();

        //Create Account
        Account acct = CPQ_TestDataFactory.createAccount(false);
        acct.Name = 'Lead You Down That Road';
        acct.BillingStreet = 'Hornsey Rd';
        acct.BillingCity = 'London';
        acct.BillingPostalCode = 'N7 7AJ';
        acct.BillingCountry = 'United States';
        acct.ZTS_EU_Market__c = 'United States';
        acct.ZTS_EU_Zip_Postal_Code__c = '00001';
        system.debug('$$ Account deatils is : '+acct);
        insert acct;

        ZTS_EU_Territory__c territory = CPQ_TestDataFactory.createTerritory('United States',null, 'Inside Sales Diagnostics','Territory', true); 
        ZTS_EU_Position__c position = CPQ_TestDataFactory.createZoetisPosition(insideDiagnosticSalesRep, territory, true);
        ZTS_AccountTerritory__c acctTerritory = CPQ_TestDataFactory.createAccountTerritory(acct, territory, true, true);
        //ZTS_EU_Account_Position__c accountPosition = CPQ_TestDataFactory.createAccountPosition(acct, position, acctTerritory, true);

        Test.stopTest();

        System.runAs(usr){
            //Create Contact
            Contact contact = CPQ_TestDataFactory.createContact(false);
            contact.ZTS_US_Profession__c = 'Veterinarian';
            contact.ZTS_US_Job_Function__c = 'Associate Vet';
            insert contact;

            //Create Call in draft status
            Call__c call = new Call__c();        
            call.Name = 'Account Call';
            call.ZTS_EU_Account__c = acct.Id;
            call.ZTS_EU_Start_Date_Time__c = Date.today();
            call.ZTS_EU_Additional_Notes__c = 'Testing';
            call.Discussion_Item__c = 'Reference Lab Lead';
            call.ZTS_EU_Duration__c = '0.5 Hour';
            call.US_Org_Id__c ='RefLab';
            call.ZTS_EU_End_Date_Time__c = Date.today();
            call.ZTS_EU_Status__c = 'Planned';
            call.ZTS_EU_Sub_Type__c = 'Account Call';
            call.ZTS_EU_Call_Owner__c = usr.Id;
            insert call;
            System.debug('Call: ' + call);
            
            Call__c call2 = new Call__c();        
            call2.Name = 'Account Call';
            call2.ZTS_EU_Account__c = acct.Id;
            call2.ZTS_EU_Start_Date_Time__c = Date.today();
            call2.ZTS_EU_Additional_Notes__c = 'Testing';
            call2.US_Org_Id__c ='Diagnostics';
            call2.Discussion_Item__c = 'Diagnostics Equipment Lead';
            call2.ZTS_EU_Duration__c = '0.5 Hour';
            call2.ZTS_EU_End_Date_Time__c = Date.today();
            call2.ZTS_EU_Status__c = 'Planned';
            call2.ZTS_EU_Sub_Type__c = 'Account Call';
            call2.ZTS_EU_Call_Owner__c = usr.Id;
            insert call2;
            System.debug('Call: ' + call2);

            //create Attendees
            Attendee__c attendee = new Attendee__c();
            attendee.ZTS_EU_call__c = call.Id;
            attendee.ZTS_EU_Contact__c = contact.Id;
            attendee.ZTS_EU_Uniqueness_Key__c = null;
            insert attendee;
            System.debug('Attendee: ' + attendee);
            
            Attendee__c attendee2 = new Attendee__c();
            attendee2.ZTS_EU_call__c = call2.Id;
            attendee2.ZTS_EU_Contact__c = contact.Id;
            attendee2.ZTS_EU_Uniqueness_Key__c = null;
            insert attendee2;
            System.debug('Attendee: ' + attendee);

            //Insert Discussion item
            ZTS_EU_Discussion_Item__c discussionItem = new ZTS_EU_Discussion_Item__c();
            discussionItem.ZTS_EU_Active__c = true;
            discussionItem.ZTS_EU_Discussion_Item_Title__c = 'Reference Lab Lead';
            insert discussionItem;
            System.debug('Discussion Item: ' + discussionItem);
            
            ZTS_EU_Discussion_Item__c discussionItem2 = new ZTS_EU_Discussion_Item__c();
            discussionItem2.ZTS_EU_Active__c = true;
            discussionItem2.ZTS_EU_Discussion_Item_Title__c = 'Diagnostics Equipment Lead';
            insert discussionItem2;
            System.debug('Discussion Item: ' + discussionItem2);

            //Create discussions
            ZTS_EU_Discussion__c discussion = new ZTS_EU_Discussion__c();
            discussion.Name = 'Reference Lab Lead';
            discussion.ZTS_EU_Call_Attendee__c = attendee.Id;
            discussion.ZTS_EU_Discussion_Items__c = discussionItem.Id;
            discussion.ZTS_EU_Discussion_Topic__c = 'Reference Lab Lead';
            insert discussion;
            System.debug('Discussion: ' + discussion);
            
            ZTS_EU_Discussion__c discussion2 = new ZTS_EU_Discussion__c();
            discussion2.Name = 'Diagnostics Equipment Lead';
            discussion2.ZTS_EU_Call_Attendee__c = attendee2.Id;
            discussion2.ZTS_EU_Discussion_Items__c = discussionItem2.Id;
            discussion2.ZTS_EU_Discussion_Topic__c = 'Diagnostics Equipment Lead';
            insert discussion2;
            System.debug('Discussion: ' + discussion2); 
        } 
    }

    @isTest
    public static void testCreateLeadFromCall() { 
        Map<Id, Call__c> callMap = new Map<Id,Call__c>([SELECT Id, ZTS_EU_Account__c,US_Org_Id__c,Discussion_Item__c FROM Call__c where US_Org_Id__c ='RefLab']);
        System.debug('callMap: '+callMap);
        System.assertEquals('Reference Lab Lead', callMap.values()[0].Discussion_Item__c);
        CreateLeadFromCall clfc = new CreateLeadFromCall(callMap);

        Test.startTest();
        //Test filterAttendeeDiscussions()
        clfc.filterAttendeeDiscussions('Reference Lab Lead');
        System.assertEquals('Sales Call',clfc.callToLeadDataMap.values()[0].leadsource);

        //Test getAccountDataForLeads()
        clfc.getAccountDataForLeads(clfc.callToLeadDataMap);
        System.assertEquals('Lead You Down That Road', clfc.callToLeadDataMap.values()[0].company);

        //Test createLeadsFromData()
        List<Lead> leads = clfc.createLeadsFromData(clfc.callToLeadDataMap);

        System.assertEquals(1, leads.size());


        clfc.processCallDiscussions('Reference Lab Lead');

        Call__c c = callMap.values()[0];

        c.ZTS_EU_Status__c = 'Completed';
        update c; 


        clfc.insertLeads(leads); 

        List<Lead> lds = [Select id,FirstName,LastName,Account_ID__c,OwnerId,Source_Call_Id__c,leadSource,Reference_Lab_Lead__c from Lead limit1 ];

        system.debug(' leads are :'+lds);
        if(lds.size()>0)
        {
            lead ld = new lead();
            for(Lead l:lds){

                 ld.id = l.id;
                ld.LastName = 'last name';
            }
            update ld;
        }
        Test.stopTest();

        /*Lead leadAfter = [SELECT Id, Company, Street, City, PostalCode, Country, Market__c, OwnerId, Lead_Assignment_Processed__c, Lead_Assignment_Status__c FROM Lead LIMIT 1];
        System.assertEquals('Lead You Down That Road', leadAfter.Company, 'The lead was not created against the correct Company (Account) name');
        System.assertEquals('United Kingdom', leadAfter.Country, 'The lead was not created with the billing country');
        System.assertEquals('Hornsey Rd', leadAfter.Street, 'The lead was not created with the billing street');
        System.assertEquals('London', leadAfter.City, 'The lead was not created with the billing city');
        System.debug('Lead Assignment Processed: ' + leadAfter.Lead_Assignment_Processed__c);
        System.debug('Lead Assignment Status: ' + leadAfter.Lead_Assignment_Status__c);
        System.debug('Lead Owner: ' + leadAfter.OwnerId);*/
    }
    
    @isTest
    public static void testCreateLead2FromCall() { 
        Map<Id, Call__c> callMap = new Map<Id,Call__c>([SELECT Id, ZTS_EU_Account__c,Discussion_Item__c,US_Org_Id__c FROM Call__c where US_Org_Id__c ='Diagnostics']);
        System.assertEquals('Diagnostics Equipment Lead', callMap.values()[0].Discussion_Item__c);
        CreateLeadFromCall clfc = new CreateLeadFromCall(callMap);
        
        Test.startTest();
        //Test filterAttendeeDiscussions()
        clfc.filterAttendeeDiscussions('Diagnostics Equipment Lead');
        System.assertEquals('Sales Call',clfc.callToLeadDataMap.values()[0].leadsource);
        
        //Test getAccountDataForLeads()
        clfc.getAccountDataForLeads(clfc.callToLeadDataMap);
        System.assertEquals('Lead You Down That Road', clfc.callToLeadDataMap.values()[0].company);
        
        //Test createLeadsFromData()
        List<Lead> Diagnosticsleads = clfc.createLeadsFromData(clfc.callToLeadDataMap);
        
        System.assertEquals(1, Diagnosticsleads.size());
        
        clfc.processCallDiscussions('Diagnostics Equipment Lead');
      
        clfc.insertLeads(Diagnosticsleads); 
     
        Test.stopTest();

    }
    
}