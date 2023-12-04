@isTest
public class PIT_TestTestOrderedTrigger {


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
    
    public static PIT_Test_Ordered__c createTestOrdered(id stompId, String testOrderedRecordType, String test, Boolean doInsert) {
        PIT_Test_Ordered__c testordered = new PIT_Test_Ordered__c();
        testordered.PIT_STOMP__c = stompId;
        
        RecordType rtTestOrdered = [SELECT Id, DeveloperName 
                                  FROM RecordType 
                                     WHERE SObjectType = 'PIT_Test_Ordered__c'
                                     AND DeveloperName = :testOrderedRecordType];
        
        testordered.RecordTypeId = rtTestOrdered.id;

        testordered.PIT_Test__c = test;
        
        if(doInsert) {
            insert testordered;
        }
        
        return testordered;
    
    }
    
    public static void createCustomSettings() {
        PIT_Test_Cost__c testCost = new PIT_Test_Cost__c();
        testCost.Name = 'SEROLOGY_APP 10 ELISA_UOM';
        testCost.PIT_Cost__c = 7.75;
        testCost.PIT_Diagnostic_Lab__c = 'University of Minnesota';
        testCost.PIT_Test__c = 'APP 10 ELISA';
        testCost.PIT_Type__c = 'PAHUS_SEROLOGY_TEST';
        
        insert testCost;
    }
    
    

    public static testmethod void testBeforeInsert() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Mosby';
        usr.zts_eu_market__c = 'United States';
        insert usr;
                
        System.runAs(usr)
        {
            PIT_TestUtils.activateTriggerSettings();
            createCustomSettings();      
            Account acc = createAccount('testAccount', true);
            PIT_STOMP__c testSTOMP = createStomp(acc.id, true);
            testSTOMP.PIT_Diagnostic_Lab__c = 'University of Minnesota';
            update testSTOMP;
            
            PIT_Test_Ordered__c testordered = createTestOrdered(testSTOMP.id, 'PIT_Pig_Serology', 'APP 10 ELISA', true);
            testordered = [SELECT PIT_Cost__c FROM PIT_Test_Ordered__c WHERE id = :testordered.id];
            
            System.assertEquals(testordered.PIT_Cost__c, 7.75);
            update testordered;
            delete testordered;
            undelete testordered;
        }
        
    }
    
    @isTest 
    static void testPIT_StompDelete() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Mosby';
        usr.zts_eu_market__c = 'United States';
        insert usr;
                
        System.runAs(usr)
        {
            PIT_TestUtils.activateTriggerSettings();
            createCustomSettings();      
            Account acc = createAccount('testAccount', true);
            PIT_STOMP__c testSTOMP = createStomp(acc.id, true);
			
            Test.startTest();
            	delete testStomp;
            Test.stopTest();
            
            List<PIT_STOMP__c> actualPitStomp = [SELECT Id FROM PIT_STOMP__c WHERE Id = :testSTOMP.Id];
            
            System.assertEquals(0, actualPitStomp.size(), 'No stomp records should be returned');
        }
    }

}