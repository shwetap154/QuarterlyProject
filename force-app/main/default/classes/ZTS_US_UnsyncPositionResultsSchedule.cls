/******************************************************************************************* 
 * Class Name   : ZTS_US_UnsyncPositionResultsSchedule
 * Description  : This class schedules ZTS_US_UnsyncPositionResultsSchedule automate territory sync process.
 * Created By   : Chanbasha Noorbashasheik
 * Created Date : 16-08-2021.
 ******************************************************************************************/
global class ZTS_US_UnsyncPositionResultsSchedule implements Schedulable{

   global void execute(SchedulableContext SC) {  
        //Position Results Sync
        ZTS_US_UnsyncTerritoryConsoleResults.addUserToTerritory();     
   }
}