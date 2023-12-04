@IsTest
public class ContactAttendeeCleanupBatch_Test {

    @isTest static void testattendeecleanup(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;

        System.runAs(usr)
        {
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            List<Contact> c = ZTS_DataUtilityTest.createContactRecord(1);
            c[0].ZTS_EU_Market__c = 'United States';
            c[0].RecentCallers__c = 'Contact Caller';
            insert c;
            List<Call__c> calllist = ZTS_DataUtilityTest.createCallRecord(1);
            calllist[0].ZTS_EU_Call_Owner__c = UserInfo.getUserId();
            insert calllist;
            List<Attendee__c> attList = ZTS_DataUtilityTest.createAttendee(1);
            attList[0].ZTS_EU_Contact__c = c[0].Id;
            attList[0].ZTS_EU_call__c = calllist[0].Id;
            insert attList;
            Test.startTest();          
            ContactAttendeeCleanupBatch batch = new ContactAttendeeCleanupBatch();
            DataBase.executeBatch(batch);
            //batch.execute(null, attList);
            Test.stopTest();

            List<Contact> contactList = [SELECT Id, RecentCallers__c FROM Contact];
            
            System.assertEquals('Contact Caller;'+UserInfo.getUserId(), contactList[0].RecentCallers__c, 'The value of RecentCallers__c must be updated to RecentCallers__c + ";" + Call.ZTS_EU_Call_Owner__c');
        }
    }
}