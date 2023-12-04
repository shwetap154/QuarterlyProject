@isTest
private class SL_FormLayoutHandlerTest { 

    @isTest 
    private static void testMultipleMethods() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        System.runAs(usr)
        {
            SL_FormLayoutHandler.dataSetup();
        }
        
        List<Account> lstfetchAccount = [SELECT Id, Name FROM Account];
        List<Contact> lstfetchContact = [SELECT Id, LastName, AccountId FROM Contact];

        SL_FormLayoutHandler.getCurrentRecord('Contact', 'Name', lstfetchContact[0].Id, 'AccountId', true);

        String strSobjName = SL_FormLayoutHandler.getSobjName('Contact', 'AccountId', true);
        System.assertEquals('Account', strSobjName);

        SL_FormLayoutHandler.getCurrentRecord('Contact', 'Name', lstfetchContact[0].Id, 'AccountId', false);
        SL_FormLayoutHandler.getSobjName('Contact', 'AccountId', false);
        SL_FormLayoutHandler.describeFieldSet('Contact','SL_ContactFieldSet', 'AccountId', false);
        SL_FormLayoutHandler.describeFieldSet('Contact','SL_ContactFieldSet', 'AccountId', true);
        SL_FormLayoutHandler.describeFieldSet('Account','SL_AccountFieldSet', 'OwnerId', true);
                
        Schema.sObjectType expected = Schema.Account.getSObjectType();
        Map<String, Schema.SObjectField> fMap = expected.getDescribe().Fields.getMap();
        SL_FormLayoutHandler.getselectOptions('Ownership',fMap);
        SL_FormLayoutHandler.updateRecord('Account', '[{"Id":"' + lstfetchAccount[0].Id + '", "Name": "updated Account"}]');
        SL_FormLayoutHandler.updateRecord('Test', '[{"Id":"' + lstfetchAccount[0].Id + '", "Name": "updated Account"}]');
        Set<String> setFields = SL_FormLayoutHandler.getCreatableFields('Account');  
    }
}