@isTest
public class ZTS_EU_DeletechildRecordsOfAccountsTest
{
    public static testMethod void TestDeleteAPs()
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        List<Account> acclist = new List<Account>();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Type = 'Administration';
        acc.ZTS_EU_Sub_Type__c = 'Academic';
        acc.ZTS_EU_Market__c='Brazil';
        acc.ZTS_EU_VAT_Code__c = '111';
        acc.Practice_Management_Software__c = 'Other';
        acc.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
        acc.ZTS_EU_Zip_Postal_Code__c = '12345';
        acclist.add(acc);
        ZTS_EU_Account_Position__c app;
        System.runAs(usr)
        {
            insert acclist;

            ZTS_EU_Territory__c terr = ZTS_DataUtilityTest.createCustomTerritory(1)[0];
            insert terr;
            
            ZTS_EU_Position__c pos = new ZTS_EU_Position__c();
            pos.ZTS_EU_Territory__c = terr.Id;
            insert pos;

            app = new ZTS_EU_Account_Position__c(ZTS_EU_Account__c = acclist[0].id, ZTS_EU_Position__c = pos.id);
            insert app;
            
            ZTS_EU_Species_Product__c p = new ZTS_EU_Species_Product__c();
            p.Name = 'Test BU';
            p.ZTS_EU_Market__c  = 'Brazil';
            p.ZTS_EU_Type__c = 'Business Unit';
            insert p;
            
            ZTS_EU_Species__c spec = new ZTS_EU_Species__c();
            spec.ZTS_EU_Market__c = 'Brazil';
            spec.Name = 'Test Species';
            spec.ZTS_EU_Business_Unit__c = p.Id;
            spec.ZTS_EU_Species__c = 'Test';
            insert spec;
                    
            ZTS_EU_Account_Species_Potential__c asc1 = new ZTS_EU_Account_Species_Potential__c();
            asc1.ZTS_EU_Animal_Consultations_new__c=10;
            asc1.ZTS_EU_Animals_Consultations_actual__c=10;
            asc1.ZTS_EU_Species_Potential__c = spec.Id;
            asc1.Account__c = acclist[0].Id;
            asc1.CurrencyIsoCode = 'BRL';
            insert asc1;
        }
        test.startTest();
        ZTS_EU_DeletechildRecordsOfAccounts.deleteChildRecordsOfAccountOnMerge(acclist);
         Database.delete(app, false);  
        test.stopTest();
    }
}