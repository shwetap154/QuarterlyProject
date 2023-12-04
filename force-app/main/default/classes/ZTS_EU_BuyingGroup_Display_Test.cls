/**
 * @description       : Test class for ZTS_EU_BuyingGroup_Display
 * @author            : Unknown
 * @group             : 
 * @last modified on  : 07-25-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   06-21-2014   Unknown                      Created the class
 * 1.1   07-25-2022   Ethan Hirsch @ Zoetis Inc    Create ZTS_GL_Account_Affiliation_Reverse_Roles__c to fix null 
 *                                                 exceptions in ZTS_EU_Affiliation_ReverseRecordCreation.
**/
@isTest (SeeAlldata = False)
public class ZTS_EU_BuyingGroup_Display_Test{
    
    static testMethod void myTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            ZTS_GL_Account_Affiliation_Reverse_Roles__c reverseRoles = ZTS_EU_DataUtilityTest.createAccountAffiliationReverseRolesSetting('Sells to');
            insert reverseRoles;
           Test.StartTest();
            PageReference pageRef = Page.ZTS_EU_BuyingGroup_Display;
            Test.setCurrentPageReference(pageRef);
            
            List<Account>primaryaccountRecord=ZTS_EU_DataUtilityTest.createAccountRecord(1);
            primaryaccountRecord[0].ZTS_EU_Market__c = 'United Kingdom';
            insert primaryaccountRecord;
            
            List<Account>bugaccountRecord=ZTS_EU_DataUtilityTest.createAccountRecord(1);
            List<Account> lstbugacc = new List<Account>();   
            for(Account acc: bugaccountRecord) {
                acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ZTS_EU_Buying_Group').getRecordTypeId();
                lstbugacc.add(acc);
            }
           

           // update lstbugacc;     
            
            List<ZTS_EU_Account_Affiliations__c>accaffRecord=ZTS_EU_DataUtilityTest.createAccAffiliationRecord(1);
            List<ZTS_EU_Account_Affiliations__c> lstbugaccins = new List<ZTS_EU_Account_Affiliations__c>();
            for(ZTS_EU_Account_Affiliations__c aff: accaffRecord){
                aff.ZTS_EU_Account__c = primaryaccountRecord[0].id;
                aff.ZTS_EU_Affiliated_Account__c = lstbugacc[0].id;
                lstbugaccins.add(aff);
            }
          //  insert lstbugaccins;
            Account newAcc = new Account(id = primaryaccountRecord[0].id);
            ApexPages.StandardController controller = new ApexPages.StandardController(newAcc);
            ZTS_EU_BuyingGroup_Display  appRedirect = new ZTS_EU_BuyingGroup_Display(controller);
            appRedirect.bugaffdisplay();
            
                       Test.StopTest();

        }
    }
    static testMethod void myTest2(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
                                    Test.StartTest();

            ZTS_GL_Account_Affiliation_Reverse_Roles__c reverseRoles = ZTS_EU_DataUtilityTest.createAccountAffiliationReverseRolesSetting('Sells to');
            insert reverseRoles;

            PageReference pageRef = Page.ZTS_EU_BuyingGroup_Display;
            Test.setCurrentPageReference(pageRef);
            
            List<Account>primaryaccountRecord=ZTS_EU_DataUtilityTest.createAccountRecord(1);
            primaryaccountRecord[0].ZTS_EU_Market__c = 'United Kingdom';
            insert primaryaccountRecord;
            
            List<Account>nbugaccountRecord=ZTS_EU_DataUtilityTest.createAccountRecord(1);
            List<Account> lstacc = new List<Account>();
            for(Account Acc : nbugaccountRecord){
                Acc.name = 'None Buying Group Account';
                lstacc.add(Acc);
            }
            Insert lstacc;
            List<ZTS_EU_Account_Affiliations__c>accaffRecord=ZTS_EU_DataUtilityTest.createAccAffiliationRecord(1);
            List<ZTS_EU_Account_Affiliations__c>lstnbugaccins = new List<ZTS_EU_Account_Affiliations__c>();
            for(ZTS_EU_Account_Affiliations__c aff: accaffRecord){
                aff.ZTS_EU_Account__c = primaryaccountRecord[0].id;
                aff.ZTS_EU_Affiliated_Account__c = lstacc[0].id;
                lstnbugaccins.add(aff);
            }
           // insert lstnbugaccins;
            Account newAcc = new Account(id = primaryaccountRecord[0].id);
            ApexPages.StandardController controller = new ApexPages.StandardController(newAcc);
            ZTS_EU_BuyingGroup_Display  appRedirect = new ZTS_EU_BuyingGroup_Display(controller);
            appRedirect.bugaffdisplay();
                        Test.StopTest();

        }
    }
}