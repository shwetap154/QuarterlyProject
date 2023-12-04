/**
 * @description       : This test class covers the classes: ZTS_EU_DisplayDataGenericController and ZTS_EU_DisplayContractsController.  
 * @author            : Shreyas @ CloudSense
 * @group             : 
 * @last modified on  : 07-25-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   06-21-2014   Shreyas @ CloudSense         Created the class
 * 1.1   07-25-2022   Ethan Hirsch @ Zoetis Inc    Create ZTS_GL_Account_Affiliation_Reverse_Roles__c to fix null 
 *                                                 exceptions in ZTS_EU_Affiliation_ReverseRecordCreation.
**/
@isTest(seeAllData = false)
public class ZTS_EU_DisplayDataGenericController_Test{
    
    public static testMethod void testMethod1(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            ZTS_GL_Account_Affiliation_Reverse_Roles__c reverseRoles = ZTS_EU_DataUtilityTest.createAccountAffiliationReverseRolesSetting('Corporate');
            insert reverseRoles;
            
            String SoLA = 'SoLA';
            String acctRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'ZTS_EU_Activated_Account'].Id;
            
            List<Account> accountsList = new List<Account>();
            for(integer i=0;i<=4;i++){
                Account acc = new Account();
                acc = TestUtilities.createNoInsertAccountRecord('TestAcct' + i,'Farm','Dairy',acctRecordTypeId,SoLA,'1',false);
                accountsList.add(acc);
            }
            Database.insert(accountsList,false);
            
            ZTS_EU_Account_Affiliations__c accAff = new ZTS_EU_Account_Affiliations__c();
            accAff = TestUtilities.createNoInsertAccountAffiliation(accountsList[3].Id,accountsList[0].Id,'Corporate'); 
            insert accAff;
            
            Account accfetch = new Account();
            accfetch = [Select Id, ParentId from Account where Id =: accountsList[0].Id AND ZTS_EU_Market__c != 'United States'];
            accfetch.ParentId = accountsList[1].Id;
            update accfetch;
            system.assertEquals(accfetch.ParentId,accountsList[1].Id);
            
            ZTS_EU_DisplayDataGenericController obj1 = new ZTS_EU_DisplayDataGenericController();
            
            list<string> listOfFields = new list<string>();
            listOfFields.add('Id');
            listOfFields.add('Name');
            obj1.fieldsList = listOfFields;
            obj1.objNamestring = 'Contract';
            obj1.accountRelationName = 'AccountId';
            obj1.recordId = accountsList[0].Id;
            
            List<sobject> sObjectList = new List<sobject>();
            sObjectList = obj1.getsObjectData();
        }
    }
    
    public static testMethod void testMethod2(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            String SoLA = 'SoLA';
            String acctRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'ZTS_EU_Activated_Account'].Id;
            
            List<Account> accountsList = new List<Account>();
            for(integer i=0;i<=1;i++){
                Account acc = new Account();
                acc = TestUtilities.createNoInsertAccountRecord('TestAcct' + i,'Farm','Dairy',acctRecordTypeId,SoLA,'1',false);
                accountsList.add(acc);
            }
            Database.insert(accountsList,false);
            
            ApexPages.StandardController controller = new ApexPages.StandardController(accountsList[0]);
            ZTS_EU_DisplayContractsController obj2 = new ZTS_EU_DisplayContractsController(controller);
        }
    }
}