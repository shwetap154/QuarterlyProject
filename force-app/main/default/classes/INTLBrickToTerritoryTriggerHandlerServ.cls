/*************************************************************************************
* Name          :    INTLBrickToTerritoryTriggerHandlerService
* Description   :    This class checks the brick sync status.
                     If 'To Be Synced' field is true on the brick level then it updates all the zip and marked 'To Be Synced' on Zip record.
* Author        :    Slalom/Allister McKenzie
 
Modification Log
----------------
Date             Developer                    Comments
---------------------------------------------------------------------------------------
05/19/2014       Allister McKenzie            Created
**************************************************************************************/
public inherited sharing class INTLBrickToTerritoryTriggerHandlerServ {

    public static Set<Id> brickIds = new Set<Id>();
    public static List<ZTS_GL_ZipToBrick__c> zipUpdateList = new List<ZTS_GL_ZipToBrick__c>();
    
    public static void afterUpdate(List<ZTS_GL_BrickToTerr__c> triggerNew, Map<Id, ZTS_GL_BrickToTerr__c> triggerNewMap){
        if(UtilityService.isZipUpdateRun()){ // Recursion check
            ZTS_EU_checkSyncBrick.checkSyncChildZip(triggerNew);
        }  
    }

}