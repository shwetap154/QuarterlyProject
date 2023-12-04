@isTest
public class CarystaOpportunityBatchSchedulerTest {
     /*
     static testmethod void testScheduler() {  
         
        User usrAdmin = new User();
        usrAdmin = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usrAdmin.FirstName = 'davidsUser';
        usrAdmin.zts_eu_market__c = 'United Kingdom';
        insert usrAdmin;
        
        System.runAs(usrAdmin)
        {         
            Id carystaRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CARYSTA_HVC').getRecordTypeId(); 
            List<Call__c> calls = ZTS_DataUtilityTest.createSOCallRecord(2);  
            calls.add(new Call__c(Name = 'Test carysta',Opportunity_Type__c = 'CARYSTA HVC', ZTS_EU_Account__c = calls[0].ZTS_EU_Account__c, ZTS_EU_Status__c = 'submitted'));
            insert calls; 
            Opportunity o = new Opportunity(Name='Test',StageName='New Lead Received (Petcare/Conference/Other)',CloseDate=System.today(),RecordTypeId=carystaRecTypeId, AccountId = calls[0].ZTS_EU_Account__c);  
            insert o;
            List<Opportunity> ops = new List<Opportunity>();
            ops.add(o);
            Test.startTest();          
            CarystaOpportunityBatch batch = new CarystaOpportunityBatch();
            DataBase.executeBatch(batch);
            batch.execute(null, ops);
            Test.stopTest();
        }
        
       
    }*/
	
	static testmethod void schedulerTest() 
    {
        User usrAdmin = new User();
        usrAdmin = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usrAdmin.FirstName = 'davidsUser';
        usrAdmin.zts_eu_market__c = 'United Kingdom';
        insert usrAdmin;
        
        System.runAs(usrAdmin)
        {
            String CRON_EXP = '0 0 0 15 3 ? *';
            
            Account acc = new Account();
            acc.name= 'test';
            acc.BillingPostalCode = '00000';
            acc.BillingCity = 'testCity';
            acc.BillingState = 'testState';
            acc.BillingStreet = 'testStreet';
            insert acc;
            
            Test.startTest();
    
                String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new CarystaOpportunityBatch());
                CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
                System.assertEquals(CRON_EXP, ct.CronExpression);
                System.assertEquals(0, ct.TimesTriggered);
    
            Test.stopTest();
        }
        
    }
}