/**
 * @description       : Test coverage for CompetitorUpdateHelper
 * @author            : Mila Imas @ Zoetis Inc
 * @group             : 
 * @last modified on  : 07-27-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   08-20-2021   Mila Imas @ Zoetis Inc       Initial Version
 * 1.1   07-27-2022   Ethan Hirsch @ Zoetis Inc    Change testUpdatesonCompetitor to set What_PIMS_Integration_Wanted__c
 *                                                 to the first active Picklist value as this is a restricted Picklist.
**/
@isTest
public class CompetitorUpdateHelperTest {
    @testSetup
    public static void setup() {
        List<Market__c> markets = CPQ_TestDataFactory.createMarkets(true);
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User insideDiagnosticSalesRep = CPQ_TestDataFactory.createUser(
            'Inside',
            'DiagnosticRep',
            'test@zoetis.com',
            'insideDiagRep@zoetistest.com',
            'testUser',
            'diagRep',
            p.Id,
            null,
            false
        );
        insideDiagnosticSalesRep.ZTS_EU_Market__c = 'United States';
        insert insideDiagnosticSalesRep;
        
        //create account to match lead against
        Account acct = CPQ_TestDataFactory.createAccount(false);
        acct.Name = 'Lead You Down That Road';
        acct.BillingStreet = 'Hornsey Rd';
        acct.BillingCity = 'San Diego';
        acct.BillingPostalCode = '92131';
        acct.BillingCountry = 'United States';
        acct.Practice_Management_Software__c = '';
        insert acct;
        
      
        
        ZTS_EU_Territory__c territory = CPQ_TestDataFactory.createTerritory(
            'United States',
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
            'LastName',
            'Hornsey Rd',
            'San Diego',
            null,
            '92131',
            'United States',
            'Lead You Down That Road',
            false
        );
        Id dxRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('International_Leads').getRecordTypeId();
        lead.RecordTypeId = dxRecTypeId;
        lead.Account_ID__c=acct.id;
        lead.LeadSource = 'Reference Lab Lead';
        lead.Reference_Lab_Lead__c = true;
        insert lead;
        
     
        
    }
    
    @isTest
    public static void testUpdatesonCompetitor() {
        
        Lead uLead = [SELECT Id, OwnerId, Lead_Assignment_Processed__c, Account_ID__c,Are_their_contract_minimums__c,Contract_include_POC_analyzers__c,
                      Any_special_terms_or_pricing__c,LeadSource,Carrier_UPS_Courier__c,What_PIMS_integration_wanted__c,Reference_Lab_Lead__c,Date_Contract_expires__c
                      from Lead LIMIT 1];
        
        Account acct = [SELECT Id FROM Account];
        System.debug('acct: ' + acct.Id);
        System.debug('Lead What_PIMS_integration_wanted__c: ' + uLead.What_PIMS_integration_wanted__c);
        string validate;
        id  aid;
        System.assertEquals(false, uLead.Lead_Assignment_Processed__c);
        Map<id,Lead> oldLeadMap = new Map<id,Lead>();
        oldLeadMap.put(uLead.id,uLead);
        List<Lead> newLeadList = new List<Lead>();
        newLeadList.add(uLead);
        
        Test.startTest();
        CompetitorUpdateHelper.updateCompetior(newLeadList, oldLeadMap);
     
		
        aid = uLead.id;
        ZTS_Competitor__c[] comp = [select id,name ,Account__c from ZTS_Competitor__c where Account__c = :aid LIMIT 1];//(SC-009384) Removed condition "name = 'Reference Lab'" in where clause as name field is now changed as Auto Number.
        if (comp.size()>0) {validate = comp[0].name;} 
        System.assertEquals(null, validate);
        //Update lead
        Map<id,Lead> oldLeadMap2 = new Map<id,Lead>();
        if (uLead.Account_ID__c != acct.Id) {uLead.Account_ID__c = acct.Id;}
        uLead.What_PIMS_integration_wanted__c = 'VetIT';
        uLead.Are_their_contract_minimums__c = '22,000.00';
        uLead.Contract_include_POC_analyzers__c = 'test';
        uLead.Any_special_terms_or_pricing__c = 'test';
        uLead.Carrier_UPS_Courier__c = 'UPS';
        oldLeadMap2.put(uLead.id,uLead);
        List<Lead> newLeadList2 = new List<Lead>();
        newLeadList2.add(uLead);
        update uLead;
       
        CompetitorUpdateHelper.updateCompetior(newLeadList2, oldLeadMap2);
        
   
        string poc;
        Lead leadAfter = [SELECT Id, Lead_Assignment_Processed__c, OwnerId, Account_ID__c,What_PIMS_integration_wanted__c FROM Lead LIMIT 1];
        System.debug(':' + leadAfter.OwnerId);
        System.assertEquals('VetIT', leadAfter.What_PIMS_integration_wanted__c);
        ZTS_Competitor__c comprec = [select id,name ,Account__c,contract_minimums__c,POC__c,Special_terms_or_pricing__c 
                                       from ZTS_Competitor__c where Account__c = :leadAfter.Account_ID__c limit 1]; //(SC-009384) Removed condition "name = 'Reference Lab'" in where clause as name field is now changed as Auto Number.
       
        System.assertEquals('test',comprec.POC__c);
        //3d test  update and insert 
        //
     	Account acct2 = CPQ_TestDataFactory.createAccount(false);
        acct2.Name = 'Lead You Down That Road2';
        acct2.BillingStreet = 'Hornsey Rd';
        acct2.BillingCity = 'San Diego';
        acct2.BillingPostalCode = '92128';
        acct2.BillingCountry = 'United States';
        acct2.Practice_Management_Software__c = '';
        insert acct2;
        set<id> idsSet = new set<id>();
        idsSet.add(acct2.id);
        Lead lead4 = CPQ_TestDataFactory.createLead(
            'Mila',
            'tt',
            'Hornsey Rd',
            'San Diego',
            null,
            '92128',
            'United States',
            'Lead that road',
            false
        );
        lead4.Account_ID__c=acct2.id;
        lead4.LeadSource = 'Reference Lab Lead';
        lead4.Reference_Lab_Lead__c = true;
        insert lead4;
        Map<id,Lead> oldLeadMap3 = new Map<id,Lead>(); 
        List<Lead> newLeadList3 = new List<Lead>();
        oldLeadMap3.put(uLead.id,uLead);
        uLead.Any_special_terms_or_pricing__c = 'test special';
        update uLead;
        newLeadList3.add(uLead);
        idsSet.add(uLead.Account_ID__c);
        newLeadList3.add(lead4);
       // Test.startTest();
        CompetitorUpdateHelper.updateCompetior(newLeadList3, oldLeadMap3);
        
      //  Test.stopTest();
            System.assertEquals('VetIT', leadAfter.What_PIMS_integration_wanted__c);
        ZTS_Competitor__c[] comprecR = [select id,name ,Account__c,contract_minimums__c,POC__c,Special_terms_or_pricing__c 
                                       from ZTS_Competitor__c where Account__c = :idsSet limit 1]; //(SC-009384) Removed condition "name = 'Reference Lab'" in where clause as name field is now changed as Auto Number.
       
        System.assertEquals(1,comprecr.size());
    }
}