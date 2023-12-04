/**
 * @description       : Test Class for ContactAuraCtrl
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : 
 * @last modified on  : 06-24-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   03-08-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 * 1.1   06-09-2021   Aritra @ Cognizant 			 Added new testmethod 'getUserFieldsTest'(SC-008687)
**/
@isTest
private class ContactAuraCtrlTest {
	@TestSetup
	static void setup(){
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;

        System.runAs(intlUsr) {
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            List<State_Country__c> stateCountryList = new List<State_Country__c>();
            List<Account> accountList = new List<Account>();    
            TestDataFactory.createVetSaveMarket_UK('United Kingdom',true);
            
            State_Country__c stateCountryUK = TestDataFactory.createStateCountry('United Kingdom','County Down',false);
            stateCountryList.add(stateCountryUK);
            insert stateCountryList;

            Account acct = TestDataFactory.createAccount_EU('UK Test Account',stateCountryUK.Id,false);
            insert acct;
        }
    }
	static testMethod void getPrepopulatedFieldsTest(){
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        Id scId = [SELECT Id FROM State_Country__c LIMIT 1].Id;
        String response = ContactAuraCtrl.getPrepopulatedFields(accountId);
        System.assert(response.startsWith('AccountId='+accountId),'Response should Start With Account Id');
        System.assert(response.contains('ZTS_EU_State_County__c='+scId),'Response should contain State Country Id');
    }

    static testMethod void getAccountInfo(){
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        Account acct = ContactAuraCtrl.getAccountInfo(accountId);
        System.assertEquals('UK Test Account', acct.Name, 'Should Find UK Test Account');
    }
    static testMethod void getUserFieldsTest(){
        Id userId = UserInfo.getUserId();
        String userMarket = [SELECT Id,ZTS_EU_Market__c FROM User WHERE Id =: userId LIMIT 1].ZTS_EU_Market__c;
        String response2 = ContactAuraCtrl.getUserFields();
        System.assert(response2.contains('ZTS_EU_Market__c='+userMarket),'Response should contain users Market name');
    }
}