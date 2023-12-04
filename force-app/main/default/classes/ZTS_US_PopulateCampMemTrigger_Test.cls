@isTest (SeeAlldata = False)
public with sharing class ZTS_US_PopulateCampMemTrigger_Test {


    static testMethod void validate_ZTS_US_PopulateCampMemTrigger() {
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
 
        System.runAs(usr)
        {
            List<Account> lstacnt = ZTS_DataUtilityTest.createAccountRecord(1);
            insert lstacnt;
            List<Contact> lstcont = ZTS_DataUtilityTest.createContactRecord(1);
            List<Contact> lstcontins = new List<Contact>();
            for(Contact con : lstcont){
                con.AccountId = lstacnt[0].id;
                con.ZTS_US_Phone_Opt_out__c = True;
                con.HasOptedOutOfEmail = True;
                con.ZTS_EU_Contact_Status__c = 'Active';
                lstcontins.add(con);
            }
            insert lstcontins;
            
            List<ZTS_EU_Affiliations__c> lstaccconafft = ZTS_DataUtilityTest.createAccConAffiliationRecord(1);
            List<ZTS_EU_Affiliations__c> lstaccconafftins = new List<ZTS_EU_Affiliations__c>();
            for(ZTS_EU_Affiliations__c accconaff : lstaccconafft){
                accconaff.ZTS_EU_Account__c = lstacnt[0].id;
                accconaff.ZTS_EU_Contact__c = lstcontins[0].id;  
                lstaccconafftins.add(accconaff);
            }
            //insert lstaccconafftins;
            
            List<Campaign> lstcamp = ZTS_DataUtilityTest.createCampaignRecord(1);
            List<Campaign> lstcampins = new List<Campaign>();
            for(Campaign camp : lstcamp){
                camp.Type = 'Email';
                camp.No_Batch__c =true;
                camp.Campaign_Name_English__c = 'Testing';
                lstcampins.add(camp);
            }
            insert lstcampins;
            List<ZTS_EU_Campaign_Account__c> lstcampacnt = ZTS_DataUtilityTest.createCampaignAccountRecord(1);
            List<ZTS_EU_Campaign_Account__c> lstcampAccntins = new List<ZTS_EU_Campaign_Account__c>();
            for(ZTS_EU_Campaign_Account__c camAccnt : lstcampacnt){
                camAccnt.ZTS_EU_Account__c = lstacnt[0].id;
                camAccnt.ZTS_EU_Campaign__c = lstcampins[0].id;
                lstcampAccntins.add( camAccnt);       
            }
            
            Test.startTest();
            insert lstcampAccntins;
            List<ZTS_EU_Campaign_Account__c> lstcampAccntupd = new List<ZTS_EU_Campaign_Account__c>();  
            for(ZTS_EU_Campaign_Account__c camaccnt : lstcampAccntins){
                camaccnt.ZTS_EU_Member_Status__c = 'Removed';
                lstcampAccntupd.add(camaccnt);
            }
            Update lstcampAccntupd;
            delete lstcampAccntupd;
            Test.Stoptest();
        }
    }
}