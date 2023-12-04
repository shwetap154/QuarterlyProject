/**
* @ClassName    : SL_BatchCaseAndRotorTransaction_Test 
* @JIRATicket   : LIGHTNI-1802
* @CreatedOn    : 21st November, 2019
* @CreatedBy    : Chetna
* @ModifiedBy   : Mohamed
* @ModifiedOn    : 8/27/2020
* @Description  : Test class for SL_BatchToInsertCaseAndRotorTransaction
*/
@isTest
public class SL_BatchCaseAndRotorTransaction_Test{
    @testSetup 
    public static void setup(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'Austria';
        insert usr;
        System.runAs(usr)
        {
            List<Account> lstAccounts = new List<Account>();
            List<Rotor_Transaction__c> lstRotorTransactions = new List<Rotor_Transaction__c>();
            for(Integer i=0;i<50;i++){
                Account objAccount = (Account)SL_TestDataFactory.createSObject(new Account(Name='Test Account'+i, ZTS_EU_Market__c='Austria', ZTS_EU_Zip_Postal_Code__c='1111111'));
                lstAccounts.add(objAccount); 
            }
            
            insert lstAccounts; 
            
            
            for(Integer i=0;i<50;i++){
                Rotor_Transaction__c objRotorTransaction = (Rotor_Transaction__c)SL_TestDataFactory.createSObject(new Rotor_Transaction__c(Rotor_Credit__c=12+i, Account__c =lstAccounts[i].Id));
                lstRotorTransactions.add(objRotorTransaction); 
            }
            insert lstRotorTransactions;
        }
        
    }
    @isTest
    public static void checkCaseAndRotorTransactionInserted(){

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'Austria';
        insert usr;
        System.runAs(usr)
        {
            List<Account> lstAccounts = new List<Account>([SELECT Id, Name, Rotor_Credit_Roll_Up_Sum__c, ZTS_EU_Market__c FROM Account WHERE Name Like 'Test Account%']);
            List<Rotor_Transaction__c> lstRotorTransactions = new List<Rotor_Transaction__c>([SELECT Id, Account__c, Rotor_Credit__c 
                                                                                                FROM Rotor_Transaction__c 
                                                                                                WHERE Rotor_Credit__c > 12 AND Account__c IN: lstAccounts]);
            test.startTest();
            
                Database.executeBatch(new SL_BatchToInsertCaseAndRotorTransaction());
            
            test.stopTest();
            system.assertEquals(50, [SELECT Id, AccountId, Number_of_Boxes__c FROM Case WHERE AccountId IN: lstAccounts AND Number_of_Boxes__c > 0].size(), '50 cases should be created');
            system.assertEquals(50, [SELECT Id, Account__c, Rotor_Credit__c FROM Rotor_Transaction__c WHERE Account__c IN: lstAccounts AND Rotor_Credit__c < 0].size(), '50 Rotor Transaction should have the negative Rotor_Credit__c');
            system.assertEquals(50, [SELECT Id, Account__c, Rotor_Credit__c, Locked__c FROM Rotor_Transaction__c WHERE Account__c IN: lstAccounts AND Locked__c = TRUE].size(), '100 Rotor Transaction should have the Locked__c = TRUE');
        }
    
    }
    
    //Art Smorodin @Slalom 07/30/20 - this is unnecessary for batchable class test
    @isTest
    public static void SchedulableTest() 
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'Austria';
        insert usr;
        System.runAs(usr)
        {
            String CRON_EXP = '0 1 * * * ?';
            SL_RotorTransactionBatchSchedule ObjSchedule = new SL_RotorTransactionBatchSchedule();
            String jobId = System.schedule('Test SL_RotorTransactionBatchSchedule class', CRON_EXP, ObjSchedule);
            System.assert(jobId != null);
        }
    }
}