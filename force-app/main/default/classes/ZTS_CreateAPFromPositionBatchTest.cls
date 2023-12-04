@isTest
public class ZTS_CreateAPFromPositionBatchTest {
    static TestMethod void ZTS_CreateAPFromPositionmethod (){
        
        ZTS_DataUtilityTest.activateTriggerSettings();
        ZTS_DataUtilityTest.insertZoetisSettings();
        
        //Test account creation
        List<Account> acclist=ZTS_DataUtilityTest.createAccountRecord(1);
        insert acclist;
        
        //Test custom territory creation
        List<ZTS_EU_Territory__c> customterrList=ZTS_DataUtilityTest.createCustomTerritory(1);
        insert customterrList;        
        
        //Create position
        List<ZTS_EU_Position__c> position= ZTS_DataUtilityTest.createUserTerritory(customterrList);
        insert position;
        
        //Create AT
        List<ZTS_AccountTerritory__c> accterr=ZTS_DataUtilityTest.createAccountTerritory(acclist, customterrList);
        insert accterr;
        
        
        //Start Test
        Test.startTest();
        List<ZTS_EU_Position__c> positionlst =[SELECT Id, ZTS_EU_Territory__c, ZTS_User_Territory_Uniq_Key__c, Name, 	ZTS_Processed__c, ZTS_End_Date__c, ZTS_EU_Employee__c, ZTS_ChangeFlag__c FROM ZTS_EU_Position__c];
        ZTS_CreateAPFromPositionBatch actm_usr_batch=new ZTS_CreateAPFromPositionBatch(positionlst);
        String batchid=Database.executeBatch(actm_usr_batch);
        System.assert(batchid!=null,'ZTS_CreateAPFromPositionBatch failed to execute');
        Test.stopTest();        
       	//Test ends
        
        /*List<ZTS_AccountTerritory__c> accterrlist2=[SELECT Id,ZTS_US_NARC_ID__c from ZTS_US_AccountTerritory__c WHERE ZTS_US_Account__c IN :acclist ];
        ZTS_TerritoryManager.getNARCIDs(accterrlist2);   */     
      	Integer acctmCount=[SELECT COUNT() FROM  ZTS_EU_Account_Position__c WHERE CreatedDate=TODAY AND ZTS_EU_Account__c IN :acclist];
        System.assert(acctmCount>0,'No Account team exists');
        
    }
        

}