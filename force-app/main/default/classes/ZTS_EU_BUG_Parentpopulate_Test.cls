@isTest (SeeAlldata = False) 
public with sharing class ZTS_EU_BUG_Parentpopulate_Test {
    
    
    static testMethod void ZTS_EU_BUG_Parentpopulate() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            List<sObject> ls = Test.loadData(ZTS_GL_Account_Affiliation_Reverse_Roles__c.sObjectType, 'AccountReverseRoles');
            
            System.debug('Entered ZTS_EU_BUG_AccountAffiliation_Test' );
            
            List<Account>acParentRecord=ZTS_EU_DataUtilityTest.createAccountRecord(1);
            List<Account>acLevel1Record=ZTS_EU_DataUtilityTest.createAccountRecord(2);
            List<Account>acLevel2Record=ZTS_EU_DataUtilityTest.createAccountRecord(1);
            List<Account>acLevel3Record=ZTS_EU_DataUtilityTest.createAccountRecord(1);
            List<Account>acBUGRecord=ZTS_EU_DataUtilityTest.createAccountRecord(1);
            List<Account>acAffliatedRecord=ZTS_EU_DataUtilityTest.createAccountRecord(1);
            List<ZTS_EU_Account_Affiliations__c>accAffRecord=ZTS_EU_DataUtilityTest.createAccAffiliationRecord(1);
            List<ZTS_EU_Account_Affiliations__c>accAffRecord1=ZTS_EU_DataUtilityTest.createAccAffiliationRecord(1);
            
            // Insert Top most account
            
            insert acParentRecord;
            System.debug('<<<acParentRecord>>>>'+acParentRecord);
            //ZTS_EU_BUG_Parentpopulate.insertAccounts(acParentRecord);
            
            // Insert first level of Account as two child accounts with parent as account inserted in list acParentRecord
            
            lIST<Account> Level1chldAcc = new lIST<Account>();
            for(Account acc: acLevel1Record) {
                acc.parentid = acParentRecord[0].id;
                Level1chldAcc.add(acc);
            }
            insert Level1chldAcc;
            //ZTS_EU_BUG_Parentpopulate.insertAccounts(Level1chldAcc);
            
            // Insert Second level of child account with parent as on of the accounts in the above accounts inserted in Level1chldAcc list
            
            lIST<Account> Level2chldAcc = new lIST<Account>();
            for(Account acc1: acLevel2Record){
                acc1.parentid = Level1chldAcc[0].id;
                Level2chldAcc.add(acc1);
            }
            insert Level2chldAcc;
            //ZTS_EU_BUG_Parentpopulate.insertAccounts(Level2chldAcc);
            
            // Insert third level of child account with parent as on of the accounts in the above accounts inserted in Level1chldAcc list
            
            lIST<Account> Level3chldAcc = new lIST<Account>();
            for(Account acc2: acLevel2Record){
                acc2.parentid = Level2chldAcc[0].id;
                Level2chldAcc.add(acc2);
            }
            insert Level3chldAcc;
            /************************
Calling delete methods
************************/
            test.starttest();
            Set<id> setAccids = new Set<Id>();
            for(Account Acc : acParentRecord){
                setAccids.add(Acc.id);}
            List<Account> lstacc1 = [Select id from Account where Id IN : acParentRecord AND ZTS_EU_Market__c != 'United States'];
            delete lstacc1;
            test.stoptest();
            
            // ZTS_EU_BUG_Parentpopulate.deletedAccounts(setAccids);
            
            List<Account> lstAcc = new List<Account>();
            for(Account accids : acParentRecord){
                lstAcc.add(accids);}
            ZTS_EU_BUG_Parentpopulate.deleteAccountsAff(lstAcc);
        }
    }
}