/* -----------------------------------------------------------------------------------------------------------------------
   Name:        ZTS_EU_Batch_AnimalConsultations_Test.cls
   Description: Test Class for ZTS_EU_Batch_AnimalConsultations and ZTS_EU_Schedulable_AnimalConsultations.cls
                    
   Date            Version Author              Summary of Changes 
   -----------    ------- -----------------   ------------------------------------------------------------------------------
   3rd-July-2015   1.0     CloudSense(Shreyas)   Initial Version          
------------------------------------------------------------------------------------------------------------------------ */


@isTest (seeAllData=false)
public class ZTS_EU_Batch_AnimalConsultations_Test{

    static testmethod void testMethod1() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            MarketGeoMapping__c marketGeoMappingObj = new MarketGeoMapping__c();
            marketGeoMappingObj.Geo__c = 'CLAR';
            marketGeoMappingObj.Name = 'Brazil';
            insert marketGeoMappingObj;
            MarketGeoMapping__c marketGeoMappingObj1 = new MarketGeoMapping__c();
            marketGeoMappingObj1.Geo__c = 'EUAFME';
            marketGeoMappingObj1.Name = 'Belgium';
            insert marketGeoMappingObj1;
            
            ExcludefromPotentialCopyJob__c excludedcopymarket = new ExcludefromPotentialCopyJob__c();
            excludedcopymarket.Market__c = 'Canada';
            excludedcopymarket.Name = 'Canada';
            insert excludedcopymarket;
            
            List<Account> accList = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            accList[0].ZTS_EU_Market__c = 'Brazil';
            accList[0].ZTS_EU_VAT_Code__c= 'VAT-20167';
            insert accList;
            
            List<ZTS_EU_Species_Product__c> buList = ZTS_EU_DataUtilityTest1.createProductBURecord(1);
            buList[0].ZTS_EU_Market__c = 'Brazil';
            insert buList;
            
            List<ZTS_EU_Species__c> speciesList = ZTS_EU_DataUtilityTest1.createSpeciesRecord(1);
            speciesList[0].ZTS_EU_Market__c = 'Brazil';
            speciesList[0].ZTS_EU_Business_Unit__c = buList[0].Id;
            insert speciesList;
            
            
            ZTS_EU_Account_Species_Potential__c asp = new ZTS_EU_Account_Species_Potential__c();
            asp.Account__c = accList[0].Id;
            asp.ZTS_EU_Species_Potential__c = speciesList[0].Id;
            asp.ZTS_EU_Animal_Consultations_new__c = 10;
            asp.ZTS_EU_Animal_Consultations_new__c = 5;
            insert asp;
            
            Test.StartTest();
            String CRON_EXP = '0 0 0 1 1 ? 2025';  
            String jobId = System.schedule('testScheduledApex', CRON_EXP, new ZTS_EU_Schedulable_AnimalConsultations() );
            
            CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];

            System.assertEquals(CRON_EXP, ct.CronExpression); 
            System.assertEquals(0, ct.TimesTriggered);
            System.assertEquals('2025-01-01 00:00:00', String.valueOf(ct.NextFireTime));
                        
            Test.StopTest();
        }
    }

}