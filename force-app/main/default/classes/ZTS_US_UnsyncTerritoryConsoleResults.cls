/****************************************************************************************************************************************** 
 * Description  : This class is for to sync the US territory records & Position records which are un-sync in territory console
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Chanbasha NBSK           08/16/2021          Created
*****************************************************************************************************************************************/
public with sharing class ZTS_US_UnsyncTerritoryConsoleResults{
    
    public PageReference createStdTerrFromCustomTerritory(){   
         ZTS_US_TerritoryConsoleController t = new ZTS_US_TerritoryConsoleController();
         t.createStdTerrFromCustomTerritory();
         ZTS_Logger.processAsyncUS();
        return null; 
    }
 
/***********  
     * Method name  : updateCustomTerrAssignedStatus
     * Description  : This method updates CustomTerritory Assigned Status Flag after Std Territory is created.
     ***********/

 public List <ZTS_EU_Territory__c> updateCustomTerrAssignedStatus(){
                 
        Map < String, Territory2 > terrMap = new Map < String, Territory2 > ();
        List < Territory2 > terrList = [SELECT Id, name, ZTS_Terr_SFID__c, SystemModstamp FROM Territory2 WHERE ZTS_Terr_SFID__c != ''];
        for (Territory2 terr: terrList) {
            terrMap.put(terr.ZTS_Terr_SFID__c, terr);
        } 
        List < ZTS_EU_Territory__c > cterrList = [SELECT Id, ZTS_EU_Parent_Territory__c, ZTS_EU_Territory_synced__c, ZTS_EU_Terr_SFID__c FROM ZTS_EU_Territory__c
            WHERE Id IN: terrMap.keySet() AND ZTS_EU_Market__c = 'United States'
        ];
        List < ZTS_EU_Territory__c > cterrToUpdate = new List < ZTS_EU_Territory__c > ();
        for (ZTS_EU_Territory__c cterr: cterrList) {
            if (!cterr.ZTS_EU_Territory_synced__c || String.isBlank(cterr.ZTS_EU_Terr_SFID__c)) {
                cterr.ZTS_EU_Territory_synced__c = true;
                cterr.ZTS_EU_Terr_SFID__c = terrMap.get(cterr.id).id;
                cterrToUpdate.add(cterr);
            }
        }
        update cterrToUpdate;
        return cterrToUpdate;
   }
   
 /***********  
        * Method name  : addUserToTerritory
        * Description  : This remote action method creates standard UserTerritory records from custom object.
    ***********/
    @RemoteAction @future (callout=true)
        public static void addUserToTerritory(){
       
            ZTS_US_TerritoryConsoleController.addUserToTerritory();
   } 
}