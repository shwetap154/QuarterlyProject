/*******************************************************************************************************************************************
* File Name     :   ZTS_EU_UncheckZip 
* Description   :  Query all the zip where need synced is true and based on the sucess record of ZTS_EU_ZipAllignBatch,It will update zip.

Sequence of events : Account(s) is/are updated with ZTS_EU_TSF_PBC__c field value.
                   : Finish method triggers
                   		->Execute ZTS_EU_UncheckBrickBatch batch class.                          

* @author       :   Deloitte consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     5/13/2014     Sunil           Created the class.

********************************************************************************************************************************************/
public class ZTS_EU_UncheckZip implements Database.Batchable<sObject>, Database.Stateful  {
	
	public Double failedUpdates = 0;
	public Set<Id> failedAccountId;
	public Map<id,Account> failedAccMap;
	public Set<Id> failedZipId = new Set<Id>();
	public Map<ID,ID> zipBrickMap = new Map<ID,ID>();
	public Database.QueryLocator start(Database.BatchableContext BC){
		 return Database.getQueryLocator([select id,ZTS_EU_ZipCode__c,ZTS_EU_BrickCode__c,name,ZTS_EU_To_Be_Synced__c from ZTS_GL_ZipToBrick__c  where ZTS_EU_To_Be_Synced__c = true]);
	}
	public void execute(Database.BatchableContext BC,List<sObject> scope){
		List<ZTS_GL_ZipToBrick__c> updateZipList = new List<ZTS_GL_ZipToBrick__c>();
		Map<String,String> failedZipMap  = new Map<String,String>();
		for(ID accId : failedAccountId){
			if(failedAccMap.containsKey(accId) && failedAccMap.get(accID).ZTS_EU_ZIP_POSTAL_CODE__C != null){
				failedZipMap.put(failedAccMap.get(accID).ZTS_EU_ZIP_POSTAL_CODE__C ,accId);
			}
		}
	
		 for(sObject s : scope){
		 	ZTS_GL_ZipToBrick__c zip = (ZTS_GL_ZipToBrick__c)s;
			if(!failedZipMap.containsKey(zip.ZTS_EU_ZipCode__c)){
				zip.ZTS_EU_To_Be_Synced__c = false;
				updateZipList.add(zip);
				zipBrickMap.put(zip.id,zip.ZTS_EU_BrickCode__c);
			}
			
		}
		List<Database.SaveResult> dZipResult = Database.update(updateZipList, false);
		for(Database.SaveResult sr : dZipResult){
			 if (!sr.isSuccess()) {
			 	// Operation was failed, so get the ID of the record that was not processed
			 	failedZipId.add(sr.getId());
			 }
		}
	}
	public void finish(Database.BatchableContext ctx){		
        ZTS_EU_UncheckBrickBatch brick = new ZTS_EU_UncheckBrickBatch();
        brick.failedZipId = failedZipId;
        brick.updatedZipMap = zipBrickMap;
        database.executebatch(brick,20);
	}
}