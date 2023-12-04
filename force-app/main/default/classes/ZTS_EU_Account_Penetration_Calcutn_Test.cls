/**
 * @description       : Test class for ZTS_EU_Account_Penetration_Calculation
 * @author            : Teresa @ Deloitte Consulting
 * @group             : 
 * @last modified on  : 07-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                          Modification
 * 1.0   04-09-2014   Teresa @ Deloitte Consulting    Created the Class.
 * 1.1   07-07-2022   Ethan Hirsch @ Zoetis Inc       Fix issues with inserting Potential Products that are not related to a Brand Product.
**/
@isTest
public class ZTS_EU_Account_Penetration_Calcutn_Test {
    static testMethod void CLARRegionTest() {
        /* Creating user records*/
        list<user> userRecs = new list<user>();
        Profile profiles=[Select Id From Profile Where Name='System Administrator'];
        userRecs.add(createNewUser(profiles.Id,'denem1e@deneme.com','denem1e@deneme.com','denme','Brazil')); 
        insert userRecs;
        
        system.runAs(userRecs[0]){
            
            list<MarketGeoMapping__c> MarketGeoMappingSetting = new list<MarketGeoMapping__c>();
            MarketGeoMappingSetting.add(createMarketGeoMappingSetting('Brazil','SKU','CLAR'));
            insert MarketGeoMappingSetting;
            
            
            set<string> objNames = new set<String>();
            objNames.add('Account');
            objNames.add('ZTS_EU_Species_Product__c');
            list<recordtype> recordtypesLst = new list<recordtype>();
            recordtypesLst = [select id, developerName,SobjectType from recordtype where SobjectType in :objNames ];
            
            map<string, string> recordtypeMap = new map<string, string>();
            
            for(Recordtype r : recordtypesLst){
                string objName_DeveloperName = r.SobjectType +'-'+ r.developerName;
                recordtypeMap.put(objName_DeveloperName, r.id);
                system.debug('objName_DeveloperName>>:'+objName_DeveloperName);
            }
            
            /*Creating Account record */
            list<Account> accountRecords = new list<account>();
            accountRecords.addAll(TestUtilities.createNoInsertVATcodeAccount('Acc','Farm','Beef',recordtypeMap.get('Account-ZTS_EU_Activated_Account'),'Brazil','1','111',false));
            accountRecords.addAll(TestUtilities.createNoInsertVATcodeAccount('Acc','Farm','Beef',recordtypeMap.get('Account-ZTS_EU_Activated_Account'),'Brazil','1','222',false));
            accountRecords.addAll(TestUtilities.createNoInsertVATcodeAccount('Acc','Farm','Beef',recordtypeMap.get('Account-ZTS_EU_Activated_Account'),'Brazil','1','333',false));
            
            if(accountRecords.size() > 0){
                insert accountRecords;
            }
            
            
            
            
            /*Creating Product Hierarchy records */
            
            ZTS_EU_Species_Product__c buRecord = new ZTS_EU_Species_Product__c();
            buRecord = TestUtilities.createNoInsertBrand('Ph 1','Business Unit','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-Business_Unit'));
            buRecord.ZTS_EU_Business_Unit_Abbr__c = 'SW';
            insert buRecord;
            
            ZTS_EU_Species_Product__c tgRecord = new ZTS_EU_Species_Product__c();
            tgRecord = TestUtilities.createNoInsertBrand('Ph 1','Therapeutic Group','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-Therapeutic_Group'));
            insert tgRecord;
           
            ZTS_EU_Species_Product__c brandRecord = new ZTS_EU_Species_Product__c();
            brandRecord = createProdHierarchyRecord('Ph 2','Brand','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-Brand'),tgRecord.id);
            insert brandRecord;
           
            ZTS_EU_Species_Product__c mpgRecord = new ZTS_EU_Species_Product__c();
            mpgRecord = createProdHierarchyRecord('Ph 2','MPG','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-MPG'),brandRecord.id);
            insert mpgRecord;
           
            ZTS_EU_Species_Product__c skuRecord = new ZTS_EU_Species_Product__c();
            skuRecord = createProdHierarchyRecord('Ph 2','SKU','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-SKU'),mpgRecord.id);
            skuRecord.ZTS_EU_Standard_Price__c = 20;
            skuRecord.ZTS_EU_Product_Unique_ID__c = 'P-0000017109';
            insert skuRecord;
            
            
            
            system.debug('skuRecord.ZTS_EU_Standard_Price__c>>>'+skuRecord.ZTS_EU_Standard_Price__c);
            /* Creating ZTS_EU_Species__c records */
            list<ZTS_EU_Species__c> speciesRecords = new list<ZTS_EU_Species__c>();
            for(integer i=0; i<5; i++){
                speciesRecords.add(TestUtilities.createNoInsertSpecies('Specie',buRecord.id,'Specie name','Brazil'));
            }
            insert speciesRecords;
            
            /* Creating ZTS_EU_Potential_Brands__c records */
            list<ZTS_EU_Potential_Brands__c> pb = new list<ZTS_EU_Potential_Brands__c>();
            for(ZTS_EU_Species__c z:speciesRecords ){
                pb.add(TestUtilities.createNoInsertPotBrands(z.id,brandRecord.id,1,1,1,1));
            }
            
            for(ZTS_EU_Potential_Brands__c z:pb ){
                z.Number_of_Doses_per_SKU__c = 20;
            }
            
            insert pb;
            
            /* Creating ZTS_EU_Potential_Brands__c records */
            list<ZTS_EU_Account_Species_Potential__c> accSpecieConsulatation = new list<ZTS_EU_Account_Species_Potential__c>();
            accSpecieConsulatation.add(TestUtilities.createNoInsertAcctSpcPot(accountRecords[0].id,speciesRecords[0].id,20,20));
            insert accSpecieConsulatation;
            ZTS_EU_Sales__c zs= createSales(accountRecords[0].id,skuRecord.Id,10,20,10,1);
            insert zs;
            
            
            ZTS_EU_Account_Product_Potential__c accProdPotential = createAccProdPotential(accSpecieConsulatation[0].id, accountRecords[0].id,tgRecord.id, 'P-0000017109', 'Ph 2', 20,11);
            insert accProdPotential;
            
            
            test.startTest();
            
            pageReference pf = page.ZTS_EU_AccountPenetrationCalculation;
            Test.setCurrentPage(pf);
            pf.getParameters().put('accountId', accountRecords[0].id);
            pf.getParameters().put('accountName', 'NAme');
            pf.getParameters().put('potentialRegion', '1');
            ApexPages.StandardController sc = new ApexPages.StandardController(accountRecords[0]);
            ZTS_EU_Account_Penetration_Calculation appc2 = new ZTS_EU_Account_Penetration_Calculation(sc);
            appc2.reRenderTGSectionInBUTab();
            appc2.reRenderTGSectionInSpecieTab();
            
            appc2.filterDataAllCLARBusinessUnitTab();
            appc2.refreshData();
            appc2.refreshData();
            integer x = appc2.getpageNumBU();
            x = appc2.gettotalNumOfPagesBU();
            appc2.getRecordsByBU();
            appc2.getshowPrevBU();
            appc2.getshowNextBU();
            appc2.nextBU();
            appc2.previousBU();
            appc2.goToFirstPageBU();
            appc2.goToLastPageBU();
            
            appc2.getRecordsBySP();
            appc2.nextSP();
            appc2.previousSP();
            appc2.goToFirstPageSP();
            appc2.goToLastPageSP();
            appc2.getpageNumSP();
            appc2.gettotalNumOfPagesSP();
            appc2.getshowPrevSP();
            appc2.getshowNextSP();
            appc2.refreshData();
            appc2.refreshSpeciesTab();
            appc2.pageNumSP = 1;
            appc2.getshowPrevSP();
            appc2.allSpeciesList.clear();
            appc2.getshowNextSP();
            appc2.pageNumBU = 1;
            appc2.getshowPrevBU();
            appc2.allUnitsSpeciesList.clear();
            appc2.getshowNextBU();
            
            ZTS_EU_Account_Penetration_Calculation appc3 = new ZTS_EU_Account_Penetration_Calculation(sc);
            appc3.filterDataAllCLARSpeciesTab();
            
            test.stopTest();
            
        }
    }
    
    static testMethod void EUAFMERegionTest() {
        /* Creating user records*/
        list<user> userRecs = new list<user>();
        Profile profiles=[Select Id From Profile Where Name='System Administrator'];
        userRecs.add(createNewUser(profiles.Id,'denem1e@deneme.com','denem1e@deneme.com','denme','United Kingdom')); 
        insert userRecs;
        
        system.runAs(userRecs[0]){
            
            list<MarketGeoMapping__c> MarketGeoMappingSetting = new list<MarketGeoMapping__c>();
            MarketGeoMappingSetting.add(createMarketGeoMappingSetting('United Kingdom','BRAND','EUAFME'));
            insert MarketGeoMappingSetting;
            
            
            set<string> objNames = new set<String>();
            objNames.add('Account');
            objNames.add('ZTS_EU_Species_Product__c');
            list<recordtype> recordtypesLst = new list<recordtype>();
            recordtypesLst = [select id, developerName,SobjectType from recordtype where SobjectType in :objNames ];
            
            map<string, string> recordtypeMap = new map<string, string>();
            
            for(Recordtype r : recordtypesLst){
                string objName_DeveloperName = r.SobjectType +'-'+ r.developerName;
                recordtypeMap.put(objName_DeveloperName, r.id);
            }
            
            /*Creating Account record */
            list<Account> accountRecords = new list<account>();
            accountRecords.addAll(TestUtilities.createNoInsertAccount('Acc','Farm','Beef',recordtypeMap.get('Account-ZTS_EU_Activated_Account'),'United Kingdom','1',false));
            accountRecords.addAll(TestUtilities.createNoInsertAccount('Acc','Farm','Beef',recordtypeMap.get('Account-ZTS_EU_Activated_Account'),'United Kingdom','1',false));
            accountRecords.addAll(TestUtilities.createNoInsertAccount('Acc','Farm','Beef',recordtypeMap.get('Account-ZTS_EU_Activated_Account'),'United Kingdom','1',false));
            
            if(accountRecords.size() > 0){
                insert accountRecords;
            }
            
            
            
            
            /*Creating Product Hierarchy records */
            
            ZTS_EU_Species_Product__c buRecord = new ZTS_EU_Species_Product__c();
            buRecord = TestUtilities.createNoInsertBrand('Ph 2','Business Unit','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-Business_Unit'));
            buRecord.ZTS_EU_Business_Unit_Abbr__c = 'SW';
            insert buRecord;
            
            ZTS_EU_Species_Product__c tgRecord = new ZTS_EU_Species_Product__c();
            tgRecord = TestUtilities.createNoInsertBrand('Ph 3','Therapeutic Group','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-Therapeutic_Group'));
            insert tgRecord;
           
            ZTS_EU_Species_Product__c brandRecord = new ZTS_EU_Species_Product__c();
            brandRecord = createProdHierarchyRecord('Ph 1','Brand','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-Brand'),tgRecord.id);
            insert brandRecord;
           
            ZTS_EU_Species_Product__c mpgRecord = new ZTS_EU_Species_Product__c();
            mpgRecord = createProdHierarchyRecord('Ph 4','MPG','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-MPG'),brandRecord.id);
            insert mpgRecord;
           
            ZTS_EU_Species_Product__c skuRecord = new ZTS_EU_Species_Product__c();
            skuRecord = createProdHierarchyRecord('Ph 5','SKU','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-SKU'),mpgRecord.id);
            skuRecord.ZTS_EU_Standard_Price__c = 20;
            skuRecord.ZTS_EU_Product_Unique_ID__c = 'P-0000017109';
            insert skuRecord;
            
            
            
            system.debug('skuRecord.ZTS_EU_Standard_Price__c>>>'+skuRecord.ZTS_EU_Standard_Price__c);
            /* Creating ZTS_EU_Species__c records */
            list<ZTS_EU_Species__c> speciesRecords = new list<ZTS_EU_Species__c>();
            for(integer i=0; i<5; i++){
                speciesRecords.add(TestUtilities.createNoInsertSpecies('Specie',buRecord.id,'Specie name','United Kingdom'));
            }
            insert speciesRecords;
            
            /* Creating ZTS_EU_Potential_Brands__c records */
            list<ZTS_EU_Potential_Brands__c> pb = new list<ZTS_EU_Potential_Brands__c>();
            for(ZTS_EU_Species__c z:speciesRecords ){
                pb.add(TestUtilities.createNoInsertPotBrands(z.id,brandRecord.id,1,1,1,1));
            }
            
            for(ZTS_EU_Potential_Brands__c z:pb ){
                z.Number_of_Doses_per_SKU__c = 20;
            }
            
            insert pb;
            
            /* Creating ZTS_EU_Potential_Brands__c records */
            list<ZTS_EU_Account_Species_Potential__c> accSpecieConsulatation = new list<ZTS_EU_Account_Species_Potential__c>();
            accSpecieConsulatation.add(TestUtilities.createNoInsertAcctSpcPot(accountRecords[0].id,speciesRecords[0].id,20,20));
            insert accSpecieConsulatation;
            ZTS_EU_Sales__c zs= createSales(accountRecords[0].id,brandRecord.Id,10,20,10,1);
            insert zs;
            
            
            test.startTest();
            
            pageReference pf = page.ZTS_EU_AccountPenetrationCalculation;
            Test.setCurrentPage(pf);
            pf.getParameters().put('accountId', accountRecords[0].id);
            pf.getParameters().put('accountName', 'NAme');
            pf.getParameters().put('potentialRegion', '1');
            pf.getParameters().put('businessUnit', 'businessUnit');
            ApexPages.StandardController sc = new ApexPages.StandardController(accountRecords[0]);
            ZTS_EU_Account_Penetration_Calculation appc = new ZTS_EU_Account_Penetration_Calculation(sc);
            appc.filterDataForTGSection();
            appc.filterDataAll();
            appc.refreshData();
            appc.refreshSpeciesTab();
            test.stopTest();
            
        }
    }
    public static ZTS_EU_Species_Product__c createProdHierarchyRecord(String speciesProdName,String recType,String Market,String recTypeId,string parentRecord){
         ZTS_EU_Species_Product__c speciesProdRec = new ZTS_EU_Species_Product__c(Name= speciesProdName,
                                                                                  ZTS_EU_Type__c= recType ,
                                                                                  ZTS_EU_Market__c= Market,
                                                                                  RecordTypeID = recTypeId,
                                                                                  ZTS_EU_Parent_Species_Product__c = parentRecord);
                                                                            
         return speciesProdRec;                                                                           
    }
    public static ZTS_EU_Account_Product_Potential__c createAccProdPotential(id accSpecieConsultationID, id accountId,id prodHierarchyId, string prodId, string prodName, double prodPotential, decimal PAC_1 ){
         ZTS_EU_Account_Product_Potential__c AccProdPotential = new ZTS_EU_Account_Product_Potential__c(Account_Species_Consultation__c = accSpecieConsultationID,
                                                                                                        Account__c = accountId,
                                                                                                        Product_Hierarchy__c = prodHierarchyId,
                                                                                                        ZTS_EU_Product_ID_1__c= prodId,
                                                                                                        ZTS_EU_Product_Name_1__c = prodName,
                                                                                                        ZTS_EU_Product_Potential_1__c = prodPotential,
                                                                                                        PAC_1__c = PAC_1 );
                                                                            
         return AccProdPotential;                                                                           
    }
    
    
    public static MarketGeoMapping__c createMarketGeoMappingSetting(string name, string potentialLevel,string geo){
         MarketGeoMapping__c marketGeoMapping = new MarketGeoMapping__c(name = name,Product_Potential_Level__c = potentialLevel,Geo__c = geo);
         return marketGeoMapping;                                                                           
    }
    
    public static ZTS_EU_Sales__c createSales(id accId,id prodId,decimal ZTS_EU_Total_MAT_Current_Sales,decimal ZTS_EU_Total_CYTD_Sales, decimal ZTS_EU_Total_PYTD_Sales,decimal ZTS_EU_Total_MAT_Prior_Sales){
         ZTS_EU_Sales__c sales = new ZTS_EU_Sales__c(ZTS_EU_Account__c = accId,
                                                     ZTS_EU_Product__c = prodId,
                                                     ZTS_EU_Date__c = date.valueOf(system.today() -1),
                                                     name = 'asdas',
                                                     ZTS_EU_Total_MAT_Current_Sales__c = ZTS_EU_Total_MAT_Current_Sales,
                                                     ZTS_EU_Total_CYTD_Sales__c = ZTS_EU_Total_CYTD_Sales,
                                                     ZTS_EU_Total_PYTD_Sales__c = ZTS_EU_Total_PYTD_Sales,
                                                     ZTS_EU_Total_MAT_Prior_Sales__c = ZTS_EU_Total_MAT_Prior_Sales);
         return sales;                                                                           
    }
    
    public static user createNewUser(id profileId,string email,string uname,string alias,string market){
        User newuser=new User();
        newuser.profileid=profileId;
        newuser.email=email;
        newuser.username=uname;
        newuser.lastname='lastname';
        newuser.alias=alias;
        newuser.languagelocalekey='en_US';
        newuser.localesidkey='en_US';
        newuser.timezonesidkey='America/Los_Angeles';
        newuser.localesidkey='en_US';
        newUser.ZTS_EU_Market__c= market;
        newUser.EmailEncodingKey= 'ISO-8859-1';
        return newUser;
    }
}