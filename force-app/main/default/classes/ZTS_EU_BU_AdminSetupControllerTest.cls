/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_BU_AdminSetupControllerTest
* Description   :  This is the test class for the coverage of the class ZTS_EU_BU_AdminSetupController

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     27th-Apr-15   Shreyas             Created the class.

********************************************************************************************************************************************/

@isTest (seealldata = false)
Public class ZTS_EU_BU_AdminSetupControllerTest{


    public static testMethod void testMethod1(){
     /* Creating user records*/
    list<user> userRecs = new list<user>();
        Profile profiles=[Select Id From Profile Where Name='System Administrator'];
        List<User> usersList = new List<User>();
        User newuser=new User();
        newuser.profileid=profiles.Id;
        newuser.email='denem1e@deneme.com';
        newuser.username='deneme1@deneme1.com';
        newuser.lastname='denme';
        newuser.alias='dene1';
        newuser.languagelocalekey='en_US';
        newuser.localesidkey='en_US';
        newuser.timezonesidkey='America/Los_Angeles';
        newuser.localesidkey='en_US';
        newUser.ZTS_EU_Market__c= 'United Kingdom';
        newUser.EmailEncodingKey= 'ISO-8859-1';
        userRecs.add(newuser); 
        insert userRecs;
        
        system.runAs(userRecs[0]){
    
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
          
          MarketGeoMapping__c csObj = new MarketGeoMapping__c();
          csObj.name = 'United Kingdom';
          csObj.Geo__c = 'EUAFME';
          csObj.Product_Potential_Level__c = 'SKU';
          insert csObj;
          
          
        ZTS_EU_SetAdjustmentFactorsController AdjFacObj = new ZTS_EU_SetAdjustmentFactorsController();
        
        ZTS_EU_BU_AdminSetupController obj1 = new ZTS_EU_BU_AdminSetupController(AdjFacObj);
        
        obj1.SelectedMarket = 'United Kingdom'; 
        
         List<String> bgList = new List<String>();
        bgList.add('Test Brand');
        obj1.SelectedBrandGroups = bgList;
        
        List<String> tgList = new List<String>();
        tgList.add('Test TG');
        obj1.SelectedTGGroups = tgList;
        
        obj1.getOptions();
        
        String buList = 'SW';
        obj1.SelectedBusinessUnit = buList;
        
        obj1.getOptions();
        
        obj1.potentialLevel = 'SKU';
        obj1.SelectedBusinessUnit= 'SW';
        obj1.populateBrands();
        obj1.populateSpecies();
        
        obj1.SelectedSpecies = 'Specie';
        obj1.setFactors();
        obj1.populateSKUs();
        obj1.Cancel();
        
        ZTS_EU_BU_AdminSetupController.ListCollection innerObj1 = new ZTS_EU_BU_AdminSetupController.ListCollection();
        
      }
    }



    public static testMethod void testMethod2(){
    
     /* Creating user records*/
    list<user> userRecs = new list<user>();
        Profile profiles=[Select Id From Profile Where Name='System Administrator'];
        List<User> usersList = new List<User>();
        User newuser=new User();
        newuser.profileid=profiles.Id;
        newuser.email='denem1e@deneme.com';
        newuser.username='deneme1@deneme1.com';
        newuser.lastname='denme';
        newuser.alias='dene1';
        newuser.languagelocalekey='en_US';
        newuser.localesidkey='en_US';
        newuser.timezonesidkey='America/Los_Angeles';
        newuser.localesidkey='en_US';
        newUser.ZTS_EU_Market__c= 'Canada';
        newUser.EmailEncodingKey= 'ISO-8859-1';
        userRecs.add(newuser); 
        insert userRecs;
        
        system.runAs(userRecs[0]){
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
          tgRecord = TestUtilities.createNoInsertBrand('Test TG','Therapeutic Group','Canada',recordtypeMap.get('ZTS_EU_Species_Product__c-Therapeutic_Group'));
          insert tgRecord;
         
          ZTS_EU_Species_Product__c brandRecord = new ZTS_EU_Species_Product__c();
          brandRecord = Account_Prod_Potential_Calculation_Test.createProdHierarchyRecord('Test Brand','Brand','Canada',recordtypeMap.get('ZTS_EU_Species_Product__c-Brand'),tgRecord.id);
          insert brandRecord;
         
          ZTS_EU_Species_Product__c mpgRecord = new ZTS_EU_Species_Product__c();
          mpgRecord = Account_Prod_Potential_Calculation_Test.createProdHierarchyRecord('Test MPG','MPG','Canada',recordtypeMap.get('ZTS_EU_Species_Product__c-MPG'),brandRecord.id);
          insert mpgRecord;
         
          ZTS_EU_Species_Product__c skuRecord = new ZTS_EU_Species_Product__c();
          skuRecord = Account_Prod_Potential_Calculation_Test.createProdHierarchyRecord('Test SKU','SKU','Canada',recordtypeMap.get('ZTS_EU_Species_Product__c-SKU'),mpgRecord.id);
          insert skuRecord;
          skuRecord.ZTS_EU_Product_Potential_Level__c='SKU';
          update skuRecord;
          
          ZTS_EU_Species_Product__c buRecord = new ZTS_EU_Species_Product__c();
          buRecord = TestUtilities.createNoInsertBrand('Test BU','Business Unit','Canada',recordtypeMap.get('ZTS_EU_Species_Product__c-Business_Unit'));
          buRecord.ZTS_EU_Business_Unit_Abbr__c = 'CA';
          insert buRecord;
          
          list<ZTS_EU_Species__c> speciesRecords = new list<ZTS_EU_Species__c>();
          for(integer i=0; i<5; i++){
            speciesRecords.add(TestUtilities.createNoInsertSpecies('Specie',buRecord.id,'Specie name','Canada'));
          }
          insert speciesRecords;
          
          list<ZTS_EU_Potential_Brands__c> pb = new list<ZTS_EU_Potential_Brands__c>();
          for(ZTS_EU_Species__c z:speciesRecords ){
            pb.add(TestUtilities.createNoInsertPotBrands(z.id,skuRecord.id,1,1,1,1));
          }
          
          
          insert pb;
          
          if(!pb.isEmpty())
          {
            for(ZTS_EU_Potential_Brands__c pb1:pb)
            {
              pb1.Protocol_For_CA__c='A';
              pb1.ZTS_EU_CA_Account_Type__c='Hospitals';
            }  
          }
          update pb;
          MarketGeoMapping__c csObj = new MarketGeoMapping__c();
          csObj.name = 'Canada';
          csObj.Geo__c = 'CLAR';
          csObj.Product_Potential_Level__c = 'SKU';
          insert csObj;
          
          MarketGeoMapping__c csObj1 = new MarketGeoMapping__c();
          csObj1.name = 'United Kingdom';
          csObj1.Geo__c = 'EUAFME';
          csObj1.Product_Potential_Level__c = 'Brand';
          insert csObj1;
          
        ZTS_EU_SetAdjustmentFactorsController AdjFacObj = new ZTS_EU_SetAdjustmentFactorsController();
        
        ZTS_EU_BU_AdminSetupController obj1 = new ZTS_EU_BU_AdminSetupController(AdjFacObj);
        ZTS_EU_BU_AdminSetupController.BrandsCheckBoxWrapper brandwrapper= new ZTS_EU_BU_AdminSetupController.BrandsCheckBoxWrapper();
        ZTS_EU_BU_AdminSetupController.ListCollection paginate = new ZTS_EU_BU_AdminSetupController.ListCollection();
        
        obj1.filterByMarket();
        obj1.SelectedMarket = 'Canada'; 
        obj1.potentialLevel = 'SKU';
        obj1.SelectedBusinessUnit= 'CA';  
        obj1.populateSpecies();
        obj1.SelectedSpecies='Specie';
        List<String> tgList = new List<String>();
        tgList.add('Test TG');
        obj1.getOptions();
        obj1.selectedTGGroups= tgList;
        
        obj1.populateBrands();
        List<String> bgList = new List<String>();
        bgList.add('Test Brand');
        obj1.SelectedBrandGroups = bgList;

        obj1.getprotocolForCAOptions();
        obj1.getcAAccountTypeOptions();
        
        obj1.selectedCAAccountType='Hospitals';
        obj1.selectedProtocolForCA='A';
        obj1.populateSKUs();
        
        brandwrapper.brandSelect=true;
        obj1.setFactors();
        
        
        obj1.SelectedMarket = 'United Kingdom'; 
        obj1.filterByMarket();
        obj1.getCheckRegionOfMarket();
        obj1.potentialLevel = 'Brand';
        obj1.SelectedBusinessUnit= 'CA';
        obj1.populateBrands();
        
        }
        
    }







}