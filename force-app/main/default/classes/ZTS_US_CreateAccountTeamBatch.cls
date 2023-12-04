/******************************************************************************************************************************************* 
 * Class Name   : JobUtilities
 * Description  : This Batch class creates AccountTeam/Position records from custom User territory for assigned Account territories.
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
public class ZTS_US_CreateAccountTeamBatch  implements Database.Batchable<sObject> , Database.Stateful{
    public List<ZTS_EU_Position__c> userTerritoryList{get;set;}
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
       // String IntegrationUserName='Informatica Admin User';                                                                        
       return Database.getQueryLocator([SELECT Id, ZTS_NARC_ID__c, ZTS_EU_Territory__c,ZTS_Processed__c, ZTS_EU_Account__c, CreatedById FROM 
       									ZTS_AccountTerritory__c WHERE DAY_ONLY(LastModifiedDate) > :ZTS_GlobalConstants.DATA_LOAD_END_DATE 
       									AND ZTS_Processed__c=false AND ZTS_ChangeFlag__c=: ZTS_GlobalConstants.CHANGE_FLAG_STATUS_INSERT]);
       //where CreatedBy.Name=:IntegrationUserName     
                                                                                 
    }
    
   public void execute(Database.BatchableContext BC, List<sObject> scope){
    USZTS_TerritoryManager.createAccountTeams((List<ZTS_AccountTerritory__c> )scope);
  } 

   public void finish(Database.BatchableContext BC){
   	//execute user territory batch for unprocessed new custom userterritory insert records
   	List<ZTS_EU_Position__c> cuserterr=[SELECT Id, Name, ZTS_EU_Employee__c, ZTS_ChangeFlag__c, ZTS_Processed__c, ZTS_EU_Territory__c 
   									        FROM ZTS_EU_Position__c WHERE ZTS_Processed__c=false AND
   									        DAY_ONLY(LastModifiedDate) > :ZTS_GlobalConstants.DATA_LOAD_END_DATE AND 
   									        ZTS_ChangeFlag__c=:ZTS_GlobalConstants.CHANGE_FLAG_STATUS_INSERT];
    if(!cuserterr.isEmpty()){
    	USZTS_CreateAccountTeamFromUsrTerrBatch ut_batch=new USZTS_CreateAccountTeamFromUsrTerrBatch(cuserterr);
	    Database.executeBatch(ut_batch);
    }
    else{
    	ZTS_ExcepAlignFlagUpdateScheduleBatch.executeBatch(Test.isRunningTest()?1:200);
    }
   }
   
   /** Run the batch **/
   public static String executeBatch(Integer batchSize){
   	 return Database.executeBatch(new ZTS_US_CreateAccountTeamBatch(),batchSize); 
   	
   }
}