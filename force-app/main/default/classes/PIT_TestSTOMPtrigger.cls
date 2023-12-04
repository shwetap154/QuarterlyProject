@isTest
public class PIT_TestSTOMPtrigger {


    public static Account createAccount(String name, Boolean doInsert) {
        
        List<Account> accs = ZTS_DataUtilityTest.createAccountRecord(1);
        Account acc = accs[0];
        acc.Name = name;
        
        if(doInsert) {
            insert acc;
        }
        
        return acc;
    
    }


    public static PIT_STOMP__c createStomp(id accId, Boolean doInsert) {
        PIT_STOMP__c testSTOMP = new PIT_STOMP__c();
        testSTOMP.PIT_Account__c = accId;
        
        if(doInsert) {
            insert testSTOMP;
        }
        
        return testSTOMP;
    
    }

    public static testmethod void testBeforeInsert() 
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Mosby';
        usr.zts_eu_market__c = 'United States';
        insert usr;
                
        System.runAs(usr)
        {
            PIT_TestUtils.activateTriggerSettings();     
            Account acc = createAccount('testAccount', true);
            PIT_STOMP__c testSTOMP = createStomp(acc.id, true);
            
            testSTOMP = [SELECT id, PIT_Owner_Manager__c FROM PIT_STOMP__c WHERE id = :testSTOMP.id];
            
            User runningUser = [SELECT id, ManagerId FROM User WHERE id = :UserInfo.getUserId() AND ZTS_EU_Market__c = 'United States'];
            System.assertEquals(testSTOMP.PIT_Owner_Manager__c, runningUser.ManagerId);
        }
    }

}