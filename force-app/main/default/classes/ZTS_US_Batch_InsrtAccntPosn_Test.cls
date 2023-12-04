/****************************************************************************************************
* File Name     :  ZTS_US_Batch_InsrtAccntPosn_Test
* Description   :  This is the test class for ZTS_US_Batch_InsrtAccntPosn class.                          

* @author       :   Tanmoy Bardhan (Cognizant Technology Solutions)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     16th-Feb-17   Tanmoy             Created the class.

******************************************************************************************************/

@isTest
public class ZTS_US_Batch_InsrtAccntPosn_Test {
	static testMethod void testBatchMethod(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            Integer count = [SELECT COUNT() FROM ZTS_EU_Account_Position__c];
            /* Insert test data for Account object */
            Account acc = new Account(Name = 'Test',Type = 'Administration', ZTS_EU_TSF_PBC__c = 'AUT-TER-CA-AM-14;AUT-TER-CA-AM-11;AUT-TER-LV-AM-12;AUT-TER-CA-AM-12;ALB-TER-ALL-BUD-1',
                    ZTS_EU_Market__c='United Kingdom',
                    Practice_Management_Software__c = 'Other',
                    Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                    ZTS_EU_Zip_Postal_Code__c = '12345');
            Insert acc;
            
            /* Insert test data for ZTS_EU_Territory__c object*/ 
            ZTS_EU_Territory__c terr = new ZTS_EU_Territory__c(Name = 'ALB-TER-ALL-BUD-1',ZTS_EU_Market__c = 'India',
                                                            ZTS_EU_Is_Assigned__c = False,ZTS_EU_Need_syncing__c=False);
            Insert terr;
            
            /* Insert test data for ZTS_EU_Position__c object */
            ZTS_EU_Position__c pos = new ZTS_EU_Position__c(ZTS_EU_Territory__c = terr.Id);
            Insert pos;
            
            List<string> accID = new List<string>();
            accID.add(acc.Id);
            
            Map<String, string> TerrIdNameMap = new Map<String, string>();
            List<ZTS_EU_Territory__c> custList = [Select ID,Name from ZTS_EU_Territory__c WHERE ZTS_EU_Market__c != 'United States'];
            for (ZTS_EU_Territory__c zt : custList){
                TerrIdNameMap.put(zt.ID, zt.Name);
            }
            
            List<ZTS_EU_Position__c> posList = [Select ZTS_EU_Territory__c from ZTS_EU_Position__c];

            List<Account> accList = [select id, name,ZTS_EU_TSF_PBC__c  from account where ID =:acc.Id AND ZTS_EU_Market__c != 'United States'];
            Map<String, list<account>> AccountTerrMap = new Map<String, list<account>>();
            AccountTerrMap.put('AUT-TER-CA-AM-14', accList);
        
            
            Test.startTest();
            ZTS_US_Batch_InsrtAccntPosn insAccPos = new ZTS_US_Batch_InsrtAccntPosn(accID,TerrIdNameMap,posList);
            Database.executeBatch(insAccPos);
            Test.stopTest();
            System.assert([SELECT COUNT() FROM ZTS_EU_Account_Position__c] > count);
        }
    }
}