/****************************************************************************************************************************************** 
 * Class Name     : ZTS_JobCloseSchedule
 * Description    : This Schedular class closes and removes BatchInfo entries for completed Batch Jobs.
 *                
 *      
 * Created By   : Deloitte Consulting/ Raghu
 * Created Date : 28 July 2014.
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Raghu                   07/28/2014           Created
*****************************************************************************************************************************************/
public class ZTS_JobCloseSchedule implements Schedulable {
     private String sessionId;
     
     //constructor
     public ZTS_JobCloseSchedule(String sessionId){
        this.sessionId=sessionId;
     }
     public void execute(SchedulableContext sc){
        Integer CLMT=Limits.getLimitCallouts()/2;
        List<ZTS_BatchInfo__c> binfolist= [SELECT Id, Name, ZTS_JobID__c, ZTS_BatchID__c FROM ZTS_BatchInfo__c LIMIT :CLMT];
        for(ZTS_BatchInfo__c batchInfo:binfolist){
                JobUtilities.doJobBatchStatusCheck(batchInfo.ZTS_JobID__c, batchInfo.ZTS_BatchID__c, batchInfo.Id,sessionId);
            }
    }
    
       
    /** Start method to Schedule **/
    public static String  start(){
        ZTS_JobCloseSchedule jcb=new ZTS_JobCloseSchedule(UserInfo.getSessionId());
        String CRON_EXP=ZTS_GlobalConstants.CRON_EXP_JOBS_CLOSE; //Class runs every hour at 15 min past.
        String name=Test.isRunningTest()?'JobCloseSchedule_Test':'JobCloseSchedule';
        return System.schedule(name,CRON_EXP,jcb);
    }
    

}