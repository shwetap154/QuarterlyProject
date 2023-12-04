/* -----------------------------------------------------------------------------------------------------------------------
   Name:        ZTS_EU_Batch_SampleHandler_NewYearTest.cls
   Description: Test Class for Class ZTS_EU_Batch_SampleHandler_NewYear.cls
                    
   Date         Version Author              Summary of Changes 
   -----------  ------- -----------------   ------------------------------------------------------------------------------
   22-01-2014   1.0     CloudSense(Shefali)   Initial Version          
------------------------------------------------------------------------------------------------------------------------ */


@isTest
public class ZTS_EU_Batch_SampleHandler_NewYearTest{
    static testMethod void testContacts(){
         	User usr = new User();
            usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            usr.FirstName = 'eltonUser';
            usr.zts_eu_market__c = 'United Kingdom';
            insert usr;
        	System.runAs(usr)
        	{
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            String CRON_EXP = '0 10 * * * ?';
            List<String> listOfApplicableMarkets = new  List<String>();
            listOfApplicableMarkets = ZTS_EU_Batch_SampleHandlerController.getListOfApplicableMarkets();
            Database.QueryLocator queryLoc;
            Database.BatchableContext BatchCont;
            
            List<Contact> contList = ZTS_EU_DataUtilityTest.createContactRecord(4);
            contList[0].ZTS_EU_Create_Samples__c = False;
            contList[0].ZTS_EU_Contact_Status__c = 'Active';
            contList[0].ZTS_EU_Contact_type__c = 'Veterinarian';
            contList[0].ZTS_EU_Market__c ='United Kingdom';
            insert contList;
            
            List<ZTS_EU_Sample__c> oldSampleList = new List<ZTS_EU_Sample__c>();
            ZTS_EU_Sample__c testSample = new ZTS_EU_Sample__c(ZTS_EU_Contact__c = contList[0].Id,ZTS_EU_Start_Quantity__c = 100,ZTS_EU_Is_Active__c = True,ZTS_EU_Year__c = '2014',ZTS_EU_Is_used_for_old_SKUs__c = true);
            oldSampleList.add(testSample);
            insert oldSampleList;
            
            ZTS_EU_Batch_SampleHandler_NewYear testBatch = new ZTS_EU_Batch_SampleHandler_NewYear();
            Test.startTest();
            testBatch.execute(BatchCont,oldSampleList);
            String jobId = System.schedule('ZTS_EU_Batch_SampleHandler_NewYear',CRON_EXP,new ZTS_EU_Schedulable_SampleHandler_NewYear());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP,ct.CronExpression);
            Test.stopTest();
            
            
            queryLoc= testBatch.start(BatchCont);
            System.debug('####Batch Context'+BatchCont);
            }
    }
            
            
}