public class allCallUpdateTest
{
    /* static void TestAllCallUpdate()
    {
        Recordtype recordType = [select Id, Name from Recordtype where Name = 'Activated Account'];
        Account acc = new Account(recordTypeId = recordType.id, Name='Test',Type='Analyst');
        insert acc;
        Call__c call = new Call__c(ZTS_EU_Account__c = acc.id,ZTS_EU_Sub_Type__c = 'Account Call',ZTS_EU_Start_Date_Time__c=datetime.newInstance(2014, 9, 15, 12, 30, 0));
        insert call;
        Attendee__c att = new Attendee__c(Name='Hello User',ZTS_EU_call__c = call.id);
        Attendee__c att1 = new Attendee__c(Name='Hello User1',ZTS_EU_call__c = call.id);
        List<Attendee__c> attList = new List<Attendee__c>();
        attList.add(att);
        attList.add(att1);
        insert attList;
        ZTS_EU_Discussion__c dis = new ZTS_EU_Discussion__c(Name='Test Discussion',ZTS_EU_Call_Attendee__c = att.id);
        ZTS_EU_Discussion__c dis1 = new ZTS_EU_Discussion__c(Name='Test Discussion1',ZTS_EU_Call_Attendee__c = att1.id);
        List<ZTS_EU_Discussion__c> disList = new List<ZTS_EU_Discussion__c>();
        disList.add(dis);
        disList.add(dis1);
        insert disList;
        String query = 'Select Id, Name, ZTS_EU_Account__c, Contact_Employee__c,Contact_Employee_Count__c, Discussion_Item__c,Discussion_Item_Count__c from Call__c';
        Test.startTest();       
        ZTS_EU_Batch_callUpdateforActivities c = new ZTS_EU_Batch_callUpdateforActivities(query);        
        Database.executeBatch(c);
        //updateCall.callUpdate(attList);
        //updateCallonDiscussion.callUpdateOnDiscussionInsert(disList);
        delete disList[1];
        delete attList[1];
        
        Test.stopTest();

    }   */
}