@isTest
public class updateCallTest
{
    static testMethod void TestupdateCall()
    {
            Profile p = [SELECT Id FROM Profile WHERE Name='FRA Business Administrator']; 
            User u = new User(Alias = 'FRE', Email='freuser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='Fr', 
            LocaleSidKey='Fr', ProfileId = p.Id, 
            TimeZoneSidKey='Europe/Paris', UserName='freuser@testorg.com',ZTS_EU_Market__c = 'France');
            insert u;
            List<Call__C> callList =new List<Call__c>();
            List<Event> eveList = new List<event>();
            Database.BatchableContext batch;
            System.runAs(u) {
                // The following code runs as user 'u'
                Account acc = new Account(Name = 'Test Account', Type = 'Farm', ZTS_EU_Market__c = 'United Kingdom', Practice_Management_Software__c = 'Other', Other_Practice_Management_Software__c = 'Sample Practice Management Software');
                insert acc;
                
                Call__C call = new Call__C(ZTS_EU_Sub_Type__c = 'Account Call', ZTS_EU_Account__c = acc.id, ZTS_EU_Start_Date_Time__c = Date.Today(), ZTS_EU_Duration__c = '0.5');
                callList.add(call);
                insert callList;
                
                Test.startTest();
                List<Attendee__c> attList = new List<Attendee__c>();
                Attendee__c att1 = new Attendee__c(Name = 'Test Attendee1', ZTS_EU_call__c = callList[0].id,ZTS_EU_Employee__c = u.id);
                Attendee__c att2 = new Attendee__c(Name = 'Test Attendee2', ZTS_EU_call__c = callList[0].id);
                Attendee__c att3 = new Attendee__c(Name = 'Test Attendee3', ZTS_EU_call__c = callList[0].id);
                attList.add(att1);
                attList.add(att2);
                attList.add(att3);
                insert attList;
                List<ZTS_EU_Discussion__c> disList = new List<ZTS_EU_Discussion__c>();
                ZTS_EU_Discussion__c discussion1 = new ZTS_EU_Discussion__c(Name = 'Test DI 1', ZTS_EU_Call_Attendee__c = attList[0].id);
                ZTS_EU_Discussion__c discussion2 = new ZTS_EU_Discussion__c(Name = 'Test DI 2', ZTS_EU_Call_Attendee__c = attList[1].id);
                disList.add(discussion1);
                disList.add(discussion2);
                insert disList;
                
                
                delete attList[2];
                updateCall.callUpdateOnAttendeeDelete(attList);             
                delete disList[1];
                ZTS_EU_Batch_callUpdateforActivities ap = new ZTS_EU_Batch_callUpdateforActivities();
                Database.executeBatch(ap);
                ap.execute(batch,callList);
            }
            Test.stopTest();
        }
}