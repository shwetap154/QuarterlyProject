@isTest
public with sharing class PIT_TestCoachingGuideTrigger {

    public testmethod static void test_PIT_trigger_insert(){
        
        PIT_Coaching_Guide__c cg = new PIT_Coaching_Guide__c();
        cg.PIT_Coach__c = Userinfo.getUserId();
        cg.PIT_Coaching_Status__c = 'Completed';
        cg.PIT_Colleague__c = Userinfo.getUserId();
        cg.PIT_Colleague_Comments__c = 'comments123';
        cg.ZTS_EU_Market__c = 'United Kingdom';
        //cg.PIT_Colleague_Territory__c = '';
        //cg.PIT_Colleagues_Director__c = '';
        //cg.PIT_Colleagues_Manager__c = '';
        //cg.PIT_Copy_Comments__c = '';
        //cg.PIT_Date_of_Visit__c = '';
        //cg.PIT_Day_Summary__c = '';
        //cg.PIT_Last_Session__c = '';
        //cg.PIT_No_of_Account_Calls__c = '';
        //cg.PIT_No_of_Days_in_Field__c = '';
        //cg.PIT_Notification_Extra_Email__c = '';
        //cg.PIT_Users_Match__c = '';
        //cg.PIT_Check_Current_User_Coach__c = '';
        //cg.PIT_Check_Current_User_Colleague__c = '';
        //cg.PIT_Check_Current_User_Manager__c = '';
        //cg.PIT_Record_ID__c = '';
        
        System.assert(cg.PIT_Record_ID__c == '' || cg.PIT_Record_ID__c == null,'At this stage field should be empty. Value found: ' + cg.PIT_Record_ID__c);
        System.assert(cg.PIT_Last_Session__c != true, 'At this stage last session flag should not be set');
        insert cg;
        
        cg = [select Id, PIT_Record_ID__c, PIT_Last_Session__c from PIT_Coaching_Guide__c where Id = :cg.Id];
        System.assert(Id.valueOf(cg.PIT_Record_ID__c) == cg.Id, 'At this stage field should be set with record Id');
        System.assert(cg.PIT_Last_Session__c = true, 'Flag should be set by a trigger');
        
        
        PIT_Coaching_Guide__c cg2 = new PIT_Coaching_Guide__c();
        cg2.PIT_Coach__c = Userinfo.getUserId();
        cg2.PIT_Coaching_Status__c = 'Completed';
        cg2.PIT_Colleague__c = Userinfo.getUserId();
        cg2.PIT_Colleague_Comments__c = 'comments123';
        cg2.ZTS_EU_Market__c = 'United Kingdom';
        insert cg2;
        
        cg = [select Id, PIT_Record_ID__c, PIT_Last_Session__c from PIT_Coaching_Guide__c where Id = :cg.Id];
        cg2 = [select Id, PIT_Record_ID__c, PIT_Last_Session__c from PIT_Coaching_Guide__c where Id = :cg2.Id];
        
        System.assert(cg2.PIT_Last_Session__c = true, 'Flag should be set by a trigger');
        //System.assert(cg.PIT_Last_Session__c != true, 'Flag for prev. coaching guide should be reseted.');
    }

    public testmethod static void test_PIT_trigger_update(){
        
        User usr0 = new User();
        usr0.CommunityNickname = '4324324';
        usr0.Email = 'example@example.com';
        usr0.Username = 'example43232ffffffd2@example.com';
        usr0.LastName = '432432';
        usr0.Alias = '4324324';
        usr0.TimeZoneSidKey = 'GMT';
        usr0.LocaleSidKey = Userinfo.getLocale();
        usr0.EmailEncodingKey = 'UTF-8';
        usr0.ProfileId = Userinfo.getProfileId();
        usr0.LanguageLocaleKey = userinfo.getLanguage();
        usr0.ZTS_EU_Market__c = 'Peru';
        insert usr0;
        
        User usr = new User();
        usr.CommunityNickname = '43243244321';
        usr.Email = 'example456@example.com';
        usr.Username = 'example43232ff32132ffffd2@example.com';
        usr.LastName = '432432';
        usr.Alias = '3243213';
        usr.TimeZoneSidKey = 'GMT';
        usr.LocaleSidKey = Userinfo.getLocale();
        usr.EmailEncodingKey = 'UTF-8';
        usr.ProfileId = Userinfo.getProfileId();
        usr.LanguageLocaleKey = userinfo.getLanguage();
        usr.ManagerId = usr0.Id;
        usr.ZTS_EU_Market__c = 'Peru';
        insert usr;
        
        User u2 = new User(Id = Userinfo.getUserId(), ManagerId = usr.Id, ZTS_EU_Market__c = 'Peru');
        update u2;
        
        PIT_Coaching_Guide__c cg = new PIT_Coaching_Guide__c();
        cg.PIT_Coach__c = Userinfo.getUserId();
        cg.PIT_Coaching_Status__c = 'New';
        cg.PIT_Colleague__c = Userinfo.getUserId();
        cg.PIT_Colleague_Comments__c = 'comments123';
        cg.ZTS_EU_Market__c = 'United Kingdom';
        insert cg;
        
        PIT_Coaching_Guide__c cg2 = new PIT_Coaching_Guide__c();
        cg2.PIT_Coach__c = Userinfo.getUserId();
        cg2.PIT_Coaching_Status__c = 'New';
        cg2.PIT_Colleague__c = Userinfo.getUserId();
        cg2.PIT_Colleague_Comments__c = 'comments123';
        cg2.ZTS_EU_Market__c = 'United Kingdom';
        insert cg2;
        
        PIT_Coaching_Guide__c cg3 = new PIT_Coaching_Guide__c();
        cg3.PIT_Coach__c = Userinfo.getUserId();
        cg3.PIT_Coaching_Status__c = 'New';
        cg3.PIT_Colleague__c = Userinfo.getUserId();
        cg3.PIT_Colleague_Comments__c = 'comments123';
        cg3.ZTS_EU_Market__c = 'United Kingdom';
        insert cg3;
        
        PIT_Coaching_Guide__c cg4 = new PIT_Coaching_Guide__c();
        cg4.PIT_Coach__c = Userinfo.getUserId();
        cg4.PIT_Coaching_Status__c = 'New';
        cg4.PIT_Colleague__c = Userinfo.getUserId();
        cg4.PIT_Colleague_Comments__c = 'comments123';
        cg4.ZTS_EU_Market__c = 'United Kingdom';
        cg4.PIT_Copy_Comments__c = false;
        insert cg4;
        
        PIT_Coaching_Guide__c[] els2upd = new PIT_Coaching_Guide__c[]{};
        els2upd.add(cg);
        els2upd.add(cg2);
        els2upd.add(cg3);
        els2upd.add(cg4);
        for(PIT_Coaching_Guide__c c1 : els2upd){
            c1.PIT_Coaching_Status__c = 'Completed';
        }
        
        els2upd[1].PIT_Coaching_Status__c = 'Pending Colleague Comments';
        els2upd[1].PIT_Copy_Comments__c = true;
        
        
        
        //Test.startTest();
        
       update els2upd;
        
        //Test.stopTest()
        
        PIT_Coaching_Guide__c[] chck = [select Id from PIT_Coaching_Guide__c where PIT_Last_Session__c = true];
        //System.assert(chck.size() == 1, 'Single coaching guide should be markes as last session.');
        
    } 

    @isTest
    static void test_PIT_trigger_update2(){
        
        User usr0 = new User();
        usr0.CommunityNickname = '4324324';
        usr0.Email = 'example@example.com';
        usr0.Username = 'example43232ffffffd2@example.com';
        usr0.LastName = '432432';
        usr0.Alias = '4324324';
        usr0.TimeZoneSidKey = 'GMT';
        usr0.LocaleSidKey = Userinfo.getLocale();
        usr0.EmailEncodingKey = 'UTF-8';
        usr0.ProfileId = Userinfo.getProfileId();
        usr0.LanguageLocaleKey = userinfo.getLanguage();
        usr0.ZTS_EU_Market__c = 'Peru';
        insert usr0;
        
        User usr = new User();
        usr.CommunityNickname = '43243244321';
        usr.Email = 'example456@example.com';
        usr.Username = 'example43232ff32132ffffd2@example.com';
        usr.LastName = '432432';
        usr.Alias = '3243213';
        usr.TimeZoneSidKey = 'GMT';
        usr.LocaleSidKey = Userinfo.getLocale();
        usr.EmailEncodingKey = 'UTF-8';
        usr.ProfileId = Userinfo.getProfileId();
        usr.LanguageLocaleKey = userinfo.getLanguage();
        usr.ManagerId = usr0.Id;
        usr.ZTS_EU_Market__c = 'Peru';
        insert usr;
        
        User u2 = new User(Id = Userinfo.getUserId(), ManagerId = usr.Id, ZTS_EU_Market__c = 'Peru');
        update u2;
        
        PIT_Coaching_Guide__c cg = new PIT_Coaching_Guide__c();
        cg.PIT_Coach__c = Userinfo.getUserId();
        cg.PIT_Coaching_Status__c = 'New';
        cg.PIT_Colleague__c = Userinfo.getUserId();
        cg.PIT_Colleague_Comments__c = 'comments123';
        cg.ZTS_EU_Market__c = 'United Kingdom';
        insert cg;
        
        PIT_Coaching_Guide__c cg2 = new PIT_Coaching_Guide__c();
        cg2.PIT_Coach__c = Userinfo.getUserId();
        cg2.PIT_Coaching_Status__c = 'New';
        cg2.PIT_Colleague__c = Userinfo.getUserId();
        cg2.PIT_Colleague_Comments__c = 'comments123';
        cg2.ZTS_EU_Market__c = 'United Kingdom';
        insert cg2;
        
        PIT_Coaching_Guide__c cg3 = new PIT_Coaching_Guide__c();
        cg3.PIT_Coach__c = Userinfo.getUserId();
        cg3.PIT_Coaching_Status__c = 'New';
        cg3.PIT_Colleague__c = Userinfo.getUserId();
        cg3.PIT_Colleague_Comments__c = 'comments123';
        cg3.ZTS_EU_Market__c = 'United Kingdom';
        insert cg3;
        
        PIT_Coaching_Guide__c cg4 = new PIT_Coaching_Guide__c();
        cg4.PIT_Coach__c = Userinfo.getUserId();
        cg4.PIT_Coaching_Status__c = 'New';
        cg4.PIT_Colleague__c = Userinfo.getUserId();
        cg4.PIT_Colleague_Comments__c = 'comments123';
        cg4.ZTS_EU_Market__c = 'United Kingdom';
        cg4.PIT_Copy_Comments__c = false;
        insert cg4;
        
        PIT_Coaching_Guide__c[] els2upd = new PIT_Coaching_Guide__c[]{};
        els2upd.add(cg);
        els2upd.add(cg2);
        els2upd.add(cg3);
        els2upd.add(cg4);

        Map<Id, PIT_Coaching_Guide__c> cgMap = new Map<Id, PIT_Coaching_Guide__c>();
        for(PIT_Coaching_Guide__c c1 : els2upd){
            c1.PIT_Coaching_Status__c = 'Completed';
            c1.PIT_Last_Session__c = true;
            c1.recalculateFormulas();
            cgMap.put(
                c1.Id, 
                new PIT_Coaching_Guide__c(
                    Id = c1.Id,
                    PIT_Coach__c = Userinfo.getUserId(),
                    PIT_Coaching_Status__c = 'New',
                    PIT_Colleague__c = Userinfo.getUserId(),
                    PIT_Colleague_Comments__c = 'comments123',
                    ZTS_EU_Market__c = 'United Kingdom',
                    PIT_Copy_Comments__c = false
                )
            );
        }
        
        els2upd[1].PIT_Coaching_Status__c = 'Pending Colleague Comments';
        els2upd[1].PIT_Copy_Comments__c = true;
        
        update els2upd;

        List<PIT_Coaching_Guide__c> cgList = [SELECT Id, CreatedDate, PIT_Coach__c, PIT_Coaching_Status__c, PIT_Colleague__c, PIT_Colleague_Comments__c, ZTS_EU_Market__c, PIT_Copy_Comments__c FROM PIT_Coaching_Guide__c WHERE Id IN :cgMap.keySet()];
        INTLPIT_Coaching_GuideTriggerService.beforeUpdate(null, cgMap, cgList, null);
        
        PIT_Coaching_Guide__c[] chck = [select Id from PIT_Coaching_Guide__c where PIT_Last_Session__c = true];
        //System.assert(chck.size() == 1, 'Single coaching guide should be markes as last session.');
        
    } 
    
    
    
    
}