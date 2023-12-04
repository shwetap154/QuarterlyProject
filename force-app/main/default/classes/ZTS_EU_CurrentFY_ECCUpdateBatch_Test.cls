@isTest
public class ZTS_EU_CurrentFY_ECCUpdateBatch_Test
{
    public static testMethod void TestZTS_EU_CurrentFY_ECCUpdateBatch()
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            List<Account> accs = ZTS_EU_DataUtilityTest.createAccountRecord(1);
           	Account acc = accs[0];
            acc.Name = 'Test Account';
            acc.Type = 'Farm';
            acc.ZTS_EU_District__c = 'XXXX';
            acc.ZTS_EU_Market__c='United Kingdom';
            acc.Practice_Management_Software__c = 'Other';
            acc.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
            insert acc;
            
            ZTS_EU_Territory__c	testTerritory = new ZTS_EU_Territory__c	(Name = 'TestSlalomTerr',
                                                                         ZTS_EU_Market__c = 'United Kingdom');
            insert testTerritory;  
            
            ZTS_EU_Position__c pos = new ZTS_EU_Position__c(ZTS_EU_Territory__c = testTerritory.Id, Market__c = 'United Kingdom');
            insert pos; 
            ZTS_EU_Account_Position__c ap = new ZTS_EU_Account_Position__c(ZTS_EU_Account__c = acc.id,ZTS_EU_Active__c = true, ZTS_EU_Position__c = pos.id, ZTS_EU_Call_Target__c = 1);
            insert ap;
            Call__c call = new Call__c(Name = 'Account call', ZTS_EU_Account__c = acc.id,ZTS_EU_Sub_Type__c = 'Account Call',ZTS_EU_Start_Date_Time__c = Date.Today(),ZTS_EU_Duration__c = '0.5');
            insert call;
            ZTS_EU_Colleague__c col = new ZTS_EU_Colleague__c(Name = 'Test Sohil', ZTS_EU_Call__c = call.id);
            insert col;
            ZTS_EU_Employee_Call_Credit__c ecc = new ZTS_EU_Employee_Call_Credit__c(ZTS_EU_Employee_Colleague__c = col.id, ZTS_EU_Account_Position__c= ap.id,ZTS_EU_Call__c=call.id, ZTS_EU_Counts_towards_Target__c = false);
            insert ecc;
            test.startTest();            
            String CRON_EXP = '0 0 0 1 1 ? 2025'; 
            String jobId = System.schedule('testScheduledApex', CRON_EXP, new ZTS_EU_CurrentFY_ECCUpdateBatchSchedule() );
            ZTS_EU_CurrentFY_ECCUpdateBatch.executeBatch();
            CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression); 
            System.assertEquals(0, ct.TimesTriggered);
            System.assertEquals('2025-01-01 00:00:00', String.valueOf(ct.NextFireTime)); 
            test.stopTest();
        }
    }
}