/**
 * @description       : Test class for Custom Edit Page for Save and submit button (DEF-00723) (Controller - changeRequestEditSubmitController & Page - ChangeRequestEditSubmitPage)
 * @author            : Sohil Shah @ CloudSense
 * @group             : 
 * @last modified on  : 03-22-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   08-08-2015   Sohil Shah @ CloudSense     Initial Version
 * 1.1   03-22-2022   Ethan Hirsch @ Zoetis Inc   Change Contact Creation to fix Unit Test errors
**/
@isTest
public class changeRequestEditSubmitControllerTest {
    
    static final String US_USER_FN = 'usUser';
    
    @TestSetup
    static void makeData(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = US_USER_FN;
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            Account acc = new Account(Name = 'test Account',
                                      ZTS_EU_Zip_Postal_Code__c = '12345',
                                      BillingPostalCode = '12345',
                                      BillingCity = 'Boca Raton',
                                      BillingState = 'Florida',
                                      BillingStreet = 'Elm Lane',
                                      ZTS_EU_Market__c = 'United States');
            
            insert acc;
            
            Contact con = ZTS_EU_DataUtilityTest.createContactRecord(1)[0];
            con.ZTS_EU_Contact_Status__c = 'Active';
            con.AccountId = acc.id;
            con.FirstName = 'Test';
            con.LastName = 'Contact';
            con.ZTS_EU_Profession__c = 'Other';
            insert con;
            
        }
    }
    
    @IsTest
    static void TestchangeRequestEditSubmitController() {
        
        User usr = [SELECT Id FROM User WHERE FirstName = :US_USER_FN];
        
        System.runAs(usr)
        {
            Account acc = [SELECT Id FROM Account LIMIT 1];
            Contact con = [SELECT Id FROM Contact LIMIT 1];
            
            ZTS_EU_Request__c request = new ZTS_EU_Request__c(ZTS_EU_Account_To_Be_Changed__c = acc.id,ZTS_EU_Contact__c=con.id,ZTS_EU_Requestor__c =  UserInfo.getUserId(), ZTS_EU_Object_Type__c ='Contact' );
            insert request;
            PageReference cancelPR;
            
            test.startTest();
            ApexPages.currentPage().getParameters().put('id',request.id);
            ApexPages.StandardController controller = new ApexPages.StandardController(request);
            changeRequestEditSubmitController obj = new changeRequestEditSubmitController(controller);
            obj.UpdateCR();
            obj.updateandSumbit();
            cancelPR = obj.cancelCR(); 
            test.stopTest();
            
            System.assert(cancelPR.getUrl().substringAfterLast('/') == request.Id);
        }
    }
    
    @IsTest
    static void TestchangeRequestEditSubmitController1() {
        User usr = [SELECT Id FROM User WHERE FirstName = :US_USER_FN];
        
        System.runAs(usr)
        {
            Account acc = [SELECT Id FROM Account LIMIT 1];
            
            ZTS_EU_Request__c request = new ZTS_EU_Request__c();
            PageReference cancelPR;
            
            test.startTest();
            ApexPages.currentPage().getParameters().put('CF00Ni000000EHlmz_lkid',acc.id);
            ApexPages.StandardController controller = new ApexPages.StandardController(request);
            changeRequestEditSubmitController obj = new changeRequestEditSubmitController(controller);
            obj.UpdateCR();
            cancelPR = obj.cancelCR();
            test.stopTest();
            
            System.assert(cancelPR.getUrl().substringAfterLast('/') == acc.Id);
        }
    }
    
    @IsTest
    static void TestchangeRequestEditSubmitController2() {
        
        User usr = [SELECT Id FROM User WHERE FirstName = :US_USER_FN];
        
        System.runAs(usr)
        {
            Contact con = [SELECT Id FROM Contact LIMIT 1];
            
            ZTS_EU_Request__c request = new ZTS_EU_Request__c();
            PageReference cancelPR;
            
            test.startTest();
            ApexPages.currentPage().getParameters().put('CF00Ni000000EHln0_lkid',con.id);
            ApexPages.StandardController controller = new ApexPages.StandardController(request);
            changeRequestEditSubmitController obj = new changeRequestEditSubmitController(controller);
            
            obj.UpdateCR();
            cancelPR = obj.cancelCR(); 
            test.stopTest();
            
            System.assert(cancelPR.getUrl().substringAfterLast('/') == con.Id);
        }
    }
    
    @IsTest
    static void TestchangeRequestEditSubmitController3() {
        User usr = [SELECT Id FROM User WHERE FirstName = :US_USER_FN];
        
        System.runAs(usr)
        {
            ZTS_EU_Request__c request = new ZTS_EU_Request__c();
            PageReference cancelPR;
            Id requestId;
            
            test.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(request);
            changeRequestEditSubmitController obj = new changeRequestEditSubmitController(controller);
            obj.UpdateCR();
            //requestId = [SELECT Id FROM ZTS_EU_Request__c LIMIT 1].Id;
            cancelPR = obj.cancelCR(); 
            test.stopTest();
            
            System.assert(cancelPR.getUrl().substringAfterLast('/') == 'o');
        }
    }
    
    @IsTest
    static void TestchangeRequestEditSubmitController4() {
        User usr = [SELECT Id FROM User WHERE FirstName = :US_USER_FN];
        
        System.runAs(usr)
        {
            ZTS_EU_Request__c request = new ZTS_EU_Request__c();
            test.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(request);
            changeRequestEditSubmitController obj = new changeRequestEditSubmitController(controller);
            obj.insertCR();
            test.stopTest();
            
            List<ZTS_EU_Request__c> insertedRequest = [SELECT Id FROM ZTS_EU_Request__c];
            System.assert(insertedRequest.size() > 0, 'Request was not inserted');
        }
    }
    
    @IsTest
    static void TestchangeRequestEditSubmitController5() {
        
        User usr = [SELECT Id FROM User WHERE FirstName = :US_USER_FN];
        
        System.runAs(usr)
        {
            Account acc = [SELECT Id FROM Account LIMIT 1];
            Contact con = [SELECT Id FROM Contact LIMIT 1];
            
            ZTS_EU_Request__c request = new ZTS_EU_Request__c();
            test.startTest();
            ApexPages.currentPage().getParameters().put('CF00Ni000000EHlmz_lkid',acc.id);
            ApexPages.currentPage().getParameters().put('CF00Ni000000EHln0_lkid',con.id);
            ApexPages.StandardController controller = new ApexPages.StandardController(request);
            changeRequestEditSubmitController obj = new changeRequestEditSubmitController(controller);
            obj.insertCR();
            test.stopTest();
            
            List<ZTS_EU_Request__c> insertedRequest = [SELECT Id FROM ZTS_EU_Request__c];
            System.assert(insertedRequest.size() > 0, 'Request was not inserted');
        }
    }
}