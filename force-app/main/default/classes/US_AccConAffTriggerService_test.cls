/**
* @description       : Test Class for USZTS_EU_AffiliationsTriggerService.cls (SC-008471) 
* @author            : Arita Chakraborty @ Cognizant
* @group             : 
* @last modified on  : 07-07-2022
* @last modified by  : Ethan Hirsch @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                          Modification
* 1.0   04-07-2021   Arita Chakraborty @ Cognizant   Created  (SC-008471)
* 1.1   07-07-2022   Ethan Hirsch @ Zoetis Inc       Fix issues with inserting Contacts that caused Unit Test failures
**/
@isTest
private class US_AccConAffTriggerService_test {
    static testmethod void MyUnitTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            
            Account acc3=new Account(Name='test345',ZTS_EU_Account_Status__c='Active',
                                     ZTS_EU_Market__c='United States',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '12345',
                                     ZTS_EU_Rep_Account_Status__c = 'Active');
            insert acc3;
            
            
            Contact contest3= ZTS_EU_DataUtilityTest.createContactRecord(1)[0];
            contest3.ZTS_EU_Rep_Contact_Status__c='Active';
            contest3.ZTS_EU_Contact_Status__c='Active';
            contest3.ZTS_EU_Market__c = 'United States';
            contest3.ZTS_US_Account_influence__c = 'Decision Maker';
            insert contest3;
            
            ZTS_EU_Affiliations__c testAffiliations3=new ZTS_EU_Affiliations__c(ZTS_EU_Account__c=acc3.id,  ZTS_EU_Contact__c=contest3.id, ZTS_EU_Affiliation_Status__c ='Active',Name ='test3');
            insert testAffiliations3;
            
            List<ZTS_EU_Affiliations__c> lstOldAff = [Select Id from ZTS_EU_Affiliations__c where Id =:testAffiliations3.Id];
            Map<Id,ZTS_EU_Affiliations__c> mapOldAff = new Map<Id,ZTS_EU_Affiliations__c>(lstOldAff);
            lstOldAff[0].ZTS_EU_Job_Function__c = 'Animal Welfare';
            lstOldAff[0].ZTS_EU_Affiliation_Status__c = 'Inactive';
            update lstOldAff[0];
            
            List<Id> contactIdList = new List<Id>();
            List<ZTS_EU_Affiliations__c> triggerList = new List<ZTS_EU_Affiliations__c>();
            contactIdList.add(contest3.id);
            triggerList.add(testAffiliations3);
            
            
            acc3.ZTS_EU_Primary_Contact__c = contest3.id;
            update acc3; 
            Map<Id,ZTS_EU_Affiliations__c> newMap = new Map<Id,ZTS_EU_Affiliations__c>{testAffiliations3.Id => testAffiliations3};
            USZTS_EU_AffiliationsTriggerService.updatePrimaryContactAffiliation(contactIdList,triggerList,newMap);
            
            delete lstOldAff[0];
        }         
        
    }
    
    static testmethod void MyUnitTest2(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr) {
            Account acc1 =new Account(Name='test345',ZTS_EU_Account_Status__c='Active',
                                     ZTS_EU_Market__c='United States',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '12345',
                                     ZTS_EU_Rep_Account_Status__c = 'Active');
            
            Account acc2 =new Account(Name='test12345',ZTS_EU_Account_Status__c='Active',
                                     ZTS_EU_Market__c='United States',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '54321',
                                     ZTS_EU_Rep_Account_Status__c = 'Active');
            insert new List<Account> {acc1, acc2};            
            
            Contact contest3= ZTS_EU_DataUtilityTest.createContactRecord(1)[0];
            contest3.ZTS_EU_Rep_Contact_Status__c='Active';
            contest3.ZTS_EU_Contact_Status__c='Active';
            contest3.ZTS_EU_Market__c = 'United States';
            contest3.ZTS_US_Account_influence__c = 'Decision Maker';
            insert contest3;            
            
            ZTS_EU_Affiliations__c testAffiliations1 = new ZTS_EU_Affiliations__c(ZTS_EU_Account__c =acc1.Id,  ZTS_EU_Contact__c =contest3.Id, ZTS_EU_Affiliation_Status__c ='Active',Name ='test1',ZTS_EU_Account_influence__c = 'Decision Maker', ZTS_US_Profession__c= 'Academia', ZTS_US_Job_Function__c= 'Administration');
            ZTS_EU_Affiliations__c testAffiliations2 = new ZTS_EU_Affiliations__c(ZTS_EU_Account__c =acc2.Id,  ZTS_EU_Contact__c =contest3.Id, ZTS_EU_Affiliation_Status__c ='Active',Name ='test2',ZTS_EU_Account_influence__c = 'Decision Maker', ZTS_US_Profession__c= 'Academia', ZTS_US_Job_Function__c= 'Administration');
            insert new List<ZTS_EU_Affiliations__c> {testAffiliations1, testAffiliations2}; 
            
            List<Id> contactIdList = new List<Id> {contest3.Id};
            List<ZTS_EU_Affiliations__c> affiliationsList = new List<ZTS_EU_Affiliations__c> {testAffiliations1};
            Map<Id,ZTS_EU_Affiliations__c> newMap = new Map<Id,ZTS_EU_Affiliations__c>{testAffiliations1.Id => testAffiliations1};
            System.assertNotEquals(affiliationsList,null,'success');
            USZTS_EU_AffiliationsTriggerService.updatePrimaryContactAffiliation(contactIdList, affiliationsList,newMap);
            
        }         
    }
    
    static testmethod void MyUnitTest3(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr) {
            Account acc1 =new Account(Name='test345',ZTS_EU_Account_Status__c='Active',
                                     ZTS_EU_Market__c='United States',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '12345',
                                     ZTS_EU_Rep_Account_Status__c = 'Active');
            
            Account acc2 =new Account(Name='test12345',ZTS_EU_Account_Status__c='Active',
                                     ZTS_EU_Market__c='United States',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '54321',
                                     ZTS_EU_Rep_Account_Status__c = 'Active');
            
            Account acc3 =new Account(Name='test321',ZTS_EU_Account_Status__c='Active',
                                     ZTS_EU_Market__c='United States',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '11111',
                                     ZTS_EU_Rep_Account_Status__c = 'Active');
            insert new List<Account> {acc1, acc2, acc3};            
            
            Contact contest3= ZTS_EU_DataUtilityTest.createContactRecord(1)[0];
            contest3.ZTS_EU_Rep_Contact_Status__c='Active';
            contest3.ZTS_EU_Contact_Status__c='Active';
            contest3.ZTS_EU_Market__c = 'United States';
            contest3.ZTS_US_Account_influence__c = 'Decision Maker';
            insert contest3;            
            
            ZTS_EU_Affiliations__c testAffiliations1 = new ZTS_EU_Affiliations__c(ZTS_EU_Account__c =acc1.Id,  ZTS_EU_Contact__c =contest3.Id, ZTS_EU_Affiliation_Status__c ='Active',Name ='test1');
            ZTS_EU_Affiliations__c testAffiliations2 = new ZTS_EU_Affiliations__c(ZTS_EU_Account__c =acc2.Id,  ZTS_EU_Contact__c =contest3.Id, ZTS_EU_Affiliation_Status__c ='Active',Name ='test2');
            ZTS_EU_Affiliations__c testAffiliations3 = new ZTS_EU_Affiliations__c(ZTS_EU_Account__c =acc3.Id,  ZTS_EU_Contact__c =contest3.Id, ZTS_EU_Affiliation_Status__c ='Active',Name ='test3');
            List<ZTS_EU_Affiliations__c> affliationlist = new List<ZTS_EU_Affiliations__c>{testAffiliations1, testAffiliations2, testAffiliations3};
            insert affliationlist;  
            //insert new List<ZTS_EU_Affiliations__c> {testAffiliations1, testAffiliations2, testAffiliations3}; 
            System.assertNotEquals(affliationlist,null,'success');
            
            List<Id> contactIdList = new List<Id> {contest3.Id};
            List<ZTS_EU_Affiliations__c> affiliationsList = new List<ZTS_EU_Affiliations__c> {testAffiliations1};
            Map<Id,ZTS_EU_Affiliations__c> newMap = new Map<Id,ZTS_EU_Affiliations__c>{testAffiliations1.Id => testAffiliations1};
            
            USZTS_EU_AffiliationsTriggerService.updatePrimaryContactAffiliation(contactIdList, affiliationsList,newMap);
            
            delete testAffiliations1;
            
        }         
    }
    
}