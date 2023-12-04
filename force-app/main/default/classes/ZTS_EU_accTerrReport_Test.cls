@isTest
public with sharing class ZTS_EU_accTerrReport_Test {
    
    static testMethod void test_method() {
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;
        System.runAs(intlUsr) {
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            ZTS_EU_accTerrReport attr = new ZTS_EU_accTerrReport();
            attr.test_method();
            ZTS_EU_AddKeyMsgController akey = new ZTS_EU_AddKeyMsgController();
            akey.test_method();
            ZTS_EU_AddSampleDrop_Controller addsample = new ZTS_EU_AddSampleDrop_Controller();
            addsample.test_method();
            List<Account> acclst = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            insert acclst;
        }
        
    }
}