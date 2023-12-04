@isTest
public class ZTS_EU_ASC_Administartion_Test {
	static testMethod void ZTS_EU_ASC_Administartion_Test_Method() {
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
	        accountRecords.addAll(TestUtilities.createNoInsertVATcodeAccount('Acc','Farm','Beef',recordtypeMap.get('Account-ZTS_EU_Activated_Account'),'Brazil','1','112',false));
	        accountRecords.addAll(TestUtilities.createNoInsertVATcodeAccount('Acc','Farm','Beef',recordtypeMap.get('Account-ZTS_EU_Activated_Account'),'Brazil','1','113',false));
	        
	        if(accountRecords.size() > 0){
	        	insert accountRecords;
	        }
	        
	        
	        
	        
	        /*Creating Product Hierarchy records */
	        
	        ZTS_EU_Species_Product__c buRecord = new ZTS_EU_Species_Product__c();
	        buRecord = TestUtilities.createNoInsertBrand('Ph 1','Business Unit','Brazil',recordtypeMap.get('ZTS_EU_Species_Product__c-Business_Unit'));
	        buRecord.ZTS_EU_Business_Unit_Abbr__c = 'SW';
	        insert buRecord;
	        
	        
	        /* Creating ZTS_EU_Species__c records */
	        list<ZTS_EU_Species__c> speciesRecords = new list<ZTS_EU_Species__c>();
	        for(integer i=0; i<5; i++){
	        	speciesRecords.add(TestUtilities.createNoInsertSpecies('Specie',buRecord.id,'Specie name','Brazil'));
	        }
	        insert speciesRecords;
	        
	        
	        /* Creating ZTS_EU_Potential_Brands__c records */
	        list<ZTS_EU_Account_Species_Potential__c> accSpecieConsulatation = new list<ZTS_EU_Account_Species_Potential__c>();
	        accSpecieConsulatation.add(TestUtilities.createNoInsertAcctSpcPot(accountRecords[0].id,speciesRecords[0].id,20,20));
	        insert accSpecieConsulatation;
	        
	        
	        list<ASC_Administration__c> ascAdmlst = new list<ASC_Administration__c>();
	        ascAdmlst.add(createASC_Administration(buRecord.id, speciesRecords[0].id, 'Farm_uses_timed_artificial_insemi__c', 'Farm uses TAI','Fattening Management', 'en_US'));
	        ascAdmlst.add(createASC_Administration(buRecord.id, speciesRecords[0].id, 'Calculated_Value_of_Potentail__c', 'Farm uses TAI','Nutritional Management', 'en_US'));
	        ascAdmlst.add(createASC_Administration(buRecord.id, speciesRecords[0].id, 'The_farm_does_not_use_TAI_but_uses_conv__c', 'Farm uses TAI','Reproductive Management', 'en_US'));
	        ascAdmlst.add(createASC_Administration(null, speciesRecords[0].id, 'ZTS_EU_Animals_Consultations_actual__c', 'Farm uses TAI','', 'en_US'));
			insert ascAdmlst;
			System.debug('$$$ ascAdmlst: '+ascAdmlst);
			System.debug('$$$ ascAdmlst[3]: '+ascAdmlst[3]);
			
			test.startTest();
			
			DispatchTriggerHandler.firstTimeTracker = new Set<String>();
			update ascAdmlst;
			
			ASC_AdministrationTriggerService.beforeUpdate(ascAdmlst);
			
	        pageReference pf = page.ZTS_EU_ASC_Administartion;
	        Test.setCurrentPage(pf);
	        pf.getParameters().put('accountId', accountRecords[0].id);
	        ApexPages.StandardController sc = new ApexPages.StandardController(accSpecieConsulatation[0]);
	        ZTS_EU_ASC_Administartion ascadm = new ZTS_EU_ASC_Administartion(sc);
	        ascadm.selectedBusinessUnits = buRecord.id;
	        ascadm.refreshSpecies();
	        ascadm.selectedSpecie = speciesRecords[0].id;
	        ascadm.displayQuetions();
	        ascadm.updateRecord();
	        
	        pageReference pf1 = page.ZTS_EU_ASC_Administartion;
	        Test.setCurrentPage(pf1);
	        pf1.getParameters().put('accountId', accountRecords[0].id);
	        pf1.getParameters().put('ascId', accSpecieConsulatation[0].id);
	        pf1.getParameters().put('mode', 'Detail');
	        ApexPages.StandardController sc1 = new ApexPages.StandardController(accSpecieConsulatation[0]);
			ZTS_EU_ASC_Administartion ascadm1 = new ZTS_EU_ASC_Administartion(sc1);
			
			update accSpecieConsulatation;
			delete accSpecieConsulatation;
			test.stopTest();
			
			System.assertEquals(0,[SELECT count() FROM ZTS_EU_Account_Species_Potential__c WHERE Id IN :accSpecieConsulatation], 'These records should no longer exist');
	        
        }
	
		 
	}
	
	public static ASC_Administration__c createASC_Administration(id bUnit, id specie, string apiName, string label, string grup, string userLanguage){
         ASC_Administration__c ascAdm = new ASC_Administration__c(API_Name__c = apiName,
         														  Business_Unit__c = bUnit,
         														  Group__c = grup,
         														  Label__c = label,
         														  Species__c = specie,
         														  User_Language__c = userLanguage);
                                                                            
         return ascAdm;                                                                           
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