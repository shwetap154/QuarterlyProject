@isTest(SeeAlldata = false)
public with sharing class ZTS_EU_Affiliation_RevRec_Test {
        public static Map < String, ZTS_GL_Account_Affiliation_Reverse_Roles__c > customSettingAcc = ZTS_GL_Account_Affiliation_Reverse_Roles__c.getAll();

    
    static testMethod void ZTS_EU_Affiliation_ReverseRecordCreation() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            
            ZTS_GL_Account_Affiliation_Reverse_Roles__c reverseRoles = new ZTS_GL_Account_Affiliation_Reverse_Roles__c();
            reverseRoles.Name = 'Corporate';
            reverseRoles.ZTS_GL_Reverse_Role__c = 'Corporate';
            
            insert reverseRoles;
            
            List < Account > acparentAccountRecord = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            insert acparentAccountRecord;
            
            List < Account > acparentAccountRecordClone = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            insert acparentAccountRecordClone;
            
            List < Account > acchildAccountRecordClone = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            
            for(Account Acc : acchildAccountRecordClone){
                Acc.parentid = acparentAccountRecordClone[0].id;
                Acc.ZTS_EU_Parent_Id__c = acparentAccountRecord[0].Id;
            }
            insert acchildAccountRecordClone;
            
            List < Account > acAffiliatedAccountRecord = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            for(Account affAcc : acAffiliatedAccountRecord){
                affAcc.ZTS_EU_Parent_Id__c = acparentAccountRecord[0].Id;
            }
            insert acAffiliatedAccountRecord;
            
            List < Account > acchildAccountRecord = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            List<Account> acupdchildAccountRecord = new List<Account>();
            
            Test.StartTest();
            for(Account Acc : acchildAccountRecord){
                Acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ZTS_EU_Buying_Group').getRecordTypeId();    
                Acc.parentid = acparentAccountRecord[0].id;
                Acc.ZTS_EU_Parent_Id__c = acparentAccountRecord[0].Id;
                acupdchildAccountRecord.add(Acc);
            }
            insert acupdchildAccountRecord;
            
            List < ZTS_EU_Account_Affiliations__c > accAffRecordClone = ZTS_EU_DataUtilityTest.createAccAffiliationRecord(1);
            for(ZTS_EU_Account_Affiliations__c aff : accAffRecordClone){
                aff.ZTS_EU_Account__c =  acupdchildAccountRecord[0].id;
                aff.ZTS_EU_Affiliated_Account__c = acAffiliatedAccountRecord[0].id; 
                aff.ZTS_EU_Affiliation_Type__c = 'Reverse'; 
                aff.ZTS_EU_Market_from_Primary_Account__c = 'test';
                aff.ZTS_EU_Role__c  = 'Corporate';
               // aff.ZTS_EU_Affiliated_Account__r.ZTS_EU_Parent_Id__c = acupdchildAccountRecord[0].id;
                
              //  aff.ZTS_EU_Affiliated_Account__c = acupdchildAccountRecord[0].ZTS_EU_Parent_Id__c;
            }
            
            insert accAffRecordClone;
            
            
            List < ZTS_EU_Account_Affiliations__c > accAffRecord = ZTS_EU_DataUtilityTest.createAccAffiliationRecord(1);
            for(ZTS_EU_Account_Affiliations__c aff : accAffRecord){
                aff.ZTS_EU_Account__c =  acchildAccountRecordClone[0].id;
                aff.ZTS_EU_Affiliated_Account__c = acupdchildAccountRecord[0].id; 
                aff.ZTS_EU_Role__c = 'Corporate';
                aff.ZTS_EU_Affiliation_Status__c = 'Active';
            }
            
            insert accAffRecord;
            
            Map<Id, ZTS_EU_Account_Affiliations__c> oldmap = new Map<Id, ZTS_EU_Account_Affiliations__c>();
            for(ZTS_EU_Account_Affiliations__c oldaff : accAffRecord){
                oldaff.ZTS_EU_Account__c= oldaff.ZTS_EU_Affiliated_Account__c;
                oldmap.put(oldaff.id,oldaff);
            }
            
            
            List<ZTS_EU_Account_Affiliations__c> updaff = new List<ZTS_EU_Account_Affiliations__c>();
            for(ZTS_EU_Account_Affiliations__c affupd : accAffRecord){
                affupd.ZTS_EU_Affiliation_Status__c = 'Inactive'; 
                updaff.add(affupd);
            }
            update updaff;
            
            
            
            
            Map<Id, ZTS_EU_Account_Affiliations__c> newmap = new Map<Id, ZTS_EU_Account_Affiliations__c>();
            for(ZTS_EU_Account_Affiliations__c newaff : updaff){
                newmap.put(newaff.id,newaff);
            }
            System.debug('oldmap :'+oldmap);
            System.debug('accAffRecord :'+accAffRecord);
            
            ZTS_EU_Affiliation_ReverseRecordCreation updcall = new ZTS_EU_Affiliation_ReverseRecordCreation();
            ZTS_EU_Affiliation_ReverseRecordCreation.insertRecord(updaff);
            updcall.updateAccountRecord(updaff,accAffRecord,newmap, oldmap);
            Test.StopTest();
        }
    }
}