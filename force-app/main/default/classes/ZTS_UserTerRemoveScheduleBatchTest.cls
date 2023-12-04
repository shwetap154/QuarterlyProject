/*******************************************************************************************************************************************
* File Name     :  ZTS_UserTerRemoveScheduleBatchTest
* Description   :  Test class for ZTS_UserTerritoryRemoveScheduleBatch
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/15         Mukta Sachdeva       Created the Class.

***************************************************************************************************************/



@isTest(Seealldata = false)
private class ZTS_UserTerRemoveScheduleBatchTest{
    
    static testmethod void ZTS_UserTerRemoveScheduleBatchTest(){
        List<ZTS_EU_Territory__c> customterrList=ZTS_DataUtilityTest.createCustomTerritory(10);
        insert customterrList;
        
        List<ZTS_EU_Position__c> userterrlist= ZTS_DataUtilityTest.createUserTerritory(customterrList);
        insert userterrlist;
        
        for(ZTS_EU_Position__c ut:userterrlist){
            ut.ZTS_ChangeFlag__c=ZTS_GlobalConstants.CHANGE_FLAG_STATUS_DELETE;
             ut.ZTS_EU_Employee__c=null;
        }
        
        update userterrlist;
        
        Test.startTest();
            //Initialize your Scheduled Class
            Date d = system.today();
            Date d1 = system.today().addDays(1);
            ZTS_UserTerritoryRemoveScheduleBatch  SBE = new ZTS_UserTerritoryRemoveScheduleBatch(UserInfo.getSessionId(),d,d1);
            String S = ZTS_UserTerritoryRemoveScheduleBatch.start();
            String S1 = ZTS_UserTerritoryRemoveScheduleBatch.run();
            SchedulableContext sc;
            //Database.executeBatch(SBE);
            SBE.execute(sc);
        Test.stopTest();
        
        Integer ut_cnt=[SELECT COUNT() FROM ZTS_EU_Position__c];
        System.assert(ut_cnt==0,'UserTerritory records not deleted');
    }
}