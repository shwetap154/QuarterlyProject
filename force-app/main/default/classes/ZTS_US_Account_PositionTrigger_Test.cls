/*******************************************************************************************************************************************
* File Name     :  ZTS_US_Account_PositionTrigger_Test
* Description   :           
* @author       :  Deloitte consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/16         Teresa             Created the Class.
*****************************************************************************************************************************************/

@isTest(SeeAlldata = True)
public class ZTS_US_Account_PositionTrigger_Test 
{   
    static testMethod void testInsertAccountPositon(){
        List<Account> acclist=ZTS_DataUtilityTest.createAccountRecord(2,6);
        for (Account acc : acclist) acc.ZTS_EU_Market__c = 'United States';
        List<Contact> conlist=ZTS_DataUtilityTest.createContactRecord(2);
        for (Contact con : conlist) con.ZTS_EU_Market__c = 'United States';
       // ZTS_DataUtilityTest.activateTriggerSettings();
        ZTS_DataUtilityTest.insertZoetisSettings() ;
        Database.insert(acclist);
        Database.insert(conlist);
        List<ZTS_EU_Territory__c> customterrList=ZTS_DataUtilityTest.createCustomTerritory(2);
        insert customterrList;
        
        List<ZTS_EU_Position__c> userterrlist= ZTS_DataUtilityTest.createUserTerritory(customterrList);
        insert userterrlist;
        
        List<ZTS_AccountTerritory__c> accterrlist=ZTS_DataUtilityTest.createAccountTerritory(acclist, customterrList);
        insert accterrlist;
        acclist=[SELECT Id, (SELECT ZTS_EU_Account__c,ZTS_Acc_Terr_Key__c,Name,ZTS_EU_Territory__c,ZTS_Territory_SF_ID__c FROM Accounts_Territory__r) FROM Account WHERE Id IN :acclist AND ZTS_EU_Market__c = 'United States'];
        Test.startTest();
       List<ZTS_EU_Account_Position__c> accPosList = [SELECT Id, VGP_Program_Owner__c FROM ZTS_EU_Account_Position__c WHERE ZTS_EU_Account__c IN :acclist];
        accPosList[0].VGP_Program_Owner__c = 'Primary';
        update accPosList; 
       Test.stopTest(); 
        
    }
    
    static testMethod void testDeleteAccountPositon(){
        List<Account> acclist=ZTS_DataUtilityTest.createAccountRecord(2,6);
        for (Account acc : acclist) acc.ZTS_EU_Market__c = 'United States';
        List<Contact> conlist=ZTS_DataUtilityTest.createContactRecord(2);
        for (Contact con : conlist) con.ZTS_EU_Market__c = 'United States';
        //ZTS_DataUtilityTest.activateTriggerSettings();
        ZTS_DataUtilityTest.insertZoetisSettings() ;
        Database.insert(acclist);
        Database.insert(conlist);
        List<ZTS_EU_Territory__c> customterrList=ZTS_DataUtilityTest.createCustomTerritory(2);
        insert customterrList;
        
        List<ZTS_EU_Position__c> userterrlist= ZTS_DataUtilityTest.createUserTerritory(customterrList);
        insert userterrlist;
        
        List<ZTS_AccountTerritory__c> accterrlist=ZTS_DataUtilityTest.createAccountTerritory(acclist, customterrList);
        insert accterrlist;
        acclist=[SELECT Id, (SELECT ZTS_EU_Account__c,ZTS_Acc_Terr_Key__c,Name,ZTS_EU_Territory__c,ZTS_Territory_SF_ID__c FROM Accounts_Territory__r) FROM Account WHERE Id IN :acclist AND ZTS_EU_Market__c = 'United States'];
        Test.startTest();
        acclist[0].VGP_Program_Owner__c = UserInfo.getFirstName()+''+UserInfo.getLastName();
        update acclist;
        List<ZTS_EU_Account_Position__c> accPosList = [SELECT Id, VGP_Program_Owner__c FROM ZTS_EU_Account_Position__c WHERE ZTS_EU_Account__c IN :acclist];
        accPosList[0].VGP_Program_Owner__c = 'Primary';
        update accPosList; 
        delete accPosList;
        Test.stopTest(); 
        
    }
    

}