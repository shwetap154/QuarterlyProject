/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_SetAdjustmentFactorsCtrlTest
* Description   :  This is the test class for the coverage of the class ZTS_EU_SetAdjustmentFactorsController

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     27th-Apr-15   Shreyas             Created the class.

********************************************************************************************************************************************/

@isTest (seealldata = false)
Public class ZTS_EU_SetAdjustmentFactorsCtrlTest{


    public static testMethod void testMethod1(){
    
        set<string> objNames = new set<String>();
        objNames.add('ZTS_EU_Species_Product__c');
        list<recordtype> recordtypesLst = new list<recordtype>();
        recordtypesLst = [select id, developerName,SobjectType from recordtype where SobjectType in :objNames ];
          
        map<string, string> recordtypeMap = new map<string, string>();
          
          for(Recordtype r : recordtypesLst){
            string objName_DeveloperName = r.SobjectType +'-'+ r.developerName;
            recordtypeMap.put(objName_DeveloperName, r.id);
            system.debug('objName_DeveloperName>>:'+objName_DeveloperName);
          }
          
          ZTS_EU_Species_Product__c tgRecord = new ZTS_EU_Species_Product__c();
          tgRecord = TestUtilities.createNoInsertBrand('Test TG','Therapeutic Group','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-Therapeutic_Group'));
          insert tgRecord;
         
          ZTS_EU_Species_Product__c brandRecord = new ZTS_EU_Species_Product__c();
          brandRecord = Account_Prod_Potential_Calculation_Test.createProdHierarchyRecord('Test Brand','Brand','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-Brand'),tgRecord.id);
          insert brandRecord;
         
          ZTS_EU_Species_Product__c mpgRecord = new ZTS_EU_Species_Product__c();
          mpgRecord = Account_Prod_Potential_Calculation_Test.createProdHierarchyRecord('Test MPG','MPG','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-MPG'),brandRecord.id);
          insert mpgRecord;
         
          ZTS_EU_Species_Product__c skuRecord = new ZTS_EU_Species_Product__c();
          skuRecord = Account_Prod_Potential_Calculation_Test.createProdHierarchyRecord('Test SKU','SKU','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-SKU'),mpgRecord.id);
          insert skuRecord;
          skuRecord.ZTS_EU_Product_Potential_Level__c='SKU';
          update skuRecord;
          
        ZTS_EU_Species_Product__c buRecord = new ZTS_EU_Species_Product__c();
          buRecord = TestUtilities.createNoInsertBrand('Test BU','Business Unit','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-Business_Unit'));
          buRecord.ZTS_EU_Business_Unit_Abbr__c = 'SW';
          insert buRecord;
          
          list<ZTS_EU_Species__c> speciesRecords = new list<ZTS_EU_Species__c>();
          for(integer i=0; i<5; i++){
            speciesRecords.add(TestUtilities.createNoInsertSpecies('Specie',buRecord.id,'Specie name','United Kingdom'));
          }
          insert speciesRecords;
          
        list<ZTS_EU_Potential_Brands__c> pb = new list<ZTS_EU_Potential_Brands__c>();
          for(ZTS_EU_Species__c z:speciesRecords ){
            pb.add(TestUtilities.createNoInsertPotBrands(z.id,skuRecord.id,1,1,1,1));
          }
          
          insert pb;
          
        ZTS_EU_SetAdjustmentFactorsController obj = new ZTS_EU_SetAdjustmentFactorsController();
        
        obj.zone1 = 'zone1';
        obj.adjustmentFactor = '1';
        obj.numberOfDosesPerSku = 2;
        obj.productRotation = 2;
        obj.numOfDosesPerMl = 2;
        obj.annualNoOfTreatments = 2;
        obj.mpgSKUMix = 2;
        obj.price = '200';
        
        
        
        obj.potentialBrandsToUpsert = pb;
        obj.goToSetAdjustmentFactors();
        obj.getUnitOptions();
        obj.getCurrencyOptions();
        obj.cancelAction();
        obj.saveAction();
        
    
    }
    
    
    
}