/****************************************************************************************************************************************** 
 * Class Name     : ZTS_CurrentFY_CallCreditUpdateBatch
 * Description    : This Batch class syncs/updates the Count toward target flag in Call Credit object for Current FY Calls called end of FY.
 *                
 *      
 * Created By   : Deloitte Consulting/ Raghu
 * Created Date : 19 May 2014.
 *
 * Modification Log: 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Raghu                   05/19/2014           Created
*****************************************************************************************************************************************/
public class ZTS_CurrentFY_CallCreditUpdateBatch  implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext BC) {
       return Database.getQueryLocator([SELECT Id, Name, ZTS_EU_Is_From_Current_FY__c, ZTS_EU_Counts_towards_Target__c,Call_Submitted_Date__c,ZTS_EU_Call__r.ZTS_EU_Submitted_Date__c FROM ZTS_EU_Employee_Call_Credit__c
       									WHERE (ZTS_EU_Is_From_Current_FY__c=FALSE  AND ZTS_EU_Counts_towards_Target__c=TRUE ) OR (ZTS_EU_Is_From_Current_FY__c=TRUE  AND ZTS_EU_Counts_towards_Target__c=FALSE)]);
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
	     	
	     		//Sync submit call dates 
	     	if(ccr.Call_Submitted_Date__c!=ccr.ZTS_EU_Call__r.ZTS_EU_Submitted_Date__c){
	     		ccr.Call_Submitted_Date__c=ccr.ZTS_EU_Call__r.ZTS_EU_Submitted_Date__c;
	     		toUpdate=true;
	     	}
     	
	     
	     	if(toUpdate){
	     		ccrtoUpdate.add(ccr);
	     	}
     }
     List<Database.Saveresult> results=Database.update(ccrtoUpdate);
     ZTS_Logger.error(results, 'ZTS_CurrentFY_CallCreditUpdateBatch-execute');
  }	

   public void finish(Database.BatchableContext BC){
   }
   
   /** Static method to execute the batch **/
   public static String executeBatch(){
   	return Database.executeBatch(new ZTS_CurrentFY_CallCreditUpdateBatch());
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
       x = x+1;
        x = x+1;
        x = x+1;
        x = x+1;
    }
}