/**
 * @description       : Test classes for EventUpdate
 * @author            : Sohil Shah @ Cloudsense
 * @group             : 
 * @last modified on  : 07-08-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-04-2015   Sohil Shah @ Cloudsense     Created
 * 1.1   07-08-2022   Ethan Hirsch @ Zoetis Inc   Disable the Call Trigger when inserting Calls to skip Event creation to fix Unit Tests
**/
@isTest
public class eventUpdateTest
{

    @IsTest
    static void TesteventUpdate()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='FRA Business Administrator']; 
            
        Set<String> subtypes = new Set<String>{
            'Account Call', 'Account Call with Speaker', 
            'Advisory / Diagnostic visit', 
            'Clinical - Seedings initial',
            'Demonstration / PPE',
            'ICP / DMA visit',
            'Loyalty / VAS visit',
            'PBC Call',
            'Practice Discussion Group'
        };

        User u = new User(Alias = 'FRE', Email='freuser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='Fr', 
            LocaleSidKey='Fr', ProfileId = p.Id, 
            TimeZoneSidKey='Europe/Paris', UserName='freuser@testorg.com',ZTS_EU_Market__c = 'France');
            insert u;
            //TriggerActivation__c customSetting = new TriggerActivation__c(Name = 'CallTrigger', ZTS_EU_Bypass__c = true);
            //insert customSetting;
            //TriggerActivation__c customSetting1 = new TriggerActivation__c(Name = 'EventTrigger', ZTS_EU_Bypass__c = true);
            //insert customSetting1;
            List<Call__C> callList =new List<Call__c>();
            List<Event> eveList = new List<event>();
            
        System.runAs(u) {
            // The following code runs as user 'u'
            Account acc = new Account(Name = 'Test Account', Type = 'Farm',
                ZTS_EU_Market__c='United Kingdom',
                Practice_Management_Software__c = 'Other',
                Other_Practice_Management_Software__c = 'Sample Practice Management Software');
            insert acc;

            //PIT_Coaching_Guide__c record create 
            PIT_Coaching_Guide__c PITcg = new PIT_Coaching_Guide__c(PIT_Coach__c = Userinfo.getUserId(),
                                                                        PIT_Coaching_Status__c = 'New',
                                                                        PIT_Colleague__c = Userinfo.getUserId(),
                                                                        PIT_Colleague_Comments__c = 'comments123',
                                                                        ZTS_EU_Market__c = 'United Kingdom');
            insert PITcg;
            
            Call__C call1 = new Call__C(ZTS_EU_Sub_Type__c = 'Account Call', ZTS_EU_Account__c = acc.id, ZTS_EU_Start_Date_Time__c = Date.Today(), ZTS_EU_Duration__c = '0.5');
            callList.add(call1);
            Call__C call2 = new Call__C(ZTS_EU_Sub_Type__c = 'Account Call with Speaker', ZTS_EU_Account__c = acc.id, ZTS_EU_Start_Date_Time__c = Date.Today(), ZTS_EU_Duration__c = '0.5');
            callList.add(call2);
            Call__C call3 = new Call__C(ZTS_EU_Sub_Type__c = 'Advisory / Diagnostic visit', ZTS_EU_Account__c = acc.id, ZTS_EU_Start_Date_Time__c = Date.Today(), ZTS_EU_Duration__c = '0.5');
            callList.add(call3);
            Call__C call4 = new Call__C(ZTS_EU_Sub_Type__c = 'Clinical - Seedings initial', ZTS_EU_Account__c = acc.id, ZTS_EU_Start_Date_Time__c = Date.Today(), ZTS_EU_Duration__c = '0.5');
            callList.add(call4);
            Call__C call5 = new Call__C(ZTS_EU_Sub_Type__c = 'Demonstration / PPE', ZTS_EU_Account__c = acc.id, ZTS_EU_Start_Date_Time__c = Date.Today(), ZTS_EU_Duration__c = '0.5');
            callList.add(call5);
            Call__C call6 = new Call__C(ZTS_EU_Sub_Type__c = 'ICP / DMA visit', ZTS_EU_Account__c = acc.id, ZTS_EU_Start_Date_Time__c = Date.Today(), ZTS_EU_Duration__c = '0.5');
            callList.add(call6);
            Call__C call7 = new Call__C(ZTS_EU_Sub_Type__c = 'Loyalty / VAS visit', ZTS_EU_Account__c = acc.id, ZTS_EU_Start_Date_Time__c = Date.Today(), ZTS_EU_Duration__c = '0.5');
            callList.add(call7);
            Call__C call8 = new Call__C(ZTS_EU_Sub_Type__c = 'PBC Call', ZTS_EU_Account__c = acc.id, ZTS_EU_Start_Date_Time__c = Date.Today(), ZTS_EU_Duration__c = '0.5');
            callList.add(call8);
            Call__C call9 = new Call__C(ZTS_EU_Sub_Type__c = 'Practice Discussion Group', ZTS_EU_Account__c = acc.id, ZTS_EU_Start_Date_Time__c = Date.Today(), ZTS_EU_Duration__c = '0.5');
            callList.add(call9);
            Call__C call10 = new Call__C(ZTS_EU_Sub_Type__c = 'Practice Discussion Group', ZTS_EU_Account__c = acc.id, ZTS_EU_Start_Date_Time__c = Date.Today(), 
                                            ZTS_EU_Duration__c = '0.5', PIT_Coaching_Guide__c = PITcg.id);
            callList.add(call10);
            Database.BatchableContext batch;
            test.startTest();
            // Skip the Call Trigger as this will create Events and interfere with the Tests
            DispatchTriggerHandler.bypass('CallTriggerHandler');
            insert callList;
            DispatchTriggerHandler.clearBypass('CallTriggerHandler');
            
            Event eve1 = new Event(Sub_Type__c = 'Account Call',CallRecordId__c = callList[0].id,DurationInMinutes = 20,ActivityDateTime = Date.Today());
            eveList.add(eve1);
            Event eve2 = new Event(Sub_Type__c = 'Account Call with Speaker',CallRecordId__c = callList[1].id,DurationInMinutes = 20,ActivityDateTime = Date.Today());
            eveList.add(eve2);
            Event eve3 = new Event(Sub_Type__c = 'Advisory / Diagnostic visit',CallRecordId__c = callList[2].id,DurationInMinutes = 20,ActivityDateTime = Date.Today());
            eveList.add(eve3);
            Event eve4 = new Event(Sub_Type__c = 'Clinical - Seedings initial',CallRecordId__c = callList[3].id,DurationInMinutes = 20,ActivityDateTime = Date.Today());
            eveList.add(eve4);
            Event eve5 = new Event(Sub_Type__c = 'Demonstration / PPE',CallRecordId__c = callList[4].id,DurationInMinutes = 20,ActivityDateTime = Date.Today());
            eveList.add(eve5);
            Event eve6 = new Event(Sub_Type__c = 'ICP / DMA visit',CallRecordId__c = callList[5].id,DurationInMinutes = 20,ActivityDateTime = Date.Today());
            eveList.add(eve6);
            Event eve7 = new Event(Sub_Type__c = 'Loyalty / VAS visit',CallRecordId__c = callList[6].id,DurationInMinutes = 20,ActivityDateTime = Date.Today());
            eveList.add(eve7);
            Event eve8 = new Event(Sub_Type__c = 'PBC Call',CallRecordId__c = callList[7].id,DurationInMinutes = 20,ActivityDateTime = Date.Today());
            eveList.add(eve8);
            Event eve9 = new Event(Sub_Type__c = 'Practice Discussion Group',CallRecordId__c = callList[8].id,DurationInMinutes = 20,ActivityDateTime = Date.Today());
            eveList.add(eve9);
            insert eveList;
            
            test.stopTest();
        }

        Set<String> updatedSubtypes = new Set<String>();
        for(Event evt : [SELECT Id, Sub_Type__c FROM Event]) {
            updatedSubtypes.add(evt.Sub_Type__c);
        }

        System.assert( subtypes.size() == updatedSubtypes.size() );
        System.assert( !subtypes.equals(updatedSubtypes), 'Sub types not translated' );
    }
}