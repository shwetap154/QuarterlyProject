/* -----------------------------------------------------------------------------------------------------------------------
   Name:        ZTS_EU_Batch_SmplHandlrFrInactivProdTest.cls
   Description: Test Class for Class ZTS_EU_Batch_SmplHandlrFrInactiveProduct.cls
                    
   Date         Version Author              Summary of Changes 
   -----------  ------- -----------------   ------------------------------------------------------------------------------
   03-07-2015   1.0     CloudSense(sohil)   Initial Version          
------------------------------------------------------------------------------------------------------------------------ */


@isTest
public class ZTS_EU_Batch_SmplHandlrFrInactivProdTest{
 
       static testMethod void TestZTS_EU_Batch_SmplHandlrFrInactiveProduct(){
            User usr = new User();
            usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            usr.FirstName = 'eltonUser';
            usr.zts_eu_market__c = 'United Kingdom';
            insert usr;
            System.runAs(usr)
            {
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            List<String> listOfApplicableMarkets = new  List<String>();
            listOfApplicableMarkets = ZTS_EU_Batch_SampleHandlerController.getListOfApplicableMarkets();
            
            Database.QueryLocator queryLoc;
            Database.BatchableContext BatchCont;
            
            ZTS_EU_Species_Product__c product1 = ZTS_EU_DataUtilityTest.createProduct('SKU', true);
            List<ZTS_EU_Species_Product__c> prodMainList =[Select ZTS_EU_Create_Samples__c,ZTS_EU_Is_Old__c,Is_Deactivated_Processed__c, ZTS_EU_is_Samplable__c,ZTS_EU_Is_Active__c from ZTS_EU_Species_Product__c where Id =: product1.Id];
            prodMainList[0].ZTS_EU_Create_Samples__c = false;
            prodMainList[0].ZTS_EU_Is_Old__c = False;
            prodMainList[0].ZTS_EU_is_Samplable__c=true;
            prodMainList[0].ZTS_EU_Is_Active__c = false;
             prodMainList[0].Is_Deactivated_Processed__c = false;
            update prodMainList;
            
            List<Contact> contList = ZTS_EU_DataUtilityTest.createContactRecord(4);
            contList[0].ZTS_EU_Create_Samples__c = False;
            contList[0].ZTS_EU_Contact_Status__c = 'Active';
            contList[0].ZTS_EU_Contact_type__c = 'Veterinarian';
            contList[0].ZTS_EU_Market__c ='Italy';
            insert contList;

            List<ZTS_EU_Species_Product__c> prdList =[Select Id, Name, ZTS_EU_Create_Samples__c, ZTS_EU_Is_Active__c, ZTS_EU_Market__c, ZTS_EU_Is_Old__c from ZTS_EU_Species_Product__c where id =: prodMainList[0].Id];
            List<ZTS_EU_Sample__c> sampleList = new List<ZTS_EU_Sample__c>();
            ZTS_EU_Sample__c sample = new ZTS_EU_Sample__c(ZTS_EU_Is_Active__c = true,ZTS_EU_Product__c =prodMainList[0].id,ZTS_EU_Contact__c = contList[0].id,ZTS_EU_Start_Quantity__c = 10 );
            sampleList.add(sample);
            insert sampleList;
            
            ZTS_EU_Batch_SmplHandlrFrInactiveProduct testBatch = new ZTS_EU_Batch_SmplHandlrFrInactiveProduct();
            Test.startTest();
            testBatch.execute(BatchCont,sampleList);
            integer bathcSize = integer.valueof(Label.ZTS_EU_BatchSizeForSamplesBatch);
            String CRON_EXP = '0 0 0 1 1 ? 2025';  
            String jobId = System.schedule('testScheduledApex', CRON_EXP, new Schedulable_SampleForInactivatedProduct() );
            CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];

            System.assertEquals(CRON_EXP, ct.CronExpression); 
            System.assertEquals(0, ct.TimesTriggered);
            System.assertEquals('2025-01-01 00:00:00', String.valueOf(ct.NextFireTime));  
            
            Test.stopTest();
            List<ZTS_EU_Species_Product__c> updatedRecords =[Select Id, Name, ZTS_EU_Create_Samples__c, ZTS_EU_Is_Active__c, ZTS_EU_Market__c, ZTS_EU_Is_Old__c from ZTS_EU_Species_Product__c where id =: prdList[0].Id];
            System.assertEquals(false,updatedRecords[0].ZTS_EU_Create_Samples__c);
            queryLoc= testBatch.start(BatchCont);
            System.debug('####Batch Context'+BatchCont);
            }
       }

}