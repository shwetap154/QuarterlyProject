@isTest
public class SampleDropTrigger_Test
{
	static testMethod void beforeDeleteTest()
	{
		User intlUsr = new User();
		intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
		intlUsr.FirstName = 'usUser';
		intlUsr.ZTS_EU_Market__c = 'United States';
		insert intlUsr;
		
		System.runAs(intlUsr) {
			
			Test.StartTest();
			ZTS_DataUtilityTest.activateTriggerSettings();
			List<Account> accList = ZTS_DataUtilityTest.createAccountRecord(1);
			accList[0].ZTS_EU_Market__c = 'United States';
			insert accList ;
			List<Call__c>callList = ZTS_DataUtilityTest.createCallRecord(1);
			insert callList;
			callList[0].ZTS_EU_Status__c = 'Submitted';
			callList[0].ZTS_EU_Submitted_Date__c=System.today()+1;

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

			ZTS_EU_Species_Product__c tgRecord = new ZTS_EU_Species_Product__c();
	        tgRecord = TestUtilities.createNoInsertBrand('Ph 1','Therapeutic Group','Canada',recordtypeMap.get('ZTS_EU_Species_Product__c-Therapeutic_Group'));
	        insert tgRecord;
	       
	        ZTS_EU_Species_Product__c brandRecord = new ZTS_EU_Species_Product__c();
	        brandRecord = createProdHierarchyRecord('Ph 2','Brand','Canada',recordtypeMap.get('ZTS_EU_Species_Product__c-Brand'),tgRecord.id);
	        insert brandRecord;
			
			ZTS_US_Sample__c sample= new ZTS_US_Sample__c(ZTS_US_Item_Code__c='ABC1233',ZTS_US_Lot__c='LOT1',ZTS_US_Start_Quantity__c=15,ZTS_US_Product__c=brandRecord.Id);
			insert sample;

			List<ZTS_US_Sample__c> sampleList=new List <ZTS_US_Sample__c>();
			sampleList.add(sample);
			List<ZTS_US_Sample__c> newsampleList=new List <ZTS_US_Sample__c>();
			ZTS_US_Sample_Drop__c samdrop= new ZTS_US_Sample_Drop__c(ZTS_US_Sample__c=sampleList[0].Id,ZTS_EU_Quantity__c=3,
			ZTS_US_Account__c = accList[0].Id,ZTS_US_Call__c = callList[0].Id);
			update callList;                                            
			insert samdrop;
			delete samdrop;
			Test.stopTest();
		}
	}

	static ZTS_EU_Species_Product__c createProdHierarchyRecord(String speciesProdName,String recType,String Market,String recTypeId,string parentRecord){
		ZTS_EU_Species_Product__c speciesProdRec = new ZTS_EU_Species_Product__c(Name= speciesProdName,
																				 ZTS_EU_Type__c= recType ,
																				 ZTS_EU_Market__c= Market,
																				 RecordTypeID = recTypeId,
																				 ZTS_EU_Parent_Species_Product__c = parentRecord);
																		   
		return speciesProdRec;                                                                           
   }
}