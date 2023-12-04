@isTest(seeAllData = false)
public class ZTS_US_UpdateAccountTerritoryShareBaTest {

    static testmethod void testBatch(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        List<Account> acc = ZTS_DataUtilityTest.createAccountRecord(1);
        System.runAs(usr)
        {
            insert acc;

        }
        
        
        List<ZTS_EU_Territory__c> terr = ZTS_DataUtilityTest.createCustomTerritory(1);
        for(ZTS_EU_Territory__c t : terr){
            t.ZTS_EU_Terr_SFID__c = '01Ii0000001uVBB';
        }
        insert terr;
        
        List<ZTS_AccountTerritory__c> aTerr = ZTS_DataUtilityTest.createAccountTerritory(acc,terr);
        for(ZTS_AccountTerritory__c at : aTerr){
            at.ZTS_ChangeFlag__c = 'Insert';
        }
        insert aTerr;
        
        ZTS_US_UpdateAccountTerritoryShareBatch.executeBatch(1);    
    }
}