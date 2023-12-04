@isTest
public with sharing class ZTS_EU_KOL_Test {
    
    static testMethod void validate_ZTS_EU_KOL() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            Primary_Contact_Inactive_Profile_List__c newCustomSetting = new Primary_Contact_Inactive_Profile_List__c();
            newCustomSetting.Name = 'Profile Names';
            newCustomSetting.profile__c = '\'ZTS AUT Business Administrator\';\'ZTS BAL Business Administrator\';\'ZTS BGR Business Administrator\';\'ZTS BNLX Business Administrator\';\'ZTS EGY Business Administrator\';\'ZTS ESP Business Administrator\';\'ZTS FIN Business Administrator\';\'System Administrator\'';
            insert newCustomSetting;
            
            Primary_Contact_Inactive_Profile_List__c newCustomSetting2 = new Primary_Contact_Inactive_Profile_List__c();
            newCustomSetting2.Name = 'Profile Names 1';
            newCustomSetting2.profile__c = '\'ZTS FRA Business Administrator\';\'ZTS UK Business Administrator\';\'ZTS ITA Business Administrator\',\'Integration Profile\',\'ZTS KOR Business Administrator\',\'ZTS THA Business Administrator\',\'ZTS PHL Business Administrator\',\'ZTS VNM Business Administrator\'';
            insert newCustomSetting2;
            
            Primary_Contact_Inactive_Profile_List__c newCustomSetting3 = new Primary_Contact_Inactive_Profile_List__c();
            newCustomSetting3.Name = 'Profile Names 2';
            newCustomSetting3.profile__c = '\'ZTS TWN Business Administrator\',\'ZTS IDN Business Administrator\',\'ZTS IND Business Administrator\', \'ZTS CHN Business Administrator\',\'Intll Business Administrator\', \'ZTS CLAR SoLA Business Administrator\'';
            insert newCustomSetting3;
            
            List<ZTS_EU_KOL__c>acPrimaryRecord=ZTS_EU_DataUtilityTest.createKolRecord(1);
            List<ZTS_EU_KOL__c> finalList= new List<ZTS_EU_KOL__c>();
            List<ZTS_EU_KOL__c> finalDeleteList= new List<ZTS_EU_KOL__c>();
            insert acPrimaryRecord;
            
            
            
            for(ZTS_EU_KOL__C kol: acPrimaryRecord)
            {
                ZTS_EU_KOL__c ztskol = new ZTS_EU_KOL__c();
                ztskol.id = kol.id;
                ztskol.ZTS_EU_Status__c = 'Secondary Target KOL';
                ztskol.ZTS_EU_Speaker__c = true;
                finalList.add(ztskol);
            }
            UtilityService.kolRun = true;
            update finalList;
            
            for(ZTS_EU_KOL__C kolDelete: acPrimaryRecord)
            {
                ZTS_EU_KOL__c ztskolDelete = new ZTS_EU_KOL__c();
                ztskolDelete.id = kolDelete.id;
                finalDeleteList.add(ztskolDelete);
            }
            UtilityService.kolRun = true;
            delete finalDeleteList;
        }
    }
    
    static testMethod void validate_ZTS_EU_KOL2() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            Primary_Contact_Inactive_Profile_List__c newCustomSetting = new Primary_Contact_Inactive_Profile_List__c();
            newCustomSetting.Name = 'Profile Names';
            newCustomSetting.profile__c = '\'ZTS AUT Business Administrator\';\'ZTS BAL Business Administrator\';\'ZTS BGR Business Administrator\';\'ZTS BNLX Business Administrator\';\'ZTS EGY Business Administrator\';\'ZTS ESP Business Administrator\';\'ZTS FIN Business Administrator\';\'System Administrator\'';
            insert newCustomSetting;
            
            Primary_Contact_Inactive_Profile_List__c newCustomSetting2 = new Primary_Contact_Inactive_Profile_List__c();
            newCustomSetting2.Name = 'Profile Names 1';
            newCustomSetting2.profile__c = '\'ZTS FRA Business Administrator\';\'ZTS UK Business Administrator\';\'ZTS ITA Business Administrator\',\'Integration Profile\',\'ZTS KOR Business Administrator\',\'ZTS THA Business Administrator\',\'ZTS PHL Business Administrator\',\'ZTS VNM Business Administrator\'';
            insert newCustomSetting2;
            
            Primary_Contact_Inactive_Profile_List__c newCustomSetting3 = new Primary_Contact_Inactive_Profile_List__c();
            newCustomSetting3.Name = 'Profile Names 2';
            newCustomSetting3.profile__c = '\'ZTS TWN Business Administrator\',\'ZTS IDN Business Administrator\',\'ZTS IND Business Administrator\', \'ZTS CHN Business Administrator\',\'Intll Business Administrator\', \'ZTS CLAR SoLA Business Administrator\'';
            insert newCustomSetting3;
            //CustomSettingService.checkIfTriggerIsForBypass('Test_Class');
            
            list<ZTS_EU_KOL__c> lstZTS = new list<ZTS_EU_KOL__c>();
            
            List<ZTS_EU_KOL__c>acPrimaryRecord=ZTS_EU_DataUtilityTest.createKolRecord(1);
            List<ZTS_EU_KOL__c> finalList= new List<ZTS_EU_KOL__c>();
            List<ZTS_EU_KOL__c> finalDeleteList= new List<ZTS_EU_KOL__c>();
            insert acPrimaryRecord;
            
            
            
            for(ZTS_EU_KOL__C kol: acPrimaryRecord)
            {
                ZTS_EU_KOL__c ztskol = new ZTS_EU_KOL__c();
                ztskol.id = kol.id;
                ztskol.ZTS_EU_Status__c = 'Secondary Target KOL';
                ztskol.ZTS_EU_Speaker__c = true;
                finalList.add(ztskol);
            }
            UtilityService.kolRun = true;
            update finalList;
            
            for(ZTS_EU_KOL__C kolDelete: acPrimaryRecord)
            {
                ZTS_EU_KOL__c ztskolDelete = new ZTS_EU_KOL__c();
                ztskolDelete.id = kolDelete.id;
                finalDeleteList.add(ztskolDelete);
            }
            UtilityService.kolRun = true;
            delete finalDeleteList;
            Test.startTest();
            //ZTS_EU_KOL__c zz = [select id from ZTS_EU_KOL__c where isdeleted=true AND ZTS_EU_Market__c != 'United States' limit 1];
            //undelete zz;
            
            
            
            List<ZTS_EU_KOL__c> objundel =ZTS_EU_DataUtilityTest.createKolRecord(1);
            System.debug('XXXXX' +objundel);
            
            for(ZTS_EU_KOL__c zz:objundel){
                System.debug('IDIDX' + zz.id);
                lstZTS.add(zz);
                //delete zz;
                //undelete zz;
            }
            
            insert lstZTS;
            delete lstZTS;
            undelete lstZTS;
            //system.debug('IDIDID'+ lstZts.);
            
            //delete objundel;
            //undelete objundel; 
            Test.stopTest();
        }
    }
}