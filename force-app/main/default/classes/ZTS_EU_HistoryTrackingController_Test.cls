/**
 * @description       : Test class for  ZTS_EU_HistoryTrackingController
 * @author            : Sunil @ Unknown
 * @group             : 
 * @last modified on  : 07-26-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-11-2014   Sunil @ Unknown             Initial Version
 * 1.1   07-26-2022   Ethan Hirsch @ Zoetis Inc   Remove creation of Affiliation in 
 *                                                ZTS_EU_HistoryTrackingController_Test1. This is created automatically now.
**/
@istest(seeAllData=false)
public class ZTS_EU_HistoryTrackingController_Test{

    public static testMethod void ZTS_EU_HistoryTrackingController_Test1(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            //Creating Test Data
            Account acc = new Account();         
            acc.name = 'Test Account';
            acc.Type = 'Farm';
            acc.ZTS_EU_Sub_Type__c = 'Beef';
            acc.ZTS_EU_Address_Line_1__c = 'Test Address Line';
            acc.ZTS_EU_City__c = 'Test City';
            acc.ZTS_EU_Zip_Postal_Code__c = 'LD';         
            acc.ZTS_EU_Main_Phone__c='9876789876';
            acc.CurrencyIsoCode='EUR';
            acc.ZTS_EU_Market__c='United Kingdom';
            acc.ZTS_EU_Vetsave_ID__c='200';
            acc.ZTS_EU_Vetsave_HO_ID__c='56';
            INSERT acc;
            
            State_Country__c Cont = new State_Country__c();
            Cont.ZTS_EU_Country__c ='Spain';
            Cont.ZTS_EU_uniqueCOUNTY__c = '!@#ADSFD';
            INSERT Cont;
                
            Contact con = new Contact(); 
            con.firstname='Test First';
            con.lastname = 'Test Contact'; 
            con.ZTS_EU_Speaker_Flag__c=true;
            con.Accountid = acc.id;
            con.ZTS_EU_Market__c= '';
            con.ZTS_EU_Country__c ='Spain';
            con.ZTS_EU_State_County__c = Cont.id;
            INSERT con;
            
            /*
            con.ZTS_EU_Market__c = 'Netherlands';
            UPDATE con;
            
            affl.ZTS_EU_Account_influence__c = 'Low';
            affl.ZTS_EU_Commitment_Level__c = 'Passive';
            UPDATE affl;
            
            acc.ZTS_EU_City__c = 'Test City123';
            UPDATE acc;
            */
            //Instantiate Dummy history records as actual history records cannot be created in Unit Tests [Since the data is never actually committed to Database]
            //Then pass this dummy list to the controller method which will process it.
            List<AccountHistory> ah = new List<AccountHistory>{}; //OldValue, NewValue not writeable
            ah.add(new AccountHistory(AccountId=acc.Id, Field='ZTS_EU_City__c'));
            
            Test.startTest();
                PageReference pgRef = Page.ZTS_EU_HistoryTracking;         
                Test.setCurrentPageReference(pgRef);
                ApexPages.currentPage().getParameters().put('id',acc.id); 
                ZTS_EU_HistoryTrackingController ZTS = new ZTS_EU_HistoryTrackingController();
                //Call the method which processes History records and pass it the Dummy Account History list
                ZTS.populateHistoryLine(ah,'Account');
                ZTS_EU_HistoryTrackingController.objectHistoryLine Objline = new ZTS_EU_HistoryTrackingController.objectHistoryLine ();
                ID objIDs = acc.id;
                Schema.SObjectType token = objIds.getSObjectType();           
                Schema.DescribeSObjectResult dr = token.getDescribe();
                List<String> childNames=ZTS.getChildNames(dr);
            Test.stopTest();
        }
    }
    
    public static testMethod void ZTS_EU_HistoryTrackingController_Test2(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            Account acc = new Account();         
            acc.name = 'Test Account';
            acc.Type = 'Farm';
            acc.ZTS_EU_Sub_Type__c = 'Beef';
            acc.ZTS_EU_Address_Line_1__c = 'Test Address Line';
            acc.ZTS_EU_City__c = 'Test City';
            acc.ZTS_EU_Zip_Postal_Code__c = 'LD';         
            acc.ZTS_EU_Main_Phone__c='9876789876';
            acc.CurrencyIsoCode='EUR';
            acc.ZTS_EU_Market__c='United Kingdom';
            acc.ZTS_EU_Vetsave_ID__c='200';
            acc.ZTS_EU_Vetsave_HO_ID__c='56';
            INSERT acc;
          
            Test.startTest();
                PageReference pgRef = Page.ZTS_EU_HistoryTracking;         
                Test.setCurrentPageReference(pgRef);
                ApexPages.currentPage().getParameters().put('id',acc.id); 
                ZTS_EU_HistoryTrackingController ZTS = new ZTS_EU_HistoryTrackingController();
                ZTS_EU_HistoryTrackingController.objectHistoryLine Objline = new ZTS_EU_HistoryTrackingController.objectHistoryLine ();
            Test.stopTest();
        }
    }
}