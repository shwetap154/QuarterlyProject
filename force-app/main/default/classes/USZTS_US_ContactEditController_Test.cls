/*******************************************************************************************************************************************
* File Name     :  USZTS_US_ContactEditController_Test
* Description   :  Test class for  USZTS_US_ContactEditController
* @author       :  Cloudsense Inc.
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     1/25/17      Laxmikanth          Created the Class.
* 1.1     4/12/22      Aritra(Cognizant)   Updated the Class.
***************************************************************************************************************/

@isTest 
public class USZTS_US_ContactEditController_Test{


  public static testMethod void ContactRedirect_Test() {
        Test.startTest();
        //Creating the test data
       List<ZTS_Events__c> Eve = ZTS_DataUtilityTest.createEvents(2);
       for (ZTS_Events__c e : Eve) e.ZTS_EU_Market__c = 'United States';
       insert Eve ;
       List<Account> Acc = ZTS_DataUtilityTest.createAccountRecord(2);
      for (Account a : Acc) a.ZTS_EU_Market__c = 'United States';

        insert Acc;
       List<Contact> conList = ZTS_DataUtilityTest.createContactRecord(2);
      for (Contact c : conList) c.ZTS_EU_Market__c = 'United States';
       conList[1].AccountId =  Acc[1].id;
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
    
       
       USZTS_US_ContactEditController Target = new USZTS_US_ContactEditController();
       ApexPages.StandardSetController controller = Target.con;
       
       Target.sortExpression = '';
       USZTS_US_ContactEditController.ContactWrapper Wrapper = new USZTS_US_ContactEditController.ContactWrapper();
       USZTS_US_ContactEditController.ContactWrapper Wrapper2 = new USZTS_US_ContactEditController.ContactWrapper(conList[0]);
        Wrapper2.checked = true;
        Wrapper.checked = true;
       Target.executeSearch();
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
       
       Pagereference P1 = Target.cancel();
       Pagereference P2 = Target.ViewSortData();
       list<USZTS_US_ContactEditController.ContactWrapper> lstadd = new  list<USZTS_US_ContactEditController.ContactWrapper>();
       lstadd.add(Wrapper);
       
       Pagereference P = Target.SaveAcc();
      test.stoptest();
         }
         
       
         }