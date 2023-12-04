/**
 * @description       : Used to test the schedule batch job which deletes the Inactive Account Contact Affiliations from the system
 * @author            : Abir Bhattacharya @ Cognizant
 * @group             : 
 * @last modified on  : 07-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                          Modification
 * 1.0   04-13-2017   Abir Bhattacharya @ Cognizant   Created the Class.
 * 1.1   07-07-2022   Ethan Hirsch @ Zoetis Inc       Fix issues with inserting Contacts
**/
@isTest 
public class ZTS_US_AccContAffiliationDelJobTest 
{
    static testMethod void InactiveAccContAffDeleteTest() 
    {
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'USUser';
        intlUsr.ZTS_EU_Market__c = 'United States';
        insert intlUsr;
        System.runAs(intlUsr) {
            Integer countCheck = 50;
            List<ZTS_EU_Affiliations__c> lstAccountContactAff= new List<ZTS_EU_Affiliations__c>();
            //Code to Insert Test Account
            Account objAccount = new Account();
            objAccount.Name = 'Test Account';
            objAccount.BillingStreet='test_b';
            objAccount.BillingCity='test_c';
            objAccount.BillingPostalCode='test_pc';
            objAccount.BillingCountry='United States';
            objAccount.BillingState='TX';
            objAccount.ZTS_EU_Market__c = 'United States';
            insert objAccount;
            
            Test.startTest();
            //Code to Insert Test Contacts
            List<Contact> lstContact = new List<Contact>();
            for(Integer i = 0; i< countCheck  ; i++){
                Contact objCon = ZTS_EU_DataUtilityTest.createContactRecord(1)[0];
                objCon.LastName='Test';
                objCon.AccountId = objAccount.Id;
                objCon.ZTS_EU_Profession__c = 'Academia';
                lstContact.add(objCon);
            }
            insert lstContact;
            
            
            
            ZTS_US_InactiveAcctContAffilDeleteBatch.executeBatch(200); 
            
            Test.stopTest();
            
            lstAccountContactAff = [SELECT Id, Name FROM ZTS_EU_Affiliations__c WHERE ZTS_EU_Affiliation_Status__c = 'Inactive' AND ZTS_EU_Market_from_Parent__c = 'United States'];
            Integer count =0;
            if(lstAccountContactAff != null ){
                count = lstAccountContactAff.size();
            }
            
            //Check whether all the Inactive Records  got Deleted due to the execution of the batch
            system.assertEquals(0,count);
            
            lstAccountContactAff = [SELECT Id, Name FROM ZTS_EU_Affiliations__c WHERE ZTS_EU_Affiliation_Status__c = 'Active' AND ZTS_EU_Market_from_Parent__c = 'United States'];
            count =0;
            if(lstAccountContactAff != null ){
                count = lstAccountContactAff.size();
            }
            
            //Check whether all the Active Records are not affected due to the execution of the batch
            system.assertEquals(countCheck ,count);
        }
    }

    static testMethod void InactiveAccContAffDeleteTest2() 
    {
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'USUser';
        intlUsr.ZTS_EU_Market__c = 'United States';
        insert intlUsr;
        System.runAs(intlUsr) {
            Integer countCheck = 50;
            List<ZTS_EU_Affiliations__c> lstAccountContactAff= new List<ZTS_EU_Affiliations__c>();
            //Code to Insert Test Account
            Account objAccount = new Account();
            objAccount.Name = 'Test Account';
            objAccount.BillingStreet='test_b';
            objAccount.BillingCity='test_c';
            objAccount.BillingPostalCode='test_pc';
            objAccount.BillingCountry='United States';
            objAccount.BillingState='TX';
            objAccount.ZTS_EU_Market__c = 'United States';
            insert objAccount;
            
            Test.startTest();
            //Code to Insert Test Contacts
            List<Contact> lstContact = new List<Contact>();
            for(Integer i = 0; i< countCheck  ; i++){
                Contact objCon = ZTS_EU_DataUtilityTest.createContactRecord(1)[0];
                objCon.LastName='Test';
                objCon.AccountId = objAccount.Id;
                objCon.ZTS_EU_Profession__c = 'Academia';
                lstContact.add(objCon);
            }
            insert lstContact;
            
            
            USAccountTriggerService.mockException = true;            
            ZTS_US_InactiveAcctContAffilDeleteBatch.executeBatch(200); 
            
            Test.stopTest();
            
            lstAccountContactAff = [SELECT Id, Name FROM ZTS_EU_Affiliations__c WHERE ZTS_EU_Affiliation_Status__c = 'Inactive' AND ZTS_EU_Market_from_Parent__c = 'United States'];
            Integer count =0;
            if(lstAccountContactAff != null ){
                count = lstAccountContactAff.size();
            }
            
            //Check whether all the Inactive Records  got Deleted due to the execution of the batch
            system.assertEquals(0,count);
            
            lstAccountContactAff = [SELECT Id, Name FROM ZTS_EU_Affiliations__c WHERE ZTS_EU_Affiliation_Status__c = 'Active' AND ZTS_EU_Market_from_Parent__c = 'United States'];
            count =0;
            if(lstAccountContactAff != null ){
                count = lstAccountContactAff.size();
            }
            
            //Check whether all the Active Records are not affected due to the execution of the batch
            system.assertEquals(countCheck ,count);
        }
    }
}