@isTest
private class CEEventRegistrationTest{
    
    static final String US_USER_FN = 'usUser';
    
    @TestSetup
    static void createTestData(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = US_USER_FN;
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            List<ZTS_Events__c> listEvents;
            List<ZTS_US_Event_Invitee__c> listEventInvitees;
            
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            listEvents = ZTS_DataUtilityTest.createEvents(1);
            listEvents[0].ZTS_US_Event_Category__c = 'CPAC';
            
            Database.insert(listEvents);
            listEventInvitees = USZTS_GL_AllCustomEventsTriggerTest.createInternalAttendees(listEvents);
            insert listEventInvitees;           
            
            List<Account> Acc = ZTS_DataUtilityTest.createAccountRecord(2);
            insert Acc;
            
            List<Contact> contactList = ZTS_DataUtilityTest.createContactRecord(1);
            contactList[0].AccountId = Acc[0].Id;
            contactList[0].ZTS_EU_Market__c = 'United States';
            
            insert contactList;
            
            listEventInvitees[0].ZTS_US_Contact__c = contactList[0].Id;
            update listEventInvitees;
            
            
            ZTS_US_Event_Account__c eventacc = new ZTS_US_Event_Account__c();
            eventacc.ZTS_US_Event_Account__c = Acc[0].id;
            eventacc.ZTS_US_Events__c = listEvents[0].id; 
            insert eventacc;  
        }
    }
    
    @isTest
    static void CEEventRegistration_ctrl_TEST(){
        
        User usr = [SELECT Id FROM User WHERE FirstName = :US_USER_FN];
        
        System.runAs(usr)
        {
            List<ZTS_Events__c> listEvents1 = [SELECT Id FROM  ZTS_Events__c];
            List<ZTS_US_Event_Invitee__c> listEventInvitees1 = [SELECT Id FROM  ZTS_US_Event_Invitee__c];
            List<Account> accountList = [SELECT Id FROM Account];
            ZTS_Events__c eve1;
            ZTS_US_Event_Invitee__c eve1Invite1;
            Test.startTest();
            PageReference pr = Page.CEEventRegistrationForm;
            if(listEvents1 != null && listEventInvitees1 != null && listEvents1.size() >0 && listEventInvitees1.size() > 0 ){           
                eve1 = listEvents1[0]; 
                eve1Invite1 = listEventInvitees1[0];
                eve1Invite1.SMS_Text_Opt_In__c = true;
                eve1Invite1.ZTS_US_Invitation_Status__c = 'Registered';
                update eve1Invite1;
                
                ApexPages.currentPage().getParameters().put('eid',eve1.id);
                ApexPages.currentPage().getParameters().PUT('eaid',eve1Invite1.id); 
                pr.getParameters().PUT('eid',eve1.id); 
            }         
            else{
                eve1 = null;
            }
            Test.setCurrentPage(pr);
            ApexPages.StandardController ctrl = new ApexPages.StandardController(eve1);
            CEEventRegistration_ctrl ct1 = new CEEventRegistration_ctrl(ctrl);
            pr.getParameters().PUT('eaid',eve1Invite1.id); 
            ct1.register();
            
            Test.stopTest();
            
            System.assertEquals(pr.getParameters().get('eid'),ct1.eventID , 'The expected value of eventID must be same as page parameter eid');
            System.assertEquals(false, ct1.registrtionFlag, 'The expected value of registrtionFlag is False');
        }
    }
    
    @isTest
    static void CEEventRegistration_ctrl_TEST123(){
        
        List<ZTS_Events__c> listEvents = [SELECT Id FROM  ZTS_Events__c];
        List<ZTS_US_Event_Invitee__c> listEventInvitees = [SELECT Id FROM  ZTS_US_Event_Invitee__c];
        ZTS_Events__c eve1;
        ZTS_US_Event_Invitee__c eve1Invite1;
        
        Test.startTest();
        PageReference pr = Page.CEEventRegistrationForm;
        if(listEvents != null && listEventInvitees != null && listEvents.size() >0 && listEventInvitees.size() > 0 ){           
            eve1 = listEvents[0]; 
            eve1Invite1 = listEventInvitees[0];
            eve1Invite1.SMS_Text_Opt_In__c = false;
            //eve1Invite1.ZTS_US_Invitation_Status__c = 'Registered';
            update eve1Invite1;
            
            ApexPages.currentPage().getParameters().put('eid',eve1.id);
            ApexPages.currentPage().getParameters().PUT('eaid',eve1Invite1.id); 
            pr.getParameters().PUT('eid',eve1.id); 
            pr.getParameters().PUT('eaid',eve1Invite1.id); 
        }         
        else{
            eve1 = null;
        }
        Test.setCurrentPage(pr);
        ApexPages.StandardController ctrl = new ApexPages.StandardController(eve1);
        CEEventRegistration_ctrl ct1 = new CEEventRegistration_ctrl(ctrl);
        ct1.register();
        Test.stopTest();
        
        System.assertEquals(pr.getParameters().get('eaid'),ct1.einviteID , 'The expected value of einviteID must be same as page parameter eaid');
        System.assertEquals(pr.getParameters().get('eid'),ct1.eventID , 'The expected value of eventID must be same as page parameter eid');
        System.assertEquals(false, ct1.registrtionFlag, 'The expected value of registrtionFlag is False');
        
    }
    
    
    @isTest
    static void CEEventRegistration_ctrl_TEST1(){
        List<ZTS_Events__c> listEvents = [SELECT Id FROM  ZTS_Events__c];
        List<ZTS_US_Event_Invitee__c> listEventInvitees = [SELECT Id FROM  ZTS_US_Event_Invitee__c];
        ZTS_Events__c eve1;
        ZTS_US_Event_Invitee__c eve1Invite1;
        
        List<Contact> conList = new List<Contact>();
        for(Integer i=0;i<2;i++) {
            Contact con = new Contact(); 
            con.firstname='Test First'+i;
            con.lastname = 'Test Contact'+i; 
            con.ZTS_US_Profession__c='Executive Leadership';
            con.ZTS_US_Job_Function__c='CEO/President';
            con.Interface_Email__c = 'test@test.com';
            con.Phone = '65657577';
            conList.add(con);
        }        
        insert conList;
        
        Test.startTest();
        system.debug('The ListEvents:'+listEvents);
        PageReference pr = Page.CEEventRegistrationForm;
        if(listEvents != null && listEventInvitees != null && listEvents.size() >0 && listEventInvitees.size() > 0 ){           
            eve1 = listEvents[0]; 
            eve1Invite1 = listEventInvitees[0];
            eve1Invite1.ZTS_US_Contact__c= conList[0].Id;
            update eve1Invite1;
            
            ApexPages.currentPage().getParameters().put('eid',eve1.id);
            ApexPages.currentPage().getParameters().PUT('eaid',eve1Invite1.id); 
            pr.getParameters().PUT('eid',eve1.id); 
            pr.getParameters().PUT('eaid',eve1Invite1.id);
        }         
        else{
            eve1 = null;
        }
        Test.setCurrentPage(pr);
        ApexPages.StandardController ctrl = new ApexPages.StandardController(eve1);
        CEEventRegistration_ctrl ct2 = new CEEventRegistration_ctrl(ctrl);  
        ct2.newInviteeContact = conList[0];
        ct2.register();
        Test.stopTest();
        
        System.assertEquals(pr.getParameters().get('eaid'),ct2.einviteID , 'The expected value of einviteID must be same as page parameter eaid');
        System.assertEquals(pr.getParameters().get('eid'),ct2.eventID , 'The expected value of eventID must be same as page parameter eid');
        System.assertEquals(true, ct2.registrtionFlag, 'The expected value of registrtionFlag is True');
        System.assertEquals(false, ct2.hasErrorsFlag, 'The expected value of Error Flag should be false');
        
    }
    
    @isTest
    static void CEEventRegistration_ctrl_TEST2(){
        
        List<ZTS_Events__c> listEvents = [SELECT Id FROM  ZTS_Events__c];
        List<ZTS_US_Event_Invitee__c> listEventInvitees = [SELECT Id FROM  ZTS_US_Event_Invitee__c];
        ZTS_Events__c eve1;
        ZTS_US_Event_Invitee__c eve1Invite1;
        
        List<Contact> conList = new List<Contact>();
        for(Integer i=0;i<2;i++) {
            Contact con = new Contact(); 
            con.firstname='Test First'+i;
            con.lastname = 'Test Contact'+i; 
            con.ZTS_US_Profession__c='Executive Leadership';
            con.ZTS_US_Job_Function__c='CEO/President';
            con.Interface_Email__c = 'test@test.com';
            con.Phone = '65657577';
            conList.add(con);
        }        
        insert conList;
        
        Test.startTest();
        PageReference pr = Page.CEEventRegistrationForm;
        if(listEvents != null && listEventInvitees != null && listEvents.size() >0 && listEventInvitees.size() > 0 ){           
            eve1 = listEvents[0]; 
            eve1Invite1 = listEventInvitees[0];
            eve1Invite1.ZTS_US_Contact__c= conList[0].Id;
            update eve1Invite1;
            
            ApexPages.currentPage().getParameters().put('eid',eve1.id);
            ApexPages.currentPage().getParameters().PUT('eaid',eve1Invite1.id); 
            pr.getParameters().PUT('eid',eve1.id); 
        }         
        else{
            eve1 = null;
        }
        
        Test.setCurrentPage(pr);
        ApexPages.StandardController ctrl = new ApexPages.StandardController(eve1);
        //CEEventRegistration_ctrl ct1 = new CEEventRegistration_ctrl(ctrl);
        pr.getParameters().PUT('eaid',eve1Invite1.id); 
        CEEventRegistration_ctrl ct2 = new CEEventRegistration_ctrl(ctrl);  
        ct2.einviteID = eve1Invite1.id;
        ct2.newInviteeContact = conList[0];
        ct2.register();
        ct2.ecid = conList[0].Id;
        ct2.register();
        Test.stopTest();
        
        System.assertEquals(pr.getParameters().get('eaid'),ct2.einviteID , 'The expected value of einviteID must be same as page parameter eaid');
        System.assertEquals(pr.getParameters().get('eid'),ct2.eventID , 'The expected value of eventID must be same as page parameter eid');
        System.assertEquals(true, ct2.registrtionFlag, 'The expected value of registrtionFlag is True');
        System.assertEquals(false, ct2.hasErrorsFlag, 'The expected value of Error Flag should be false');
    }
    
    @isTest
    static void CEEventRegistration_ctrl_TestNullInviteId(){
        
        List<ZTS_Events__c> listEvents = [SELECT Id FROM  ZTS_Events__c];
        List<ZTS_US_Event_Invitee__c> listEventInvitees = [SELECT Id FROM  ZTS_US_Event_Invitee__c];
        List<Account> accList = [SELECT Id FROM Account];
        ZTS_Events__c eve1;
        ZTS_US_Event_Invitee__c eve1Invite1;
        
        List<Contact> conList = new List<Contact>();
        for(Integer i=0;i<2;i++) {
            Contact con = new Contact(); 
            con.firstname='Test First'+i;
            con.lastname = 'Test Contact'+i; 
            con.ZTS_US_Profession__c='Executive Leadership';
            con.ZTS_US_Job_Function__c='CEO/President';
            con.Interface_Email__c = 'test@test.com';
            con.Phone = '65657577';
            conList.add(con);
        }        
        insert conList;
        
        Test.startTest();
        PageReference pr = Page.CEEventRegistrationForm;
        
        ApexPages.currentPage().getParameters().put('eid',null);
        ApexPages.currentPage().getParameters().PUT('eaid',null); 
        pr.getParameters().PUT('eid',null); 
        
        Test.setCurrentPage(pr);
        ApexPages.StandardController ctrl = new ApexPages.StandardController(new ZTS_Events__c());
        CEEventRegistration_ctrl ct1 = new CEEventRegistration_ctrl(ctrl);
        ct1.smsOptIn = true;
        
        pr.getParameters().PUT('eid',listEvents[0].id); 
        ct1.eventID = listEvents[0].id;
        ct1.newInviteeContact = conList[0];
        ct1.selAccount = accList[0].Id;
        ct1.register();
        
        pr.getParameters().PUT('eaid',null); 
        ct1.newInviteeContact = conList[0];
        ct1.selAccount = accList[0].Id;
        ct1.register();
        Test.stopTest();
        
        System.assertEquals(pr.getParameters().get('eaid'),ct1.einviteID , 'The expected value of einviteID must be same as page parameter eaid');
        System.assertEquals(pr.getParameters().get('eid'),ct1.eventID , 'The expected value of eventID must be same as page parameter eid');
        System.assertEquals(true, ct1.registrtionFlag, 'The expected value of registrtionFlag is True');
        System.assertEquals(false, ct1.hasErrorsFlag, 'The expected value of Error Flag should be false');
    }
    
        @isTest
    static void CEEventRegistration_ctrl_TestNegativeInvalidEventId(){
        
        List<ZTS_Events__c> listEvents = [SELECT Id FROM  ZTS_Events__c];
        List<ZTS_US_Event_Invitee__c> listEventInvitees = [SELECT Id FROM  ZTS_US_Event_Invitee__c];
        List<Account> accList = [SELECT Id FROM Account];
        ZTS_Events__c eve1;
        ZTS_US_Event_Invitee__c eve1Invite1;
        
        Contact con = new Contact(); 
        con.firstname='Test';
        con.lastname = 'Test Contact'; 
        con.ZTS_US_Profession__c='Executive Leadership';
        con.ZTS_US_Job_Function__c='CEO/President';
        con.Interface_Email__c = 'test@test.com';
        con.Phone = '65657577';       
        insert con;
        
        Test.startTest();
        PageReference pr = Page.CEEventRegistrationForm;
        
        ApexPages.currentPage().getParameters().put('eid','00112233445566'); //invalid id
        ApexPages.currentPage().getParameters().PUT('eaid',null); 
        pr.getParameters().PUT('eid','00112233445566'); //invalid id
        pr.getParameters().PUT('eaid', null);  
        
        Test.setCurrentPage(pr);
        ApexPages.StandardController ctrl = new ApexPages.StandardController(new ZTS_Events__c());
        CEEventRegistration_ctrl ct1 = new CEEventRegistration_ctrl(ctrl);
        
        pr.getParameters().PUT('eid','00112233445566'); //invalid id
        ct1.eventID = listEvents[0].id;
        ct1.newInviteeContact = con;
        ct1.selAccount = accList[0].Id;
        ct1.register();
        
        pr.getParameters().PUT('eaid',null); 
        ct1.newInviteeContact = con;
        ct1.selAccount = accList[0].Id;
        ct1.register();
        Test.stopTest();
        
        System.assertEquals(false, ct1.registrtionFlag, 'The expected value of registrtionFlag is True');
        System.assertEquals(true, ct1.hasErrorsFlag, 'The expected value of Error Flag should be false');
        
    }    
    @isTest
    static void CEEventRegistration_ctrl_TestNegativeInvalidInviteId(){
        
        List<ZTS_Events__c> listEvents = [SELECT Id FROM  ZTS_Events__c];
        List<ZTS_US_Event_Invitee__c> listEventInvitees = [SELECT Id FROM  ZTS_US_Event_Invitee__c];
        List<Account> accList = [SELECT Id FROM Account];
        ZTS_Events__c eve1;
        ZTS_US_Event_Invitee__c eve1Invite1;
        
        Contact con = new Contact(); 
        con.firstname='Test';
        con.lastname = 'Test Contact'; 
        con.ZTS_US_Profession__c='Executive Leadership';
        con.ZTS_US_Job_Function__c='CEO/President';
        con.Interface_Email__c = 'test@test.com';
        con.Phone = '65657577';       
        insert con;
        
        Test.startTest();
        PageReference pr = Page.CEEventRegistrationForm;
        
        ApexPages.currentPage().getParameters().put('eid',listEvents[0].id);
        ApexPages.currentPage().getParameters().PUT('eaid','00112233445566'); //invalid id
        pr.getParameters().PUT('eid',listEvents[0].id); 
        pr.getParameters().PUT('eaid','00112233445566'); 
        
        Test.setCurrentPage(pr);
        ApexPages.StandardController ctrl = new ApexPages.StandardController(new ZTS_Events__c());
        CEEventRegistration_ctrl ct1 = new CEEventRegistration_ctrl(ctrl);
        
        pr.getParameters().PUT('eid',listEvents[0].id);
        ct1.eventID = listEvents[0].id;
        ct1.newInviteeContact = con;
        ct1.selAccount = accList[0].Id;
        ct1.register();
        
        pr.getParameters().PUT('eaid','00112233445566'); //invalid id
        ct1.newInviteeContact = con;
        ct1.selAccount = accList[0].Id;
        ct1.register();
        Test.stopTest();
        
        System.assertEquals(false, ct1.registrtionFlag, 'The expected value of registrtionFlag is True');
        System.assertEquals(true, ct1.hasErrorsFlag, 'The expected value of Error Flag should be false');
        
    }
    
}