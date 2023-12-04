/*

Test class for ZTS_EU_submit_CR_record
* @ModifiedBy   : Mohamed Seliman
* @ModifiedOn   : 8/26/2020
* @Description  : Test class for INTLZTS_EU_RequestTriggerService.
*/

@isTest(seeAllData = false)
public with sharing class ZTS_EU_submit_CR_recordTest {

    public static testMethod void testMethod1(){
    
        Group newGroup = new Group();
        newGroup.Name = 'Change Request Queue';
        newGroup.Type = 'Queue';
        insert newGroup;
        
        
        List<Account> acclist = ZTS_EU_DataUtilityTest.createAccountRecord(1);
        acclist[0].ZTS_EU_Zip_Postal_Code__c = '12345';
        acclist[0].BillingPostalCode = '12345';
        acclist[0].BillingCity = 'Boca Raton';
        acclist[0].BillingState = 'Florida';
        acclist[0].BillingStreet = 'Elm Lane';
        acclist[0].ZTS_EU_Market__c = 'United States';
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        System.runAs(usr){
            insert acclist;
        }
        
        ZTS_EU_Request__c req = new ZTS_EU_Request__c();
        req.ZTS_EU_Account_To_Be_Changed__c = acclist[0].Id;
        req.ZTS_EU_Comments__c = 'test';
        req.ZTS_EU_Requestor__c = Userinfo.getuserId();
        req.ZTS_EU_Status__c = 'Accepted';
        req.ZTS_EU_Object_Type__c = 'Account';
        insert req;
        
        List<ZTS_EU_Request__c> reqList = new List<ZTS_EU_Request__c>();
        reqList.add(req);
        
        Map <Id, ZTS_EU_Request__c> newMap = new Map <Id, ZTS_EU_Request__c>();
        Map <Id, ZTS_EU_Request__c> oldMap = new Map <Id, ZTS_EU_Request__c>();
        
        newMap.put(req.Id, req);
        
        
        QueueSobject mappingObject = new QueueSobject(QueueId = newGroup.Id, SobjectType = 'ZTS_EU_Request__c');
        System.runAs(new User(Id = UserInfo.getUserId()))
        {insert mappingObject;}
        
        ZTS_EU_Request__c reqFetch = [Select Id, ZTS_EU_Status__c, OwnerId, ZTS_EU_Requestor__c from ZTS_EU_Request__c where Id =: req.Id];
        reqFetch.ZTS_EU_Status__c = 'Rejected';
        oldMap.put(reqFetch.Id, reqFetch);
        
        ZTS_EU_submit_CR_record.submitRecord(req.Id);
        
        
        ZTS_EU_submit_CR_record.updateCRRecord(reqList, newMap, oldMap);
    }
    

}