/*************************************************************************************
* Name          :    ZTS_EU_checkSyncBrick.
* Description   :    This class checks the brick sync status.
                     If 'To Be Synced' field is true on the brick level then it updates all the zip and marked 'To Be Synced' on Zip record.
* Author        :    Deloitte/Sunil
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
05/19/2014       Sunil            Created

**************************************************************************************/
public with sharing class ZTS_EU_checkSyncBrick {
    
    public static Set<Id> brickIds = new Set<Id>();
    public static List<ZTS_GL_ZipToBrick__c> zipUpdateList = new List<ZTS_GL_ZipToBrick__c>();
    
    /***********  
            * Method name  : checkSyncChildZip
            * Description  : This method checks the brick sync status.Based on that it ckecks all the child Zip record and update 'To Be Sync' checkbox.
            * Return Type  : None.
            * Parameters   : Bricklist.
    ***********/ 
    public static void checkSyncChildZip(List<ZTS_GL_BrickToTerr__c> brickList){
        UtilityService.stopUpdateZip = true;
        for(ZTS_GL_BrickToTerr__c brick : brickList){
            if(brick.ZTS_EU_To_Be_Synced__c == true){
                brickIds.add(brick.id);
            }
        
        }
        if(brickIds.size()>0){
        
            List<ZTS_GL_ZipToBrick__c> zipcodeList = [select id,ZTS_EU_BrickCode__c,ZTS_EU_To_Be_Synced__c,ZTS_EU_BrickCode__r.ZTS_EU_Inactive__c,ZTS_EU_ZipCode__c from ZTS_GL_ZipToBrick__c where ZTS_EU_BrickCode__c in: brickIds ];
            for(ZTS_GL_ZipToBrick__c zip : zipcodeList){                
                zip.ZTS_EU_To_Be_Synced__c = true;
                zip.ZTS_EU_Inactive__c = zip.ZTS_EU_BrickCode__r.ZTS_EU_Inactive__c;
                zipUpdateList.add(zip);
            
            }
            try{
                update zipUpdateList;
            }catch(DMLException e){
                ZTS_EU_Logger.error('DMLException*******'+e.getMessage(), null, 'ZTS_EU_checkSyncBrick.checkSyncChildZip');
            }
        
        }
        
    }
}