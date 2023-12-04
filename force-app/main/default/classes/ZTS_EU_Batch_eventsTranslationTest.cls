@isTest
public class ZTS_EU_Batch_eventsTranslationTest
{
    static testMethod void TestZTS_EU_Batch_eventsTranslation()
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            List<Call__C> callList =new List<Call__c>();
            List<Event> eveList = new List<event>();
            Account acc = new Account(Name = 'Test Account', Type = 'Farm',
                ZTS_EU_Market__c='United Kingdom',
                Practice_Management_Software__c = 'Other',
                Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                ZTS_EU_Zip_Postal_Code__c='12345');
            insert acc;
            
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
            Database.BatchableContext batch;
            test.startTest();
            insert callList;
            
            
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
            
            string querys = '';
            ZTS_EU_Batch_eventsTranslation ap = new ZTS_EU_Batch_eventsTranslation(querys);
            Database.executeBatch(ap);
            ap.execute(batch,eveList);
            test.stopTest();
        }
    }
}