@IsTest
public class CntctAttndCleanupBatchNoCaller_test {

    @IsTest
    static void testattendeecleanupnocaller(){
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.LastName = 'user';
        usr.zts_eu_market__c = 'United States';
        insert usr;

        System.runAs(usr){
            List<Account> a = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            a[0].ZTS_EU_Market__c='United States';
            insert a;
        
            List<Contact> c = ZTS_DataUtilityTest.createContactRecord(1);
            c[0].ZTS_EU_Market__c='United States';
            c[0].ZTS_US_Profession__c = 'Academia';
            c[0].ZTS_US_Job_Function__c= 'Clinical Faculty';
            c[0].RecentCallers__c = UserInfo.getUserId();
            c[0].ZTS_EU_Contact_Status__c = 'Active';
            c[0].ZTS_EU_Last_Call_Date__c = System.today().addDays(-365);
            c[0].AccountId = a[0].Id;
            insert c;
            
            String recentCaller = [Select RecentCallers__c from Contact where id =: c[0].id limit 1].RecentCallers__c;
            system.debug('recentCaller -->'+ recentCaller);
/*
            List<Call__c> calllist = ZTS_DataUtilityTest.createCallRecord(1);
            calllist[0].ZTS_EU_Call_Owner__c = UserInfo.getUserId();

            insert calllist;

            List<Attendee__c> attList = ZTS_DataUtilityTest.createAttendee(1);
            attList[0].ZTS_EU_Contact__c = c[0].Id;
            attList[0].ZTS_EU_call__c = calllist[0].Id;
            insert attList;*/
    
            Test.startTest();   
                ContactAttendeeCleanupBatchNoCallers batch = new ContactAttendeeCleanupBatchNoCallers();
                DataBase.executeBatch(batch);
            Test.stopTest();
            
            List<Contact> cons = [SELECT Id, RecentCallers__c FROM Contact];
        	system.debug('cons data -->'+ cons[0].RecentCallers__c);
        	System.assert( String.isBlank(cons[0].RecentCallers__c), 'Recent callers is cleared' );
        }  

        
    }
}