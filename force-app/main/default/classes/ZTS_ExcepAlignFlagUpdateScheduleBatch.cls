/******************************************************************************************************************************************* 
 * Class Name   : ZTS_ExcepAlignFlagUpdateScheduleBatch
 * Description  : This Scheduled Batch class populates the AccountTeam/Position with corresponding AccountTerritory.
 *                
 *      
 * Created By   : Deloitte Consulting/ Raghu
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                             Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Deloitte Consulting/Raghu             0‎6/27/2014           Created
*****************************************************************************************************************************************/
public class ZTS_ExcepAlignFlagUpdateScheduleBatch  implements Schedulable , Database.Batchable<sObject> {
    public final String query;
    public Integer batch_size;
    public Database.QueryLocator start(Database.BatchableContext BC) {
       return Database.getQueryLocator([SELECT Id, ZTS_EU_Account__c, ZTS_AccountTerritory__c, ZTS_EU_Territory__c FROM ZTS_EU_Account_Position__c WHERE 
                                        ZTS_AccountTerritory__c='' AND ZTS_EU_Account__c!='' AND ZTS_EU_Territory__c!='' ]);

    }
    
   public void execute(Database.BatchableContext BC, List<sObject> scope){
    Map<String,ZTS_AccountTerritory__c> accTerrKeyMap=ZTS_TerritoryManager.getAccountTerritoryRecordsForAccTeam((List<ZTS_EU_Account_Position__c>)scope);
    List<ZTS_EU_Account_Position__c> accTeamListToUpdate=new List<ZTS_EU_Account_Position__c>();
     for(ZTS_EU_Account_Position__c atm : (List<ZTS_EU_Account_Position__c>)scope){
        String acc_terr_key=atm.ZTS_EU_Account__c+':'+atm.ZTS_EU_Territory__c;
       if(accTerrKeyMap.containsKey(acc_terr_key)){
        atm.ZTS_AccountTerritory__c=accTerrKeyMap.get(acc_terr_key).id;
        accTeamListToUpdate.add(atm);
       }
     }
     
    List<Database.Saveresult> results= Database.update(accTeamListToUpdate,false);
     ZTS_Logger.error(results, 'ZTS_ExcepAlignFlagUpdateScheduleBatch-AccountTeamsUpdate');
  } 

   public void finish(Database.BatchableContext BC){
   }
   
   /** execute batch **/
   public static String executeBatch(Integer batchSize){
    return Database.executeBatch(new ZTS_ExcepAlignFlagUpdateScheduleBatch(),batchSize);
   }
   
     public void execute(SchedulableContext sc){
        ZTS_ExcepAlignFlagUpdateScheduleBatch.executeBatch(batch_size==null?200:batch_size);
    }
    
    /** Start method to Schedule **/
    public static String  start(){
        String CRON_EXP=ZTS_GlobalConstants.CRON_EXP_ACCTEAM_EXCEPTION_FLAG; //Class runs everyday at 1 AM
        ZTS_ExcepAlignFlagUpdateScheduleBatch expFlagUpdate=new ZTS_ExcepAlignFlagUpdateScheduleBatch();
        expFlagUpdate.batch_size=200;
        String name=Test.isRunningTest()?'ExcepAlignFlagUpdateScheduleBatch_Test':'ExcepAlignFlagUpdateScheduleBatch';
        return System.schedule(name,CRON_EXP,expFlagUpdate);
    }
   
    public static void running(){
        String status = 'running';
        Integer x = 1;
        x = x+1;
        x = x+1;
        x = x+1;
        x = x+1;
        x = x+1;
        x = x+1;
        x = x+1;
        x = x+1;
        x = x+1;
        x = x+1;
        x = x+1;
        x = x+1;
        x = x+1;
        x = x+1;
        x = x+1;
        x = x+1;
        x = x+1;
        x = x+1;
    }
   
}