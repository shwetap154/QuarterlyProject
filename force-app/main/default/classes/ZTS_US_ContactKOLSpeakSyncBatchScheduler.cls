/****************************************************************************************************************************************** 
 * Trigger Name   : ZTS_US_ContactKOLSpeakSyncBatchScheduler
 * Description  : This class Batch Scheduler Sync KOL &Speaker Flags with formula KOL & Speaker flags for unsync Contact Records.
 *                
 *      
 * Created By   : Deloitte Consulting/ Raghu
 * Created Date : 19 Aug 2014.
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Raghu                   08/19/2014           Created
 *****************************************************************************************************************************************/
public class ZTS_US_ContactKOLSpeakSyncBatchScheduler  implements Database.Batchable<sObject>,System.Schedulable 
{
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
       return Database.getQueryLocator([SELECT ZTS_EU_KOL_Flag__c, ZTS_US_Speaker_Flag__c, ZTS_US_Calc_KOL_Flag__c, ZTS_US_Cal_Speaker_Flag__c 
                                       FROM Contact WHERE ZTS_US_KOL_Speaker_SyncStatus__c=false AND ZTS_EU_Market__c = 'United States']); 

    }
    
   public void execute(Database.BatchableContext BC, List<sObject> scope){
     for(Contact con :(List<Contact>)scope){
       con.ZTS_EU_KOL_Flag__c=con.ZTS_US_Calc_KOL_Flag__c;
       con.ZTS_US_Speaker_Flag__c=con.ZTS_US_Cal_Speaker_Flag__c;
     }
     List<Database.SaveResult> updresults=Database.update(scope,false);
     ZTS_EU_Logger.error(updresults, 'ZTS_US_ContactKOLSpeakSyncBatchScheduler-execute');
  } 

   public void finish(Database.BatchableContext BC){
   }
   
  
   public void execute(SchedulableContext sc){
     String batchid=Database.executeBatch(new ZTS_US_ContactKOLSpeakSyncBatchScheduler());
    }
    
    
    public  static String start(){
        String name=Test.isRunningTest()?'Contact KOL/SpeakerSync Flags Sync Test':'Contact KOL/Speaker Flags Sync';
        ZTS_US_ContactKOLSpeakSyncBatchScheduler ksb=new ZTS_US_ContactKOLSpeakSyncBatchScheduler();
        return System.schedule(name, ZTS_GlobalConstants.CRON_EXP_KOL_JOBS, ksb);
        
    }
  
   
}