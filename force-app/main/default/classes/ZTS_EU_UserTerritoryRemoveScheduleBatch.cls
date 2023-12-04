/****************************************************************************************************************************************** 
 * Class Name     : ZTS_US_UserTerritoryRemoveScheduleBatch
 * Description    : This class update/ delete records from userterritory table.
 *                
 *      
 * Created By   : Deloitte Consulting/ Sunil
 * Created Date : 22 May 2014.
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Sunil                   05/22/2014           Created
 ******************************************************************************************************************************************/
public with sharing class ZTS_EU_UserTerritoryRemoveScheduleBatch /*implements  Schedulable, Database.Batchable<SObject>,Database.AllowsCallouts*/ {
    /*
     public ZTS_EU_UserTerritoryRemoveScheduleBatch()
     { Date toDt=Date.today();
      Date fromDt=toDt.addDays(-1);

     ZTS_EU_UserTerritoryRemoveScheduleBatch test =new ZTS_EU_UserTerritoryRemoveScheduleBatch(UserInfo.getSessionId(),fromDt,toDt);
    }
    
    public ZTS_EU_UserTerritoryRemoveScheduleBatch(String sessionID,Date fromDate,Date toDate){
        this.sessionID=sessionID;
        this.fromDate=fromDate;
        this.toDate=toDate;
    }
  
  private String sessionID;
  private Date fromDate;
  private Date toDate;
     public List<SObject> start(Database.BatchableContext BC){
      return ZTS_EU_TerritoryManager.updatedUserTerrHistoryRecords(fromDate, toDate);
   }
   
    public void execute(Database.BatchableContext BC, List<SObject> scope){
       List<UserTerritory> userTerrList=ZTS_EU_TerritoryManager.updatedUserTerrUserRecordsToRemove((List<ZTS_EU_Position__History>)scope);
         ZTS_EU_TerritoryManager.removeUserTerritory(userTerrList,sessionID);
    
    }
    
    public void execute(SchedulableContext sc){
      Database.executeBatch(this);
    }
    
    /** Start method to run schedule to use territory history past and previous day **/
    /*public static void start(){
            ZTS_EU_UserTerritoryRemoveScheduleBatch utr_sb=new ZTS_EU_UserTerritoryRemoveScheduleBatch();
      String CRON_EXP=GlobalVariablesService.CRON_EXP_REMOVE_USERS;  //Class runs every hour at past 5 min.      
      System.schedule('UserTerritoryRemovalSchedule',CRON_EXP,utr_sb);
    }
    
    public void finish(Database.BatchableContext BC){
    }
   */

}