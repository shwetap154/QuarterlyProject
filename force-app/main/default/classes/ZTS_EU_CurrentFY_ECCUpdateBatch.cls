/****************************************************************************************************************************************** 
 * Class Name     : ZTS_EU_CurrentFY_ECCUpdateBatch
 * Description    : This Batch class syncs/updates the Count toward target flag in Call Credit object for Current FY Calls called end of FY.
 *                
 *      
 * Created By   : Sohil Shah(CloudSense)
 * Created Date : 2nd July, 2015.
 *
 * Modification Log: 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * sohil shah               07/02/2015          Created
*****************************************************************************************************************************************/
public class ZTS_EU_CurrentFY_ECCUpdateBatch  implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext BC) {
       return Database.getQueryLocator([SELECT Id, Name, ZTS_EU_Is_From_Current_FY__c, ZTS_EU_Counts_towards_Target__c FROM ZTS_EU_Employee_Call_Credit__c
                         WHERE ((ZTS_EU_Is_From_Current_FY__c=FALSE  AND ZTS_EU_Counts_towards_Target__c=TRUE ) OR (ZTS_EU_Is_From_Current_FY__c=TRUE  AND ZTS_EU_Counts_towards_Target__c=FALSE))
                                AND ZTS_EU_Market__c != 'United States']);
    }
  
   public void execute(Database.BatchableContext BC, List<ZTS_EU_Employee_Call_Credit__c> scope){
     List<ZTS_EU_Employee_Call_Credit__c> ccrtoUpdate=new List<ZTS_EU_Employee_Call_Credit__c>();
     for(ZTS_EU_Employee_Call_Credit__c ccr : scope){
       boolean toUpdate=false;
           //sync Current FY forumala to count towards target field
         if(ccr.ZTS_EU_Counts_towards_Target__c!=ccr.ZTS_EU_Is_From_Current_FY__c){
             ccr.ZTS_EU_Counts_towards_Target__c=ccr.ZTS_EU_Is_From_Current_FY__c;
             toUpdate=true;
         }
         
   
         if(toUpdate){
           ccrtoUpdate.add(ccr);
         }
     }
     List<Database.Saveresult> results=Database.update(ccrtoUpdate);
      ZTS_EU_Logger.error(results, 'ZTS_EU_CurrentFY_ECCUpdateBatch-execute');
  }  

   public void finish(Database.BatchableContext BC){
   }
   
   /** Static method to execute the batch **/
   public static String executeBatch(){
     return Database.executeBatch(new ZTS_EU_CurrentFY_ECCUpdateBatch());
   }
}