/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_Chatter_Answers_Test
* Description   :  Test class for ChatterAnswers
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/14         Teresa           Created the Class.

***************************************************************************************************************/
@isTest
public with sharing class ZTS_EU_Chatter_Answers_Test {
    
    @isTest static void validate_ZTS_EU_Chatter_Answers_Test() {

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        System.runAs(usr)
        {
            String accountFN = 'Test';
            String accountLN = 'Account';
            String accountName = accountFN + ' ' + accountLN;
            
            ChatterAnswers chatAnswers = new ChatterAnswers();

            try{
                Test.startTest();
                String actualAccountId = chatAnswers.createAccount(accountFN,accountLN,UserInfo.getUserId());
                Test.stopTest();
                //System.assert(false, 'This should fail since there is no primary address info');
            }
            catch(Exception dex) {

                Integer numAccount = [SELECT count() FROM Account WHERE Name = :accountName];
    
                System.assertEquals(0, numAccount, 'No accounts should be created');
            }

        }
        
    }
}