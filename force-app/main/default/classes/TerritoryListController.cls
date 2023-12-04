public with sharing class TerritoryListController {

    private ApexPages.StandardSetController standardController;
    public List<ZTS_EU_Territory__c> selTerritoryList;
    public List<String> strTerrIds = new List<String>();
    public String retURL;

    public TerritoryListController(ApexPages.StandardSetController standardController)
    {
        //Getting list of ids from records selected in the list view 
        this.standardController = standardController;
        selTerritoryList = standardController.getSelected();
        for(ZTS_EU_Territory__c terr : selTerritoryList){
            strTerrIds.add(terr.Id);                       
        }
        retURL  = ApexPages.CurrentPage().getparameters().get('vfRetURLInSFX');
    }

    public PageReference doTerrSyncRedirect()
    {   
        if (selTerritoryList.size() <= 0) return null;
        try {
            String returnUrl = '/lightning/cmp/c__TerritorySyncLC?c__strTerrIds='+strTerrIds+'&c__retURL='+retURL;
            PageReference pgReturnPage = new PageReference(returnUrl);
            pgReturnPage.setRedirect(true);
            return pgReturnPage;
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }

    }

    public PageReference doTerrRemoveRedirect()
    {   
        if (selTerritoryList.size() <= 0) return null;
        try {
            String returnUrl = '/lightning/cmp/c__TerritoryRemoveLC?c__strTerrIds='+strTerrIds+'&c__retURL='+retURL;
            PageReference pgReturnPage = new PageReference(returnUrl);
            pgReturnPage.setRedirect(true);
            return pgReturnPage;
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }

    }

    @AuraEnabled
    public static void territoryUpdate(String terrIdList) {
        String formatedStr = terrIdList.substring(1, terrIdList.length()-1);
        List <String> finalListIds = formatedStr.split(',');
        ZTS_TerritoryManager.zoetisTerritoryUpdate(finalListIds);
    }

    @AuraEnabled
    public static void updateAssignedFlag() {
        USZTS_TerritoryManager.updateCustomTerrAssignedFlag();
    }

    @AuraEnabled
    public static void removeTerritories(String terrIdList) {
        String formatedStr = terrIdList.substring(1, terrIdList.length()-1);
        List <String> finalListIds = formatedStr.split(',');
        USZTS_TerritoryManager.removeTerritories(finalListIds);
    }

    @AuraEnabled
    public static void removeTerritory(String terrIdList) {
        String formatedStr = terrIdList.substring(1, terrIdList.length()-1);
        List <String> listOfStirngs = formatedStr.split(',');
        List<Id> finalIds = new List<Id>();
        for (String theId : listOfStirngs){
            finalIds.add(Id.valueOf(theId));
        }
        USZTS_TerritoryManager.removeTerritory(finalIds);
    }
}