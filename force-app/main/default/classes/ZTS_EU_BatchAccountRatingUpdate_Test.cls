/* -----------------------------------------------------------------------------------------------------------------------
   Name:        ZTS_EU_BatchAccountRatingUpdate_Test.cls
   Description: Test Class for Batch Apex ZTS_EU_BatchAccountSegmentationUpdate.cls
                    
   Date         Version   Author             Summary of Changes 
   -----------  -------   -----------------  ------------------------------------------------------------------------------
   14-09-2017   1.0       Mayukh             Initial Version          
------------------------------------------------------------------------------------------------------------------------ */
@isTest
private class ZTS_EU_BatchAccountRatingUpdate_Test{
    /*******************************************************************
    Purpose:  Method to create test data                                                     
    Parameters: none
    Returns: none
    *******************************************************************/ 
    private static String Brazil = 'Brazil';
    private static String busUnit = 'Business Unit';
    private static String brand = 'Brand';
    
    static void setUpData(Account account){
        List<ZTS_EU_Account_Species_Potential__c> acctSpeciesPotList = new List<ZTS_EU_Account_Species_Potential__c>();
        List<ZTS_EU_Species_Product__c> prodHierarchyList = new List<ZTS_EU_Species_Product__c>();
        List<ZTS_EU_Species__c> speciesList = new List<ZTS_EU_Species__c>();
        List<ZTS_EU_Potential_Brands__c> potBrandList = new List<ZTS_EU_Potential_Brands__c>();
        List<Account_Segmentation_threshold__c> thresholdList = new List<Account_Segmentation_threshold__c>();
        String busUnitRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Business_Unit'].Id;
        String brandRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Brand'].Id;
        system.debug('busUnitRecordTypeId');
        system.debug('brandRecordTypeId');
        ZTS_EU_Species_Product__c prodHier1 = TestUtilities.createNoInsertBusUnit('Companion Animals',busUnit,Brazil,'CA',busUnitRecordTypeId);
        prodHierarchyList.add(prodHier1);   
        
        ZTS_EU_Species_Product__c prodHier2 = TestUtilities.createNoInsertBusUnit('Swine',busUnit,Brazil,'SW',busUnitRecordTypeId);
        prodHierarchyList.add(prodHier2);
        
        ZTS_EU_Species_Product__c prodHier3 = TestUtilities.createNoInsertBrand('Draxxin',brand,Brazil,brandRecordTypeId);
        prodHierarchyList.add(prodHier3);
        
        Database.insert(prodHierarchyList,false);
        
        ZTS_EU_Species__c species1 = TestUtilities.createNoInsertSpecies('Dog',prodHierarchyList[0].id,'Dog',Brazil);
        speciesList.add(species1);
        
        ZTS_EU_Species__c species2 = TestUtilities.createNoInsertSpecies('Pigeon',prodHierarchyList[1].id,'Pigeon',Brazil);
        speciesList.add(species2);
        
        Database.insert(speciesList,false);
        
        List<ZTS_EU_Species__c> insertedSpecies = [SELECT Name, Id FROM ZTS_EU_Species__c ];
        
        ZTS_EU_Potential_Brands__c potBrand1 = TestUtilities.createNoInsertPotBrands(speciesList[0].Id,prodHierarchyList[2].Id,10,5,5,5);
        potBrandList.add(potBrand1);
        
        ZTS_EU_Potential_Brands__c potBrand2 = TestUtilities.createNoInsertPotBrands(speciesList[1].Id,prodHierarchyList[2].Id,5,2,2,2);
        potBrandList.add(potBrand2);
        
        Database.insert(potBrandList,false);
        
        ZTS_EU_Account_Species_Potential__c ascRec1 = TestUtilities.createNoInsertAcctSpcPot(account.Id,speciesList[0].Id,5,5);
        acctSpeciesPotList.add(ascRec1);  
        
        ZTS_EU_Account_Species_Potential__c ascRec2 = TestUtilities.createNoInsertAcctSpcPot(account.Id,speciesList[1].Id,5,5);
        acctSpeciesPotList.add(ascRec2);                                                                                           
        
        Database.SaveResult[] srList = Database.insert(acctSpeciesPotList,false);
        
        List<ZTS_EU_Account_Species_Potential__c> insertedAccountPotential = [SELECT ZTS_EU_Species_Potential__c, ZTS_EU_Animal_Consultations_new__c, ZTS_EU_Animals_Consultations_actual__c, Calculated_Value_of_Potentail__c FROM ZTS_EU_Account_Species_Potential__c ];
        
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted record. RecordID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Fields that affected this error: ' + err.getFields());
                }
            }
        }
        
        Account_Segmentation_threshold__c thre1 = TestUtilities.createNoInsertAccountSegmentationThreshold(Brazil,'CA',0,1000,'C3');
        Account_Segmentation_threshold__c thre2 = TestUtilities.createNoInsertAccountSegmentationThreshold(Brazil,'CA',1000,3000,'C2');
        Account_Segmentation_threshold__c thre3 = TestUtilities.createNoInsertAccountSegmentationThreshold(Brazil,'CA',3000,10000,'C1'); 
        Account_Segmentation_threshold__c thre4 = TestUtilities.createNoInsertAccountSegmentationThreshold(Brazil,'RU',0,10000,'A');                                                                             
        Account_Segmentation_threshold__c thre5 = TestUtilities.createNoInsertAccountSegmentationThreshold(Brazil,'RU',10000,999999,'K');
        Account_Segmentation_threshold__c thre6 = TestUtilities.createNoInsertAccountSegmentationThreshold(Brazil,'CT BF',0,15000,'BF-1');
        Account_Segmentation_threshold__c thre7 = TestUtilities.createNoInsertAccountSegmentationThreshold(Brazil,'CT BF',15000,999999,'BF-K');
        Account_Segmentation_threshold__c thre8 = TestUtilities.createNoInsertAccountSegmentationThreshold(Brazil,'CT FL',0,12000,'FL-1');
        Account_Segmentation_threshold__c thre9 = TestUtilities.createNoInsertAccountSegmentationThreshold(Brazil,'CT FL',12001,25000,'FL-2');
        Account_Segmentation_threshold__c thre10 = TestUtilities.createNoInsertAccountSegmentationThreshold(Brazil,'CT FL',25000,999999,'FL-K');
        Account_Segmentation_threshold__c thre11 = TestUtilities.createNoInsertAccountSegmentationThreshold(Brazil,'All',0,1000000,'OA1');
        thresholdList.add(thre1);
        thresholdList.add(thre2);
        thresholdList.add(thre3);
        thresholdList.add(thre4);
        thresholdList.add(thre5);
        thresholdList.add(thre6);
        thresholdList.add(thre7);
        thresholdList.add(thre8);
        thresholdList.add(thre9);
        thresholdList.add(thre10);
        thresholdList.add(thre11);
        
        Database.insert(thresholdList,false);
        system.debug('thresholdlist inserted-->'+thresholdList);
        
        MarketGeoMapping__c gmcs = new MarketGeoMapping__c(Geo__c='CLAR',Name = 'Mexico');
        insert gmcs;
    }
    
    /*******************************************************************
     Purpose: Test Method to run the batch class                                                 
     Parameters: none
     Returns: none
     *******************************************************************/ 
    static testMethod void testAccSegBatch(){
        User user = ZTS_EU_DataUtilityTest.createUtilityUser(true,' ',' ',Brazil);
        System.runAs(user){
            Test.StartTest();
            String busUnitRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Business_Unit'].Id;
            MarketGeoMapping__c mcs = new MarketGeoMapping__c(Geo__c='CLAR',Name = 'Brazil');
            insert mcs;
            
            ZTS_EU_Exception_Potential_Calculation__c expc = new ZTS_EU_Exception_Potential_Calculation__c(Name ='Brazil',ZTS_EU_Market__c='Brazil',
                                                                                                           ZTS_EU_Potential_Fields_to_Sum_up__c='CT BF;CT DY;CT FL',
                                                                                                           ZTS_EU_BU__c='RU');
            insert expc;
            
            String acctRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'ZTS_EU_Activated_Account'].Id;
            
            Account accRecord = TestUtilities.createNoInsertAccountRecord('TestAcct','Farm','Dairy',acctRecordTypeId,Brazil,'1',false); 
            accRecord.ZTS_EU_VAT_Code__c='12345';
            Database.insert(accRecord);
            system.debug('accounts inserted-->'+accRecord); 
            setUpData(accRecord);
            
            String CRON_EXP = '0 0 0 1 1 ? 2025';
            String jobId = System.schedule('testScheduledApex', CRON_EXP, new ZTS_EU_AcctRatBatchScheduler() );
            CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
            System.assertEquals('2025-01-01 00:00:00', String.valueOf(ct.NextFireTime));
            Test.StopTest();
            
            Account acc = [Select Id,Name,ZTS_EU_All_Rating__c,ZTS_EU_RAT_SW__c,ZTS_EU_RAT_CA__c from Account WHERE Id = :accRecord.Id AND ZTS_EU_Market__c != 'United States'];
            String BURecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Business_Unit'].Id;
            ZTS_EU_Species_Product__c prodHier = TestUtilities.createNoInsertBusUnit('Companion Animals',busUnit,Brazil,'CA',busUnitRecordTypeId);
            Database.insert(prodHier,false);
            ZTS_EU_Species_Product__c prodHier1 = TestUtilities.createNoInsertBusUnit('Cattle Beef',busUnit,Brazil,'CT BF',busUnitRecordTypeId);
            Database.insert(prodHier1,false);
            ZTS_EU_Species_Product__c prodHier2 = TestUtilities.createNoInsertBusUnit('Cattle Feedlot',busUnit,Brazil,'CT FL',busUnitRecordTypeId);
            Database.insert(prodHier2,false);
            
            ZTS_EU_Species__c specie = TestUtilities.createNoInsertSpecies('Dog',prodHier.id,'Dog',Brazil);
            Database.insert(specie,false);
            ZTS_EU_Species__c specie1 = TestUtilities.createNoInsertSpecies('Beef Cow',prodHier1.id,'Beef Cow',Brazil);
            Database.insert(specie1,false);
            ZTS_EU_Species__c specie2 = TestUtilities.createNoInsertSpecies('Feedlot Calves',prodHier2.id,'Feedlot Calves',Brazil);
            Database.insert(specie2,false);
            
            ZTS_EU_Potential_Brands__c potBrand = TestUtilities.createNoInsertPotBrands(specie.Id,prodHier.Id,100,50,50,50);
            Database.insert(potBrand,false);
            ZTS_EU_Potential_Brands__c potBrand1 = TestUtilities.createNoInsertPotBrands(specie.Id,prodHier1.Id,100,70,70,70);
            Database.insert(potBrand1,false); 
            ZTS_EU_Potential_Brands__c potBrand2 = TestUtilities.createNoInsertPotBrands(specie.Id,prodHier2.Id,100,60,60,60);
            Database.insert(potBrand2,false); 
            
            ZTS_EU_Account_Species_Potential__c accSpecPot = TestUtilities.createNoInsertAcctSpcPot(accRecord.Id,specie.Id,5,5);
            Database.insert(accSpecPot,false);
            ZTS_EU_Account_Species_Potential__c accSpecPot1 = TestUtilities.createNoInsertAcctSpcPot(accRecord.Id,specie1.Id,15,15);
            Database.insert(accSpecPot1,false);
            ZTS_EU_Account_Species_Potential__c accSpecPot2 = TestUtilities.createNoInsertAcctSpcPot(accRecord.Id,specie2.Id,5,5);
            Database.insert(accSpecPot2,false);
            
            System.assert(accRecord.ZTS_EU_CA_Potential__c == accSpecPot.Calculated_Value_of_Potentail__c, 'Potential on account should be calculated properly.');      
        }   
    }
    static testMethod void testwebservice1(){
		ZTS_EU_AccountRatingBatchWebservice.scheduleBatch();
    }
    static testMethod void testwebservice2(){
		
    }  
}