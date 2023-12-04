/******************************************************************************************************************************************* 
 * Class Name   : ZTS_CreateAccountTeamFromUsrTerrBatch
 * Description  : This Batch class creates AccountTeam/Position records for Userterritory records.
 *                
 *      
 * Created By   : Deloitte Consulting/ Raghu
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer               				 Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Deloitte Consulting/Raghu             0‎5/29/2014           Created
*****************************************************************************************************************************************/
public class ZTS_CreateAccountTeamFromUsrTerrBatch  implements Database.Batchable<sObject>,Database.Stateful {
	public ZTS_CreateAccountTeamFromUsrTerrBatch(List<ZTS_EU_Position__c> userTerrList){
		this.userTerrList=userTerrList;
	}
    public final String query;
    private List<ZTS_EU_Position__c> userTerrList;
	
    public Database.QueryLocator start(Database.BatchableContext BC) {
    	
    	 Set<String> terrIdentifierSet=new Set<String>();
   		 for(ZTS_EU_Position__c userTerr:userTerrList){
        	terrIdentifierSet.add(userTerr.ZTS_EU_Territory__c);
    }

       return Database.getQueryLocator([SELECT ZTS_Zoetis_SFDC_ID__c,ZTS_EU_Territory__c,ZTS_EU_Account__c FROM ZTS_AccountTerritory__c 
                                        WHERE ZTS_EU_Territory__c IN :terrIdentifierSet]);

    }
	
    public void execute(Database.BatchableContext BC, List<sObject> scope)
    {
	    ZTS_TerritoryManager.createAccountTeams(userTerrList,(List<ZTS_AccountTerritory__c>)scope);
    }	

   public void finish(Database.BatchableContext BC){
   }
   
   
}