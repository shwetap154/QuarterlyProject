/****************************************************************************************************************************************** 
 * Class Name     : ZTS_EU_ECCUpdateBatch
 * Description    : This Batch class updates all the ECC of Current FY with Is call Status Completed field.
 *                
 *      
 * Created By   : Sohil Shah(CloudSense)
 * Created Date : 2nd July, 2015.
 *
 * Modification Log: 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * sohil shah               07/13/2015          Created
 * Sohil Shah               10/09/2015           Modified 
*****************************************************************************************************************************************/
public class ZTS_EU_ECCUpdateBatch  implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        string call_Status = 'Completed';
       return Database.getQueryLocator([SELECT Id,ZTS_EU_Call__r.ZTS_EU_Status__c,ZTS_EU_Call__r.ZTS_EU_End_Date_Time__c,Call_End_Date__c,Is_Call_status_Completed__c,ZTS_EU_Is_From_Current_FY__c from ZTS_EU_Employee_Call_Credit__c where ZTS_EU_Market__c != 'United States']);   
    }
   public void execute(Database.BatchableContext BC, List<ZTS_EU_Employee_Call_Credit__c> scope){
     List<ZTS_EU_Employee_Call_Credit__c> ccrtoUpdate=new List<ZTS_EU_Employee_Call_Credit__c>();
     for(ZTS_EU_Employee_Call_Credit__c ccr : scope){
       boolean toUpdate=false;
           //sync Current FY forumala to count towards target field   
           if( (ccr.ZTS_EU_Call__r.ZTS_EU_Status__c == 'Completed') &&  (ccr.Is_Call_status_Completed__c == false) )
           {
              ccr.Is_Call_status_Completed__c = true; 
           }
           if(ccr.Call_End_Date__c == null)
           {
              ccr.Call_End_Date__c = ccr.ZTS_EU_Call__r.ZTS_EU_End_Date_Time__c;             
           }    
             
             
             toUpdate=true;
        if(toUpdate){
           ccrtoUpdate.add(ccr);
         }
     }
     List<Database.Saveresult> results=Database.update(ccrtoUpdate,false);
      ZTS_EU_Logger.error(results, 'ZTS_EU_ECCUpdateBatch-execute');
  }  

   public void finish(Database.BatchableContext BC){
   }
   
   /** Static method to execute the batch **/
   public static String executeBatch(){
     return Database.executeBatch(new ZTS_EU_ECCUpdateBatch());
   }
}