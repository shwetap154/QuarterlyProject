/*******************************************************************************************************************************************
* File Name     :  ZTS_US_AddAccountRedirect_Test
* Description   :  Test class for ZTS_US_AddAccountRedirect
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/15         Mukta Sachdeva       Created the Class.

***************************************************************************************************************/


@isTest(SeeAllData=false) 
public class ZTS_US_AddAccountRedirect_Test{


  public static testMethod void ZTS_US_targetAccountNARCController_Test() {
        Test.startTest();
        //Creating the test data
       List<ZTS_Events__c> Eve = ZTS_DataUtilityTest.createEvents(2);
        insert Eve ;
       List<Account> Acc = ZTS_DataUtilityTest.createAccountRecord(2);
       PageReference pgRef = Page.ZTS_US_Add_Account_Redirect;
       Test.setCurrentPageReference (pgRef);
       ApexPages.currentPage().getParameters().put('isError',eve[0].id); 
           
    
       ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(Eve[0]);
       ZTS_US_AddAccountRedirect Target = new ZTS_US_AddAccountRedirect (controller);
       Pagereference P = Target.saveEventAccount();
        Pagereference P1 = Target.fetchIDAndSave();
       
      test.stoptest();
         }
         
       public static testMethod void ZTS_US_targetAccountNARCController_Negativetest() {
        Test.startTest();
        //Creating the test data
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
       List<ZTS_Events__c> Eve = ZTS_DataUtilityTest.createEvents(2);
        System.runAs(usr)
        {
        	insert Eve ;
        }
       List<Account> Acc = ZTS_DataUtilityTest.createAccountRecord(2);
       System.runAs(usr)
       {
       		insert Acc;  
       }
       PageReference pgRef = Page.ZTS_US_Add_Account_Redirect;
       Test.setCurrentPageReference (pgRef);
       ApexPages.currentPage().getParameters().put('eventId',eve[0].id); 
        ApexPages.currentPage().getParameters().put('records',acc[0].id);     
        
       ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(Eve[0]);
       ZTS_US_AddAccountRedirect Target = new ZTS_US_AddAccountRedirect (controller);
       Target.source = 'account';
       Pagereference P = Target.saveEventAccount();
        Pagereference P1 = Target.fetchIDAndSave();
       
      test.stoptest();
         }   
         
         
}