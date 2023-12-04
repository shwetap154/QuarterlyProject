/**
 * @description       : Test class for AddAttendeesAndContactController
 * @author            : Deloitte consulting
 * @group             : 
 * @last modified on  : 07-25-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   06-14-2014   Teresa @ Deloitte Consulting   Created the class
 * 1.1   07-25-2022   Ethan Hirsch @ Zoetis Inc      Update validate_setConUser to use ZTS_EU_DataUtilityTest to create
 *                                                   data to reduce data creation and limit usage.
 *                                                   Move test.startTest and test.stopTest around AddAttendeesAndContactController
 *                                                   usage for proper testing and to get a fresh set of limits.
**/
@isTest
public without sharing class ZTS_EU_AddAttendeesAndContactContTest {
  
  /**public static testMethod void validate_setConCont(){
    
    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
    string userName = generateRandomUserName(); 
    User u = new User(Alias = 'standt', Email=userName, 
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
    LocaleSidKey='en_US', ProfileId = p.Id, 
    TimeZoneSidKey='America/Los_Angeles', UserName=userName,ZTS_EU_Market__c = 'United Kingdom');
    insert u;
    
    System.runAs(u) {
      Test.startTest();
      List<Account> accList = ZTS_EU_DataUtilityTest1.createAccountRecord(1);
      insert accList ;        
      List<Contact> contList = ZTS_EU_DataUtilityTest1.createContactRecord(4);
      insert contList;   
      List<Attendee__c>attendeeList = ZTS_EU_DataUtilityTest1.createAttendee(1);
      insert attendeeList;
      List<ZTS_EU_Account_Species_Potential__c> aspList = ZTS_EU_DataUtilityTest1.createAcctSpeciesPotRecords(4,accList[0].id);
      insert aspList;
      //List<ZTS_EU_Colleague__c> collList = ZTS_EU_DataUtilityTest1.createColleague(1);
      // insert collList ;
      List<Campaign>campaignList = ZTS_EU_DataUtilityTest1.createCampaignRecord(4);
      insert campaignList;
      List<ZTS_EU_Discussion_Item__c>discItemList = ZTS_EU_DataUtilityTest1.createDiscussionItemsRecord(4);
      insert discItemList;
      List<ZTS_EU_Species_Product__c> productList = [SELECT Id,Name from ZTS_EU_Species_Product__c WHERE ZTS_EU_Type__c ='Brand' ];
      List<ZTS_EU_Discussion__c> discussionList = new List<ZTS_EU_Discussion__c>();
      ZTS_EU_Discussion__c discussion = new ZTS_EU_Discussion__c();
      discussion.ZTS_EU_Product__c = productList[0].Id;
      discussion.Name = productList[0].Name;
      discussion.ZTS_EU_Call_Attendee__c = attendeeList[0].Id;
      discussionList.add(discussion);
      discussion = new ZTS_EU_Discussion__c();
      discussion.ZTS_EU_Campaign__c = campaignList[0].Id;
      discussion.Name = campaignList[0].Name;
      discussion.ZTS_EU_Call_Attendee__c = attendeeList[0].Id;
      discussionList.add(discussion);
      discussion = new ZTS_EU_Discussion__c();
      discussion.ZTS_EU_Discussion_Items__c = discItemList[0].Id;
      discussion.Name = discItemList[0].Name;
      discussion.ZTS_EU_Call_Attendee__c = attendeeList[0].Id;
      discussionList.add(discussion);
      insert discussionList;
      PageReference pageRef = Page.AddAttendeesAndContact;
      Test.setCurrentPage(pageRef);
      List<Call__c> callObj = [SELECT Id FROM Call__c];
      system.debug('************callObj************'+callObj);
      if(callObj.size() > 0)
      ApexPages.currentPage().getParameters().put('callId',callObj[0].Id);  
      ApexPages.currentPage().getParameters().put('searchString','Test');  
      ApexPages.currentPage().getParameters().put('accountId',contList[0].AccountId); 
      ApexPages.currentPage().getParameters().put('contactFlag','true'); 
      ApexPages.currentPage().getParameters().put('isOnload','true');             
      ApexPages.StandardSetController setConCont = new ApexPages.StandardSetController(contList); 
      AddAttendeesAndContactController addAttendeeCont = new AddAttendeesAndContactController();
      system.debug('AAAA' +contList[0].id);
      system.debug('BBBB' +accList[0].id);
      Contact c = new Contact(firstName ='Name', lastName = 'last');
      //ZTS_EU_Affiliations__c aff = new ZTS_EU_Affiliations__c(ZTS_EU_Contact__c = contList[0].Id, ZTS_EU_Account__c = accList[0].Id);
      ZTS_EU_Affiliations__c aff = new ZTS_EU_Affiliations__c(ZTS_EU_Contact__c = contList[0].Id, ZTS_EU_Account__c = accList[0].Id, ZTS_EU_Profession__c = 'Academia', ZTS_EU_Job_Function__c = 'Associate Vet', ZTS_EU_Account_influence__c = 'Medium', ZTS_EU_LE_Contact__c = true);
      addAttendeeCont.accContAff = aff;
      system.debug('CCCC' +aff);
      addAttendeeCont.oContact = c;
      addAttendeeCont.mapConIdAtten.put(attendeeList[0].Id,attendeeList[0]);
      addAttendeeCont.getContacts();
      addAttendeeCont.conId = contList[0].Id;
      addAttendeeCont.showContactCreation();
      addAttendeeCont.Add();
      addAttendeeCont.saveConact();
      addAttendeeCont.flipFlop();
      addAttendeeCont.flipFlop1();
      addAttendeeCont.updateContactForLastCallDate(attendeeList[0].ZTS_EU_Contact__c);
      addAttendeeCont.attId = attendeeList[0].Id;
      addAttendeeCont.conIdDel = contList[0].Id;
      addAttendeeCont.RemoveAttendee();
      addAttendeeCont.attId = attendeeList[0].Id;
      addAttendeeCont.RemoveAttn();
      Test.stopTest();
    }
  }**/
    
  public static testMethod void validate_setConUser(){
     DispatchTriggerHandler.bypass('AccountTriggerHandler');

    Id adminProfileId;
    Id standardUserProfileId;
    
    for (Profile profileRecord : [
      SELECT Id, Name
      FROM Profile 
      WHERE Name in ('System Administrator', 'Standard User')]) {
      if (profileRecord.Name == 'System Administrator') {
        adminProfileId = profileRecord.Id;
      }
      else {
        standardUserProfileId = profileRecord.Id;
      }
    }

    List<User> testUsers = new List<User>();
    User intlUsr = new User();
    intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile(adminProfileId, false);
    intlUsr.FirstName = 'IntUser';
    intlUsr.ZTS_EU_Market__c = 'United Kingdom';
    testUsers.add(intlUsr);

    User colleagueUser = ZTS_EU_DataUtilityTest.createUserWithProfile(standardUserProfileId, false);
    testUsers.add(colleagueUser);

    User pageUser = ZTS_EU_DataUtilityTest.createUserWithProfile(standardUserProfileId, false);
    testUsers.add(pageUser);

    insert testUsers;
    // List<Account> objAcc = new Account();
    // List<Contact> objContact = new Contact();
    // ApexPages.StandardSetController setCon;
    // SL_LinkContactToAccountController objCntl;
    System.runAs(intlUsr) {
      ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
      
      
      List<Account> accList = ZTS_EU_DataUtilityTest.createAccountRecord(1);
      insert accList ;
      
      List<Contact> contList = ZTS_EU_DataUtilityTest.createContactRecord(4);
      for (Contact testContact : contList) {
        testContact.AccountId = accList[0].Id;
         testContact.ZTS_EU_Contact_Status__c = 'Active';
      }

      insert contList;

      Call__c testCall = ZTS_EU_DataUtilityTest.createCallWithAcc(accList[0].Id, true);

      List<Attendee__c>attendeeList = ZTS_EU_DataUtilityTest.createAttendees(contList, testCall);
      insert attendeeList;

      ZTS_EU_Colleague__c testColleague = ZTS_EU_DataUtilityTest.createColleague(testCall.Id, colleagueUser.Id);
      insert testColleague;
       
      ZTS_EU_Affiliations__c aff1 = new ZTS_EU_Affiliations__c(ZTS_EU_Contact__c = contList[0].Id, ZTS_EU_Account__c = accList[0].Id);
      //insert aff1;
      PageReference pageRef = Page.AddAttendeesAndContact;
      Test.setCurrentPage(pageRef);
      
      for(Attendee__c at1: attendeeList ){
        at1.ZTS_EU_Employee__c = pageUser.Id;
      }
      update attendeeList;

      Test.startTest();
        ApexPages.currentPage().getParameters().put('callId',testCall.Id);  
        ApexPages.currentPage().getParameters().put('searchString','Test');  
        ApexPages.currentPage().getParameters().put('accountId',contList[0].AccountId); 
        ApexPages.currentPage().getParameters().put('EmployeeFlag','true');
          //new lines
          ApexPages.currentPage().getParameters().put('isOnload','true');
          ApexPages.currentPage().getParameters().put('ContactFlag','true');
        AddAttendeesAndContactController addAttendeeCont = new AddAttendeesAndContactController();
          addAttendeeCont.conId = contList[0].Id;
        addAttendeeCont.attId = attendeeList[0].Id;
        addAttendeeCont.conIdDel = contList[0].Id;
          addAttendeeCont.attConIdDel=contList[0].Id;
          addAttendeeCont.attUserIdDel = pageUser.Id;
          addAttendeeCont.MailingCity='Test';
          addAttendeeCont.MailingCountry='TestCountry';
          addAttendeeCont.MailingState='TestState';
          addAttendeeCont.MailingStreet='Test Street';
          addAttendeeCont.MailingPostalCode='500081';
          addAttendeeCont.lastName='Test lastName';
          addAttendeeCont.title='Mrs.';
          addAttendeeCont.phone='+1 3245678';
          addAttendeeCont.email='Test@gmail.com';
        addAttendeeCont.mapColleagues.put(testColleague.Id,testColleague);
        addAttendeeCont.attId = attendeeList[0].Id;
        
        system.debug('EEEE' +attendeeList[0].ZTS_EU_Employee__c);
        
        addAttendeeCont.getUsers();
        addAttendeeCont.search();
        addAttendeeCont.empId = pageUser.Id;
        addAttendeeCont.Add();
        addAttendeeCont.conId = aff1.ZTS_EU_Contact__c;
        addAttendeeCont.attId = testColleague.Id;
        addAttendeeCont.removeCol();
        addAttendeeCont.userIdDel = pageUser.id;
        addAttendeeCont.RemoveAttendee();
        // Test.stopTest();
        // new lines
        addAttendeeCont.showContactCreation();
          addAttendeeCont.getContacts();
        addAttendeeCont.RemoveAttn();
        boolean ContactInsert=true;
        boolean ContactFlag =true;
          addAttendeeCont.saveConact();
          addAttendeeCont.flipFlop();
          addAttendeeCont.flipFlop1();
          addAttendeeCont.updateContactForLastCallDate(contList[0].Id);
        
      Test.stopTest();
    }
    DispatchTriggerHandler.clearbypass('AccountTriggerHandler'); 
  }
  
  public static string generateRandomUserName() {
    double a=(Math.random() + 1)*100000;
    integer b = a.intValue();
    string c = String.valueOf(b);
    string userName = 'standarduser' + c + '@testorg.com';
    return userName;     
  } 
  
 @isTest
    static void additional_market(){
     	
        User usrAdmin = new User();
        usrAdmin = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usrAdmin.FirstName = 'davidsUser';
        usrAdmin.zts_eu_market__c = 'Belgium';
        insert usrAdmin;
        
        System.runAs(usrAdmin)
        {
            List<Account> accListnew = ZTS_DataUtilityTest.createAccountRecord(1,5);
            
            for(Account acc:accListnew){
                acc.ZTS_EU_Market__c = 'Belgium';
                acc.ZTS_EU_Country__c = 'Belgium';
                acc.ZTS_EU_Zip_Postal_Code__c = '45220';
            }
            
            
            insert accListnew;
            
            
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            User u = ZTS_DataUtilityTest.createcoacherUser()[0];
            u.FirstName = 'AlexCarstairs';
            u.ZTS_EU_Market__c = 'Belgium';
            insert u;
            
            Call__c call = new Call__c();
            call.ZTS_EU_Sub_Type__c = 'Account Call'; 
            call.ZTS_EU_Duration__c = '0.5'; 
            call.ZTS_EU_Account__c = accListnew[0].Id;
            call.ZTS_EU_Call_Owner__c = usrAdmin.Id;
            //call.ZTS_EU_Status__c='Completed';
            insert call; 
            
            
            // System.runAs(u){
            //insert call;
            //}
            
            List<Contact> contListnew = ZTS_DataUtilityTest.createContactRecord(4);
            for(Contact c : contListnew){
                c.AccountId = accListnew[0].Id;
                c.ZTS_EU_Market__c = 'Belgium';
            }
            insert contListnew; 
            
            
            Attendee__c attendee = new Attendee__c();
            attendee.ZTS_EU_Contact__c = contListnew[0].Id;
            attendee.ZTS_EU_call__c = call.Id; 
            
            insert attendee;
            
            List<Campaign>campaignList = ZTS_DataUtilityTest.createCampaignRecord(4);
            for (Campaign c : campaignList)
            {
                c.Campaign_Name_English__c = 'English';
                c.ZTS_EU_Market__c = 'Belgium';
            }
            insert campaignList;
            List<ZTS_EU_Discussion_Item__c>discItemList = ZTS_DataUtilityTest.createDiscussionItemsRecord(4);
            insert discItemList;
            
            ZTS_EU_Species_Product__c prod= new ZTS_EU_Species_Product__c(Name='Test Product',ZTS_Hierarchy_Level__c='Brand');
            List<ZTS_EU_Species_Product__c> productList= new List<ZTS_EU_Species_Product__c>();
            prod.ZTS_EU_Is_Active__c = true; 
            prod.ZTS_EU_Is_Detailable__c = true;
            productList.add(prod);
            insert productList;
            
            List<ZTS_EU_Discussion__c> discussionList = new List<ZTS_EU_Discussion__c>();
            ZTS_EU_Discussion__c discussion = new ZTS_EU_Discussion__c();
            discussion.ZTS_EU_Product__c = productList[0].Id;
            discussion.Name = productList[0].Name;
            discussion.ZTS_EU_Call_Attendee__c = attendee.Id;
            discussionList.add(discussion);
            
            discussion = new ZTS_EU_Discussion__c();
            discussion.ZTS_EU_Campaign__c = campaignList[0].Id;
            discussion.Name = campaignList[0].Name;
            discussion.ZTS_EU_Call_Attendee__c = attendee.Id;
            discussionList.add(discussion);
            
            discussion = new ZTS_EU_Discussion__c();
            discussion.ZTS_EU_Discussion_Items__c = discItemList[0].Id;
            discussion.Name = discItemList[0].Name;
            discussion.ZTS_EU_Call_Attendee__c = attendee.Id;
            discussionList.add(discussion);
            
            insert discussionList;
            
            
            
            List<User> userList = new List<User>();
            //Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' limit 1]; 
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            
            /*User userTest = new User(Alias = 'standt', Email=uniqueName + '@test' + orgId + '.org', 
                                     EmailEncodingKey='UTF-8', LastName='TestingUser'+uniqueName, LanguageLocaleKey='en_US', 
                                     LocaleSidKey='en_US', ProfileId = p.Id, 
                                     TimeZoneSidKey='America/Los_Angeles', UserName=uniqueName+'@testorg.com', ZTS_EU_Market__c = 'Belgium');*/
            
          /*  userList.add(userTest);
            insert userList; */
            
            List<ZTS_EU_Colleague__c> collList = new List<ZTS_EU_Colleague__c>();
            ZTS_EU_Colleague__c colleague = new ZTS_EU_Colleague__c();
            //colleague.ZTS_EU_User__c = userList[0].Id;
            colleague.ZTS_EU_Call__c = call.Id;
            collList.add(colleague);
            
            insert collList;
            
            ZTS_EU_Affiliations__c aff = new ZTS_EU_Affiliations__c(ZTS_EU_Contact__c = contListnew[0].Id, ZTS_EU_Account__c = accListnew[0].Id,ZTS_EU_Affiliation_Status__c = 'Active',ZTS_EU_Account_influence__c = 'Key Decision Maker'); 
            //insert aff;
            
            Test.startTest();
            PageReference pageRef = Page.AddAttendeesAndContact;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('callId',call.Id);  
            
            ApexPages.currentPage().getParameters().put('searchString','TestingUser');  
            ApexPages.currentPage().getParameters().put('accountId',accListnew[0].Id); 
            ApexPages.currentPage().getParameters().put('contactFlag','false'); 
            ApexPages.currentPage().getParameters().put('EmployeeFlag','false');  
            ApexPages.currentPage().getParameters().put('isOnload','false');             
            ApexPages.StandardSetController setConUser = new ApexPages.StandardSetController(userList); 
            AddAttendeesAndContactController addAttendeeCont = new AddAttendeesAndContactController();
            
            Market_Setting__mdt marketsettingMetadata =  [SELECT Market__c,Additional_Call_Colleague_Markets__c  
                                                          FROM Market_Setting__mdt where Market__c='Belgium'][0];
            String additionalMarket = marketsettingMetadata.Additional_Call_Colleague_Markets__c;
            Map<String, String> additionalMarketsMap = new Map<String, String>();
            additionalMarketsMap.put('Belgium', marketSettingMetadata.Additional_Call_Colleague_Markets__c);
            addAttendeeCont.CurrentAccount = accListnew[0];
            system.assertEquals(additionalMarketsMap.get('Belgium'),'Netherlands');
            
           // addAttendeeCont.userIdDel = userList[0].Id;
            
            addAttendeeCont.ContactFlag=true;
            addAttendeeCont.EmployeeFlag=true;
            addAttendeeCont.mapColleagues.put(collList[0].Id,collList[0]);
            
            addAttendeeCont.getUsers(); 
            
            //addAttendeeCont.empId = userList[0].Id;
            
            
            ZTS_EU_Affiliations__c accContAff=[SELECT Id,ZTS_EU_Contact__c from ZTS_EU_Affiliations__c LIMIT 1];
            addAttendeeCont.conId = accContAff.ZTS_EU_Contact__c;
            addAttendeeCont.Add();
            addAttendeeCont.attId = collList[0].Id;
            
            addAttendeeCont.search();
            Test.stopTest();
            
        }
        
    }
  
}