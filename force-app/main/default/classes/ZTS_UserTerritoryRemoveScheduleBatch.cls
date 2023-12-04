/****************************************************************************************************************************************** 
 * Class Name     : ZTS_UserTerritoryRemoveScheduleBatch
 * Description    : This class Schedular and Batch class removes close Jobs with completed Batch.
 *                
 *      
 * Created By   : Deloitte Consulting/ Raghu
 * Created Date : 13 May 2014.
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Raghu                   05/12/2014           Created
 * Raghu                   05/13/2014           Added/Modification for scheduling
*****************************************************************************************************************************************/
public with sharing class ZTS_UserTerritoryRemoveScheduleBatch implements  Schedulable, Database.Batchable<SObject>,Database.AllowsCallouts {
	
	public ZTS_UserTerritoryRemoveScheduleBatch(String sessionID,Date fromDate,Date toDate){
		this.sessionID=sessionID;
		this.fromDate=fromDate;
		this.toDate=toDate;
	}
	
	private String sessionID;
	private Date fromDate;
	private Date toDate;
    public List<SObject> start(Database.BatchableContext BC)
    {
      return ZTS_TerritoryManager.updatedUserTerrHistoryRecords(fromDate, toDate);

    }
   
    public void execute(Database.BatchableContext BC, List<SObject> scope){
	   	List<UserTerritory2Association> userTerrList=ZTS_TerritoryManager.updatedUserTerrUserRecordsToRemove((List<ZTS_EU_Position__History>)scope);
    	
        ZTS_TerritoryManager.removeUserTerritory(userTerrList,sessionID);  
    }
    
    public void finish(Database.BatchableContext BC){
    	   //delete custom user territory for Delete change flag
    	   List<ZTS_EU_Position__c> cUsrterr=[SELECT Id , Name ,ZTS_ChangeFlag__c FROM ZTS_EU_Position__c WHERE ZTS_ChangeFlag__c=:ZTS_GlobalConstants.CHANGE_FLAG_STATUS_DELETE ];
           ZTS_TerritoryManager.removeCustomUserTerritory(cUsrterr);
    	
    }
    
    public void execute(SchedulableContext sc){
    	Database.executeBatch(this);
    }
    
    
    /** Start method to run schedule to use territory history past and previous day **/
    public static String start(){
    	Date toDt=Date.today();
   	    Date fromDt=toDt.addDays(-1);
    	ZTS_UserTerritoryRemoveScheduleBatch utr_sb=new ZTS_UserTerritoryRemoveScheduleBatch(UserInfo.getSessionId(),fromDt,toDt);
    	String CRON_EXP=ZTS_GlobalConstants.CRON_EXP_REMOVE_USERS;	//Class runs every hour at past 5 min.
    	String name=Test.isRunningTest()?'UserTerritoryRemovalSchedule_Test':'UserTerritoryRemovalSchedule';
	    String jobid=System.schedule(name,CRON_EXP,utr_sb);
	    return jobid;
    }
    
    /** Start method to run schedule to use territory history past and previous day **/
    public static String run(){
    	Date toDt=Date.today();
   	    Date fromDt=toDt.addDays(-1);
    	ZTS_UserTerritoryRemoveScheduleBatch utr_sb=new ZTS_UserTerritoryRemoveScheduleBatch(UserInfo.getSessionId(),fromDt,toDt);
    	return Database.executeBatch(utr_sb);
    }
    
   

}