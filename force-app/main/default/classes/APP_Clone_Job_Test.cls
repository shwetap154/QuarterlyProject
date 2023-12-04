/*
    @@ Puropose: Test class for APP_Clone_Job
    @@ Author: Pavan Kumar
    @@ Date : 03- Feb-2015 
*/
@isTest
public class APP_Clone_Job_Test {
	
	static testmethod void APP_Clone_Job_Test_Method(){
        /* Creating user records*/
        list<user> userRecs = new list<user>();
        Profile profiles = [Select Id From Profile Where Name='System Administrator'];
        List<User> usersList = new List<User>();
        User newuser=new User();
        newuser.profileid = profiles.Id;
        newuser.email = 'denem1e@deneme.com';
        newuser.username = 'deneme1@deneme1.com';
        newuser.lastname = 'denme';
        newuser.alias = 'dene1';
        newuser.languagelocalekey = 'en_US';
        newuser.localesidkey = 'en_US';
        newuser.timezonesidkey = 'America/Los_Angeles';
        newuser.localesidkey = 'en_US';
        newUser.ZTS_EU_Market__c = 'Canada';
        newUser.EmailEncodingKey = 'ISO-8859-1';
        userRecs.add(newuser); 
        insert userRecs;
        
        system.runAs(userRecs[0]){
        	list<Acc_Prod_Pot_Markets__c> accProdSettings = new list<Acc_Prod_Pot_Markets__c>();
        	accProdSettings.add(createAccProdPotMarketSetting('Sunday','United Kingdom,Canada'));
        	accProdSettings.add(createAccProdPotMarketSetting('Monday','United Kingdom,Canada'));
        	accProdSettings.add(createAccProdPotMarketSetting('Tuesday','Canada,United Kingdom'));
        	accProdSettings.add(createAccProdPotMarketSetting('Wednesday','United Kingdom,Canada'));
        	accProdSettings.add(createAccProdPotMarketSetting('Thursday','United Kingdom,Canada'));
        	accProdSettings.add(createAccProdPotMarketSetting('Friday','United Kingdom,Canada'));
        	accProdSettings.add(createAccProdPotMarketSetting('Saturday','United Kingdom,Canada'));
        	insert accProdSettings;
        	
        	list<MarketGeoMapping__c> MarketGeoMappingSetting = new list<MarketGeoMapping__c>();
        	MarketGeoMappingSetting.add(createMarketGeoMappingSetting('Canada','Brand'));
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
	        accountRecords.addAll(TestUtilities.createNoInsertAccount('Acc','Farm','Beef',recordtypeMap.get('Account-ZTS_EU_Activated_Account'),'Canada','1',false));
	        accountRecords.addAll(TestUtilities.createNoInsertAccount('Acc','Farm','Beef',recordtypeMap.get('Account-ZTS_EU_Activated_Account'),'Canada','1',false));
	        accountRecords.addAll(TestUtilities.createNoInsertAccount('Acc','Farm','Beef',recordtypeMap.get('Account-ZTS_EU_Activated_Account'),'Canada','1',false));
	        
	        if(accountRecords.size() > 0){
	        	insert accountRecords;
	        }
	        
	        
	        
	        
	        /*Creating Product Hierarchy records */
	        
	        ZTS_EU_Species_Product__c buRecord = new ZTS_EU_Species_Product__c();
	        buRecord = TestUtilities.createNoInsertBrand('Ph 1','Business Unit','Canada',recordtypeMap.get('ZTS_EU_Species_Product__c-Business_Unit'));
	        buRecord.ZTS_EU_Business_Unit_Abbr__c = 'SW';
	        insert buRecord;
	        
	        ZTS_EU_Species_Product__c tgRecord = new ZTS_EU_Species_Product__c();
	        tgRecord = TestUtilities.createNoInsertBrand('Ph 1','Therapeutic Group','Canada',recordtypeMap.get('ZTS_EU_Species_Product__c-Therapeutic_Group'));
	        insert tgRecord;
	       
	        ZTS_EU_Species_Product__c brandRecord = new ZTS_EU_Species_Product__c();
	        brandRecord = createProdHierarchyRecord('Ph 2','Brand','Canada',recordtypeMap.get('ZTS_EU_Species_Product__c-Brand'),tgRecord.id);
	        insert brandRecord;
	       
	        ZTS_EU_Species_Product__c mpgRecord = new ZTS_EU_Species_Product__c();
	        mpgRecord = createProdHierarchyRecord('Ph 2','MPG','Canada',recordtypeMap.get('ZTS_EU_Species_Product__c-MPG'),brandRecord.id);
	        insert mpgRecord;
	       
	        ZTS_EU_Species_Product__c skuRecord = new ZTS_EU_Species_Product__c();
	        skuRecord = createProdHierarchyRecord('Ph 2','SKU','Canada',recordtypeMap.get('ZTS_EU_Species_Product__c-SKU'),mpgRecord.id);
	        skuRecord.ZTS_EU_Standard_Price__c = 20;
	        insert skuRecord;
			
			/* Creating ZTS_EU_Species__c records */
	        list<ZTS_EU_Species__c> speciesRecords = new list<ZTS_EU_Species__c>();
	        for(integer i=0; i<5; i++){
	        	speciesRecords.add(TestUtilities.createNoInsertSpecies('Specie',buRecord.id,'Specie name','Canada'));
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
	        
	        for(ZTS_EU_Potential_Brands__c z:pb ){
	        }
	        
	        /* Creating ZTS_EU_Potential_Brands__c records */
	        list<ZTS_EU_Account_Species_Potential__c> accSpecieConsulatation = new list<ZTS_EU_Account_Species_Potential__c>();
	        for(Account acc: accountRecords){
	        	accSpecieConsulatation.add(TestUtilities.createNoInsertAcctSpcPot(acc.id,speciesRecords[0].id,20,20));
	        }
	        
	        insert accSpecieConsulatation;
	        
	        
	        ZTS_EU_Account_Product_Potential__c accProdPotential = createAccProdPotential(accSpecieConsulatation[0].id, accountRecords[0].id,tgRecord.id, tgRecord.id, 'Name', 20);
	        insert accProdPotential;
	        
	        ZTS_EU_Account_Product_Potential__c accProdPotential1 = createAccProdPotential(accSpecieConsulatation[1].id, accountRecords[0].id,tgRecord.id, tgRecord.id, 'Name', 20);
			insert accProdPotential1;
			
	        
	        test.startTest();
	        
		        set<id> ascIDs = new set<id>();
		        ascIDs.add(accSpecieConsulatation[0].id);
		        ascIDs.add(accSpecieConsulatation[1].id);
		        APP_Clone_Job acj = new APP_Clone_Job(ascIds);
				database.executeBatch(acj);
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
    public static ZTS_EU_Account_Product_Potential__c createAccProdPotential(id accSpecieConsultationID, id accountId,id prodHierarchyId, string prodId, string prodName, double prodPotential){
         ZTS_EU_Account_Product_Potential__c AccProdPotential = new ZTS_EU_Account_Product_Potential__c(Account_Species_Consultation__c = accSpecieConsultationID,
         																								Account__c = accountId,
         																								Product_Hierarchy__c = prodHierarchyId,
         																								ZTS_EU_Product_ID_1__c= prodId,
         																								ZTS_EU_Product_Name_1__c = prodName,
         																								ZTS_EU_Product_Potential_1__c = prodPotential );
                                                                            
         return AccProdPotential;                                                                           
    }
    
    public static Acc_Prod_Pot_Markets__c createAccProdPotMarketSetting(string name, string market){
         Acc_Prod_Pot_Markets__c AccProdPotential = new Acc_Prod_Pot_Markets__c(name = name,markets__c = market);
         return AccProdPotential;                                                                           
    }
    
    public static MarketGeoMapping__c createMarketGeoMappingSetting(string name, string potentialLevel){
         MarketGeoMapping__c marketGeoMapping = new MarketGeoMapping__c(name = name,Product_Potential_Level__c = potentialLevel);
         return marketGeoMapping;                                                                           
    }

}