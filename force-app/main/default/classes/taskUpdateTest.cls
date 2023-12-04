@isTest
public class taskUpdateTest
{
    static testMethod void TestTaskUpdate()
    {
      Profile platformUser = [select id from Profile where Name = 'Standard User'];
       User templateUser = [select id, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, ProfileId, LanguageLocaleKey from User WHERE ZTS_EU_Market__c != 'United States' limit 1];
       User testUser_USA =  new User(
                                    FirstName = 'usa123',
                                    LastName = 'usa123',
                                    Email = 'usa123@test.com',
                                    Username = 'usa123@test.com',
                                    ProfileId = platformUser.Id,
                                    Country = 'usa123',
                                    Alias = 'usa123'.substring(0,5),
                                    CommunityNickname = 'usa123'.substring(0,5), 
                                    TimeZoneSidKey=templateUser.TimeZoneSidKey,
                                    LocaleSidKey=templateUser.LocaleSidKey,
                                    EmailEncodingKey=templateUser.EmailEncodingKey,
                                    ZTS_EU_Market__c='Central America',
                                    LanguageLocaleKey=templateUser.LanguageLocaleKey 
                                    );
        insert testUser_USA;
            
            List<Call__C> callList =new List<Call__c>();
            List<Event> eveList = new List<event>();
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
                Account acc = new Account(Name = 'Test Account', Type = 'Farm',
                    ZTS_EU_Market__c='United Kingdom',
                    Practice_Management_Software__c = 'Other',
                    Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                    ZTS_EU_Zip_Postal_Code__c = '12345');
        System.runAs(usr)
        {
            insert acc;
        }                
                
                Call__C call1 = new Call__C(ZTS_EU_Sub_Type__c = 'Account Call', ZTS_EU_Account__c = acc.id, ZTS_EU_Start_Date_Time__c = Date.Today(), ZTS_EU_Duration__c = '0.5',ZTS_EU_Call_Owner__c=testUser_USA.Id);
                callList.add(call1);
                Call__C call2 = new Call__C(ZTS_EU_Sub_Type__c = 'Account Call with Speaker', ZTS_EU_Account__c = acc.id, ZTS_EU_Start_Date_Time__c = Date.Today(), ZTS_EU_Duration__c = '0.5',ZTS_EU_Call_Owner__c=testUser_USA.Id);
                callList.add(call2);
                Call__C call3 = new Call__C(ZTS_EU_Sub_Type__c = 'Advisory / Diagnostic visit', ZTS_EU_Account__c = acc.id, ZTS_EU_Start_Date_Time__c = Date.Today(), ZTS_EU_Duration__c = '0.5',ZTS_EU_Call_Owner__c=testUser_USA.Id);
                callList.add(call3);
                Call__C call4 = new Call__C(ZTS_EU_Sub_Type__c = 'Clinical - Seedings initial', ZTS_EU_Account__c = acc.id, ZTS_EU_Start_Date_Time__c = Date.Today(), ZTS_EU_Duration__c = '0.5',ZTS_EU_Call_Owner__c=testUser_USA.Id);
                callList.add(call4);
                Call__C call5 = new Call__C(ZTS_EU_Sub_Type__c = 'Demonstration / PPE', ZTS_EU_Account__c = acc.id, ZTS_EU_Start_Date_Time__c = Date.Today(), ZTS_EU_Duration__c = '0.5',ZTS_EU_Call_Owner__c=testUser_USA.Id);
                callList.add(call5);
                Call__C call6 = new Call__C(ZTS_EU_Sub_Type__c = 'ICP / DMA visit', ZTS_EU_Account__c = acc.id, ZTS_EU_Start_Date_Time__c = Date.Today(), ZTS_EU_Duration__c = '0.5',ZTS_EU_Call_Owner__c=testUser_USA.Id);
                callList.add(call6);
                Call__C call7 = new Call__C(ZTS_EU_Sub_Type__c = 'Loyalty / VAS visit', ZTS_EU_Account__c = acc.id, ZTS_EU_Start_Date_Time__c = Date.Today(), ZTS_EU_Duration__c = '0.5',ZTS_EU_Call_Owner__c=testUser_USA.Id);
                callList.add(call7);
                Call__C call8 = new Call__C(ZTS_EU_Sub_Type__c = 'PBC Call', ZTS_EU_Account__c = acc.id, ZTS_EU_Start_Date_Time__c = Date.Today(), ZTS_EU_Duration__c = '0.5',ZTS_EU_Call_Owner__c=testUser_USA.Id);
                callList.add(call8);
                Call__C call9 = new Call__C(ZTS_EU_Sub_Type__c = 'Practice Discussion Group', ZTS_EU_Account__c = acc.id, ZTS_EU_Start_Date_Time__c = Date.Today(), ZTS_EU_Duration__c = '0.5',ZTS_EU_Call_Owner__c=testUser_USA.Id);
                callList.add(call9);
                test.startTest();
        System.runAs(usr)
        {
            insert callList;
        }    
            
            
                List<Attendee__c> attList = new List<Attendee__c>();
                Attendee__c att1 = new Attendee__c(Name = 'Test Attendee1', ZTS_EU_call__c = callList[0].id);
                Attendee__c att2 = new Attendee__c(Name = 'Test Attendee2', ZTS_EU_call__c = callList[0].id);
                Attendee__c att3 = new Attendee__c(Name = 'Test Attendee3', ZTS_EU_call__c = callList[0].id);
                attList.add(att1);
                attList.add(att2);
                attList.add(att3);
        		System.runAs(usr)
                {
                    insert attList;
                }    
        
                List<ZTS_EU_Discussion__c> disList = new List<ZTS_EU_Discussion__c>();
                ZTS_EU_Discussion__c discussion1 = new ZTS_EU_Discussion__c(Name = 'Test DI 1', ZTS_EU_Call_Attendee__c = attList[0].id);
                ZTS_EU_Discussion__c discussion2 = new ZTS_EU_Discussion__c(Name = 'Test DI 2', ZTS_EU_Call_Attendee__c = attList[1].id);
                disList.add(discussion1);
                disList.add(discussion2);
                insert disList;
                
                List<Task> taskList = new List<Task>();
                Task ts1 = new Task(WhatId = call1.id);
                taskList.add(ts1);
                Task ts2 = new Task(WhatId = call2.id);
                taskList.add(ts2);
                Task ts3 = new Task(WhatId = call3.id);
                taskList.add(ts3);
                Task ts4 = new Task(WhatId = call4.id);
                taskList.add(ts4);
                Task ts5 = new Task(WhatId = call5.id);
                taskList.add(ts5);
                Task ts6 = new Task(WhatId = call6.id);
                taskList.add(ts6);
                Task ts7 = new Task(WhatId = call7.id);
                taskList.add(ts7);
                Task ts8 = new Task(WhatId = call8.id);
                taskList.add(ts8);
                Task ts9 = new Task(WhatId = call9.id);
                taskList.add(ts9);
                insert taskList;
                TaskUpdateOnInsert.updatTaskOnInsert(taskList);
                 callList[0].ZTS_EU_Sub_Type__c = 'Account Call with Speaker';
                 update callList[0];
                taskUpdateonCallUpdate.updateTaskOnCallUpdate(callList);
        }
}