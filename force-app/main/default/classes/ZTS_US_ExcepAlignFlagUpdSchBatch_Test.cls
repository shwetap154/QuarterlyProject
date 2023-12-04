/*******************************************************************************************************************************************
* File Name     :  ZTS_US_ExcepAlignFlagUpdSchBatch_Test
* Description   :           
* @author       :  Deloitte consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/15         Chandra            Created the Class.
*****************************************************************************************************************************************/

@isTest(SeeAlldata = False)
public class ZTS_US_ExcepAlignFlagUpdSchBatch_Test 
{   
    static testMethod void ZTS_US_ExcepAlignFlagUpdSchBatchs(){
    ZTS_DataUtilityTest.activateTriggerSettings();

    List<Account> lstacnt = ZTS_DataUtilityTest.createAccountRecord(1);
    insert lstacnt;
    List<ZTS_EU_Territory__c> terrList = ZTS_DataUtilityTest.createCustomTerritory(1);
    insert terrList;
    List<ZTS_EU_Position__c> lstuserterr = ZTS_DataUtilityTest.createUserTerritory(terrList);
    insert lstuserterr;
    List<ZTS_EU_Account_Position__c> lstacntteam = ZTS_DataUtilityTest.createAccountTeam(lstacnt,lstuserterr);
    insert lstacntteam;
    List<ZTS_EU_Account_Position__c> theQuery = [SELECT Id, ZTS_EU_Account__c, ZTS_AccountTerritory__c, ZTS_US_Territory_ID__c FROM ZTS_EU_Account_Position__c WHERE 
                         ZTS_AccountTerritory__c='' AND ZTS_EU_Account__c!='' AND ZTS_US_Territory_ID__c!='' AND ZTS_EU_Market__c = 'United States'];
        test.startTest();

        ZTS_ExcepAlignFlagUpdateScheduleBatch batchObj = new ZTS_ExcepAlignFlagUpdateScheduleBatch();
        batchObj.start(null);
        String Id = Database.executeBatch( batchObj, 200);
        batchObj.execute(null,theQuery);
        ZTS_ExcepAlignFlagUpdateScheduleBatch.start();
        batchObj.finish(null);
        test.stopTest();
    }
    

}