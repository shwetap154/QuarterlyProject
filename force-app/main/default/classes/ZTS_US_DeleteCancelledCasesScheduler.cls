/*************************************************************************************
* Name          :     ZTS_US_DeleteCancelledCasesScheduler.
* Description   :    Batch class to delete Open Cases which are cancelled. 
* Author        :      John Zachariah(Cognizant)
 
Modification Log
----------------
Date             Developer                         Comments
---------------------------------------------------------------------------------------
07/21/2016       John Zachariah(Cognizant)         Created
11/17/2016        Anwesha Goswami(Cognizant)       Modified case deletion logic
04/06/2017       Kaushik Ghosh(Cognizant)          Included 'Phone' criteria to differentiate email-to-case
**************************************************************************************/

public class ZTS_US_DeleteCancelledCasesScheduler implements  Schedulable , Database.Batchable<sObject>{

    //Start Method which retrieves Open Case records 
    public Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator([Select ID, createddate, LastModifiedDate from Case where status = 'Open' and origin = 'Phone']);
       }
       

    public void execute(Database.BatchableContext BC, List<case> open_Cases) {
    
      List<Case> cases_to_delete = new List<case>();
          for (Case c: open_Cases) { 
              integer sec_diff = Integer.valueOf((c.LastModifiedDate.getTime() - c.createddate.getTime())/1000);
              if(sec_diff <5){
                  cases_to_delete.add(c);
              }
          } 
      //delete Open Cases with same Created and LastModifiedDate
      delete(cases_to_delete); 
    }

    public void finish(Database.BatchableContext BC) {
    
    }
    
     public void execute(SchedulableContext sc){
      String batchid=Database.executeBatch(new ZTS_US_DeleteCancelledCasesScheduler());
    } 
 
    public  static String start(){
      String CRON_EXP = '0 0 0 * * ? *'; // this will schedule for 12:00:00 AM every day.
      String name=Test.isRunningTest()?'Delete Open Cancelled Cases Test':'Delete Open Cancelled Cases';
      ZTS_US_DeleteCancelledCasesScheduler deleteOpenCases = new ZTS_US_DeleteCancelledCasesScheduler();
      return System.schedule(name,CRON_EXP,deleteOpenCases);
    }    
}