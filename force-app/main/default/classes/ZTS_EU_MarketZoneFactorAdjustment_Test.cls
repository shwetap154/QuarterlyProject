/*
    @@ Puropose: Test class for ZTS_EU_MarketZoneFactorAdjustmentCtrl 
    @@ Author: Pavan Kumar
*/
@isTest
public class ZTS_EU_MarketZoneFactorAdjustment_Test {
	
	@testSetup 
	static void testData() {
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
        	list<Acc_Prod_Pot_Markets__c> accProdSettings = new list<Acc_Prod_Pot_Markets__c>();
        	accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Sunday','United Kingdom,Canada'));
        	accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Monday','United Kingdom,Canada'));
        	accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Tuesday','United Kingdom,Canada'));
        	accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Wednesday','United Kingdom,Canada'));
        	accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Thursday','United Kingdom,Canada'));
        	accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Friday','United Kingdom,Canada'));
        	accProdSettings.add(Account_Prod_Potential_Calculation_Test.createAccProdPotMarketSetting('Saturday','United Kingdom,Canada'));
        	insert accProdSettings;
        	
        	list<MarketGeoMapping__c> MarketGeoMappingSetting = new list<MarketGeoMapping__c>();
        	MarketGeoMappingSetting.add(Account_Prod_Potential_Calculation_Test.createMarketGeoMappingSetting('United Kingdom','SKU'));
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
	        accountRecords.addAll(TestUtilities.createNoInsertAccount('Acc','Farm','Beef',recordtypeMap.get('Account-ZTS_EU_Activated_Account'),'United Kingdom','1',false));
	        accountRecords.addAll(TestUtilities.createNoInsertAccount('Acc','Farm','Beef',recordtypeMap.get('Account-ZTS_EU_Activated_Account'),'United Kingdom','1',false));
	        
	        if(accountRecords.size() > 0){
	        	insert accountRecords;
	        }
	        
	        
	        
	        
	        /*Creating Product Hierarchy records */
	        
	        ZTS_EU_Species_Product__c buRecord = new ZTS_EU_Species_Product__c();
	        buRecord = TestUtilities.createNoInsertBrand('Ph 1','Business Unit','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-Business_Unit'));
	        buRecord.ZTS_EU_Business_Unit_Abbr__c = 'SW';
	        insert buRecord;
	        
	        ZTS_EU_Species_Product__c tgRecord = new ZTS_EU_Species_Product__c();
	        tgRecord = TestUtilities.createNoInsertBrand('Ph 1','Therapeutic Group','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-Therapeutic_Group'));
	        insert tgRecord;
	       
	        ZTS_EU_Species_Product__c brandRecord = new ZTS_EU_Species_Product__c();
	        brandRecord = Account_Prod_Potential_Calculation_Test.createProdHierarchyRecord('Ph 2','Brand','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-Brand'),tgRecord.id);
	        insert brandRecord;
	       
	        ZTS_EU_Species_Product__c mpgRecord = new ZTS_EU_Species_Product__c();
	        mpgRecord = Account_Prod_Potential_Calculation_Test.createProdHierarchyRecord('Ph 2','MPG','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-MPG'),brandRecord.id);
	        insert mpgRecord;
	       
	        ZTS_EU_Species_Product__c skuRecord = new ZTS_EU_Species_Product__c();
	        skuRecord = Account_Prod_Potential_Calculation_Test.createProdHierarchyRecord('Ph 2','SKU','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-SKU'),mpgRecord.id);
	        insert skuRecord;
	        
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
	        
	        insert pb;
        }
	}
	//Test method for ZTS_EU_MarketZoneFactorAdjustmentCtrl Class
	public static testMethod void ZTS_EU_MarketZoneFactorAdjustmentCtrl_Test(){
        Profile profiles=[Select Id From Profile Where Name='System Administrator'];
        List<User> usersList = new List<User>();
        User newuser=new User();
        newuser.profileid=profiles.Id;
        newuser.email='denem1e@deneme.com';
        newuser.username='user2@deneme1.com';
        newuser.lastname='denm2e';
        newuser.alias='dene21';
        newuser.languagelocalekey='en_US';
        newuser.localesidkey='en_US';
        newuser.timezonesidkey='America/Los_Angeles';
        newuser.localesidkey='en_US';
        newUser.ZTS_EU_Market__c= 'United Kingdom';
        newUser.EmailEncodingKey= 'ISO-8859-1';
        insert newuser; 
		system.runAs(newuser){
			test.startTest();
	        PageReference pf = Page.ZTS_EU_MarketZoneFactorRedirect;
	        test.setcurrentPage(pf);
	        ZTS_EU_MarketZoneFactorRedirect mr = new ZTS_EU_MarketZoneFactorRedirect();
	        mr.redirectToPotentialFactorAdjustment();
	        id buId = [select id from ZTS_EU_Species_Product__c limit 1].id;
	        id specieID =  [select id from ZTS_EU_Species__c limit 1].id;
	        PageReference pageRef = Page.ZTS_EU_MarketZoneFactorAdjustment;
	        pageRef.getParameters().put('bu', buId);
	        pageRef.getParameters().put('pageNum', '1');
	        pageRef.getParameters().put('query', 'true');
	        pageRef.getParameters().put('sp', specieID);
	        test.setcurrentPage(pageRef);
	        ZTS_EU_MarketZoneFactorAdjustmentCtrl obj = new ZTS_EU_MarketZoneFactorAdjustmentCtrl();
	        obj.selectedBu = buId;
	        obj.prepareSpecieList();
	        obj.query = true;
	        obj.intialLoad = true;
	        obj.prepareSpecieList();
	        obj.selectedSpecie = specieID;
	        obj.getwrapperList();
	        obj.wrapperList[0].selected = true;
	        obj.adjustmentFactr = 1;
	        obj.mpgSKUMix = 1;
	        obj.annualNoOfTreatments = 1;
	        obj.numOfDosesPerMl = 1;
	        obj.productRotation = 1;
	        obj.numberOfDosesPerSku = 1;
	        obj.setFactorsRedirect(); 
	        obj.save();
	        obj.reLoad();
	        obj.sortList();
	        obj.resetPageTable();
	        obj.getSortDirection();
	        obj.setSortDirection('ASC');
	        obj.selection();
	        obj.setFactorValues();
	        obj.previousPage();
	        obj.nextPage();
	        obj.firstPage();
	        obj.lastPage();
	        integer x = obj.fromRecords;
	        x = obj.toRecords;
	        obj.setwrapperList(obj.wrapperList);
	        
	        test.stopTest();
		}
        
        
	}
	/*//Test method for ZTS_EU_SetAdjustmentFactorsController Class
	public static testMethod void ZTS_EU_SetAdjustmentFactorsController_Test(){
		PageReference pf = Page.ZTS_EU_MarketZoneFactorAdjustment;
        test.setcurrentPage(pf);
        ZTS_EU_SetAdjustmentFactorsController zt1 = new ZTS_EU_SetAdjustmentFactorsController();
		ZTS_EU_SetAdjustmentFactorsController zt = new ZTS_EU_SetAdjustmentFactorsController();
		zt.goToSetAdjustmentFactors();
		List<SelectOption> sp1 = zt.getUnitOptions(); 
		List<SelectOption> sp2 = zt.getCurrencyOptions();
		//zt.saveAction();
		zt.cancelAction(); 
	}*/
	
}