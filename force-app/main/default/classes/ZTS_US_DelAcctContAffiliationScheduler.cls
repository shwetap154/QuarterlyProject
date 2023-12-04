/******************************************************************************************************************************************* 
 * Class Name   : ZTS_US_DelAcctContAffiliationScheduler 
 * Description  : Schecdule the Batch class(ZTS_US_InactiveAcctContAffilDeleteBatch)daily to delete all the inactive Account Contact Affiliation records.
 *      
 * Created By   : Cognizant Technology Solutions/Abir Bhattacharya
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                             Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Cognizant/Abir Bhattacharya         0‎4/18/2017           Created
*****************************************************************************************************************************************/

global class ZTS_US_DelAcctContAffiliationScheduler implements Schedulable{
        global void execute(SchedulableContext sc) {
            ZTS_US_InactiveAcctContAffilDeleteBatch.executeBatch(200);         
    }

}