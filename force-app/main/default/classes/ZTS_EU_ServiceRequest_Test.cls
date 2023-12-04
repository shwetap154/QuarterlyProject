/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_ServiceRequest_Test
* Description   :  Test class for ZTS_EU_ServiceRequest trigger
:  Test class for ZTS_EU_CloseServiceRequest class
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/14         Teresa           Created the Class.
* 1.1    08/20         Daniel Shaheen   Modified the Class
***************************************************************************************************************/
@isTest
public with sharing class ZTS_EU_ServiceRequest_Test {
    
    static testMethod void validate_ZTS_EU_ServiceRequest() {
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'teterson';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            try{
                List<Account> accList = ZTS_EU_DataUtilityTest.createAccountRecord(1);
                insert accList;
                
                List<Contact> contactsList = new List<Contact>();
                
                contactsList.add(new Contact(LastName = 'Test', FirstName='Name',AccountId = accList.get(0).Id,ZTS_EU_Market__c='United Kingdom'));
                insert contactsList;
                
                ZTS_EU_Species_Product__c prodSpecies= new ZTS_EU_Species_Product__c();
                prodSpecies.Name='Test Product';
                prodSpecies.ZTS_EU_Market__c='United Kingdom';
                prodSpecies.ZTS_EU_Type__c='Business Unit';
                prodSpecies.CurrencyIsoCode = 'EUR';
                prodSpecies.ZTS_EU_Is_Active__c=true;
                prodSpecies.ZTS_EU_Is_Detailable__c = false;
                insert prodSpecies;
                
                ZTS_EU_Species_Product__c prodSpeciesBrand= new ZTS_EU_Species_Product__c();
                prodSpeciesBrand.Name='Test Product Brand';
                prodSpeciesBrand.ZTS_EU_Market__c='United Kingdom';
                prodSpeciesBrand.ZTS_EU_Type__c='Brand';
                prodSpeciesBrand.CurrencyIsoCode = 'EUR';
                prodSpeciesBrand.ZTS_EU_Is_Active__c=true;
                prodSpeciesBrand.ZTS_EU_Is_Active__c = true;
                insert prodSpeciesBrand;
                
                ZTS_EU_Species__c species= new ZTS_EU_Species__c();
                species.Name='Test Species';
                species.ZTS_EU_Business_Unit__c = prodSpecies.id;
                species.ZTS_EU_Species__c = 'Test Species';
                species.CurrencyIsoCode='EUR'; 
                species.ZTS_EU_Market__c ='United Kingdom';
                insert species;
                
                List<Case> caseList = new List<Case>();
                caseList.add(new Case(ZTS_EU_Species__c = species.Id, ContactId = contactsList.get(0).Id, ZTS_EU_Product__c= prodSpeciesBrand.id, ZTS_EU_PV_Works__c='1234',status='open',Type='Complaint',ZTS_EU_Needed_By__c=System.today(),Description='Sample Description',Origin='Phone from Pet Owner'));
                insert caseList;
                
                List<Task> taskList = new List<Task>();
                List<Task> taskUpdatedList = new List<Task>();
                Task taskNew = new Task ();
                taskNew.WhatId= caseList.get(0).id;
                taskNew.CurrencyIsoCode = 'EUR';
                taskNew.Status='Not Started';
                taskNew.Priority='High';
                taskNew.Subject='Call';
                taskList.add(taskNew);
                
                insert taskList;
                Test.startTest();
                caseList[0].status='closed';
                update caseList;
                
                for(Task t:taskList)
                {
                    Task updateTask = new Task (id= t.Id);
                    t.Status='Closed';
                    taskUpdatedList.add(t);
                }
                
                update taskUpdatedList;
                Test.stopTest();
                
            }catch (DmlException e) {
                //Assert Error Message
                System.assert( e.getMessage().contains('Update failed. First exception on '), 
                              e.getMessage() );
                
            }
        }
    }
    
    static testMethod void validate_ZTS_EU_ServiceRequest1() {
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting(); 
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'teterson';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            List<Account> accList = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            insert accList;
            
            List<Contact> contactsList = new List<Contact>();
            
            contactsList.add(new Contact(LastName = 'Test', FirstName='Name',AccountId = accList.get(0).Id,ZTS_EU_Market__c='United Kingdom'));
            insert contactsList;
            
            ZTS_EU_Species_Product__c prodSpecies= new ZTS_EU_Species_Product__c();
            prodSpecies.Name='Test Product';
            prodSpecies.ZTS_EU_Market__c='United Kingdom';
            prodSpecies.ZTS_EU_Type__c='Business Unit';
            prodSpecies.CurrencyIsoCode = 'EUR';
            prodSpecies.ZTS_EU_Is_Active__c=true;
            prodSpecies.ZTS_EU_Is_Detailable__c = false;
            insert prodSpecies;
            
            ZTS_EU_Species_Product__c prodSpeciesBrand= new ZTS_EU_Species_Product__c();
            prodSpeciesBrand.Name='Test Product Brand';
            prodSpeciesBrand.ZTS_EU_Market__c='United Kingdom';
            prodSpeciesBrand.ZTS_EU_Type__c='Brand';
            prodSpeciesBrand.CurrencyIsoCode = 'EUR';
            prodSpeciesBrand.ZTS_EU_Is_Active__c=true;
            prodSpeciesBrand.ZTS_EU_Is_Active__c = true;
            insert prodSpeciesBrand;
            
            ZTS_EU_Species__c species= new ZTS_EU_Species__c();
            species.Name='Test Species';
            species.ZTS_EU_Business_Unit__c = prodSpecies.id;
            species.ZTS_EU_Species__c = 'Test Species';
            species.CurrencyIsoCode='EUR'; 
            species.ZTS_EU_Market__c ='United Kingdom';
            insert species;
            
            List<Case> caseList = new List<Case>();
            caseList.add(new Case(ZTS_EU_Species__c = species.Id, ContactId = contactsList.get(0).Id, ZTS_EU_Product__c= prodSpeciesBrand.id, ZTS_EU_PV_Works__c='1234',status='open',Type='Complaint',ZTS_EU_Needed_By__c=System.today(),Description='Sample Description',Origin='Phone from Pet Owner'));
            insert caseList;
            update caseList;

        }
    }
}