/*******************************************************************************************************************************************
* File Name     :  ZTS_US_ContactEditController_Test
* Description   :  Test class for  ZTS_US_ContactEditController
* @author       :  Cloudsense Inc.
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     1/25/17      Laxmikanth          Created the Class.

***************************************************************************************************************/

@isTest 
public class ZTS_US_ContactEditController_Test{
  public static testMethod void ContactRedirect_Test() 
  {
    ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
    User usr = new User();
    usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
    usr.FirstName = 'davidsUser';
    usr.zts_eu_market__c = 'United Kingdom';
    insert usr;

    System.runAs(usr)
    {
      Test.startTest();
      //Creating the test data
      List<ZTS_Events__c> Eve = ZTS_EU_DataUtilityTest.createEvents(2);
      for (ZTS_Events__c event : Eve) event.ZTS_EU_Market__c = 'Italy';
      insert Eve ;
      List<Account> Acc = ZTS_EU_DataUtilityTest.createAccountRecord(2);
      insert Acc;
      List<Contact> conList = ZTS_EU_DataUtilityTest.createContactRecord(2);
      conList[1].AccountId =  Acc[1].id;
      conList[0].ZTS_EU_Market__c = 'United Kingdom';
      conList[1].ZTS_EU_Market__c = 'United Kingdom';
      insert conList;
      PageReference pgRef = Page.ZTS_US_ContactEditPage;
      Test.setCurrentPageReference (pgRef);
      //ApexPages.currentPage().getParameters().put('isError',eve[0].id); 
      ApexPages.currentPage().getParameters().put('eventId',eve[0].id); 
      //ApexPages.currentPage().getParameters().put('records',acc[0].id);     


      /*List<ZTS_US_Event_Account__c> eveaccList = new List<ZTS_US_Event_Account__c>();
            
      for(Integer i=0;i<2;i++) {
        ZTS_US_Event_Account__c eveacc = new ZTS_US_Event_Account__c();         
        eveacc.ZTS_US_Event_Account__c =  Acc[i].id;
        eveacc.ZTS_US_Events__c = eve[0].id;
        eveaccList.add(eveacc);
      }    

      insert eveaccList;*/

      ZTS_US_Event_Account__c eventacc = new ZTS_US_Event_Account__c();
      eventacc.ZTS_US_Event_Account__c = Acc[0].id;
      eventacc.ZTS_US_Events__c = eve[0].id; 
      insert eventacc;  

      ZTS_US_Event_Account__c eventacc1 = new ZTS_US_Event_Account__c();
      eventacc1.ZTS_US_Event_Account__c = Acc[1].id;
      eventacc1.ZTS_US_Events__c = eve[0].id; 
      insert eventacc1;  

      ZTS_US_Event_Invitee__c eveinvite = new ZTS_US_Event_Invitee__c();
      eveinvite.ZTS_US_Contact__c = conList[0].id;
      eveinvite.ZTS_US_Event__c = eve[0].id; 
      insert eveinvite;


      ZTS_US_ContactEditController Target = new ZTS_US_ContactEditController();
      ApexPages.StandardSetController controller = Target.con;

      Target.sortExpression = '';
      ZTS_US_ContactEditController.ContactWrapper Wrapper = new ZTS_US_ContactEditController.ContactWrapper();
      ZTS_US_ContactEditController.ContactWrapper Wrapper2 = new ZTS_US_ContactEditController.ContactWrapper(conList[0]);
      Wrapper2.checked = true;
      Wrapper.checked = true;

      Target.getContacts();
      Target.getCategories();
      Target.setSortDirection('Name');
      String s = Target.sortExpression;
      Target.getSortDirection();
      Target.first();
      Target.last();
      Target.previous();
      Target.next();
      Target.PageNumber = 5;
      integer page_no = Target.PageNumber;
      Target.hasNext = true;
      boolean has = Target.hasNext;
      Target.hasPrevious = true;
      boolean hasp = Target.hasPrevious;

      Pagereference P3 = Target.executeSearch();
      Pagereference P1 = Target.cancel();
      Pagereference P2 = Target.ViewSortData();
      list<ZTS_US_ContactEditController.ContactWrapper> lstadd = new  list<ZTS_US_ContactEditController.ContactWrapper>();
      lstadd.add(Wrapper);

      Pagereference P = Target.SaveAcc();
      test.stoptest();
    }
  }
}