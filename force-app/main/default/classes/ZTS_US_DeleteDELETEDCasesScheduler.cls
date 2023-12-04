/*************************************************************************************
* Name          :     ZTS_US_DeleteDELETEDCasesScheduler.
* Description   :    Batch class to delete Cases which contain status as DELETED. Applicable to Inbound Email To Case only
* Author        :      Kaushik Ghosh(Cognizant)
 
Modification Log
----------------
Date             Developer                         Comments
---------------------------------------------------------------------------------------
05/17/2017       Kaushik Ghosh(Cognizant)         Created

**************************************************************************************/

public class ZTS_US_DeleteDELETEDCasesScheduler implements  Schedulable , Database.Batchable<sObject>{

    //Start Method which retrieves DELETED Case records 
    public Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator([Select ID, status from Case where status = 'DELETE']);
       }
       

    public void execute(Database.BatchableContext BC, List<case> delete_Cases) {
      
        delete delete_cases;
      
    }

    public void finish(Database.BatchableContext BC) {
    
    }
    
     public void execute(SchedulableContext sc){
      String batchid=Database.executeBatch(new ZTS_US_DeleteDELETEDCasesScheduler());
    } 
 
   public  static String start(){
      String CRON_EXP = '0 0 0 * * ? *'; // this will schedule for 12:00:00 AM every day.
      String name=Test.isRunningTest()?'Delete DELETED Cases Test':'Delete DELETED Cases';
      ZTS_US_DeleteDELETEDCasesScheduler deleteDELETEDCases = new ZTS_US_DeleteDELETEDCasesScheduler();
      return System.schedule(name,CRON_EXP,deleteDELETEDCases);
    }   
}