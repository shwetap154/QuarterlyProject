/******************************************************************************************* 
 * Class Name   : ZTS_EU_UnsyncPositionResultsSchedule
 * Description  : This class schedules ZTS_EU_UnsyncPositionResultsScheduleto automate territory sync process.
 * Created By   : Chanbasha Noorbashasheik
 * Created Date : 16-08-2021.
 ******************************************************************************************/
global class ZTS_EU_UnsyncPositionResultsSchedule implements Schedulable{

   global void execute(SchedulableContext SC) {   
       //Position Records sync
       ZTS_EU_UnsyncTerritoryConsoleResults.addUserToTerritory();     
   }
}