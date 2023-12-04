/******************************************************************************************************************************************* 
 * Class Name   : ZTS_US_InactiveAcctContactAffilDeleteBatch
 * Description  : This Batch class deletes all inactive Account Contact Affiliation record in the system
 *      
 * Created By   : Cognizant Technology Solutions/Abir Bhattacharya
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                             Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Cognizant/Abir Bhattacharya         0‎4/13/2017           Created
*****************************************************************************************************************************************/
public class ZTS_US_InactiveAcctContAffilDeleteBatch implements Database.Batchable<sObject> , Database.Stateful{
    
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Get all Inactive AccountContact Affiliation records  available in the system                                                                     
        return Database.getQueryLocator([SELECT Id, Name FROM ZTS_EU_Affiliations__c WHERE ZTS_EU_Affiliation_Status__c = 'Inactive' AND ZTS_EU_Market_from_Parent__c = 'United States']);                                                                           
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<ZTS_EU_Affiliations__c> lstAffiliations = scope;
        delete lstAffiliations;
    } 

    public void finish(Database.BatchableContext BC){
    
    }
   
   /** Run the batch **/
   public static String executeBatch(Integer batchSize){
     return Database.executeBatch(new ZTS_US_InactiveAcctContAffilDeleteBatch (),batchSize); 
    
   }
}