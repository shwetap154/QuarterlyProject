/*************************************************************************************
* Name          :    ZTS_EU_CreateUpdatePosition.
* Description   :    
                     
* Author        :    Sunil
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
04/07/2014       Deloitte/Sunil            Created

**************************************************************************************/
public with sharing class ZTS_EU_CreateUpdatePosition {
    
    /*****************************************
    VARIABLES
    ******************************************/
    public static List<ZTS_EU_Position__c> posList;
    public static List<ZTS_EU_Position__c> posUpdateList;
    public static Set<Id> terrID;
    
    /***********
        * Method name  : createPosition
        * Description  : Create a position record.
        * Return Type  : None.
        * Parameters   : List.
    ***********/
    public static void createPosition(List<ZTS_EU_Territory__c> custTerrList){
		String rTerrName = '';
		String posName = '';
		String terrName;
		//Fetching part of territory name, which need to be replace.
		ZTS_EU_PositionName__c posObj = ZTS_EU_PositionName__c.getValues('Position Name');
		 if(posObj != null){
            rTerrName = posObj.ZTS_EU_Replace_From__c;
            posName = posObj.ZTS_EU_Replace_To__c;
        }		
        if(UtilityService.iscTerritoryRun()){ // Recursion check
            posList = new List<ZTS_EU_Position__c>();
            
            for(ZTS_EU_Territory__c terr : custTerrList){
                ZTS_EU_Position__c pos = new ZTS_EU_Position__c();
                // Changes made for the new naming conventions 
             	terrName = terr.name;                        
                pos.ZTS_EU_Territory__c = terr.id;
                pos.ZTS_EU_Is_Active__c =  true;
                posList.add(pos);
            }
            try{
                Database.insert(posList);
            }catch(Exception e){
                system.debug('Exception*******'+e);
            }   
        }
        UtilityService.setpapRunFalse(); // Recursion check
    }
    
    /***********
        * Method name  : updatePosition
        * Description  : Update a position record.
        * Return Type  : None.
        * Parameters   : List.
    ***********/
    public static void updatePosition(List<ZTS_EU_Territory__c> custTerrList){
        if(UtilityService.iscTerritoryRun()){ // Recursion check
            terrID = new Set<Id>();
            posUpdateList = new List<ZTS_EU_Position__c>();
            
            for(ZTS_EU_Territory__c terr : custTerrList){
                if(terr.ZTS_EU_Is_Active__c == false){
                    terrID.add(terr.id);
                }
            }           
            
            List<ZTS_EU_Position__c> activPosList = [select id,ZTS_EU_Is_Active__c,ZTS_EU_Territory__c from ZTS_EU_Position__c where ZTS_EU_Territory__c in : terrID and ZTS_EU_Is_Active__c = true];
            
            for(ZTS_EU_Position__c posUpdate : activPosList){
                ZTS_EU_Position__c pos = new ZTS_EU_Position__c(id = posUpdate.Id);
                pos.ZTS_EU_Is_Active__c = false;
                posUpdateList.add(pos);
            }
            try{
                Database.update(posUpdateList);
            }catch(Exception e){
                system.debug('Exception*******'+e);
            }
        }
        UtilityService.setpapRunFalse(); // Recursion check
    }
}