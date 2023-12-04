/**
* File Name     :  LeadOwnerHelperTest
* @description  :  Test coverage for LeadOwnerHelper
* @author       :  Ramiro Alvarez @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     09/08/2020   Ramiro Alvarez @ ATG     Created the Class.
* 2.0     10/22/2020   Cesar Sandrigo @ ATG     Changed the name of the class. It was LeadTriggerHandlerTest.
**/

@isTest
public class LeadOwnerHelperTest {
  @testSetup
  public static void setup() {
    List<Market__c> markets = CPQ_TestDataFactory.createMarkets(true);

    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

    User insideDiagnosticSalesRep = CPQ_TestDataFactory.createUser(
      'Inside',
      'DiagnosticRep',
      'Cory.bartholomew@atginfo.com',
      'insideDiagRep@zoetistest.com',
      'testUser',
      'diagRep',
      p.Id,
      null,
      false
    );
    insideDiagnosticSalesRep.ZTS_EU_Market__c = 'United Kingdom';
    insert insideDiagnosticSalesRep;

    //create account to match lead against
    Account acct = CPQ_TestDataFactory.createAccount(false);
    acct.Name = 'Lead You Down That Road';
    acct.BillingStreet = 'Hornsey Rd';
    acct.BillingCity = 'London';
    acct.BillingPostalCode = 'N7 7AJ';
    acct.BillingCountry = 'United Kingdom';
    insert acct;

    ZTS_EU_Territory__c territory = CPQ_TestDataFactory.createTerritory(
      'United Kingdom',
      null,
      'Inside Sales Diagnostics',
      'Territory',
      true
    );
    ZTS_EU_Position__c position = CPQ_TestDataFactory.createZoetisPosition(insideDiagnosticSalesRep, territory, true);
    ZTS_AccountTerritory__c acctTerritory = CPQ_TestDataFactory.createAccountTerritory(acct, territory, true, true);
    //ZTS_EU_Account_Position__c accountPosition = CPQ_TestDataFactory.createAccountPosition(acct, position, acctTerritory, true);
    
    //create Lead that will match an account
    Lead lead = CPQ_TestDataFactory.createLead(
      'Cory',
      'Bartholomew',
      'Hornsey Rd',
      'London',
      null,
      'N7 7AJ',
      'United Kingdom',
      'Lead You Down That Road',
      false
    );
    insert lead;
  }

  @isTest
  public static void testUpdatesonAccountfield() {
    
    Lead aLead = [SELECT Id, OwnerId, Lead_Assignment_Processed__c, Account_ID__c FROM Lead LIMIT 1];

    Account acct = [SELECT Id FROM Account];
    System.debug('acct: ' + acct.Id);
   	System.debug('Lead acct: ' + aLead.Account_ID__c);

    System.debug('Owner Lead Before:' + lead.OwnerId);
    System.assertEquals(false, aLead.Lead_Assignment_Processed__c);
 
    Test.startTest();
    //Update account on lead
    aLead.Account_ID__c = acct.Id;
    update aLead;
    Test.stopTest();

    Lead leadAfter = [SELECT Id, Lead_Assignment_Processed__c, OwnerId, Account_ID__c FROM Lead LIMIT 1];
    System.debug('Owner Lead After:' + leadAfter.OwnerId);
    System.assertEquals(true, leadAfter.Lead_Assignment_Processed__c);
  }
}