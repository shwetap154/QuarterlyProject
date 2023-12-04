/**
 * @description       : Test class for Account_Prod_Potential_Calculation_Job and Account_Product_Potential_Job 
 * @author            : Pavan Kumar @ Unknown
 * @group             : 
 * @last modified on  : 07-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-03-2015   Pavan Kumar @ Unknown       Initial Version
 * 1.1   07-07-2022   Ethan Hirsch @ Zoetis Inc   Update file header and fix an issue where scheduled jobs would never fire
 **/
@isTest
public class Account_Prod_Potential_Calculation_Test {
	
	@testSetup 
	static void testData() {
		list<Acc_Prod_Pot_Markets__c> blLst = new list<Acc_Prod_Pot_Markets__c>();
		Acc_Prod_Pot_Markets__c bl = new Acc_Prod_Pot_Markets__c(name='Account_Prod_Potential_Calculation_Job',Batch_Limit__c=10);
		blLst.add(bl);
		Acc_Prod_Pot_Markets__c bl1 = new Acc_Prod_Pot_Markets__c(name='Account_Product_Potential_Job',Batch_Limit__c=10);
		blLst.add(bl1);
		insert blLst;

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

        	List<Acc_Prod_Pot_Markets__c> accProdSettings = new list<Acc_Prod_Pot_Markets__c>();
        	accProdSettings.add(createAccProdPotMarketSetting('Sunday','United Kingdom,Canada'));
        	accProdSettings.add(createAccProdPotMarketSetting('Monday','United Kingdom,Canada'));
        	accProdSettings.add(createAccProdPotMarketSetting('Tuesday','United Kingdom,Canada'));
        	accProdSettings.add(createAccProdPotMarketSetting('Wednesday','United Kingdom,Canada'));
        	accProdSettings.add(createAccProdPotMarketSetting('Thursday','United Kingdom,Canada'));
        	accProdSettings.add(createAccProdPotMarketSetting('Friday','United Kingdom,Canada'));
        	accProdSettings.add(createAccProdPotMarketSetting('Saturday','United Kingdom,Canada'));
        	insert accProdSettings;
        	
        	List<MarketGeoMapping__c> MarketGeoMappingSetting = new list<MarketGeoMapping__c>();
        	MarketGeoMappingSetting.add(createMarketGeoMappingSetting('United Kingdom','SKU'));
        	insert MarketGeoMappingSetting;
        	
			
	        Set<string> objNames = new Set<String>();
	        objNames.add('Account');
			objNames.add('ZTS_EU_Species_Product__c');
	        List<Recordtype> recordtypesLst = new list<Recordtype>();
	        recordtypesLst = [select id, developerName,SobjectType from recordtype where SobjectType in :objNames ];
	        
	        Map<String, String> recordtypeMap = new Map<String, String>();
	        
	        for(Recordtype r : recordtypesLst){
	        	String objName_DeveloperName = r.SobjectType +'-'+ r.developerName;
	        	recordtypeMap.put(objName_DeveloperName, r.id);
	        }
	        
	        /*Creating Account record */
	        list<Account> accountRecords = new list<account>();
	        accountRecords.addAll(TestUtilities.createNoInsertAccount('Acc','Farm','Beef',recordtypeMap.get('Account-ZTS_EU_Activated_Account'),'United Kingdom','Other','1',false));
	        accountRecords.addAll(TestUtilities.createNoInsertAccount('Acc','Farm','Beef',recordtypeMap.get('Account-ZTS_EU_Activated_Account'),'United Kingdom','Other','1',false));
	        
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
	        brandRecord = createProdHierarchyRecord('Ph 2','Brand','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-Brand'),tgRecord.id);
	        insert brandRecord;
	       
	        ZTS_EU_Species_Product__c mpgRecord = new ZTS_EU_Species_Product__c();
	        mpgRecord = createProdHierarchyRecord('Ph 2','MPG','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-MPG'),brandRecord.id);
	        insert mpgRecord;
	       
	        ZTS_EU_Species_Product__c skuRecord = new ZTS_EU_Species_Product__c();
	        skuRecord = createProdHierarchyRecord('Ph 2','SKU','United Kingdom',recordtypeMap.get('ZTS_EU_Species_Product__c-SKU'),mpgRecord.id);
	        insert skuRecord;
	        
	        /* Creating ZTS_EU_Species__c records */
	        list<ZTS_EU_Species__c> speciesRecords = new list<ZTS_EU_Species__c>();
	        for(integer i=0; i<5; i++){
	        	speciesRecords.add(TestUtilities.createNoInsertSpecies('Specie',buRecord.id,'Specie name','United Kingdom'));
	        }
	        insert speciesRecords;
	        
	        /* Creating ZTS_EU_Potential_Brands__c (Potential Product) records */
	        list<ZTS_EU_Potential_Brands__c> pb = new list<ZTS_EU_Potential_Brands__c>();
			
			for(ZTS_EU_Species__c z : speciesRecords ){
	        	pb.add(TestUtilities.createNoInsertPotBrands(z.id,brandRecord.id,1,1,1,1));
	        }
	        
	        insert pb;
	        
	        /* Creating ZTS_EU_Potential_Brands__c (Account Species / Consultation) records */
	        list<ZTS_EU_Account_Species_Potential__c> accSpecieConsulatation = new list<ZTS_EU_Account_Species_Potential__c>();
	        for(Account acc: accountRecords){
	        	accSpecieConsulatation.add(TestUtilities.createNoInsertAcctSpcPot(acc.id,speciesRecords[0].id,20,20));
	        }
	        
			insert accSpecieConsulatation;
		}

	}
	
	static testmethod void Account_Prod_Potential_Calculation_Test_Method(){
		
		User systemAdminUser = [SELECT Id FROM User WHERE Username = 'deneme1@deneme1.com' LIMIT 1];
		
		System.runAs(systemAdminUser){

			List<ZTS_EU_Account_Species_Potential__c> accSpeciesConsulatations = [SELECT Id FROM ZTS_EU_Account_Species_Potential__c];
			List<Account> accounts = [SELECT Id FROM Account];
			List<ZTS_EU_Species_Product__c> tgProdHierarchies = [SELECT Id FROM ZTS_EU_Species_Product__c WHERE Name = 'Ph 1' AND ZTS_EU_Market__c = 'United Kingdom' AND ZTS_EU_Type__c = 'Therapeutic Group'];
	        
	        ZTS_EU_Account_Product_Potential__c accProdPotential = createAccProdPotential(accSpeciesConsulatations[0].Id, accounts[0].id,tgProdHierarchies[0].id, tgProdHierarchies[0].id, 'Name', 20);
			insert accProdPotential;
			
			
			Integer accountProdPotentialCount = [SELECT count() FROM ZTS_EU_Account_Product_Potential__c WHERE Account_Species_Consultation__c = :accSpeciesConsulatations[0].Id];

			System.assertEquals(accountProdPotentialCount, 1, 'The expected count of Account Product Potential record is 1');
			
	        test.startTest();
	        set<string> markets = new set<string>();
	        markets.add('United Kingdom');
	        markets.add('Canada');
	        Account_Product_Potential_Delete_Job a = new Account_Product_Potential_Delete_Job(); 
	        String CRON_EXP = '0 0 0 15 3 ?';
	        System.schedule('ScheduleApexClassTest',CRON_EXP, a);
	        dataBase.executeBatch(a);
			test.stopTest();
			
			Integer accountProdPotentialCountAfterDelete = [SELECT count() FROM ZTS_EU_Account_Product_Potential__c];
			
			System.assertEquals(accountProdPotentialCountAfterDelete, 0, 'The expected count of Account Product Potential record after delete is 0');   
        }
        
	}
	
	static testmethod void Account_Delete_With_BU_Test_Method(){
		
		User systemAdminUser = [SELECT Id FROM User WHERE Username = 'deneme1@deneme1.com' LIMIT 1];
		
		System.runAs(systemAdminUser){

			List<ZTS_EU_Account_Species_Potential__c> accSpeciesConsulatations = [SELECT Id FROM ZTS_EU_Account_Species_Potential__c];
			List<Account> accounts = [SELECT Id FROM Account];
			List<ZTS_EU_Species_Product__c> tgProdHierarchies = [SELECT Id FROM ZTS_EU_Species_Product__c WHERE Name = 'Ph 1' AND ZTS_EU_Market__c = 'United Kingdom' AND ZTS_EU_Type__c = 'Therapeutic Group'];
	        
	        ZTS_EU_Account_Product_Potential__c accProdPotential = createAccProdPotential(accSpeciesConsulatations[0].id, accounts[0].id,tgProdHierarchies[0].id, tgProdHierarchies[0].id, 'Name', 20);
	        insert accProdPotential;
			
			
			Integer accountProdPotentialCount = [SELECT count() FROM ZTS_EU_Account_Product_Potential__c];

			System.assertEquals(accountProdPotentialCount, 1, 'The expected count of Account Product Potential record is 1');

	        test.startTest();
	        set<string> markets = new set<string>();
	        markets.add('United Kingdom');
	        markets.add('Canada');
	        Account_Product_Potential_Delete_Job a = new Account_Product_Potential_Delete_Job('SW'); 
	        String CRON_EXP = '0 0 0 15 3 ?';
	        System.schedule('ScheduleApexClassTest',CRON_EXP, a);
	        dataBase.executeBatch(a);
			test.stopTest();
			
	        Integer accountProdPotentialCountAfterDelete = [SELECT count() FROM ZTS_EU_Account_Product_Potential__c];
			
			System.assertEquals(accountProdPotentialCountAfterDelete, 0, 'The expected count of Account Product Potential record after delete is 0'); 
        }
        
	}
	
	static testmethod void APP_Clone_Job_Test_Method(){
       
		User systemAdminUser = [SELECT Id FROM User WHERE Username = 'deneme1@deneme1.com' LIMIT 1];
		
		System.runAs(systemAdminUser){

			List<ZTS_EU_Account_Species_Potential__c> accSpeciesConsulatations = [SELECT Id FROM ZTS_EU_Account_Species_Potential__c];
			List<Account> accounts = [SELECT Id FROM Account];
			List<ZTS_EU_Species_Product__c> tgProdHierarchies = [SELECT Id FROM ZTS_EU_Species_Product__c WHERE Name = 'Ph 1' AND ZTS_EU_Market__c = 'United Kingdom' AND ZTS_EU_Type__c = 'Therapeutic Group'];
	        
	        
	        ZTS_EU_Account_Product_Potential__c accProdPotential = createAccProdPotential(accSpeciesConsulatations[0].id, accounts[0].id,tgProdHierarchies[0].id, tgProdHierarchies[0].id, 'Name', 20);
	        insert accProdPotential;
	        
	        ZTS_EU_Account_Product_Potential__c accProdPotential1 = createAccProdPotential(accSpeciesConsulatations[1].id, accounts[0].id,tgProdHierarchies[0].id, tgProdHierarchies[0].id, 'Name', 20);
			insert accProdPotential1;
			
			
	        test.startTest();
	        
	        set<id> ascIDs = new set<id>();
	        ascIDs.add(accSpeciesConsulatations[0].id);
	        ascIDs.add(accSpeciesConsulatations[1].id);
	        
	        system.debug('ascIDs>>>>'+ascIDs);
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