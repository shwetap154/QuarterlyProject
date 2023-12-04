/*******************************************************************************************************************************************
* File Name     :  ZTS_US_AddContactRedirect_Test
* Description   :  Test class for  USZTS_US_AddContactRedirect
* Description   :  Test class for  USZTS_US_AddNewContactRedirect
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/15        Sonali Chhabria       Created the Class.

***************************************************************************************************************/

@isTest(SeeAllData=false) 
public class ZTS_US_AddContactRedirect_Test{


    public static testMethod void ContactRedirect_Test() {
        Test.startTest();
        //Creating the test data
        List<ZTS_Events__c> Eve = ZTS_DataUtilityTest.createEvents(2);
        for (ZTS_Events__c e : Eve) e.ZTS_EU_Market__c = 'United States';
        insert Eve ;
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        List<Account> Acc = ZTS_DataUtilityTest.createAccountRecord(2);
        System.runAs(usr)
        {
            insert Acc;  
        } 
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        List<Contact> conList = ZTS_DataUtilityTest.createContactRecord(2);
        conList[0].AccountId =  Acc[0].id;
        conList[0].ZTS_EU_Contact_Status__c = 'Active';
        conList[0].ZTS_EU_Market__c = 'United States';
        
        conList[1].AccountId =  Acc[1].id;
        conList[1].ZTS_EU_Contact_Status__c = 'Active';
        conList[1].ZTS_EU_Market__c = 'United States';
        System.runAs(usr)
        {
            insert conList; 
        }
        system.debug('conList=' + conList);
        
        ZTS_US_Event_Account__c eventacc = new ZTS_US_Event_Account__c();
        eventacc.ZTS_US_Event_Account__c = Acc[0].id;
        eventacc.ZTS_US_Events__c = eve[0].id; 
        insert eventacc;  
        
        ZTS_US_Event_Account__c eventacc1 = new ZTS_US_Event_Account__c();
        eventacc1.ZTS_US_Event_Account__c = Acc[1].id;
        eventacc1.ZTS_US_Events__c = eve[0].id; 
        insert eventacc1;  
        
        ZTS_US_Event_Invitee__c eveinvite = new ZTS_US_Event_Invitee__c();
        eveinvite.ZTS_US_Contact__c = conList[1].id;
        eveinvite.ZTS_US_Event__c = eve[0].id; 
        insert eveinvite;
        
        PageReference pgRef = Page.ZTS_US_AddContactRedirect;
        Test.setCurrentPageReference (pgRef);
        ApexPages.currentPage().getParameters().put('eventId',eve[0].id);     
        
        USZTS_US_AddContactRedirect Target = new USZTS_US_AddContactRedirect ();
        ApexPages.StandardSetController controller = Target.con;
        
        Target.sortExpression = '';
        
        USZTS_US_AddContactRedirect.ContactWrapper Wrapper = new USZTS_US_AddContactRedirect.ContactWrapper();
        USZTS_US_AddContactRedirect.ContactWrapper Wrapper2 = new USZTS_US_AddContactRedirect.ContactWrapper(conList[0]);
        Wrapper2.checked = true;
        Wrapper.checked = true;
        
        Target.sortFullExp = null;
        Target.getCategories();
        Target.executeSearch();
        Target.getContacts();
        Target.setSortDirection('Name');
        Target.SaveAcc();
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
        list<USZTS_US_AddContactRedirect.ContactWrapper> lstadd = new  list<USZTS_US_AddContactRedirect.ContactWrapper>();
        lstadd.add(Wrapper);
        
        Pagereference P = Target.saveContacts();
        test.stoptest();
    }
         
  public static testMethod void ContactRedirect_TestSortExpr() {
        Test.startTest();
        //Creating the test data
       List<ZTS_Events__c> Eve = ZTS_DataUtilityTest.createEvents(2);
       insert Eve ;
       User usr = new User();
       usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
       usr.FirstName = 'eltonUser';
       usr.zts_eu_market__c = 'United Kingdom';
       insert usr;
       List<Account> Acc = ZTS_DataUtilityTest.createAccountRecord(2);
       System.runAs(usr)
       {
            insert Acc;     
       }
       ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
       List<Contact> conList = ZTS_DataUtilityTest.createContactRecord(2);
       conList[1].AccountId =  Acc[1].id;
       System.runAs(usr)
       {
           insert conList;
       }
             
       PageReference pgRef = Page.ZTS_US_AddContactRedirect;
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
    
       
       USZTS_US_AddContactRedirect Target = new USZTS_US_AddContactRedirect ();
       ApexPages.StandardSetController controller = Target.con;
             
       
       Target.sortExpression = '';
       USZTS_US_AddContactRedirect.ContactWrapper Wrapper = new USZTS_US_AddContactRedirect.ContactWrapper();
       USZTS_US_AddContactRedirect.ContactWrapper Wrapper2 = new USZTS_US_AddContactRedirect.ContactWrapper(conList[0]);
        Wrapper2.checked = True;
        Wrapper.checked = true;
       
       //Target.sortFullExp = 'Test';
       Target.executeSearch();
       Target.getContacts();
       Target.getCategories();
       Target.setSortDirection('Name');
       Target.SaveAcc();
       
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
       list<USZTS_US_AddContactRedirect.ContactWrapper> lstadd = new  list<USZTS_US_AddContactRedirect.ContactWrapper>();
       lstadd.add(Wrapper);
       
       Pagereference P = Target.saveContacts();
      test.stoptest();
     }
         
  //Test method to cover USZTS_US_AddNewContactRedirect class
public static testMethod void addNewContactRedirect_Test() {
    
        Test.startTest();
            //Creating the test data
           List<ZTS_Events__c> Eve = ZTS_DataUtilityTest.createEvents(2);
           for (ZTS_Events__c e : Eve) e.ZTS_EU_Market__c = 'United States';
           insert Eve ;
           
           User usr = new User();
           usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
           usr.FirstName = 'eltonUser';
           usr.zts_eu_market__c = 'United Kingdom';
           insert usr;
           
           List<Account> Acc = ZTS_DataUtilityTest.createAccountRecord(2);
           System.runAs(usr)
           {
                insert Acc;  
           } 
           
           ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
           List<Contact> conList = ZTS_DataUtilityTest.createContactRecord(2);
           conList[1].AccountId =  Acc[1].id;
           System.runAs(usr)
           {
              insert conList; 
           }         
           
           List<ZTS_US_Event_Account__c> eventaccList  =  new List<ZTS_US_Event_Account__c>();
           ZTS_US_Event_Account__c eventacc = new ZTS_US_Event_Account__c();
           eventacc.ZTS_US_Event_Account__c = Acc[0].id;
           eventacc.ZTS_US_Events__c = eve[0].id; 
           eventaccList.add(eventacc); 
           
           ZTS_US_Event_Account__c eventacc1 = new ZTS_US_Event_Account__c();
           eventacc1.ZTS_US_Event_Account__c = Acc[1].id;
           eventacc1.ZTS_US_Events__c = eve[0].id; 
           eventaccList.add(eventacc1);
           
           insert eventaccList;  
           
           ZTS_US_Event_Invitee__c eveinvite = new ZTS_US_Event_Invitee__c();
           eveinvite.ZTS_US_Contact__c = conList[0].id;
           eveinvite.ZTS_US_Event__c = eve[0].id; 
           insert eveinvite;
           
           PageReference pgRef = Page.USZTS_US_AddNewContactRedirect;
           Test.setCurrentPageReference (pgRef);
           ApexPages.currentPage().getParameters().put('eventId',eve[0].id); 
        
           
           USZTS_US_AddNewContactRedirect Target = new USZTS_US_AddNewContactRedirect ();
           ApexPages.StandardSetController controller = Target.con;
           
           Target.cancel();
           Target.getAllAccountbyEvent();
           Target.objCon = new Contact(Lastname = 'TestContact'); 
           Target.customSaveContact();
           Target.customCancelContact();
          
      test.stoptest();
     }       

    //Test method to cover changes done for SC-008149
    public static testMethod void addNewDuplicateContactRedirectPositive_Test() {
        
        Test.startTest();
        //Creating the test data
        List<ZTS_Events__c> Eve = ZTS_DataUtilityTest.createEvents(2);
        for (ZTS_Events__c e : Eve) e.ZTS_EU_Market__c = 'United States';
        insert Eve ;
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        List<Account> Acc = ZTS_DataUtilityTest.createAccountRecord(2);
        System.runAs(usr)
        {
            insert Acc;  
        } 
        
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        List<Contact> conList = ZTS_DataUtilityTest.createContactRecord(2);
        conList[1].AccountId =  Acc[1].id;
        conList[1].ZTS_EU_Market__c =  'United States';
        conList[1].ZTS_US_Profession__c =  'Academia';
        conList[1].ZTS_US_Job_Function__c =  'Clinical Faculty';
        conList[1].Interface_Email__c = 'test12332@test.com';
        System.runAs(usr)
        {
            insert conList; 
        }
        
        system.debug('conList ->'+ conList);
        
        List<ZTS_US_Event_Account__c> eventaccList  =  new List<ZTS_US_Event_Account__c>();
        ZTS_US_Event_Account__c eventacc = new ZTS_US_Event_Account__c();
        eventacc.ZTS_US_Event_Account__c = Acc[0].id;
        eventacc.ZTS_US_Events__c = eve[0].id; 
        eventaccList.add(eventacc); 
        
        ZTS_US_Event_Account__c eventacc1 = new ZTS_US_Event_Account__c();
        eventacc1.ZTS_US_Event_Account__c = Acc[1].id;
        eventacc1.ZTS_US_Events__c = eve[0].id; 
        eventaccList.add(eventacc1);
        
        insert eventaccList;  
        
        ZTS_US_Event_Invitee__c eveinvite = new ZTS_US_Event_Invitee__c();
        eveinvite.ZTS_US_Contact__c = conList[0].id;
        eveinvite.ZTS_US_Event__c = eve[0].id; 
        insert eveinvite;
        
        PageReference pgRef = Page.USZTS_US_AddNewContactRedirect;
        Test.setCurrentPageReference (pgRef);
        ApexPages.currentPage().getParameters().put('eventId',eve[0].id); 
        
        
        USZTS_US_AddNewContactRedirect Target = new USZTS_US_AddNewContactRedirect ();
        ApexPages.StandardSetController controller = Target.con;
        
        Target.cancel();
        Target.getAllAccountbyEvent();
        Target.strAccountId = Acc[1].id;
        Target.objCon = new Contact(Lastname = conList[1].Lastname, FirstName = conList[1].FirstName, ZTS_EU_Market__c= 'United States',ZTS_US_Profession__c =  'Academia',
                      ZTS_US_Job_Function__c =  'Clinical Faculty', Interface_Email__c = 'test12332@test.com'); 
        system.debug('objCon in test class ->'+ Target.objCon);
        PageReference nextPage = Target.customSaveContact();
        System.assertNotEquals(new PageReference('/'+eve[0].id), nextPage);
        
        
        
        Target.getDupContactDetails(New List<Id>{conList[0].id, conList[1].id});
        System.assertNotEquals(Target.allContactsWrap.size(), 0);

        PageReference nextPage2 = Target.saveDuplicateContact();
        
        System.assertNotEquals([Select id from ZTS_US_Event_Invitee__c where ZTS_US_Event__c = :eve[0].id].size() , 0);
        
        Target.selectedContactId = Target.allContactsWrap[0].con.Id;
        Target.allContactsWrap[0].isSelected = true;
        Target.disableCheckbox();
        
        Target.associateSelectedCon();
        System.assertNotEquals([Select id from ZTS_US_Event_Invitee__c where ZTS_US_Event__c = :eve[0].id and ZTS_US_Contact__c = :Target.allContactsWrap[0].con.Id].size() , 0);
        
        test.stoptest();
    }
    
    
}