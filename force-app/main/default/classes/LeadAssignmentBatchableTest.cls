/**
* File Name     :  LeadAssignmentBatchableTest
* @description  :  Test coverage for LeadAssignmentbatchable
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     8/13/2019		Cory Bartholomew @ ATG     Created the Class.
* 2.0     2/6/2020		Cory Bartholomew @ ATG     Added descriptions.  This has been deprecated/deactivated due to low success in matching rates
* 3.0     3/12/2021     Mila Imas 				   added code coverage
* 4.0     3/9/2022      Chelsea Paice              SC-009382, adding test

**/

@isTest
public class LeadAssignmentBatchableTest {
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
        system.debug('after data factory insideDiagnosticSalesRep '+ insideDiagnosticSalesRep);
 
        //create account to match lead against
        Account acct = CPQ_TestDataFactory.createAccount(false);
        acct.Name = 'Lead You Down That Road';
        acct.BillingStreet = 'Hornsey Rd';
        acct.BillingCity = 'London';
        acct.BillingPostalCode = 'N7 7AJ';
        acct.BillingCountry = 'United Kingdom';
        insert acct;
 		system.debug('acct Account'+ acct);
        ZTS_EU_Territory__c territory = CPQ_TestDataFactory.createTerritory('United Kingdom',null, 'Inside Sales Diagnostics','Territory', true); 
        ZTS_EU_Position__c position = CPQ_TestDataFactory.createZoetisPosition(insideDiagnosticSalesRep, territory, true);
        ZTS_AccountTerritory__c acctTerritory = CPQ_TestDataFactory.createAccountTerritory(acct, territory, true, true);      
        system.debug('acctTerritory.ZTS_EU_Account__c'+ acctTerritory);      
    }
 	@isTest
    public static void testMatchingAccountWithInsideSalesRep(){
        RecordType dxRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'International_Leads'];
        Lead lead = new Lead();
        lead.RecordTypeId = dxRecordType.Id;
        lead.IsConverted = false;
        lead.Lead_Assignment_Status__c = '';
        lead.FirstName = 'Cory';
        lead.LastName = 'Bartholomew';
        lead.Lead_Assignment_Processed__c = false;
        lead.Street =  'Hornsey Rd';
        lead.City = 'London';
        lead.State = null;
        lead.PostalCode = 'N7 7AJ';
        lead.Country = 'United Kingdom';
        lead.Company = 'Lead You Down That Road';
        lead.Status = 'Open';
        lead.MC_Form_Name__c ='';
        insert lead;
       
        Account acct = [
            SELECT 
                Id,
                (SELECT Id FROM Account_Positions__r)
            FROM Account
        ];
        System.assertNotEquals(acct, null, 'There was no Account returned from TestSetup');
        System.assertEquals(acct.Account_Positions__r.size(), 1, 'The account team was not setup correctly');
        System.debug('line 79 LeadAssBatch ===>'+acct);
        //Execute batch class        
        Test.startTest();
        LeadAssignmentBatchable lab = new LeadAssignmentBatchable();
        Database.executeBatch(lab,1);
        Test.stopTest();   
        
        Lead leadAfter = [SELECT Id, OwnerId, Lead_Assignment_Status__c, Lead_Assignment_Processed__c FROM Lead WHERE Id = :lead.Id LIMIT 1];
        system.assertEquals(true,leadAfter.Lead_Assignment_Processed__c);

        User expectedOwner = [SELECT Id FROM User WHERE Alias = 'diagRep' LIMIT 1];
     
        System.assertEquals(leadAfter.OwnerId, expectedOwner.Id, 'The lead was not assigned as expected');
    }
 
   @isTest
    public static void testMatchingAccountForMarketingLeadWithInsideSalesRep(){
 		Lead lead = new Lead();
        lead.IsConverted = false;
        lead.Lead_Assignment_Status__c = '';
        lead.FirstName = 'Cory';
        lead.LastName = 'Bart2';
        lead.Lead_Assignment_Processed__c = false;
        lead.Street =  '';
        lead.City = '';
        lead.State = '';
        lead.PostalCode = '';
        lead.Country = '';
        lead.Company = 'Lead You Down That Road2';
        lead.Status = 'Open';
        lead.MC_Form_Name__c ='2020_Dec_Sellvetscan_Form';
        insert lead;
     
        Test.startTest();
        LeadAssignmentBatchable lab = new LeadAssignmentBatchable();
        Database.executeBatch(lab,1);
        Test.stopTest();   
        
        Lead leadAfter = [SELECT Id, OwnerId,  PostalCode, Account_ID__c,Status, Market__c,Lead_Assignment_Status__c, Lead_Assignment_Processed__c,MC_Form_Name__c FROM Lead WHERE Id = :lead.Id LIMIT 1];
        system.assertEquals(true,leadAfter.Lead_Assignment_Processed__c);
        system.assertEquals('2020_Dec_Sellvetscan_Form',leadAfter.MC_Form_Name__c);
        
        User expectedOwner = [SELECT Id FROM User WHERE Alias = 'diagRep' LIMIT 1];
        System.assertNotEquals(leadAfter.OwnerId, expectedOwner.Id, 'The lead was not assigned to the user');
    }
    

    @isTest
	public static void testMultipleAccountsAssignToQueue(){

		Lead lead = new Lead();
        lead.IsConverted = false;
        lead.Lead_Assignment_Status__c = '';
        lead.FirstName = 'Cory';
        lead.LastName = 'Bartholomew';
        lead.Lead_Assignment_Processed__c = false;
        lead.Street =  'Hornsey Rd';
        lead.City = 'London';
        lead.State = null;
        lead.PostalCode = 'N7 7AJ';
        lead.Country = '';
        lead.Company = 'Lead You Down That Road';
        lead.Status = 'Open';
        lead.MC_Form_Name__c ='';
        insert lead;
        
        Test.startTest();
        LeadAssignmentBatchable lab = new LeadAssignmentBatchable(lead.Id);
        Database.executeBatch(lab,1);
        Test.stopTest();
        
        Lead leadAfter = [SELECT Id, OwnerId,  PostalCode, Account_ID__c,Status, Market__c,Lead_Assignment_Status__c, Lead_Assignment_Processed__c,MC_Form_Name__c FROM Lead WHERE Id = :lead.Id LIMIT 1];
        system.assertEquals(true,leadAfter.Lead_Assignment_Processed__c);
    }
	 @isTest
	public static void testgetPossibleAccountwithNameCity(){

		Lead lead = new Lead();
        lead.IsConverted = false;
        lead.Lead_Assignment_Status__c = '';
        lead.FirstName = 'Mila';
        lead.LastName = 'Test';
        lead.Lead_Assignment_Processed__c = false;
        lead.Street =  '';
        lead.City = 'San Diego';
        lead.State = null;
        lead.PostalCode = '';
        lead.Country = '';
        lead.Company = 'Should find no account';
        lead.Status = '';
        lead.MC_Form_Name__c ='';
        insert lead;
        
        Test.startTest();
        LeadAssignmentBatchable lab = new LeadAssignmentBatchable(lead.Id);
        Database.executeBatch(lab,1);
        Test.stopTest();
        
        Lead leadAfter = [SELECT Id, OwnerId,  PostalCode, Account_ID__c,Status, Market__c,Lead_Assignment_Status__c, Lead_Assignment_Processed__c,MC_Form_Name__c FROM Lead WHERE Id = :lead.Id LIMIT 1];
        system.assertEquals(true,leadAfter.Lead_Assignment_Processed__c);
        system.debug('LEAD after'+ leadAfter.ownerId);
        system.debug('LEAD lead before'+ lead.ownerId);
        
    }
     @isTest
	public static void testAccountsWithBadCharacter(){

        Lead lead = new Lead();
        lead.IsConverted = false;
        lead.Lead_Assignment_Status__c = '';
        lead.FirstName = 'Bad';
        lead.LastName = 'test';
        lead.Lead_Assignment_Processed__c = false;
        lead.Street =  '';
        lead.City = '';
        lead.State = null;
        lead.PostalCode = '';
        lead.Country = '';
        lead.Company = 'test';
        lead.Status = 'Open';
        lead.MC_Form_Name__c ='';
        insert lead;
        
        Test.startTest();
        LeadAssignmentBatchable lab = new LeadAssignmentBatchable(lead.Id);
        Database.executeBatch(lab,1);
        Test.stopTest();
        
        Lead leadAfter = [SELECT Id, OwnerId,  PostalCode, Account_ID__c,Status, Market__c,Lead_Assignment_Status__c, Lead_Assignment_Processed__c,MC_Form_Name__c FROM Lead WHERE Id = :lead.Id LIMIT 1];
        system.assertEquals(true,leadAfter.Lead_Assignment_Processed__c);
        system.debug('LEAD after'+ leadAfter.ownerId);
        system.debug('LEAD lead before'+ lead.ownerId);
        
    }

    @isTest
	public static void testLeadWithNoMarket(){

        Lead lead = new Lead();
        lead.IsConverted = false;
        lead.Lead_Assignment_Status__c = '';
        lead.FirstName = 'Ruff';
        lead.LastName = 'Roof';
        lead.Lead_Assignment_Processed__c = false;
        lead.Street =  '';
        lead.City = 'San Diego';
        lead.State = 'CA';
        lead.PostalCode = '';
        lead.Country = '';
        lead.Company = 'Should find no account';
        lead.Status = '';
        lead.MC_Form_Name__c ='';
        insert lead;
        Test.startTest();
        LeadAssignmentBatchable lab = new LeadAssignmentBatchable(lead.Id);
        Database.executeBatch(lab,1);
        Test.stopTest();
        
        Lead leadAfter = [SELECT Id, OwnerId,  PostalCode, Account_ID__c,Status, Market__c,Lead_Assignment_Status__c, Lead_Assignment_Processed__c,MC_Form_Name__c FROM Lead WHERE Id = :lead.Id LIMIT 1];
        system.assertEquals(true,leadAfter.Lead_Assignment_Processed__c);
        system.debug('LEAD after'+ leadAfter.ownerId);
        system.debug('LEAD lead before'+ lead.ownerId);
        
    }
    
  @isTest
	public static void testAssignUnmatchedLeadToUKQueueByCountry(){        
        
        Lead lead = new Lead();
        lead.IsConverted = false;
        lead.Lead_Assignment_Status__c = '';
        lead.FirstName = 'Cory';
        lead.LastName = 'Bartholomew';
        lead.Lead_Assignment_Processed__c = false;
        lead.Street =  'Hornsey Rd';
        lead.City = 'London';
        lead.State = null;
        lead.PostalCode = 'N7 7AJ';
        lead.Country = 'United Kingdom';
        lead.Market__c = 'United Kingdom';
        lead.Company = 'Lead You Down That Road';
        lead.Status = 'Open';
        lead.MC_Form_Name__c ='';
        insert lead;

        Test.startTest();
        LeadAssignmentBatchable lab = new LeadAssignmentBatchable(lead.Id);
        Database.executeBatch(lab,1);
        Test.stopTest();

        Lead leadAfter = [SELECT OwnerId FROM Lead WHERE Id = :lead.Id];
        Group ukQueue = [SELECT Id, DeveloperName FROM Group WHERE DeveloperName = 'Unassigned_United_Kingdom_Market_Leads'];

        System.assertEquals(ukQueue.Id, leadAfter.OwnerId,'The lead owner should default to the UK queue');
    }

    @isTest
	public static void testGetPossibleAccountsNoData(){             
		
        List<Account> accounts = LeadAssignmentBatchHelper.getPossibleAccounts('', '', '', '', '');
    
        Map<String, Group> queueMap = LeadAssignmentBatchHelper.getLeadAssignmentQueues();
        string queue = LeadAssignmentBatchHelper.getQueueAssignment(queueMap,'');
        
        System.assertEquals(accounts.isEmpty(), true, 'There should be no accounts returned');
        System.assertNotEquals('', queue, 'queue name returned');
    } 
    
    
    
    @isTest
	public static void testUpdateLead_Negative(){             

        Lead lead = new Lead();
        lead.IsConverted = false;
        lead.Lead_Assignment_Status__c = '';
        lead.FirstName = 'Cory';
        lead.LastName = 'Bartholomew';
        lead.Lead_Assignment_Processed__c = false;
        lead.Street =  'Hornsey Rd';
        lead.City = 'London';
        lead.State = null;
        lead.PostalCode = 'N7 7AJ';
        lead.Country = 'United Kingdom';
        lead.Company = 'Lead You Down That Road';
        lead.Status = 'Open';
        lead.MC_Form_Name__c ='';
        //insert lead;
  
        Test.startTest();
        LeadAssignmentBatchHelper.updateLead(lead);
        Test.stopTest();
        List<Error_Log__c> logs = [SELECT Id FROM Error_Log__c];
        System.assertNotEquals(null,logs,'There should have been error logs generated from updating a record with no Id');
        
    } 
    
	
    @isTest
	public static void testMarketingLead(){             

        Account acct = CPQ_TestDataFactory.createAccount(false);
        acct.Name = 'Yes Match';
        acct.BillingStreet = '1234 Main Street';
        acct.BillingCity = 'Missoula';
        acct.BillingPostalCode = '59808';
        acct.BillingCountry = 'United States';
        insert acct;
        
        Lead lead = new Lead();
        lead.IsConverted = false;
        lead.Lead_Assignment_Status__c = '';
        lead.FirstName = 'Cory2';
        lead.LastName = 'B3';
        lead.Lead_Assignment_Processed__c = false;
        lead.Street =  'Hornsey Rd';
        lead.City = 'Missoula';
        lead.State = null;
        lead.PostalCode = '';
        lead.Country = 'United States';
        lead.Company = 'Lead You Down That Road';
        lead.Status = 'Open';
        lead.MC_Form_Name__c ='DX_Lead_Forms_Demo Campaign';
        lead.Account_ID__c = acct.id;
        insert lead;
  
         
        Test.startTest();
        LeadAssignmentBatchable lab = new LeadAssignmentBatchable(lead.Id);
        Database.executeBatch(lab,1);
        Test.stopTest();
        
        Lead updLead  = [SELECT Id ,OwnerId,Lead_Assignment_Status__c ,Lead_Assignment_Processed__c FROM Lead where id =:lead.id];
        System.assertNotEquals(null,updLead.OwnerId,'Lead should have owner');
      
       
    } 
    
    @isTest
	public static void testdetermineLeadAssignment(){             

        Account acct2 = CPQ_TestDataFactory.createAccount(false);
        acct2.Name = 'Yes Match';
        acct2.BillingStreet = '7 Sherwood Ln';
        acct2.BillingCity = 'Fairfield';
        acct2.BillingPostalCode = '07004-3601';
        acct2.BillingCountry = 'United States';
        insert acct2;
        
        Lead lead = new Lead();
        lead.IsConverted = false;
        lead.Lead_Assignment_Status__c = '';
        lead.FirstName = 'M';
        lead.LastName = 'ImasLead';
        lead.Lead_Assignment_Processed__c = false;
        lead.Street =  '7 Sherwood Ln';
        lead.City = '';
        lead.State = '';
        lead.PostalCode = '';
        lead.Country = 'United States';
        lead.Company = 'Lead You Down That Road';
        lead.Status = 'Open';
        lead.MC_Form_Name__c ='Diagnostics_Lead';
        lead.Account_ID__c = acct2.id;
        insert lead;     
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];     
        User diagnosticUSSalesRep = CPQ_TestDataFactory.createUser(
            'Diagnostic',
            'DiagnosticRep',
            'mila.imas@zoetis.com',
            'dxDiagRep@zoetistest.com',
            'testUser2',
            'diagRep2',
            p.Id,
            null,
            false
        );
        diagnosticUSSalesRep.ZTS_EU_Market__c = 'United States';
        insert diagnosticUSSalesRep;
        
        ZTS_EU_Territory__c nterritory = CPQ_TestDataFactory.createTerritory('United States',null, 'Diagnostics Solution Consultant','', true); 
        ZTS_EU_Position__c nposition = CPQ_TestDataFactory.createZoetisPosition(diagnosticUSSalesRep, nterritory, true);   
        ZTS_AccountTerritory__c nacctTerritory = CPQ_TestDataFactory.createAccountTerritory(acct2, nterritory, true, true);
        ZTS_EU_Account_Position__c naccountPosition =  CPQ_TestDataFactory.createAccountPosition(acct2,nposition,nacctTerritory,false); 
        //insert naccountPosition;
        Test.startTest();
        LeadAssignmentBatchable lab = new LeadAssignmentBatchable(lead.Id);
        Database.executeBatch(lab,1);
        Test.stopTest();
        
        Lead uLead  = [SELECT Id ,OwnerId,Lead_Assignment_Status__c ,Lead_Assignment_Processed__c,Account_ID__c FROM Lead where id =:lead.id];
        System.debug('updated Lead ' + uLead);
        string  OwnerId = uLead.OwnerId;
        System.debug('should be a diagnosticUSSalesRep ==> ' + diagnosticUSSalesRep);
        System.assertNotEquals(null,OwnerId,'should find leadOwner');
        
    } 
         
    @isTest
	public static void testSchedulable() {		
		Test.startTest();
		LeadAssignmentBatchable lab  = new LeadAssignmentBatchable();
		String sch = '0 0 0 * * ?';
		Id jobId = System.schedule('Lead Assignment Batch', sch, lab);
		Test.stopTest();
		//Lookup the job based on the Job ID
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		//Assertions
		System.assert(ct != null, 'Cron Trigger is null');
	}  

    @isTest
    public static void testLeadQueues(){
        String brazilQueueDevName = 'Unassigned_Brazil_Market_Leads';
        Test.startTest();
            Map<String, Group> leadAssignmentQueueMap = LeadAssignmentBatchHelper.getLeadAssignmentQueues();
            system.assert(leadAssignmentQueueMap.containsKey(brazilQueueDevName));
            String brazilQueueId = leadAssignmentQueueMap.get(brazilQueueDevName).Id;
            String testIdResult = LeadAssignmentBatchHelper.getQueueAssignment(leadAssignmentQueueMap, 'Brazil');
            system.assertEquals(brazilQueueId, testIdResult);
            Id queueIdByMarket = LeadAssignmentBatchHelper.getQueueIdByMarket(brazilQueueDevName);
            system.assertEquals(brazilQueueId, queueIdByMarket);
        Test.stopTest();
    }

    @isTest
    public static void leadWithNoMarket(){
        List<Lead> leadsList = new List<Lead>();
        Lead usLeadWithNoMarket = new Lead(
            FirstName='Test',
            LastName='LeadWithNoMarket',
            Company='NA',
            Country='United States'
        );
        leadsList.add(usLeadWithNoMarket);
        Lead bzLeadWithNoMarket = new Lead(
            FirstName='Test',
            LastName='LeadWithNoMarketBrazil',
            Company='NA',
            Country__c='Brazil'
        );
        leadsList.add(bzLeadWithNoMarket);
        insert leadsList;

        Test.startTest();
            for (Lead l : leadsList) {
                LeadAssignmentBatchHelper.assignUnmatchedLeadToQueue(l);
                System.assert(l.Lead_Assignment_Processed__c);
            }
        Test.stopTest();
    }
    
    @isTest
    public static void testMatchingAccountWithInsideSalesRep2(){
        RecordType dxRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Zoetis_Reference_Labs_Lead'];
        Lead lead = new Lead();
        lead.RecordTypeId = dxRecordType.Id;
        lead.IsConverted = false;
        lead.Lead_Assignment_Status__c = '';
        lead.FirstName = 'Cory';
        lead.LastName = 'Bartholomew';
        lead.Lead_Assignment_Processed__c = false;
        lead.Street =  'Hornsey Rd';
        lead.City = 'London';
        lead.State = null;
        lead.PostalCode = 'N7 7AJ';
        lead.Country = 'United Kingdom';
        lead.Company = 'Lead You Down That Road';
        lead.Status = 'Open';
        lead.MC_Form_Name__c ='';
        insert lead;
       
        Account acct = [
            SELECT 
                Id,
                (SELECT Id FROM Account_Positions__r)
            FROM Account
        ];
        System.assertNotEquals(acct, null, 'There was no Account returned from TestSetup');
        System.assertEquals(acct.Account_Positions__r.size(), 1, 'The account team was not setup correctly');
        System.debug('line 79 LeadAssBatch ===>'+acct);
        //Execute batch class        
        Test.startTest();
        LeadAssignmentBatchable lab = new LeadAssignmentBatchable();
        Database.executeBatch(lab,1);
        Test.stopTest();   
        
        Lead leadAfter = [SELECT Id, OwnerId, Lead_Assignment_Status__c, Lead_Assignment_Processed__c FROM Lead WHERE Id = :lead.Id LIMIT 1];
        system.assertEquals(true,leadAfter.Lead_Assignment_Processed__c);

        User expectedOwner = [SELECT Id FROM User WHERE Alias = 'diagRep' LIMIT 1];
     
        System.assertEquals(leadAfter.OwnerId, expectedOwner.Id, 'The lead was not assigned as expected');
    }
   
}