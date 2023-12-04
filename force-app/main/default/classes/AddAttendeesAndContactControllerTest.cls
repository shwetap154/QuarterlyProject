/*******************************************************************************************************************************************
* File Name     :  AddAttendeesAndContactControllerTest
* Description   :  Test class for USAddAttendeesAndContactController

* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/14          Akanksha         Created the Class.

***************************************************************************************************************/
@isTest
private class AddAttendeesAndContactControllerTest {
    
    @TestSetup
    static void createTestData(){
        DispatchTriggerHandler.bypass('ZTS_EU_AffiliationsTriggerHandler');
        DispatchTriggerHandler.bypass('AttendeeTriggerHandler');
        DispatchTriggerHandler.bypass('CallTriggerHandler');
        DispatchTriggerHandler.bypass('ZTS_EU_ColleagueTriggerHandler');
        DispatchTriggerHandler.bypass('ZTS_EU_DiscussionTriggerHandler');
        DispatchTriggerHandler.bypass('EUSpeciesProductTriggerHandler');
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('CampaignTriggerHandler');
        DispatchTriggerHandler.bypass('ContactTriggerHandler');
        DispatchTriggerHandler.bypass('UserTriggerHandler');
        
        User usrAdmin = new User();
        usrAdmin = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usrAdmin.FirstName = 'davidsUser';
        usrAdmin.zts_eu_market__c = 'United States';
        insert usrAdmin;
        
        System.runAs(usrAdmin)
        {
            List<Account> accList = ZTS_DataUtilityTest.createAccountRecord(1,5);
            
            for(Account acc:accList){
                acc.ZTS_US_NARC_ID__c='NC12345';
                acc.ZTS_EU_Market__c = 'United States';
                acc.ZTS_EU_Country__c = 'United States';
                acc.ZTS_EU_Zip_Postal_Code__c = '45220';
            }
            
            
            insert accList;
            
            
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            User u = ZTS_DataUtilityTest.createcoacherUser()[0];
            u.FirstName = 'AlexCarstairs';
            u.ZTS_EU_Market__c = 'United States';
            insert u;
            
            Call__c call = new Call__c();         
            call.ZTS_EU_Account__c = accList[0].Id;
            call.ZTS_EU_Start_Date_Time__c = datetime.newInstance(2015, 9, 1, 12, 30, 2);        
            call.ZTS_EU_End_Date_Time__c = datetime.newInstance(2015, 9, 1, 12, 30, 2).addHours(1);
            call.ZTS_EU_Sub_Type__c = 'Account Call';   
            call.ZTS_EU_Call_Owner__c = u.Id;
            
            
            System.runAs(u){
                insert call;
            }
            
            List<Contact> contList = ZTS_DataUtilityTest.createContactRecord(4);
            for(Contact c : contList){
                c.AccountId = accList[0].Id;
                c.ZTS_EU_Market__c = 'United States';
            }
            
            User usr = new User();
            usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            usr.FirstName = 'davidsUser';
            usr.zts_eu_market__c = 'United States';
            insert usr;
            
            System.runAs(usr){ 
                insert contList; 
            }
            
            Attendee__c attendee = new Attendee__c();
            attendee.ZTS_EU_Contact__c = contList[0].Id;
            attendee.ZTS_EU_call__c = call.Id; 
            
            System.runAs(u){
                insert attendee;
            }
            
            List<Campaign>campaignList = ZTS_DataUtilityTest.createCampaignRecord(4);
            for (Campaign c : campaignList)
            {
                c.Campaign_Name_English__c = 'English';
                c.ZTS_EU_Market__c = 'United States';
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
            
        }
        DispatchTriggerHandler.clearBypass('ZTS_EU_AffiliationsTriggerHandler');
        DispatchTriggerHandler.clearBypass('AttendeeTriggerHandler');
        DispatchTriggerHandler.clearBypass('CallTriggerHandler');
        DispatchTriggerHandler.clearBypass('ZTS_EU_ColleagueTriggerHandler');
        DispatchTriggerHandler.clearBypass('ZTS_EU_DiscussionTriggerHandler');
        DispatchTriggerHandler.clearBypass('EUSpeciesProductTriggerHandler');
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        DispatchTriggerHandler.clearBypass('CampaignTriggerHandler');
        DispatchTriggerHandler.clearBypass('ContactTriggerHandler');
        DispatchTriggerHandler.clearBypass('UserTriggerHandler');
    }
    
    @isTest
    private static void validate_setConCont(){
    
        
        Test.startTest();
        PageReference pageRef = Page.AddAttendeesAndContact;
        Test.setCurrentPage(pageRef);
        Test.stopTest();
        
        List<Account> accList = [SELECT Id FROM Account];
        List<Contact> contList = [SELECT Id FROM Contact];
        List<Call__c> callList = [SELECT Id, ZTS_EU_Start_Date_Time__c FROM Call__c];
        List<Attendee__c> attendeeList = [SELECT Id FROM Attendee__c];
        
        if(callList.size() > 0){
            
            ApexPages.currentPage().getParameters().put('callId',callList[0].Id);  
            ApexPages.currentPage().getParameters().put('searchString','Test');  
            ApexPages.currentPage().getParameters().put('accountId',accList[0].Id); 
            ApexPages.currentPage().getParameters().put('EmployeeFlag','true');  
            ApexPages.currentPage().getParameters().put('contactFlag','true'); 
            ApexPages.currentPage().getParameters().put('isOnload','true');             
            ApexPages.StandardSetController setConCont = new ApexPages.StandardSetController(contList); 
            
            USAddAttendeesAndContactController addAttendeeCont = new USAddAttendeesAndContactController();
            addAttendeeCont.ContactFlag=true;
            addAttendeeCont.EmployeeFlag=true;
            addAttendeeCont.MailingCity = 'TestCity';
            addAttendeeCont.MailingCountry = 'TestCountry';
            addAttendeeCont.MailingState = 'TestState';
            addAttendeeCont.MailingStreet = 'TestStreet';
            addAttendeeCont.MailingPostalCode = 'TestCode';
            addAttendeeCont.lastName = 'TestLastName';
            addAttendeeCont.title = 'TestTitle';
            addAttendeeCont.phone = '123456';
            addAttendeeCont.email = 'test@test.com';
            addAttendeeCont.dispjobfunc = new Map<String,String>{'TestKey' => 'TestValue'};
            addAttendeeCont.conIdDel = contList[0].Id;
            Contact c = new Contact(firstName ='Name', lastName = 'last', ZTS_EU_Market__c = 'United Kingdom');
            //addAttendeeCont.accContAff = aff;
            addAttendeeCont.oContact = c;
            addAttendeeCont.mapConIdAtten.put(attendeeList[0].Id,attendeeList[0]);
            addAttendeeCont.getContacts();
            
            addAttendeeCont.conId = contList[0].Id;
            addAttendeeCont.showContactCreation();
            System.assertEquals(accList[0].Id, addAttendeeCont.accContAff.ZTS_EU_Account__c,'The expected Account Id should be same as inserted');
            System.assertEquals(contList[0].Id, addAttendeeCont.accContAff.ZTS_EU_Contact__c,'The expected Account Id should be same as inserted');
            
            addAttendeeCont.Add();
            System.assertEquals(callList[0].Id, addAttendeeCont.CurrentCall.Id, 'The expected call must match the Attendee Call'); 
            
            addAttendeeCont.flipFlop();
            System.assertEquals(true, addAttendeeCont.isRendered, 'The expected value of isRendered is True');
            
            addAttendeeCont.attId = attendeeList[0].Id;
            addAttendeeCont.RemoveAttendee();
            addAttendeeCont.RemoveAttn();
            List<Attendee__c> attendeeList1 = [SELECT Id, ZTS_EU_call__c, ZTS_EU_Contact__c FROM Attendee__c];
            System.assertEquals(0, attendeeList1.size() , 'The expected size of attendee related to current call should be 0');
            
            addAttendeeCont.search();
        }
          
    }
    
    @isTest
    static void validate_setConUser(){
     
        User usrAdmin = [SELECT Id FROM User WHERE FirstName = 'davidsUser' AND ZTS_EU_Market__c = 'United States' LIMIT 1];
        
        System.runAs(usrAdmin)
        {
            
            List<Account> accList = [SELECT Id FROM Account];
            List<Contact> contList = [SELECT Id FROM Contact];
            List<Call__c> callList = [SELECT Id, ZTS_EU_Start_Date_Time__c FROM Call__c];
            List<Attendee__c> attendeeList = [SELECT Id FROM Attendee__c];
            
            
            List<User> userList = new List<User>();
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            
            User userTest = new User(Alias = 'standt', Email=uniqueName + '@test' + orgId + '.org', 
            EmailEncodingKey='UTF-8', LastName='TestingUser'+uniqueName, LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=uniqueName+'@testorg.com', ZTS_EU_Market__c = 'United States');
            
            userList.add(userTest);
            insert userList; 
            
            List<ZTS_EU_Colleague__c> collList = new List<ZTS_EU_Colleague__c>();
            ZTS_EU_Colleague__c colleague = new ZTS_EU_Colleague__c();
            colleague.ZTS_EU_User__c = userList[0].Id;
            colleague.ZTS_EU_Call__c = callList[0].Id;
            collList.add(colleague);
            
            insert collList;
            
            // ZTS_EU_Affiliations__c aff = new ZTS_EU_Affiliations__c(ZTS_EU_Contact__c = contList[0].Id, ZTS_EU_Account__c = accList[0].Id, ZTS_EU_Affiliation_Status__c = 'Active');
            // insert aff;
            List<Call__c> callObj = [SELECT Id FROM Call__c];
            Test.startTest();
            PageReference pageRef = Page.AddAttendeesAndContact;
            Test.setCurrentPage(pageRef);
            if(callObj.size() > 0) {
                ApexPages.currentPage().getParameters().put('callId',callObj[0].Id);  
            }
            ApexPages.currentPage().getParameters().put('searchString','TestingUser');  
            ApexPages.currentPage().getParameters().put('accountId',accList[0].Id); 
            ApexPages.currentPage().getParameters().put('contactFlag','false'); 
            ApexPages.currentPage().getParameters().put('EmployeeFlag','false');  
            ApexPages.currentPage().getParameters().put('isOnload','false');             
            ApexPages.StandardSetController setConUser = new ApexPages.StandardSetController(userList); 
            USAddAttendeesAndContactController addAttendeeCont = new USAddAttendeesAndContactController();
            
            addAttendeeCont.userIdDel = userList[0].Id;
            
            addAttendeeCont.ContactFlag=true;
            addAttendeeCont.EmployeeFlag=true;
            addAttendeeCont.mapColleagues.put(collList[0].Id,collList[0]);
            
            addAttendeeCont.getUsers();
            System.assertEquals(setConUser.getRecords().size(), addAttendeeCont.getUsers().size(), 'The expected users size should be same as set in the standard controller');
            System.assertEquals(setConUser.getRecords()[0].Id, addAttendeeCont.getUsers()[0].Id , 'The expected users should be same as set in the standard controller');
            
            addAttendeeCont.empId = userList[0].Id;
            addAttendeeCont.Add();
            System.assertEquals(callList[0].Id, addAttendeeCont.CurrentCall.Id, 'The expected call must match the Attendee Call');
            
            addAttendeeCont.attId = collList[0].Id;
            addAttendeeCont.removeCol();
            addAttendeeCont.RemoveAttendee();
            //addAttendeeCont.getContacts();
            addAttendeeCont.search();
            
            Test.stopTest();
        }
        
    }
    /*
    public static testmethod void updateContactEmail_Test(){
        
        User usrAdmin = new User();
        usrAdmin = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usrAdmin.FirstName = 'davidsUser';
        usrAdmin.zts_eu_market__c = 'United Kingdom';
        insert usrAdmin;
        
        System.runAs(usrAdmin)
        {
            List<Account> accountRecord = ZTS_DataUtilityTest.createAccountRecord(1,6);
            for (Account acc : accountRecord) acc.ZTS_EU_Market__c = 'United Kingdom';
            insert accountRecord;
            
            User u = ZTS_DataUtilityTest.createcoacherUser()[0];
            u.ZTS_EU_Market__c = 'United Kingdom';
            insert u;
            
            Call__c call = new Call__c();         
            call.ZTS_EU_Account__c = accountRecord[0].Id;
            call.ZTS_EU_Start_Date_Time__c = datetime.newInstance(2015, 9, 1, 12, 30, 2);        
            call.ZTS_EU_End_Date_Time__c = datetime.newInstance(2015, 9, 1, 12, 30, 2).addHours(1);
            call.ZTS_EU_Sub_Type__c = 'Account Call';   
            call.ZTS_EU_Call_Owner__c = u.Id;   
            System.runAs(u){insert call;}
            
            Contact cont = new Contact(); 
            cont.firstname='Test FirstN';
            cont.lastname = 'Test LastN'; 
            cont.Email = 'MrTest@Test.com';
            cont.ZTS_EU_Profession__c='Executive Leadership';
            cont.ZTS_Job_Function__c='CEO/President';
            insert cont;
            
            
            Attendee__c attendee = new Attendee__c();
            attendee.ZTS_EU_Contact__c = cont.Id;
            attendee.ZTS_EU_call__c = call.Id; 
            System.runAs(u){insert attendee;}        
            Test.startTest(); 
            
            PageReference pageRef = Page.AddAttendeesAndContact;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('callId',call.Id);   
            ApexPages.currentPage().getParameters().put('accountId',accountRecord[0].Id); 
            ApexPages.currentPage().getParameters().put('contactFlag','false'); 
            ApexPages.currentPage().getParameters().put('EmployeeFlag','false');  
            ApexPages.currentPage().getParameters().put('isOnload','false');           
            
            //addAttendeeCont.CurrentCall = call;
            USAddAttendeesAndContactController addAttendeeCont = new USAddAttendeesAndContactController();
            for(Attendee__c att: addAttendeeCont.CurrentCall.Attendees__r){
                att.ZTS_EU_Contact__r.Email = 'Test@test.com';
                break;
            }
            
            addAttendeeCont.updateContactEmail();
            Test.stopTest();
        }
        
    }    */
    
}