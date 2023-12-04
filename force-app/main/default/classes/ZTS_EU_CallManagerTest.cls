/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_CallManagerTest
* Description   :           
* @author       :  Deloitte consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/14         Akanksha             Created the Class.
*****************************************************************************************************************************************/

@isTest
public class ZTS_EU_CallManagerTest 
{     
    static testMethod void validate_CallManager () 
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            Test.startTest();
            List<Call__c> calList = ZTS_EU_DataUtilityTest1.createCallRecord(1);
            List<Time_Out_of_Territory__c> totList= ZTS_EU_DataUtilityTest1.createToTOffFull(1);
            totList[0].ZTS_EU_Status__c='Planned';
            Map<Id,Call__c> mapcal=new Map<Id,Call__c>();
            ZTS_EU_CallManager cm= new ZTS_EU_CallManager();
            Map<Id,List<Time_Out_of_Territory__c>> maptot=new Map<Id,List<Time_Out_of_Territory__c>>();
            
            insert calList;
            system.debug('---calllist----------'+calList[0]+'----'+calList[0].CreatedBy.Id);
            List <Call__c> listcall=[Select Id,ZTS_EU_Account__c ,CreatedById,ZTS_EU_Start_Date_Time__c ,ZTS_EU_End_Date_Time__c ,ZTS_EU_Sub_Type__c  from Call__c where Id=:calList[0].Id AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
            System.debug('------------------------'+listcall[0].CreatedById);
            mapcal.put(listcall[0].Id,listcall[0]);
            insert totList;
            cm.Ma(mapcal);
            Test.stopTest();
        }
    }
}