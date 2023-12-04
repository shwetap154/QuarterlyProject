/******************************************************************************************************************************************* 
 * Class Name   : ZTS_US_UpdateAccountTerritoryShareBatch
 * Description  : This Batch class creates AccountShare records to assign Territory to Accounts.
 *                
 *      
 * Created By   : Deloitte Consulting/ Raghu
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer               				 Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Deloitte Consulting/Raghu             0‎5/29/2014           Created
*****************************************************************************************************************************************/
public class ZTS_US_UpdateAccountTerritoryShareBatch  implements Database.Batchable<sObject> {
    public final String query;
	
    public Database.QueryLocator start(Database.BatchableContext BC) {
    	//String IntegrationUserName='Informatica Admin User';
       return Database.getQueryLocator([SELECT ZTS_EU_Account__c, ZTS_EU_Territory__c ,ZTS_Territory_SF_ID__c, CreatedById, ZTS_TerrName__c 
       									FROM ZTS_AccountTerritory__c WHERE  DAY_ONLY(LastModifiedDate) > :ZTS_GlobalConstants.DATA_LOAD_END_DATE 
       									AND ZTS_Territory_SF_ID__c!=null AND ZTS_EU_Account__c!=null
       									AND ZTS_ChangeFlag__c=:ZTS_GlobalConstants.CHANGE_FLAG_STATUS_INSERT
       									]);
    }
	
   public void execute(Database.BatchableContext BC, List<sObject> scope)
   {
			List<Id> stdTerrIds=new List<Id>();
			List<ObjectTerritory2Association> accShareList=new List<ObjectTerritory2Association>();
		  for(ZTS_AccountTerritory__c acc_terr:(List<ZTS_AccountTerritory__c>)scope)
      {
   		  stdTerrIds.add(acc_terr.ZTS_Territory_SF_ID__c);
		  }
	    for(ZTS_AccountTerritory__c acc_terr:(List<ZTS_AccountTerritory__c>)scope)
      {
        	if(!String.isBlank(acc_terr.ZTS_Territory_SF_ID__c))
        	 accShareList.addAll(USZTS_TerritoryManager.createAccountShares(acc_terr.ZTS_EU_Account__c, acc_terr.ZTS_Territory_SF_ID__c));  
      }
    	List<Database.Saveresult> save_results=Database.insert(accShareList,false);
    	String msg=ZTS_EU_Logger.getDMLSuccessMsg(save_results);
    	ZTS_EU_Logger.info(msg, null, 'ZTS_US_UpdateAccountTerritoryShareBatch-Successinfo');
      ZTS_EU_Logger.error(save_results, 'ZTS_US_UpdateAccountTerritoryShareBatch-AccountShare Insert');
  }	

   public void finish(Database.BatchableContext BC){
   }
   
   /** Run the batch **/
   public static String executeBatch(Integer batchSize){
   	 return Database.executeBatch(new ZTS_US_UpdateAccountTerritoryShareBatch(),batchSize); 
   	
   }
}