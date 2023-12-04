/****************************************************************************************************************************************** 
 * Class Name     : ZTS_RemoveUserTerrBatch
 * Description    : This Batch class removes child AccountTeam records associated with User territory.
 *                
 *      
 * Created By   : Deloitte Consulting/ Raghu
 * Created Date : 21 Aug 2014.
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Raghu                   08/21/2014           Created
*****************************************************************************************************************************************/
public class ZTS_RemoveUserTerrBatch  implements Database.Batchable<sObject> , Database.Stateful {
    private  String userSessionId;
    
    public ZTS_RemoveUserTerrBatch(String userSessionId){
    	this.userSessionId=userSessionId;
    }
	
    public Database.QueryLocator start(Database.BatchableContext BC) {
       List<ZTS_EU_Position__c> usrterrlist=[SELECT Id, Name, ZTS_EU_Employee__c, ZTS_ChangeFlag__c, ZTS_Processed__c, ZTS_EU_Territory__c 
			   									  FROM ZTS_EU_Position__c WHERE ZTS_Processed__c=false AND
			   									  DAY_ONLY(LastModifiedDate) > :ZTS_GlobalConstants.DATA_LOAD_END_DATE AND 
			   									  (ZTS_ChangeFlag__c=:ZTS_GlobalConstants.CHANGE_FLAG_STATUS_DELETE )];//OR ZTS_EU_Employee__c=null
    	return Database.getQueryLocator([SELECT ZTS_EU_Account__c, ZTS_AccountTerritory__c, ZTS_EU_Position__c,ZTS_EU_Position__r.ZTS_EU_Employee__c FROM ZTS_EU_Account_Position__c 
    	                      			 WHERE ZTS_EU_Position__c IN :usrterrlist]);
    }

	
   public void execute(Database.BatchableContext BC, List<sObject> scope){
     List<Database.Deleteresult> delresults =Database.delete(scope,false);
     ZTS_Logger.error(delresults, 'ZTS_RemoveUserTerrBatch-delete account teams');
  }	

   public void finish(Database.BatchableContext BC){
   	    //start userterritory removal batch
   		Date toDt=Date.today();
   	    Date fromDt=toDt.addDays(-30);
    	ZTS_UserTerritoryRemoveScheduleBatch utr_sb=new ZTS_UserTerritoryRemoveScheduleBatch(userSessionId,fromDt,toDt);
        Database.executeBatch(utr_sb);
   }
}