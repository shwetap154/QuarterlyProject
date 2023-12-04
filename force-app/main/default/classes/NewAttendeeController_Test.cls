@isTest
public class NewAttendeeController_Test {
    public static List<Account>accList= new List<Account>();
    public static testMethod void validate_setConCont()
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            accList = ZTS_DataUtilityTest.createAccountRecord(1,5);
            Test.startTest();
            for(Account acc:accList){
                acc.ZTS_US_NARC_ID__c='NC12345';
            }
            insert accList;
            
            List<Contact> contList = ZTS_DataUtilityTest.createContactRecord(4);
            for(Contact c : contList){
                c.AccountId = accList[0].Id;
            }
            insert contList;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(accList[0]);
            NewAttendeeController newatt = new NewAttendeeController(sc);
            test.stopTest();
        }
    }   
}