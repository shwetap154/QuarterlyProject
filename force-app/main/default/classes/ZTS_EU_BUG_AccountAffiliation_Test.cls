@isTest
public with sharing class ZTS_EU_BUG_AccountAffiliation_Test {
    static testMethod void validate_ZTS_EU_BUG_AccountAffiliation() {
        TriggerActivation__c triActivation = new TriggerActivation__c(Name = 'ZTS_US_Account_Affi_InsertDupliRec', isActive__c=true);
        insert triActivation;
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            List < sObject > ls = Test.loadData(ZTS_GL_Account_Affiliation_Reverse_Roles__c.sObjectType, 'AccountReverseRoles');
            System.debug('Entered ZTS_EU_BUG_AccountAffiliation_Test'); 
            List < Account > acParentRecord = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            List < Account > acchildRecord = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            List < Account > acBUGRecord = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            List < Account > acAffliatedRecord = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            List < ZTS_EU_Account_Affiliations__c > accAffRecord = ZTS_EU_DataUtilityTest.createAccAffiliationRecord(1);
            
            insert acParentRecord;
            
            
            List < Account > chldAcc = new List < Account > ();
            for (Account acc: acchildRecord) {
                acc.parentid = acParentRecord[0].id;
                chldAcc.add(acc);
            }
            insert chldAcc;
            
            List < Account > bugAcc = new List < Account > ();
            for (Account accrec: acBUGRecord) {
                accrec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ZTS_EU_Buying_Group').getRecordTypeId();
               
                bugAcc.add(accrec);
            }
            insert bugAcc;
            List < ZTS_EU_Account_Affiliations__c > lstaccAff = new List < ZTS_EU_Account_Affiliations__c > ();
            for (ZTS_EU_Account_Affiliations__c aff: accAffRecord) {
                aff.ZTS_EU_Account__c = acParentRecord[0].id;
                aff.ZTS_EU_Account_Affiliation_Id__c = acParentRecord[0].id;
                aff.ZTS_EU_After_Insert__c= acParentRecord[0].id;
                aff.ZTS_EU_Affiliated_Account__c = bugAcc[0].id;
                //aff.ZTS_EU_Market_from_Primary_Account__c = 'Canada';
 
                lstaccAff.add(aff);
            }
            insert lstaccAff;
            
            Map < Id, ZTS_EU_Account_Affiliations__c > mapbugoldaccAff = new Map < Id, ZTS_EU_Account_Affiliations__c > ();
            for (ZTS_EU_Account_Affiliations__c aff: lstaccAff) {
                mapbugoldaccAff.put(aff.id, aff);
            }
            integer QueryCount = Limits.getQueries();
            System.debug('SOQL queries used IN AOActivation: After BUG Aff Insert ' + QueryCount);
            List < ZTS_EU_Account_Affiliations__c > lstupdaccAff = new  List < ZTS_EU_Account_Affiliations__c > ();
            for(ZTS_EU_Account_Affiliations__c newaff : lstaccAff){
              //  newaff.ZTS_EU_Affiliation_Status__c = 'Inactive';
                 newaff.ZTS_EU_Role__c = 'Sells to';
                lstupdaccAff.add(newaff);
            }
            Update lstupdaccAff;
            
            List < Account > accnewhildRecord = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            
            List < Account > newchldAcc = new List < Account > ();
            for (Account newacc: accnewhildRecord) {
               newacc.ZTS_EU_Parent_Id__c = acParentRecord[0].id;
                newacc.parentid = acParentRecord[0].id;
                newchldAcc.add(newacc);
            }
            insert newchldAcc;
            
            Map < Id, Account > mapnewacc = new Map < Id, Account > ();
            for (Account newaccount: newchldAcc) {
                mapnewacc.put(newaccount.id, newaccount);
            }
            Test.starttest();
            ZTS_EU_BUG_AccountAffiliation.insertAffiliates(lstaccAff);
            ZTS_EU_BUG_AccountAffiliation.beforeupdateAffiliates(lstaccAff);
            ZTS_EU_BUG_AccountAffiliation.updateAffiliates(lstaccAff,mapbugoldaccAff);      
            ZTS_EU_BUG_AccountAffiliation.insertAffiliatesfromAccount(accnewhildRecord);
            ZTS_EU_BUG_AccountAffiliation.deleteBUGAffRecords(lstupdaccAff);
            
           // delete lstupdaccAff;
            undelete lstupdaccAff;
            Test.stoptest();
        }   
    }
    static testMethod void validate_ZTS_EU_BUG_AccountAffiliationForAustraliaAndNewZealand() {
        TriggerActivation__c triActivation = new TriggerActivation__c(Name = 'ZTS_US_Account_Affi_InsertDupliRec', isActive__c=true);
        insert triActivation;
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'Australia';
        insert usr;
        
        System.runAs(usr)
        {
            List < sObject > ls = Test.loadData(ZTS_GL_Account_Affiliation_Reverse_Roles__c.sObjectType, 'AccountReverseRoles');
            List < Account > acParentRecord = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            List < Account > acchildRecord = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            List < Account > acBUGRecord = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            
            //parent account
            acParentRecord[0].ZTS_EU_Market__c = 'Australia';
            insert acParentRecord;
            
            List < Account > chldAcc = new List < Account > ();
            for (Account acc: acchildRecord) {
                acc.parentid = acParentRecord[0].id;
                acc.ZTS_EU_Market__c = 'Australia';
                acc.ZTS_EU_Parent_Id__c = acParentRecord[0].Id;
                chldAcc.add(acc);
            }
            //child accounts
            insert chldAcc;
            
            List < Account > bugAcc = new List < Account > ();
            for (Account accrec: acBUGRecord) {
                accrec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ZTS_EU_Buying_Group').getRecordTypeId();
                accrec.ZTS_EU_Market__c = 'Australia';
                bugAcc.add(accrec);
            }
            //buying group account
            insert bugAcc;
            
            ZTS_EU_Account_Affiliations__c aff = new ZTS_EU_Account_Affiliations__c(
            ZTS_EU_Account__c = acParentRecord[0].id,
            ZTS_EU_Affiliated_Account__c = bugAcc[0].id,
            ZTS_EU_Role__c = 'Corporate',
            ZTS_EU_Affiliation_Status__c = 'Active',
            ZTS_EU_Account_influence__c = 'High',
            ZTS_EU_Account_Affiliation_Id__c = acParentRecord[0].id);
            
            List < ZTS_EU_Account_Affiliations__c > lstaccAff = new List < ZTS_EU_Account_Affiliations__c > ();
            lstaccAff.add(aff);
            Test.starttest();
            //adding affiliation to parent
            insert lstaccAff;
            
            List < ZTS_EU_Account_Affiliations__c > checkaccAff = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Affiliated_Account__c, ZTS_EU_Affiliation_Status__c, ZTS_EU_Account_influence__c, ZTS_EU_Role__c FROM ZTS_EU_Account_Affiliations__c WHERE ZTS_EU_Account__c =: chldAcc[0].id];
            //Assert Statement
            System.assertequals(checkaccAff.size(),0);
            List < ZTS_EU_Account_Affiliations__c > checkaccAff1 = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Affiliated_Account__c, ZTS_EU_Affiliation_Status__c, ZTS_EU_Account_influence__c, ZTS_EU_Role__c FROM ZTS_EU_Account_Affiliations__c WHERE ZTS_EU_Account__c =: acParentRecord[0].id];
            //Assert Statement
            System.assertequals(checkaccAff1.size(),1);
            
            ZTS_EU_Account_Affiliations__c newaff = new ZTS_EU_Account_Affiliations__c(
            ZTS_EU_Account__c = acParentRecord[0].id,
            ZTS_EU_Affiliated_Account__c = bugAcc[0].id,
            ZTS_EU_Role__c = 'Sells to',
            ZTS_EU_Affiliation_Status__c = 'Active',
            ZTS_EU_Account_influence__c = 'High',
            ZTS_EU_Account_Affiliation_Id__c = acParentRecord[0].id);
            
            ZTS_EU_Account_Affiliations__c newaff1 = new ZTS_EU_Account_Affiliations__c(
            ZTS_EU_Account__c = chldAcc[0].id,
            ZTS_EU_Affiliated_Account__c = bugAcc[0].id,
            ZTS_EU_Role__c = 'Sells to',
            ZTS_EU_Affiliation_Status__c = 'Active',
            ZTS_EU_Account_influence__c = 'High',
            ZTS_EU_Account_Affiliation_Id__c = chldAcc[0].id);
            
            List < ZTS_EU_Account_Affiliations__c > lstaccAffnew = new List < ZTS_EU_Account_Affiliations__c > ();
            lstaccAffnew.add(newaff);
            lstaccAffnew.add(newaff1);
            
            //adding new affiliation to parent and child
            insert lstaccAffnew;
            
            checkaccAff = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Affiliated_Account__c, ZTS_EU_Affiliation_Status__c, ZTS_EU_Account_influence__c, ZTS_EU_Role__c FROM ZTS_EU_Account_Affiliations__c WHERE ZTS_EU_Account__c =: chldAcc[0].id];
            //Assert Statement
            System.assertequals(checkaccAff.size(),1);
            checkaccAff1 = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Affiliated_Account__c, ZTS_EU_Affiliation_Status__c, ZTS_EU_Account_influence__c, ZTS_EU_Role__c FROM ZTS_EU_Account_Affiliations__c WHERE ZTS_EU_Account__c =: acParentRecord[0].id];
            //Assert Statement
            System.assertequals(checkaccAff1.size(),2);
            
            //deleting affiliation from parent
            delete newaff;
            
            checkaccAff = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Affiliated_Account__c, ZTS_EU_Affiliation_Status__c, ZTS_EU_Account_influence__c, ZTS_EU_Role__c FROM ZTS_EU_Account_Affiliations__c WHERE ZTS_EU_Account__c =: chldAcc[0].id];
            //Assert Statement
            System.assertequals(checkaccAff.size(),1);
            checkaccAff1 = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Affiliated_Account__c, ZTS_EU_Affiliation_Status__c, ZTS_EU_Account_influence__c, ZTS_EU_Role__c FROM ZTS_EU_Account_Affiliations__c WHERE ZTS_EU_Account__c =: acParentRecord[0].id];
            //Assert Statement
            System.assertequals(checkaccAff1.size(),1);
            
            List < Account > accnewhildRecord = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            
            List < Account > newchldAcc = new List < Account > ();
            for (Account newacc: accnewhildRecord) {
                newacc.parentid = acParentRecord[0].id;
                newacc.ZTS_EU_Parent_Id__c = acParentRecord[0].id;
                newacc.ZTS_EU_Market__c = 'Australia';
                newchldAcc.add(newacc);
            }
            //new child account
            insert newchldAcc;
            
            checkaccAff = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Affiliated_Account__c FROM ZTS_EU_Account_Affiliations__c WHERE ZTS_EU_Account__c =: newchldAcc[0].id];
            //Assert Statement
            System.assertequals(checkaccAff.size(),0);
            Test.stoptest();
 }   
    }
}