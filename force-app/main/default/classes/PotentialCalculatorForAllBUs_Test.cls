/*
    @@ Puropose: Test class for "CA" 
    @@ Author: Mamta Chintalapudi
*/
@isTest
public class PotentialCalculatorForAllBUs_Test {

  static testmethod void CAPotentialCalculator_Test_Method(){
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
        newUser.ZTS_EU_Market__c= 'Brazil';
        newUser.EmailEncodingKey= 'ISO-8859-1';
        userRecs.add(newuser); 
        insert userRecs;
        
        system.runAs(userRecs[0]){
          list<Acc_Prod_Pot_Markets__c> accProdSettings = new list<Acc_Prod_Pot_Markets__c>();
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Sunday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Monday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Tuesday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Wednesday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Thursday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Friday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Saturday','Brazil,Canada'));
          insert accProdSettings;
          
          list<MarketGeoMapping__c> MarketGeoMappingSetting = new list<MarketGeoMapping__c>();
          MarketGeoMappingSetting.add(Account_Prod_Potential_Calculation_Test.createMarketGeoMappingSetting('Brazil','SKU'));
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
          accountRecords.addAll(createNoInsertAccount('Acc','Farm','Beef',recordtypeMap.get('Account-ZTS_EU_Activated_Account'),'Brazil','1',false,'<=2','Basic','>100m2','1'));
          accountRecords.addAll(createNoInsertAccount('Acc1','Farm','Beef',recordtypeMap.get('Account-ZTS_EU_Activated_Account'),'Brazil','1',false,'<=2','Basic','>100m2','2'));
          if(accountRecords.size() > 0){
            insert accountRecords;
            
            for(Account accnt:accountRecords)
             {
               accnt.ZTS_EU_CA_Account_Type__c='Hospitals';
               accnt.Key_Account__c=True;
             }
             
            
            update accountRecords; 
           }
          
       
          /*Creating Product Hierarchy records */
          
          ZTS_EU_Species_Product__c buRecord = new ZTS_EU_Species_Product__c();
          buRecord = TestUtilities.createNoInsertBrand('Ph 1','Business Unit','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-Business_Unit'));
          buRecord.ZTS_EU_Business_Unit_Abbr__c = 'CA';
          buRecord.ZTS_EU_Standard_Price__c = 20;
          insert buRecord;
          system.debug('buRecord.ZTS_EU_Standard_Price__c>>>'+buRecord);
          ZTS_EU_Species_Product__c tgRecord = new ZTS_EU_Species_Product__c();
          tgRecord = TestUtilities.createNoInsertBrand('Ph 1','Therapeutic Group','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-Therapeutic_Group'));
          tgRecord.ZTS_EU_Standard_Price__c = 20;
          insert tgRecord;
         
          ZTS_EU_Species_Product__c brandRecord = new ZTS_EU_Species_Product__c();
          brandRecord = Account_Prod_Potential_Calculation_Test.createProdHierarchyRecord('Ph 2','Brand','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-Brand'),tgRecord.id);
          brandRecord.ZTS_EU_Standard_Price__c = 20;
          insert brandRecord;
         
          ZTS_EU_Species_Product__c mpgRecord = new ZTS_EU_Species_Product__c();
          mpgRecord = Account_Prod_Potential_Calculation_Test.createProdHierarchyRecord('Ph 2','MPG','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-MPG'),brandRecord.id);
          mpgRecord.ZTS_EU_Standard_Price__c = 20;
          insert mpgRecord;
         
          ZTS_EU_Species_Product__c skuRecord = new ZTS_EU_Species_Product__c();
          skuRecord = createProdHierarchyRecord('Ph 2','SKU','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-SKU'),mpgRecord.id,1);
          insert skuRecord;
          
          skuRecord.ZTS_EU_Product_Potential_Level__c='SKU';
          update skuRecord;
          /* Key Account Product Price Records */
          
          Key_Account_Product_Price__c accnt_price= new Key_Account_Product_Price__c();
          accnt_price.Account__c=accountRecords[0].id;
          accnt_price.Price__c=1234.00;
          accnt_price.Product__c=skuRecord.id;
          insert accnt_price;
          List<Key_Account_Product_Price__c> keyAccntList = new List<Key_Account_Product_Price__c>();
          keyAccntList.add(accnt_price);
          
          /* Creating ZTS_EU_Species__c records */
          list<ZTS_EU_Species__c> speciesRecords = new list<ZTS_EU_Species__c>();
          for(integer i=0; i<5; i++){
            speciesRecords.add(TestUtilities.createNoInsertSpecies('Specie',buRecord.id,'Specie name','Brazil'));
          }
          insert speciesRecords;
          
        
          /* Creating ZTS_EU_Potential_Brands__c records */
          list<ZTS_EU_Potential_Brands__c> pb = new list<ZTS_EU_Potential_Brands__c>();
          for(ZTS_EU_Species__c z:speciesRecords ){
            pb.add(createNoInsertPotBrands(z.id,skuRecord.id,1,1,1,1,2,2,2,22,2));
          }
          
          insert pb;
          set<id> st = new set<id>();
          set<id> productHierst= new set<id>();
          for(ZTS_EU_Potential_Brands__c z:pb ){
            z.ZTS_EU_CA_Account_Type__c='Hospitals';
            z.Potential_Factor__c=True;
            z.Protocol_For_CA__c='A';
            st.add(z.id);
            productHierst.add(z.brand__c);
          }
          
          update pb;
          List<ZTS_EU_Species_Product__c> productWithTG=[select id,ZTS_EU_Product_Potential_Level__c,ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c from  ZTS_EU_Species_Product__c where id in:productHierst and ZTS_EU_type__c='SKU'];
          set<id> TGIds = new set<id>();
          for(ZTS_EU_Species_Product__c sp : productWithTG){
                            if(sp.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c != null){
                                TGIds.add(sp.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c);
                            }
                }
                map<id,list<ZTS_EU_Species_Product__c>> tGroupSpecieProd = new map<id,list<ZTS_EU_Species_Product__c>>();
                for(Id i : TGIds){
                    list<ZTS_EU_Species_Product__c> tmpLst = new list<ZTS_EU_Species_Product__c>();
                    for(ZTS_EU_Species_Product__c sp: productWithTG){
                        if(i == sp.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c){
                            tmpLst.add(sp);
                        }
                    }
                    if(!tmpLst.isEmpty()){
                        tGroupSpecieProd.put(i,tmpLst);
                    }
                }
                    
       List<ZTS_EU_Potential_Brands__c> productHierarchies = [Select Protocol_For_CA__c,brand__r.ZTS_EU_Product_Potential_Level__c,CurrencyIsoCode,name,ZTS_EU_CA_Account_Type__c,brand__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c,brand__r.name,brand__r.ZTS_EU_Product_Unique_ID__c,brand__r.ZTS_EU_Influenced_By_Farm_Subsistence__c, brand__r.ZTS_EU_Influenced_By_Farm_Artificial_Sem__c,Adjustment_Factor__c,Annual_Number_of_treatments_Animal__c,Brand__c,ZTS_EU_Business_Unit_Abbr__c,MPG_SKU_Mix__c, Number_of_Doses_per_Animal__c,Number_of_Doses_per_SKU__c,Potential__c,Potential_Factor__c,Price_Doses_or_ml__c,Price_SKU__c,Product_Rotation__c,ZTS_EU_Value_Region_1__c,ZTS_EU_Value_Region_2__c,ZTS_EU_Value_Region_3__c,ZTS_EU_Value_Region_4__c From ZTS_EU_Potential_Brands__c z where id=:st];               
                          
          Map<Id, Map<Id, List<ZTS_EU_Potential_Brands__c>>> speciePotentialProd = new  Map<Id, Map<Id, List<ZTS_EU_Potential_Brands__c>>>();
         List<ZTS_EU_Potential_Brands__c> pBsWithSameTg = new List<ZTS_EU_Potential_Brands__c>();
           Map<id,List<ZTS_EU_Potential_Brands__c>> prodTgMap = new Map<id,List<ZTS_EU_Potential_Brands__c>>();
          for(ZTS_EU_Potential_Brands__c pbh:productHierarchies)
           {

               pBsWithSameTg.add(pbh);
               prodTgMap.put(pbh.brand__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c,pBsWithSameTg);
               speciePotentialProd.put(pbh.Potential__c,prodTgMap);
           
           }
          
          
          /* Creating ZTS_EU_Potential_Brands__c records */
          list<ZTS_EU_Account_Species_Potential__c> accSpecieConsulatation = new list<ZTS_EU_Account_Species_Potential__c>();
          for(Account acc: accountRecords){
            accSpecieConsulatation.add(TestUtilities.createNoInsertAcctSpcPot(acc.id,speciesRecords[0].id,20,20));
          }
          
          insert accSpecieConsulatation;

          ZTS_EU_Account_Product_Potential__c accProdPotential = Account_Prod_Potential_Calculation_Test.createAccProdPotential(accSpecieConsulatation[0].id, accountRecords[0].id,tgRecord.id, tgRecord.id, 'Name', 20);
          insert accProdPotential;
          
          test.startTest();
          
                  list<ZTS_EU_Species_Product__c> products = new list<ZTS_EU_Species_Product__c>();
          products.add(buRecord);
          products.add(tgRecord);
          products.add(brandRecord);
          products.add(mpgRecord);
          products.add(skuRecord);
          Set<String> markets= new Set<String>();
          markets.add('Brazil');
          list<ZTS_EU_Account_Species_Potential__c> ascp = [Select CurrencyIsoCode,name,Number_of_Animal_Interval__c,ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__r.ZTS_EU_Business_Unit_Abbr__c,ZTS_EU_Animal_Consultations_new__c,ZTS_EU_Animals_Consultations_actual__c,Account__c,ZTS_EU_BU_Abbr__c,Calculated_Value_of_Potentail__c,ZTS_EU_Animals_bought_from_other_herds__c,ZTS_EU_No_of_Nelore_Cattle_In_Genetic__c,ZTS_EU_No_of_Purebred_Animals__c,ZTS_EU_No_of_Slaughtered_Cattle__c,ZTS_EU_Species_Potential__c,ZTS_EU_Species_Potential_Value__c,ZTS_EU_Sum_Of_Account_Product_Potentials__c,ZTS_EU_Uniqueness_Key__c From ZTS_EU_Account_Species_Potential__c z where id=:accSpecieConsulatation[0].id ];
          PotentialCalculatorEngine pa = new PotentialCalculatorEngine(markets);
          list<ZTS_EU_Species_Product__c> specieProd=  [Select ZTS_EU_NO_OF_CA_Species__c,ZTS_EU_NO_OF_EQ_Species__c,ZTS_EU_NO_OF_PY_Species__c,ZTS_EU_NO_OF_RU_Species__c,ZTS_EU_Sales_Budgets_SB__c,ZTS_EU_NO_OF_SW_Species__c,ZTS_EU_NO_OF_VPS_Species__c,ZTS_EU_Brand_is_Budgetable__c,ZTS_EU_BU_from_Brand__c,ZTS_EU_Business_Unit_Abbr__c,ZTS_EU_Business_Units__c,ZTS_EU_Create_Samples__c,ZTS_EU_Gift_Type__c,ZTS_EU_Gift_Value__c,ZTS_EU_Influenced_By_Farm_Artificial_Sem__c,ZTS_EU_Influenced_By_Farm_Subsistence__c,ZTS_EU_Influenced_By_Fattening_Mgmnt__c,ZTS_EU_Influenced_By_Purebreed_Calves__c,ZTS_EU_Influenced_By_Nutritional_Mgmnt__c,ZTS_EU_Influenced_By_Other_Herds_Animals__c,ZTS_EU_Influenced_By_Reproductive_Mgmnt__c,ZTS_EU_Is_Active__c,ZTS_EU_is_an_Internal_competitor__c,ZTS_EU_is_Budgetable__c,ZTS_EU_is_Child_of_Brand__c,ZTS_EU_Is_Detailable__c,ZTS_EU_is_Gift__c,ZTS_EU_Is_KOL_Area_of_Expertise__c,ZTS_EU_Is_Old__c,ZTS_EU_Is_Orderable__c,ZTS_EU_is_Samplable__c,ZTS_EU_Standard_Price__c,ZTS_EU_Market__c,ZTS_EU_Parent_Species_Product__c,ZTS_EU_Product_Potential_Level__c,ZTS_EU_Product_Unique_ID__c,ZTS_EU_SAP_Product_ID__c,ZTS_EU_Total_Budget_SB__c,ZTS_EU_Type__c,ZTS_EU_Zoetis_SFDC_ID__c,CurrencyIsoCode,name From ZTS_EU_Species_Product__c z where id=:tgRecord.id];
          pa.productsPerTherGroup=tGroupSpecieProd;
          pa.speciePotentialProd=speciePotentialProd;
          List<ZTS_EU_Account_Product_Potential__c> aa = pa.calculatePotential(accountRecords[0], ascp,keyAccntList);
          test.stopTest();
          
        }
        
    
        
  }
  
  static testmethod void CattlePotentialCalculator_Test_Method(){
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
        newUser.ZTS_EU_Market__c= 'Brazil';
        newUser.EmailEncodingKey= 'ISO-8859-1';
        userRecs.add(newuser); 
        insert userRecs;
        
        system.runAs(userRecs[0]){
          list<Acc_Prod_Pot_Markets__c> accProdSettings = new list<Acc_Prod_Pot_Markets__c>();
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Sunday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Monday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Tuesday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Wednesday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Thursday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Friday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Saturday','Brazil,Canada'));
          insert accProdSettings;
          
          list<MarketGeoMapping__c> MarketGeoMappingSetting = new list<MarketGeoMapping__c>();
          MarketGeoMappingSetting.add(Account_Prod_Potential_Calculation_Test.createMarketGeoMappingSetting('Brazil','SKU'));
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
          accountRecords.addAll(createNoInsertAccount('Acc','Farm','Beef',recordtypeMap.get('Account-ZTS_EU_Activated_Account'),'Brazil','1',false,'<=2','Basic','>100m2','3'));
          accountRecords.addAll(createNoInsertAccount('Acc1','Farm','Beef',recordtypeMap.get('Account-ZTS_EU_Activated_Account'),'Brazil','1',false,'<=2','Basic','>100m2','4'));
          if(accountRecords.size() > 0){
            insert accountRecords;
            
            for(Account accnt:accountRecords)
             {
               accnt.ZTS_EU_CA_Account_Type__c='Hospitals';
               accnt.Key_Account__c=True;
             }
             
            
            update accountRecords; 
           }
          
       
          /*Creating Product Hierarchy records */
          
          ZTS_EU_Species_Product__c buRecord = new ZTS_EU_Species_Product__c();
          buRecord = TestUtilities.createNoInsertBrand('Ph 1','Business Unit','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-Business_Unit'));
          buRecord.ZTS_EU_Business_Unit_Abbr__c = 'CT FL';
          buRecord.ZTS_EU_Standard_Price__c = 20;
          insert buRecord;
            ZTS_EU_Species_Product__c buRecord1 = new ZTS_EU_Species_Product__c();
          buRecord1 = TestUtilities.createNoInsertBrand('Ph 1','Business Unit','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-Business_Unit'));
          buRecord1.ZTS_EU_Business_Unit_Abbr__c = 'CT DY';
          buRecord1.ZTS_EU_Standard_Price__c = 20;
          insert buRecord1;
              ZTS_EU_Species_Product__c buRecord2 = new ZTS_EU_Species_Product__c();
          buRecord2 = TestUtilities.createNoInsertBrand('Ph 1','Business Unit','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-Business_Unit'));
          buRecord2.ZTS_EU_Business_Unit_Abbr__c = 'CT BF';
          buRecord2.ZTS_EU_Standard_Price__c = 20;
          insert buRecord2;
          system.debug('buRecord.ZTS_EU_Standard_Price__c>>>'+buRecord);
          ZTS_EU_Species_Product__c tgRecord = new ZTS_EU_Species_Product__c();
          tgRecord = TestUtilities.createNoInsertBrand('Ph 1','Therapeutic Group','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-Therapeutic_Group'));
          tgRecord.ZTS_EU_Standard_Price__c = 20;
          insert tgRecord;
         
          ZTS_EU_Species_Product__c brandRecord = new ZTS_EU_Species_Product__c();
          brandRecord = Account_Prod_Potential_Calculation_Test.createProdHierarchyRecord('Ph 2','Brand','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-Brand'),tgRecord.id);
          brandRecord.ZTS_EU_Standard_Price__c = 20;
          insert brandRecord;
         
          ZTS_EU_Species_Product__c mpgRecord = new ZTS_EU_Species_Product__c();
          mpgRecord = Account_Prod_Potential_Calculation_Test.createProdHierarchyRecord('Ph 2','MPG','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-MPG'),brandRecord.id);
          mpgRecord.ZTS_EU_Standard_Price__c = 20;
          insert mpgRecord;
         
          ZTS_EU_Species_Product__c skuRecord = new ZTS_EU_Species_Product__c();
          skuRecord = createProdHierarchyRecord('Ph 2','SKU','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-SKU'),mpgRecord.id,1);
          insert skuRecord;
          
          ZTS_EU_Species_Product__c skuRecord1 = new ZTS_EU_Species_Product__c();
          skuRecord1 = createProdHierarchyRecord('Ph 2','SKU','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-SKU'),mpgRecord.id,1);
          insert skuRecord1;
          
          ZTS_EU_Species_Product__c skuRecord2 = new ZTS_EU_Species_Product__c();
          skuRecord2 = createProdHierarchyRecord('Ph 2','SKU','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-SKU'),mpgRecord.id,1);
          insert skuRecord2;
          
          skuRecord.ZTS_EU_Influenced_By_Farm_Artificial_Sem__c=True;
          skuRecord.ZTS_EU_Product_Potential_Level__c='SKU';
          update skuRecord;
          
          skuRecord1.ZTS_EU_Influenced_By_Purebreed_Calves__c=True;
          skuRecord1.ZTS_EU_Influenced_By_Farm_Subsistence__c=True;
          skuRecord1.ZTS_EU_Product_Potential_Level__c='SKU';
          update skuRecord1;
          
          skuRecord2.ZTS_EU_Influenced_By_Slaughtered_Females__c=True;
          skuRecord2.ZTS_EU_Product_Potential_Level__c='SKU';
          update skuRecord2;
          
          /* Key Account Product Price Records */
          
          Key_Account_Product_Price__c accnt_price= new Key_Account_Product_Price__c();
          accnt_price.Account__c=accountRecords[0].id;
          accnt_price.Price__c=1234.00;
          accnt_price.Product__c=skuRecord.id;
          insert accnt_price;
          List<Key_Account_Product_Price__c> keyAccntList = new List<Key_Account_Product_Price__c>();
          keyAccntList.add(accnt_price);
          
          /* Creating ZTS_EU_Species__c records */
          list<ZTS_EU_Species__c> speciesRecords = new list<ZTS_EU_Species__c>();
          for(integer i=0; i<5; i++){
            speciesRecords.add(TestUtilities.createNoInsertSpecies('Specie',buRecord.id,'Specie name','Brazil'));
            speciesRecords.add(TestUtilities.createNoInsertSpecies('Specie1',buRecord1.id,'Specie name1','Brazil'));
            speciesRecords.add(TestUtilities.createNoInsertSpecies('Specie2',buRecord2.id,'Specie name2','Brazil'));
          }
          insert speciesRecords;
          
          
          /* Creating ZTS_EU_Potential_Brands__c records */
          list<ZTS_EU_Potential_Brands__c> pb = new list<ZTS_EU_Potential_Brands__c>();
          for(ZTS_EU_Species__c z:speciesRecords ){
            pb.add(createNoInsertPotBrands(z.id,skuRecord.id,1,1,1,1,2,2,2,22,2));
            pb.add(createNoInsertPotBrands(z.id,skuRecord1.id,1,1,1,1,2,2,2,22,2));
            pb.add(createNoInsertPotBrands(z.id,skuRecord2.id,1,1,1,1,2,2,2,22,2));
          }
          
          insert pb;
          set<id> st = new set<id>();
          set<id> productHierst= new set<id>();
          for(ZTS_EU_Potential_Brands__c z:pb ){
            z.ZTS_EU_CA_Account_Type__c='Hospitals';
            z.Potential_Factor__c=True;
            z.Treated_Food_Yearly_Intake_by_Animal__c=4;
            z.Period_of_Use_Months__c=6;
            z.Protocol_For_CA__c='A';
            st.add(z.id);
            productHierst.add(z.brand__c);
          }
          
          update pb;
          List<ZTS_EU_Species_Product__c> productWithTG=[select id,ZTS_EU_Product_Potential_Level__c,ZTS_EU_Influenced_By_Farm_Subsistence__c,ZTS_EU_Influenced_By_Farm_Artificial_Sem__c,ZTS_EU_Influenced_By_Purebreed_Calves__c,ZTS_EU_Influenced_By_Slaughtered_Females__c,ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c from  ZTS_EU_Species_Product__c where id in:productHierst and ZTS_EU_type__c='SKU'];
          set<id> TGIds = new set<id>();
          for(ZTS_EU_Species_Product__c sp : productWithTG){
                            if(sp.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c != null){
                                TGIds.add(sp.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c);
                            }
                }
                map<id,list<ZTS_EU_Species_Product__c>> tGroupSpecieProd = new map<id,list<ZTS_EU_Species_Product__c>>();
                for(Id i : TGIds){
                    list<ZTS_EU_Species_Product__c> tmpLst = new list<ZTS_EU_Species_Product__c>();
                    for(ZTS_EU_Species_Product__c sp: productWithTG){
                        if(i == sp.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c){
                            tmpLst.add(sp);
                        }
                    }
                    if(!tmpLst.isEmpty()){
                        tGroupSpecieProd.put(i,tmpLst);
                    }
                }
                    
       List<ZTS_EU_Potential_Brands__c> productHierarchies = [Select Protocol_For_CA__c, CurrencyIsoCode,name,brand__r.ZTS_EU_Product_Potential_Level__c,ZTS_EU_CA_Account_Type__c,brand__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c,brand__r.name,brand__r.ZTS_EU_Product_Unique_ID__c,brand__r.ZTS_EU_Influenced_By_Farm_Subsistence__c, brand__r.ZTS_EU_Influenced_By_Farm_Artificial_Sem__c,brand__r.ZTS_EU_Influenced_By_Purebreed_Calves__c,brand__r.ZTS_EU_Influenced_By_Slaughtered_Females__c,Adjustment_Factor__c,Annual_Number_of_treatments_Animal__c,Brand__c,ZTS_EU_Business_Unit_Abbr__c,MPG_SKU_Mix__c, Number_of_Doses_per_Animal__c,Number_of_Doses_per_SKU__c,Potential__c,Potential_Factor__c,Price_Doses_or_ml__c,Price_SKU__c,Product_Rotation__c,ZTS_EU_Value_Region_1__c,ZTS_EU_Value_Region_2__c,ZTS_EU_Value_Region_3__c,ZTS_EU_Value_Region_4__c From ZTS_EU_Potential_Brands__c z where id=:st];               
                          
          Map<Id, Map<Id, List<ZTS_EU_Potential_Brands__c>>> speciePotentialProd = new  Map<Id, Map<Id, List<ZTS_EU_Potential_Brands__c>>>();
         List<ZTS_EU_Potential_Brands__c> pBsWithSameTg = new List<ZTS_EU_Potential_Brands__c>();
           Map<id,List<ZTS_EU_Potential_Brands__c>> prodTgMap = new Map<id,List<ZTS_EU_Potential_Brands__c>>();
          for(ZTS_EU_Potential_Brands__c pbh:productHierarchies)
           {

               pBsWithSameTg.add(pbh);
               prodTgMap.put(pbh.brand__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c,pBsWithSameTg);
               speciePotentialProd.put(pbh.Potential__c,prodTgMap);
           
           }
          
          /* Creating ASC Administration records*/
            list<ASC_Administration__c> ascAdmlst = new list<ASC_Administration__c>();
          ascAdmlst.add(createASC_Administration(buRecord.id, speciesRecords[0].id, 'Calculated_Value_of_Potentail__c', 'Farm uses TAI','Nutritional Management', 'en_US',''));
          ascAdmlst.add(createASC_Administration(buRecord.id, speciesRecords[0].id, 'The_farm_does_not_use_TAI_but_uses_conv__c', 'Farm uses TAI','Reproductive Management', 'en_US',''));
          ascAdmlst.add(createASC_Administration(null, speciesRecords[0].id, 'ZTS_EU_Animals_Consultations_actual__c', 'Farm uses TAI','', 'en_US',''));
          ascAdmlst.add(createASC_Administration(buRecord.id, speciesRecords[0].id,'Farm_uses_timed_artificial_insemi__c','Artifical Sem','','en_US','ZTS_EU_Influenced_By_Farm_Artificial_Sem__c'));
          ascAdmlst.add(createASC_Administration(buRecord1.id, speciesRecords[1].id,'ZTS_EU_No_of_Purebred_Animals__c','Purebred','','en_US','ZTS_EU_Influenced_By_Purebreed_Calves__c'));
          ascAdmlst.add(createASC_Administration(buRecord2.id, speciesRecords[2].id,'ZTS_EU_No_of_Slaughtered_Cattle__c','Slaughtered','','en_US','ZTS_EU_Influenced_By_Slaughtered_Females__c'));
          ascAdmlst.add(createASC_Administration(buRecord1.id, speciesRecords[1].id,'The_farm_is_a_subsistence_activity__c','Subsistence','','en_US','ZTS_EU_Influenced_By_Farm_Subsistence__c'));
          insert ascAdmlst;
          
          update ascAdmlst;
          /* Creating ZTS_EU_Potential_Brands__c records */
          list<ZTS_EU_Account_Species_Potential__c> accSpecieConsulatation = new list<ZTS_EU_Account_Species_Potential__c>();
          for(Account acc: accountRecords){
            accSpecieConsulatation.add(TestUtilities.createNoInsertAcctSpcPot(acc.id,speciesRecords[0].id,20,20));
            accSpecieConsulatation.add(TestUtilities.createNoInsertAcctSpcPot(acc.id,speciesRecords[1].id,20,20));
            accSpecieConsulatation.add(TestUtilities.createNoInsertAcctSpcPot(acc.id,speciesRecords[2].id,20,20));
          }
          test.startTest();
          insert accSpecieConsulatation;
          
           Set<id> ascIdSet = new Set<id>();
         for(ZTS_EU_Account_Species_Potential__c ascp :accSpecieConsulatation)
          {
            ascp.Farm_uses_timed_artificial_insemi__c=True;
            ascp.ZTS_EU_No_of_Purebred_Animals__c=200;
            ascp.ZTS_EU_No_of_Slaughtered_Cattle__c=400;
            ascp.The_farm_is_a_subsistence_activity__c=True;
            ascIdSet.add(ascp.id); 
          }
          
          update accSpecieConsulatation;
          
          ZTS_EU_Account_Product_Potential__c accProdPotential = Account_Prod_Potential_Calculation_Test.createAccProdPotential(accSpecieConsulatation[0].id, accountRecords[0].id,tgRecord.id, tgRecord.id, 'Name', 20);
          insert accProdPotential;
          
          
          list<ZTS_EU_Species_Product__c> products = new list<ZTS_EU_Species_Product__c>();
          products.add(buRecord);
          products.add(tgRecord);
          products.add(brandRecord);
          products.add(mpgRecord);
          products.add(skuRecord);
          Set<String> markets= new Set<String>();
          markets.add('Brazil');
          list<ZTS_EU_Account_Species_Potential__c> ascp = [Select CurrencyIsoCode,The_farm_is_a_subsistence_activity__c,name,Number_of_Animal_Interval__c,Farm_uses_timed_artificial_insemi__c,ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__r.ZTS_EU_Business_Unit_Abbr__c,ZTS_EU_Animal_Consultations_new__c,ZTS_EU_Animals_Consultations_actual__c,Account__c,ZTS_EU_BU_Abbr__c,Calculated_Value_of_Potentail__c,ZTS_EU_Animals_bought_from_other_herds__c,ZTS_EU_No_of_Nelore_Cattle_In_Genetic__c,ZTS_EU_No_of_Purebred_Animals__c,ZTS_EU_No_of_Slaughtered_Cattle__c,ZTS_EU_Species_Potential__c,ZTS_EU_Species_Potential_Value__c,ZTS_EU_Sum_Of_Account_Product_Potentials__c,ZTS_EU_Uniqueness_Key__c From ZTS_EU_Account_Species_Potential__c z where id in :ascIdSet];
          PotentialCalculatorEngine pa = new PotentialCalculatorEngine(markets);
          list<ZTS_EU_Species_Product__c> specieProd=  [Select ZTS_EU_NO_OF_CA_Species__c,ZTS_EU_NO_OF_EQ_Species__c,ZTS_EU_NO_OF_PY_Species__c,ZTS_EU_NO_OF_RU_Species__c,ZTS_EU_Sales_Budgets_SB__c,ZTS_EU_NO_OF_SW_Species__c,ZTS_EU_NO_OF_VPS_Species__c,ZTS_EU_Brand_is_Budgetable__c,ZTS_EU_BU_from_Brand__c,ZTS_EU_Business_Unit_Abbr__c,ZTS_EU_Business_Units__c,ZTS_EU_Create_Samples__c,ZTS_EU_Gift_Type__c,ZTS_EU_Gift_Value__c,ZTS_EU_Influenced_By_Farm_Artificial_Sem__c,ZTS_EU_Influenced_By_Slaughtered_Females__c,ZTS_EU_Influenced_By_Farm_Subsistence__c,ZTS_EU_Influenced_By_Fattening_Mgmnt__c,ZTS_EU_Influenced_By_Purebreed_Calves__c,ZTS_EU_Influenced_By_Nutritional_Mgmnt__c,ZTS_EU_Influenced_By_Other_Herds_Animals__c,ZTS_EU_Influenced_By_Reproductive_Mgmnt__c,ZTS_EU_Is_Active__c,ZTS_EU_is_an_Internal_competitor__c,ZTS_EU_is_Budgetable__c,ZTS_EU_is_Child_of_Brand__c,ZTS_EU_Is_Detailable__c,ZTS_EU_is_Gift__c,ZTS_EU_Is_KOL_Area_of_Expertise__c,ZTS_EU_Is_Old__c,ZTS_EU_Is_Orderable__c,ZTS_EU_is_Samplable__c,ZTS_EU_Standard_Price__c,ZTS_EU_Market__c,ZTS_EU_Parent_Species_Product__c,ZTS_EU_Product_Potential_Level__c,ZTS_EU_Product_Unique_ID__c,ZTS_EU_SAP_Product_ID__c,ZTS_EU_Total_Budget_SB__c,ZTS_EU_Type__c,ZTS_EU_Zoetis_SFDC_ID__c,CurrencyIsoCode,name From ZTS_EU_Species_Product__c z where id=:tgRecord.id];
          pa.productsPerTherGroup=tGroupSpecieProd;
          pa.speciePotentialProd=speciePotentialProd;
          List<ZTS_EU_Account_Product_Potential__c> aa = pa.calculatePotential(accountRecords[0], ascp,keyAccntList);
          test.stopTest();
          
        }
        
    
        
  }
  
    static testmethod void EQPotentialCalculator_Test_Method(){
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
        newUser.ZTS_EU_Market__c= 'Brazil';
        newUser.EmailEncodingKey= 'ISO-8859-1';
        userRecs.add(newuser); 
        insert userRecs;
        
        system.runAs(userRecs[0]){
          list<Acc_Prod_Pot_Markets__c> accProdSettings = new list<Acc_Prod_Pot_Markets__c>();
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Sunday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Monday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Tuesday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Wednesday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Thursday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Friday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Saturday','Brazil,Canada'));
          insert accProdSettings;
          
          list<MarketGeoMapping__c> MarketGeoMappingSetting = new list<MarketGeoMapping__c>();
          MarketGeoMappingSetting.add(Account_Prod_Potential_Calculation_Test.createMarketGeoMappingSetting('Brazil','SKU'));
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
          accountRecords.addAll(createNoInsertAccount('Acc','Farm','Beef',recordtypeMap.get('Account-ZTS_EU_Activated_Account'),'Brazil','1',false,'<=2','Basic','>100m2','5'));
          accountRecords.addAll(createNoInsertAccount('Acc1','Farm','Beef',recordtypeMap.get('Account-ZTS_EU_Activated_Account'),'Brazil','1',false,'<=2','Basic','>100m2','6'));
          if(accountRecords.size() > 0){
            insert accountRecords;
            
            for(Account accnt:accountRecords)
             {
               accnt.ZTS_EU_CA_Account_Type__c='Hospitals';
               accnt.Key_Account__c=True;
             }
             
            
            update accountRecords; 
           }
          
       
          /*Creating Product Hierarchy records */
          
          ZTS_EU_Species_Product__c buRecord = new ZTS_EU_Species_Product__c();
          buRecord = TestUtilities.createNoInsertBrand('Ph 1','Business Unit','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-Business_Unit'));
          buRecord.ZTS_EU_Business_Unit_Abbr__c = 'EQ';
          buRecord.ZTS_EU_Standard_Price__c = 20;
          insert buRecord;
          system.debug('buRecord.ZTS_EU_Standard_Price__c>>>'+buRecord);
          ZTS_EU_Species_Product__c tgRecord = new ZTS_EU_Species_Product__c();
          tgRecord = TestUtilities.createNoInsertBrand('Ph 1','Therapeutic Group','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-Therapeutic_Group'));
          tgRecord.ZTS_EU_Standard_Price__c = 20;
          insert tgRecord;
         
          ZTS_EU_Species_Product__c brandRecord = new ZTS_EU_Species_Product__c();
          brandRecord = Account_Prod_Potential_Calculation_Test.createProdHierarchyRecord('Ph 2','Brand','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-Brand'),tgRecord.id);
          brandRecord.ZTS_EU_Standard_Price__c = 20;
          insert brandRecord;
         
          ZTS_EU_Species_Product__c mpgRecord = new ZTS_EU_Species_Product__c();
          mpgRecord = Account_Prod_Potential_Calculation_Test.createProdHierarchyRecord('Ph 2','MPG','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-MPG'),brandRecord.id);
          mpgRecord.ZTS_EU_Standard_Price__c = 20;
          insert mpgRecord;
         
          ZTS_EU_Species_Product__c skuRecord = new ZTS_EU_Species_Product__c();
          skuRecord = createProdHierarchyRecord('Ph 2','SKU','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-SKU'),mpgRecord.id,1);
          insert skuRecord;
          
          skuRecord.ZTS_EU_Product_Potential_Level__c='SKU';
          update skuRecord;
          /* Key Account Product Price Records */
          
          Key_Account_Product_Price__c accnt_price= new Key_Account_Product_Price__c();
          accnt_price.Account__c=accountRecords[0].id;
          accnt_price.Price__c=1234.00;
          accnt_price.Product__c=skuRecord.id;
          insert accnt_price;
          List<Key_Account_Product_Price__c> keyAccntList = new List<Key_Account_Product_Price__c>();
          keyAccntList.add(accnt_price);
          
          /* Creating ZTS_EU_Species__c records */
          list<ZTS_EU_Species__c> speciesRecords = new list<ZTS_EU_Species__c>();
          for(integer i=0; i<5; i++){
            speciesRecords.add(TestUtilities.createNoInsertSpecies('Specie',buRecord.id,'Specie name','Brazil'));
          }
          insert speciesRecords;
          
         
          /* Creating ZTS_EU_Potential_Brands__c records */
          list<ZTS_EU_Potential_Brands__c> pb = new list<ZTS_EU_Potential_Brands__c>();
          for(ZTS_EU_Species__c z:speciesRecords ){
            pb.add(createNoInsertPotBrands(z.id,skuRecord.id,1,1,1,1,2,2,2,22,2));
          }
          
          insert pb;
          set<id> st = new set<id>();
          set<id> productHierst= new set<id>();
          for(ZTS_EU_Potential_Brands__c z:pb ){
            z.ZTS_EU_CA_Account_Type__c='Hospitals';
            z.Potential_Factor__c=True;
            z.Treated_Food_Yearly_Intake_by_Animal__c=4;
            z.Period_of_Use_Months__c=6;
            st.add(z.id);
            productHierst.add(z.brand__c);
          }
          
          update pb;
          List<ZTS_EU_Species_Product__c> productWithTG=[select id,ZTS_EU_Product_Potential_Level__c,ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c from  ZTS_EU_Species_Product__c where id in:productHierst and ZTS_EU_type__c='SKU'];
          set<id> TGIds = new set<id>();
          for(ZTS_EU_Species_Product__c sp : productWithTG){
                            if(sp.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c != null){
                                TGIds.add(sp.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c);
                            }
                }
                map<id,list<ZTS_EU_Species_Product__c>> tGroupSpecieProd = new map<id,list<ZTS_EU_Species_Product__c>>();
                for(Id i : TGIds){
                    list<ZTS_EU_Species_Product__c> tmpLst = new list<ZTS_EU_Species_Product__c>();
                    for(ZTS_EU_Species_Product__c sp: productWithTG){
                        if(i == sp.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c){
                            tmpLst.add(sp);
                        }
                    }
                    if(!tmpLst.isEmpty()){
                        tGroupSpecieProd.put(i,tmpLst);
                    }
                }
                    
       List<ZTS_EU_Potential_Brands__c> productHierarchies = [Select Protocol_For_CA__c, brand__r.ZTS_EU_Product_Potential_Level__c,CurrencyIsoCode,name,ZTS_EU_CA_Account_Type__c,brand__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c,brand__r.name,brand__r.ZTS_EU_Product_Unique_ID__c,brand__r.ZTS_EU_Influenced_By_Farm_Subsistence__c, brand__r.ZTS_EU_Influenced_By_Farm_Artificial_Sem__c,Adjustment_Factor__c,Annual_Number_of_treatments_Animal__c,Brand__c,ZTS_EU_Business_Unit_Abbr__c,MPG_SKU_Mix__c, Number_of_Doses_per_Animal__c,Number_of_Doses_per_SKU__c,Potential__c,Potential_Factor__c,Price_Doses_or_ml__c,Price_SKU__c,Product_Rotation__c,ZTS_EU_Value_Region_1__c,ZTS_EU_Value_Region_2__c,ZTS_EU_Value_Region_3__c,ZTS_EU_Value_Region_4__c From ZTS_EU_Potential_Brands__c z where id=:st];               
                          
          Map<Id, Map<Id, List<ZTS_EU_Potential_Brands__c>>> speciePotentialProd = new  Map<Id, Map<Id, List<ZTS_EU_Potential_Brands__c>>>();
         List<ZTS_EU_Potential_Brands__c> pBsWithSameTg = new List<ZTS_EU_Potential_Brands__c>();
           Map<id,List<ZTS_EU_Potential_Brands__c>> prodTgMap = new Map<id,List<ZTS_EU_Potential_Brands__c>>();
          for(ZTS_EU_Potential_Brands__c pbh:productHierarchies)
           {

               pBsWithSameTg.add(pbh);
               prodTgMap.put(pbh.brand__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c,pBsWithSameTg);
               speciePotentialProd.put(pbh.Potential__c,prodTgMap);
           
           }
          
          
          /* Creating ZTS_EU_Potential_Brands__c records */
          list<ZTS_EU_Account_Species_Potential__c> accSpecieConsulatation = new list<ZTS_EU_Account_Species_Potential__c>();
          for(Account acc: accountRecords){
            accSpecieConsulatation.add(TestUtilities.createNoInsertAcctSpcPot(acc.id,speciesRecords[0].id,20,20));
          }
          
          insert accSpecieConsulatation;

          ZTS_EU_Account_Product_Potential__c accProdPotential = Account_Prod_Potential_Calculation_Test.createAccProdPotential(accSpecieConsulatation[0].id, accountRecords[0].id,tgRecord.id, tgRecord.id, 'Name', 20);
          insert accProdPotential;
          
          test.startTest();
          
                  list<ZTS_EU_Species_Product__c> products = new list<ZTS_EU_Species_Product__c>();
          products.add(buRecord);
          products.add(tgRecord);
          products.add(brandRecord);
          products.add(mpgRecord);
          products.add(skuRecord);
          Set<String> markets= new Set<String>();
          markets.add('Brazil');
          list<ZTS_EU_Account_Species_Potential__c> ascp = [Select CurrencyIsoCode,name,Number_of_Animal_Interval__c,ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__r.ZTS_EU_Business_Unit_Abbr__c,ZTS_EU_Animal_Consultations_new__c,ZTS_EU_Animals_Consultations_actual__c,Account__c,ZTS_EU_BU_Abbr__c,Calculated_Value_of_Potentail__c,ZTS_EU_Animals_bought_from_other_herds__c,ZTS_EU_No_of_Nelore_Cattle_In_Genetic__c,ZTS_EU_No_of_Purebred_Animals__c,ZTS_EU_No_of_Slaughtered_Cattle__c,ZTS_EU_Species_Potential__c,ZTS_EU_Species_Potential_Value__c,ZTS_EU_Sum_Of_Account_Product_Potentials__c,ZTS_EU_Uniqueness_Key__c From ZTS_EU_Account_Species_Potential__c z where id=:accSpecieConsulatation[0].id ];
          PotentialCalculatorEngine pa = new PotentialCalculatorEngine(markets);
          list<ZTS_EU_Species_Product__c> specieProd=  [Select ZTS_EU_NO_OF_CA_Species__c,ZTS_EU_NO_OF_EQ_Species__c,ZTS_EU_NO_OF_PY_Species__c,ZTS_EU_NO_OF_RU_Species__c,ZTS_EU_Sales_Budgets_SB__c,ZTS_EU_NO_OF_SW_Species__c,ZTS_EU_NO_OF_VPS_Species__c,ZTS_EU_Brand_is_Budgetable__c,ZTS_EU_BU_from_Brand__c,ZTS_EU_Business_Unit_Abbr__c,ZTS_EU_Business_Units__c,ZTS_EU_Create_Samples__c,ZTS_EU_Gift_Type__c,ZTS_EU_Gift_Value__c,ZTS_EU_Influenced_By_Farm_Artificial_Sem__c,ZTS_EU_Influenced_By_Farm_Subsistence__c,ZTS_EU_Influenced_By_Fattening_Mgmnt__c,ZTS_EU_Influenced_By_Purebreed_Calves__c,ZTS_EU_Influenced_By_Nutritional_Mgmnt__c,ZTS_EU_Influenced_By_Other_Herds_Animals__c,ZTS_EU_Influenced_By_Reproductive_Mgmnt__c,ZTS_EU_Is_Active__c,ZTS_EU_is_an_Internal_competitor__c,ZTS_EU_is_Budgetable__c,ZTS_EU_is_Child_of_Brand__c,ZTS_EU_Is_Detailable__c,ZTS_EU_is_Gift__c,ZTS_EU_Is_KOL_Area_of_Expertise__c,ZTS_EU_Is_Old__c,ZTS_EU_Is_Orderable__c,ZTS_EU_is_Samplable__c,ZTS_EU_Standard_Price__c,ZTS_EU_Market__c,ZTS_EU_Parent_Species_Product__c,ZTS_EU_Product_Potential_Level__c,ZTS_EU_Product_Unique_ID__c,ZTS_EU_SAP_Product_ID__c,ZTS_EU_Total_Budget_SB__c,ZTS_EU_Type__c,ZTS_EU_Zoetis_SFDC_ID__c,CurrencyIsoCode,name From ZTS_EU_Species_Product__c z where id=:tgRecord.id];
          pa.productsPerTherGroup=tGroupSpecieProd;
          pa.speciePotentialProd=speciePotentialProd;
          List<ZTS_EU_Account_Product_Potential__c> aa = pa.calculatePotential(accountRecords[0], ascp,keyAccntList);
          test.stopTest();
          
        }
        
    
        
  }

    static testmethod void SwinePotentialCalculator_Test_Method(){
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
        newUser.ZTS_EU_Market__c= 'Brazil';
        newUser.EmailEncodingKey= 'ISO-8859-1';
        userRecs.add(newuser); 
        insert userRecs;
        
        system.runAs(userRecs[0]){
          list<Acc_Prod_Pot_Markets__c> accProdSettings = new list<Acc_Prod_Pot_Markets__c>();
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Sunday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Monday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Tuesday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Wednesday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Thursday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Friday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Saturday','Brazil,Canada'));
          insert accProdSettings;
          
          list<MarketGeoMapping__c> MarketGeoMappingSetting = new list<MarketGeoMapping__c>();
          MarketGeoMappingSetting.add(Account_Prod_Potential_Calculation_Test.createMarketGeoMappingSetting('Brazil','SKU'));
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
          accountRecords.addAll(createNoInsertAccount('Acc','Farm','Beef',recordtypeMap.get('Account-ZTS_EU_Activated_Account'),'Brazil','1',false,'<=2','Basic','>100m2','7'));
          accountRecords.addAll(createNoInsertAccount('Acc1','Farm','Beef',recordtypeMap.get('Account-ZTS_EU_Activated_Account'),'Brazil','1',false,'<=2','Basic','>100m2','8'));
          if(accountRecords.size() > 0){
            insert accountRecords;
            
            for(Account accnt:accountRecords)
             {
               accnt.ZTS_EU_CA_Account_Type__c='Hospitals';
               accnt.Key_Account__c=True;
             }
             
            
            update accountRecords; 
           }
          
       
          /*Creating Product Hierarchy records */
          
          ZTS_EU_Species_Product__c buRecord = new ZTS_EU_Species_Product__c();
          buRecord = TestUtilities.createNoInsertBrand('Ph 1','Business Unit','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-Business_Unit'));
          buRecord.ZTS_EU_Business_Unit_Abbr__c = 'SW';
          buRecord.ZTS_EU_Standard_Price__c = 20;
          insert buRecord;
          system.debug('buRecord.ZTS_EU_Standard_Price__c>>>'+buRecord);
          ZTS_EU_Species_Product__c tgRecord = new ZTS_EU_Species_Product__c();
          tgRecord = TestUtilities.createNoInsertBrand('Ph 1','Therapeutic Group','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-Therapeutic_Group'));
          tgRecord.ZTS_EU_Standard_Price__c = 20;
          insert tgRecord;
         
          ZTS_EU_Species_Product__c brandRecord = new ZTS_EU_Species_Product__c();
          brandRecord = Account_Prod_Potential_Calculation_Test.createProdHierarchyRecord('Ph 2','Brand','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-Brand'),tgRecord.id);
          brandRecord.ZTS_EU_Standard_Price__c = 20;
          insert brandRecord;
         
          ZTS_EU_Species_Product__c mpgRecord = new ZTS_EU_Species_Product__c();
          mpgRecord = Account_Prod_Potential_Calculation_Test.createProdHierarchyRecord('Ph 2','MPG','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-MPG'),brandRecord.id);
          mpgRecord.ZTS_EU_Standard_Price__c = 20;
          insert mpgRecord;
         
          ZTS_EU_Species_Product__c skuRecord = new ZTS_EU_Species_Product__c();
          skuRecord = createProdHierarchyRecord('Ph 2','SKU','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-SKU'),mpgRecord.id,1);
          insert skuRecord;

          skuRecord.ZTS_EU_Product_Potential_Level__c='SKU';
          update skuRecord;
          
          /* Key Account Product Price Records */
          
          Key_Account_Product_Price__c accnt_price= new Key_Account_Product_Price__c();
          accnt_price.Account__c=accountRecords[0].id;
          accnt_price.Price__c=1234.00;
          accnt_price.Product__c=skuRecord.id;
          insert accnt_price;
          List<Key_Account_Product_Price__c> keyAccntList = new List<Key_Account_Product_Price__c>();
          keyAccntList.add(accnt_price);
          
          /* Creating ZTS_EU_Species__c records */
          list<ZTS_EU_Species__c> speciesRecords = new list<ZTS_EU_Species__c>();
          for(integer i=0; i<5; i++){
            speciesRecords.add(TestUtilities.createNoInsertSpecies('Specie',buRecord.id,'Specie name','Brazil'));
          }
          insert speciesRecords;
          
            /* Creating ZTS_EU_Potential_Brands__c records */
          list<ZTS_EU_Potential_Brands__c> pb = new list<ZTS_EU_Potential_Brands__c>();
          for(ZTS_EU_Species__c z:speciesRecords ){
            pb.add(createNoInsertPotBrands(z.id,skuRecord.id,1,1,1,1,2,2,2,22,2));
          }
          
          insert pb;
          set<id> st = new set<id>();
          set<id> productHierst= new set<id>();
          for(ZTS_EU_Potential_Brands__c z:pb ){
            z.ZTS_EU_CA_Account_Type__c='Hospitals';
            z.Potential_Factor__c=True;
            z.Treated_Food_Yearly_Intake_by_Animal__c=4;
            z.Period_of_Use_Months__c=6;
            st.add(z.id);
            productHierst.add(z.brand__c);
          }
          
          update pb;
          List<ZTS_EU_Species_Product__c> productWithTG=[select id,ZTS_EU_Product_Potential_Level__c,ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c from  ZTS_EU_Species_Product__c where id in:productHierst and ZTS_EU_type__c='SKU'];
          set<id> TGIds = new set<id>();
          for(ZTS_EU_Species_Product__c sp : productWithTG){
                            if(sp.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c != null){
                                TGIds.add(sp.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c);
                            }
                }
                map<id,list<ZTS_EU_Species_Product__c>> tGroupSpecieProd = new map<id,list<ZTS_EU_Species_Product__c>>();
                for(Id i : TGIds){
                    list<ZTS_EU_Species_Product__c> tmpLst = new list<ZTS_EU_Species_Product__c>();
                    for(ZTS_EU_Species_Product__c sp: productWithTG){
                        if(i == sp.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c){
                            tmpLst.add(sp);
                        }
                    }
                    if(!tmpLst.isEmpty()){
                        tGroupSpecieProd.put(i,tmpLst);
                    }
                }
                    
       List<ZTS_EU_Potential_Brands__c> productHierarchies = [Select Protocol_For_CA__c, brand__r.ZTS_EU_Product_Potential_Level__c,Period_of_Use_Months__c,Treated_Food_Yearly_Intake_by_Animal__c,CurrencyIsoCode,name,ZTS_EU_CA_Account_Type__c,brand__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c,brand__r.name,brand__r.ZTS_EU_Product_Unique_ID__c,brand__r.ZTS_EU_Influenced_By_Farm_Subsistence__c, brand__r.ZTS_EU_Influenced_By_Farm_Artificial_Sem__c,Adjustment_Factor__c,Annual_Number_of_treatments_Animal__c,Brand__c,ZTS_EU_Business_Unit_Abbr__c,MPG_SKU_Mix__c, Number_of_Doses_per_Animal__c,Number_of_Doses_per_SKU__c,Potential__c,Potential_Factor__c,Price_Doses_or_ml__c,Price_SKU__c,Product_Rotation__c,ZTS_EU_Value_Region_1__c,ZTS_EU_Value_Region_2__c,ZTS_EU_Value_Region_3__c,ZTS_EU_Value_Region_4__c From ZTS_EU_Potential_Brands__c z where id=:st];               
                          
          Map<Id, Map<Id, List<ZTS_EU_Potential_Brands__c>>> speciePotentialProd = new  Map<Id, Map<Id, List<ZTS_EU_Potential_Brands__c>>>();
         List<ZTS_EU_Potential_Brands__c> pBsWithSameTg = new List<ZTS_EU_Potential_Brands__c>();
           Map<id,List<ZTS_EU_Potential_Brands__c>> prodTgMap = new Map<id,List<ZTS_EU_Potential_Brands__c>>();
          for(ZTS_EU_Potential_Brands__c pbh:productHierarchies)
           {

               pBsWithSameTg.add(pbh);
               prodTgMap.put(pbh.brand__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c,pBsWithSameTg);
               speciePotentialProd.put(pbh.Potential__c,prodTgMap);
           
           }
          
          
          /* Creating ZTS_EU_Potential_Brands__c records */
          list<ZTS_EU_Account_Species_Potential__c> accSpecieConsulatation = new list<ZTS_EU_Account_Species_Potential__c>();
          for(Account acc: accountRecords){
            accSpecieConsulatation.add(TestUtilities.createNoInsertAcctSpcPot(acc.id,speciesRecords[0].id,20,20));
          }
          
          insert accSpecieConsulatation;

          ZTS_EU_Account_Product_Potential__c accProdPotential = Account_Prod_Potential_Calculation_Test.createAccProdPotential(accSpecieConsulatation[0].id, accountRecords[0].id,tgRecord.id, tgRecord.id, 'Name', 20);
          insert accProdPotential;
          
          test.startTest();
          
                  list<ZTS_EU_Species_Product__c> products = new list<ZTS_EU_Species_Product__c>();
          products.add(buRecord);
          products.add(tgRecord);
          products.add(brandRecord);
          products.add(mpgRecord);
          products.add(skuRecord);
          Set<String> markets= new Set<String>();
          markets.add('Brazil');
          list<ZTS_EU_Account_Species_Potential__c> ascp = [Select CurrencyIsoCode,Monthly_Cost_per_1000_Eggs__c,Yearly_Cost_per_1000_Eggs__c,name,Number_of_Animal_Interval__c,ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__r.ZTS_EU_Business_Unit_Abbr__c,ZTS_EU_Animal_Consultations_new__c,ZTS_EU_Animals_Consultations_actual__c,Account__c,ZTS_EU_BU_Abbr__c,Calculated_Value_of_Potentail__c,ZTS_EU_Animals_bought_from_other_herds__c,ZTS_EU_No_of_Nelore_Cattle_In_Genetic__c,ZTS_EU_No_of_Purebred_Animals__c,ZTS_EU_No_of_Slaughtered_Cattle__c,ZTS_EU_Species_Potential__c,ZTS_EU_Species_Potential_Value__c,ZTS_EU_Sum_Of_Account_Product_Potentials__c,ZTS_EU_Uniqueness_Key__c From ZTS_EU_Account_Species_Potential__c z where id=:accSpecieConsulatation[0].id ];
          PotentialCalculatorEngine pa = new PotentialCalculatorEngine(markets);
          list<ZTS_EU_Species_Product__c> specieProd=  [Select ZTS_EU_NO_OF_CA_Species__c,ZTS_EU_NO_OF_EQ_Species__c,ZTS_EU_NO_OF_PY_Species__c,ZTS_EU_NO_OF_RU_Species__c,ZTS_EU_Sales_Budgets_SB__c,ZTS_EU_NO_OF_SW_Species__c,ZTS_EU_NO_OF_VPS_Species__c,ZTS_EU_Brand_is_Budgetable__c,ZTS_EU_BU_from_Brand__c,ZTS_EU_Business_Unit_Abbr__c,ZTS_EU_Business_Units__c,ZTS_EU_Create_Samples__c,ZTS_EU_Gift_Type__c,ZTS_EU_Gift_Value__c,ZTS_EU_Influenced_By_Farm_Artificial_Sem__c,ZTS_EU_Influenced_By_Farm_Subsistence__c,ZTS_EU_Influenced_By_Fattening_Mgmnt__c,ZTS_EU_Influenced_By_Purebreed_Calves__c,ZTS_EU_Influenced_By_Nutritional_Mgmnt__c,ZTS_EU_Influenced_By_Other_Herds_Animals__c,ZTS_EU_Influenced_By_Reproductive_Mgmnt__c,ZTS_EU_Is_Active__c,ZTS_EU_is_an_Internal_competitor__c,ZTS_EU_is_Budgetable__c,ZTS_EU_is_Child_of_Brand__c,ZTS_EU_Is_Detailable__c,ZTS_EU_is_Gift__c,ZTS_EU_Is_KOL_Area_of_Expertise__c,ZTS_EU_Is_Old__c,ZTS_EU_Is_Orderable__c,ZTS_EU_is_Samplable__c,ZTS_EU_Standard_Price__c,ZTS_EU_Market__c,ZTS_EU_Parent_Species_Product__c,ZTS_EU_Product_Potential_Level__c,ZTS_EU_Product_Unique_ID__c,ZTS_EU_SAP_Product_ID__c,ZTS_EU_Total_Budget_SB__c,ZTS_EU_Type__c,ZTS_EU_Zoetis_SFDC_ID__c,CurrencyIsoCode,name From ZTS_EU_Species_Product__c z where id=:tgRecord.id];
          pa.productsPerTherGroup=tGroupSpecieProd;
          pa.speciePotentialProd=speciePotentialProd;
          List<ZTS_EU_Account_Product_Potential__c> aa = pa.calculatePotential(accountRecords[0], ascp,keyAccntList);
          test.stopTest();
          
        }
        
    
        
  }
      static testmethod void PoultryPotentialCalculator_Test_Method(){
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
        newUser.ZTS_EU_Market__c= 'Brazil';
        newUser.EmailEncodingKey= 'ISO-8859-1';
        userRecs.add(newuser); 
        insert userRecs;
        
        system.runAs(userRecs[0]){
          list<Acc_Prod_Pot_Markets__c> accProdSettings = new list<Acc_Prod_Pot_Markets__c>();
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Sunday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Monday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Tuesday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Wednesday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Thursday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Friday','Brazil,Canada'));
          accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Saturday','Brazil,Canada'));
          insert accProdSettings;
          
          list<MarketGeoMapping__c> MarketGeoMappingSetting = new list<MarketGeoMapping__c>();
          MarketGeoMappingSetting.add(Account_Prod_Potential_Calculation_Test.createMarketGeoMappingSetting('Brazil','SKU'));
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
          accountRecords.addAll(createNoInsertAccount('Acc','Farm','Beef',recordtypeMap.get('Account-ZTS_EU_Activated_Account'),'Brazil','1',false,'<=2','Basic','>100m2','9'));
          accountRecords.addAll(createNoInsertAccount('Acc1','Farm','Beef',recordtypeMap.get('Account-ZTS_EU_Activated_Account'),'Brazil','1',false,'<=2','Basic','>100m2','10'));
          if(accountRecords.size() > 0){
            insert accountRecords;
            
            for(Account accnt:accountRecords)
             {
               accnt.ZTS_EU_CA_Account_Type__c='Hospitals';
               accnt.Key_Account__c=True;
             }
             
            
            update accountRecords; 
           }
          
       
          /*Creating Product Hierarchy records */
          
          ZTS_EU_Species_Product__c buRecord = new ZTS_EU_Species_Product__c();
          buRecord = TestUtilities.createNoInsertBrand('Ph 1','Business Unit','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-Business_Unit'));
          buRecord.ZTS_EU_Business_Unit_Abbr__c = 'PY';
          buRecord.ZTS_EU_Standard_Price__c = 20;
          insert buRecord;
          system.debug('buRecord.ZTS_EU_Standard_Price__c>>>'+buRecord);
          ZTS_EU_Species_Product__c tgRecord = new ZTS_EU_Species_Product__c();
          tgRecord = TestUtilities.createNoInsertBrand('Ph 1','Therapeutic Group','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-Therapeutic_Group'));
          tgRecord.ZTS_EU_Standard_Price__c = 20;
          insert tgRecord;
         
          ZTS_EU_Species_Product__c brandRecord = new ZTS_EU_Species_Product__c();
          brandRecord = Account_Prod_Potential_Calculation_Test.createProdHierarchyRecord('Ph 2','Brand','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-Brand'),tgRecord.id);
          brandRecord.ZTS_EU_Standard_Price__c = 20;
          insert brandRecord;
         
          ZTS_EU_Species_Product__c mpgRecord = new ZTS_EU_Species_Product__c();
          mpgRecord = Account_Prod_Potential_Calculation_Test.createProdHierarchyRecord('Ph 2','MPG','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-MPG'),brandRecord.id);
          mpgRecord.ZTS_EU_Standard_Price__c = 20;
          insert mpgRecord;
         
          ZTS_EU_Species_Product__c skuRecord = new ZTS_EU_Species_Product__c();
          skuRecord = createProdHierarchyRecord('Ph 2','SKU','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-SKU'),mpgRecord.id,1);
          insert skuRecord;
          
          skuRecord.ZTS_EU_Product_Potential_Level__c='SKU';
          update skuRecord;
          /* Key Account Product Price Records */
          
          Key_Account_Product_Price__c accnt_price= new Key_Account_Product_Price__c();
          accnt_price.Account__c=accountRecords[0].id;
          accnt_price.Price__c=1234.00;
          accnt_price.Product__c=skuRecord.id;
          insert accnt_price;
          List<Key_Account_Product_Price__c> keyAccntList = new List<Key_Account_Product_Price__c>();
          keyAccntList.add(accnt_price);
          
          /* Creating ZTS_EU_Species__c records */
          list<ZTS_EU_Species__c> speciesRecords = new list<ZTS_EU_Species__c>();
          for(integer i=0; i<5; i++){
            speciesRecords.add(TestUtilities.createNoInsertSpecies('Specie',buRecord.id,'Specie name','Brazil'));
            speciesRecords.add(TestUtilities.createNoInsertSpecies('Specie1',buRecord.id,'Specie name1','Brazil'));
          }
          insert speciesRecords;
          
          
          /* Creating ZTS_EU_Potential_Brands__c records */
          list<ZTS_EU_Potential_Brands__c> pb = new list<ZTS_EU_Potential_Brands__c>();
          for(ZTS_EU_Species__c z:speciesRecords ){
            pb.add(createNoInsertPotBrands(z.id,skuRecord.id,1,1,1,1,2,2,2,22,2));
          }
          
          insert pb;
          set<id> st = new set<id>();
          set<id> productHierst= new set<id>();
          for(ZTS_EU_Potential_Brands__c z:pb ){
            z.ZTS_EU_CA_Account_Type__c='Hospitals';
            z.Potential_Factor__c=True;
            z.Treated_Food_Yearly_Intake_by_Animal__c=4;
            z.Period_of_Use_Months__c=6;
            st.add(z.id);
            productHierst.add(z.brand__c);
          }
          
          update pb;
          List<ZTS_EU_Species_Product__c> productWithTG=[select id,ZTS_EU_Product_Potential_Level__c,ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c from  ZTS_EU_Species_Product__c where id in:productHierst and ZTS_EU_type__c='SKU'];
          set<id> TGIds = new set<id>();
          for(ZTS_EU_Species_Product__c sp : productWithTG){
                            if(sp.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c != null){
                                TGIds.add(sp.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c);
                            }
                }
                map<id,list<ZTS_EU_Species_Product__c>> tGroupSpecieProd = new map<id,list<ZTS_EU_Species_Product__c>>();
                for(Id i : TGIds){
                    list<ZTS_EU_Species_Product__c> tmpLst = new list<ZTS_EU_Species_Product__c>();
                    for(ZTS_EU_Species_Product__c sp: productWithTG){
                        if(i == sp.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c){
                            tmpLst.add(sp);
                        }
                    }
                    if(!tmpLst.isEmpty()){
                        tGroupSpecieProd.put(i,tmpLst);
                    }
                }
                    
       List<ZTS_EU_Potential_Brands__c> productHierarchies = [Select Protocol_For_CA__c, brand__r.ZTS_EU_Product_Potential_Level__c,Period_of_Use_Months__c,Treated_Food_Yearly_Intake_by_Animal__c,CurrencyIsoCode,name,ZTS_EU_CA_Account_Type__c,brand__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c,brand__r.name,brand__r.ZTS_EU_Product_Unique_ID__c,brand__r.ZTS_EU_Influenced_By_Farm_Subsistence__c, brand__r.ZTS_EU_Influenced_By_Farm_Artificial_Sem__c,Adjustment_Factor__c,Annual_Number_of_treatments_Animal__c,Brand__c,ZTS_EU_Business_Unit_Abbr__c,MPG_SKU_Mix__c, Number_of_Doses_per_Animal__c,Number_of_Doses_per_SKU__c,Potential__c,Potential_Factor__c,Price_Doses_or_ml__c,Price_SKU__c,Product_Rotation__c,ZTS_EU_Value_Region_1__c,ZTS_EU_Value_Region_2__c,ZTS_EU_Value_Region_3__c,ZTS_EU_Value_Region_4__c From ZTS_EU_Potential_Brands__c z where id=:st];               
                          
          Map<Id, Map<Id, List<ZTS_EU_Potential_Brands__c>>> speciePotentialProd = new  Map<Id, Map<Id, List<ZTS_EU_Potential_Brands__c>>>();
         List<ZTS_EU_Potential_Brands__c> pBsWithSameTg = new List<ZTS_EU_Potential_Brands__c>();
           Map<id,List<ZTS_EU_Potential_Brands__c>> prodTgMap = new Map<id,List<ZTS_EU_Potential_Brands__c>>();
          for(ZTS_EU_Potential_Brands__c pbh:productHierarchies)
           {

               pBsWithSameTg.add(pbh);
               prodTgMap.put(pbh.brand__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c,pBsWithSameTg);
               speciePotentialProd.put(pbh.Potential__c,prodTgMap);
           
           }
          
          
          /* Creating ASC records */
          list<ZTS_EU_Account_Species_Potential__c> accSpecieConsulatation = new list<ZTS_EU_Account_Species_Potential__c>();
          for(Account acc: accountRecords){
            accSpecieConsulatation.add(TestUtilities.createNoInsertAcctSpcPot(acc.id,speciesRecords[0].id,20,20));
            accSpecieConsulatation.add(TestUtilities.createNoInsertAcctSpcPot(acc.id,speciesRecords[1].id,25,20));
          }
          
          insert accSpecieConsulatation;
          //Adding monthly cost per eggs at ASC level.
           accSpecieConsulatation[0].Monthly_Cost_per_1000_Eggs__c=1000;
          
          update accSpecieConsulatation[0];
          Set<id> ascIdSet = new Set<id>();
         for(ZTS_EU_Account_Species_Potential__c ascp :accSpecieConsulatation)
          {
            ascIdSet.add(ascp.id); 
          }
          ZTS_EU_Account_Product_Potential__c accProdPotential = Account_Prod_Potential_Calculation_Test.createAccProdPotential(accSpecieConsulatation[0].id, accountRecords[0].id,tgRecord.id, tgRecord.id, 'Name', 20);
          insert accProdPotential;
          
          test.startTest();
          
                  list<ZTS_EU_Species_Product__c> products = new list<ZTS_EU_Species_Product__c>();
          products.add(buRecord);
          products.add(tgRecord);
          products.add(brandRecord);
          products.add(mpgRecord);
          products.add(skuRecord);
          Set<String> markets= new Set<String>();
          markets.add('Brazil');
          list<ZTS_EU_Account_Species_Potential__c> ascp = [Select CurrencyIsoCode,Monthly_Cost_per_1000_Eggs__c,Yearly_Cost_per_1000_Eggs__c,name,Number_of_Animal_Interval__c,ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__r.ZTS_EU_Business_Unit_Abbr__c,ZTS_EU_Animal_Consultations_new__c,ZTS_EU_Animals_Consultations_actual__c,Account__c,ZTS_EU_BU_Abbr__c,Calculated_Value_of_Potentail__c,ZTS_EU_Animals_bought_from_other_herds__c,ZTS_EU_No_of_Nelore_Cattle_In_Genetic__c,ZTS_EU_No_of_Purebred_Animals__c,ZTS_EU_No_of_Slaughtered_Cattle__c,ZTS_EU_Species_Potential__c,ZTS_EU_Species_Potential_Value__c,ZTS_EU_Sum_Of_Account_Product_Potentials__c,ZTS_EU_Uniqueness_Key__c From ZTS_EU_Account_Species_Potential__c z where id in:ascIdSet];
          PotentialCalculatorEngine pa = new PotentialCalculatorEngine(markets);
          list<ZTS_EU_Species_Product__c> specieProd=  [Select ZTS_EU_NO_OF_CA_Species__c,ZTS_EU_NO_OF_EQ_Species__c,ZTS_EU_NO_OF_PY_Species__c,ZTS_EU_NO_OF_RU_Species__c,ZTS_EU_Sales_Budgets_SB__c,ZTS_EU_NO_OF_SW_Species__c,ZTS_EU_NO_OF_VPS_Species__c,ZTS_EU_Brand_is_Budgetable__c,ZTS_EU_BU_from_Brand__c,ZTS_EU_Business_Unit_Abbr__c,ZTS_EU_Business_Units__c,ZTS_EU_Create_Samples__c,ZTS_EU_Gift_Type__c,ZTS_EU_Gift_Value__c,ZTS_EU_Influenced_By_Farm_Artificial_Sem__c,ZTS_EU_Influenced_By_Farm_Subsistence__c,ZTS_EU_Influenced_By_Fattening_Mgmnt__c,ZTS_EU_Influenced_By_Purebreed_Calves__c,ZTS_EU_Influenced_By_Nutritional_Mgmnt__c,ZTS_EU_Influenced_By_Other_Herds_Animals__c,ZTS_EU_Influenced_By_Reproductive_Mgmnt__c,ZTS_EU_Is_Active__c,ZTS_EU_is_an_Internal_competitor__c,ZTS_EU_is_Budgetable__c,ZTS_EU_is_Child_of_Brand__c,ZTS_EU_Is_Detailable__c,ZTS_EU_is_Gift__c,ZTS_EU_Is_KOL_Area_of_Expertise__c,ZTS_EU_Is_Old__c,ZTS_EU_Is_Orderable__c,ZTS_EU_is_Samplable__c,ZTS_EU_Standard_Price__c,ZTS_EU_Market__c,ZTS_EU_Parent_Species_Product__c,ZTS_EU_Product_Potential_Level__c,ZTS_EU_Product_Unique_ID__c,ZTS_EU_SAP_Product_ID__c,ZTS_EU_Total_Budget_SB__c,ZTS_EU_Type__c,ZTS_EU_Zoetis_SFDC_ID__c,CurrencyIsoCode,name From ZTS_EU_Species_Product__c z where id=:tgRecord.id];
          pa.productsPerTherGroup=tGroupSpecieProd;
          pa.speciePotentialProd=speciePotentialProd;
          List<ZTS_EU_Account_Product_Potential__c> aa = pa.calculatePotential(accountRecords[0], ascp,keyAccntList);
          test.stopTest();
          
        }
        
    
        
  }  
  public static List<Account> createNoInsertAccount(String name,String type,String subtype,String recTypeId,String market,String PotRegion,Boolean omitFlag,string numOfFTE, string prescriptonProfile, string sizeOfHospital, string vatcodestrtno){
        
        List<Account> accountsList= new List<Account>();
        for(Integer i=0;i<5;i++) {
            Account acc = new Account(Name= name + i,
                                        Type= type,
                                        ZTS_EU_Sub_Type__c= subtype,
                                        ZTS_EU_Account_Status__c = 'Active',
                                        RecordTypeID = recTypeId,
                                        ZTS_EU_Market__c = market,
                                        ZTS_EU_Potential_Region__c = PotRegion,
                                        ZTS_EU_Omit_Segmentation_Calculations__c = omitFlag,
                                        ZTS_EU_Number_of_FTEs__c = numOfFTE,
                                        ZTS_EU_Prescription_Profile__c = prescriptonProfile,
                                        ZTS_EU_Size_of_the_Hospital__c = sizeOfHospital,
                                        ZTS_EU_VAT_Code__c = 'VAT'+vatcodestrtno+'-'+i);
            accountsList.add(acc);  
        }   
        return accountsList; 
    }
    
    
  public static ZTS_EU_Potential_Brands__c createNoInsertPotBrands(Id speciesId,Id brandId,Integer valReg1,Integer valReg2,Integer valReg3,Integer valReg4,decimal adjFactor, decimal mpgSKuMix, integer nuOdDosesPerAnimal, integer noOfDosesPerSku, integer anualNoOfTreatments){
         ZTS_EU_Potential_Brands__c potBrandRec = new ZTS_EU_Potential_Brands__c(Potential__c = speciesId,
                                                                              Brand__c =  brandId,
                                                                              Number_of_Doses_per_SKU__c = noOfDosesPerSku,
                                                                              ZTS_EU_Value_Region_1__c = valReg1,
                                                                              ZTS_EU_Value_Region_2__c = valReg2,
                                                                              ZTS_EU_Value_Region_3__c = valReg3,
                                                                              ZTS_EU_Value_Region_4__c = valReg4,
                                                                              Adjustment_Factor__c = adjFactor,
                                                                              MPG_SKU_Mix__c= mpgSKuMix,
                                                                              Number_of_Doses_per_Animal__c = nuOdDosesPerAnimal,
                                                                              Annual_Number_of_treatments_Animal__c =anualNoOfTreatments);   
         return potBrandRec; 
     }
     public static ZTS_EU_Species_Product__c createProdHierarchyRecord(String speciesProdName,String recType,String Market,String recTypeId,string parentRecord,decimal stdPrice){
         ZTS_EU_Species_Product__c speciesProdRec = new ZTS_EU_Species_Product__c(Name= speciesProdName,
                                                                                ZTS_EU_Type__c= recType ,
                                                                                ZTS_EU_Market__c= Market,
                                                                                RecordTypeID = recTypeId,
                                                                                ZTS_EU_Parent_Species_Product__c = parentRecord,
                                                                                ZTS_EU_Standard_Price__c = stdPrice);
                                                                            
         return speciesProdRec;                                                                           
    }
    public static ASC_Administration__c createASC_Administration(id bUnit, id specie, string apiName, string label, string grup, string userLanguage, string prodInfluence){
         ASC_Administration__c ascAdm = new ASC_Administration__c(API_Name__c = apiName,
                                       Business_Unit__c = bUnit,
                                       Group__c = grup,
                                       Label__c = label,
                                       Species__c = specie,
                                       User_Language__c = userLanguage,
                                       Product_Influence_API_Name__c = prodInfluence);
                                                                            
         return ascAdm;                                                                           
    }

    static List<ASC_Administration__c> getAdminList() {
      return new List<ASC_Administration__c>();
  }

  static Map<Id, ASC_Administration__c> getAdminMap() {
      return new Map<Id, ASC_Administration__c>();
  }

  @isTest
  static void beforeUpdate_test() {
      ASC_AdministrationTriggerHandler handler = new ASC_AdministrationTriggerHandler();
      Test.startTest();
      handler.afterUpdate(getAdminList(), getAdminMap(), getAdminList(), getAdminMap());
      Test.stopTest();
  }
  
  @isTest
  static void beforeDelete_test() {
      ASC_AdministrationTriggerHandler handler = new ASC_AdministrationTriggerHandler();
      Test.startTest();
      handler.beforeDelete(getAdminList(), getAdminMap());
      Test.stopTest();
  }

  @isTest
  static void afterInsert_test() {
      ASC_AdministrationTriggerHandler handler = new ASC_AdministrationTriggerHandler();
      Test.startTest();
      handler.afterInsert(getAdminList(), getAdminMap());
      Test.stopTest();
  }

  @isTest
  static void afterUpdate_test() {
      ASC_AdministrationTriggerHandler handler = new ASC_AdministrationTriggerHandler();
      Test.startTest();
      handler.afterUpdate(getAdminList(), getAdminMap(), getAdminList(), getAdminMap());
      Test.stopTest();
  }

  @isTest
  static void afterDelete_test() {
      ASC_AdministrationTriggerHandler handler = new ASC_AdministrationTriggerHandler();
      Test.startTest();
      handler.afterDelete(getAdminList(), getAdminMap());
      Test.stopTest();
  }

  @isTest
  static void afterUndelete_test() {
      ASC_AdministrationTriggerHandler handler = new ASC_AdministrationTriggerHandler();
      Test.startTest();
      handler.afterUndelete(getAdminList(), getAdminMap());
  }
}