/*************************************************************************************
* Name          :    ZTS_EU_checkZipSync.
* Description   :    Controller for update Need sync checkbox  .
* Author        :    Deloitte/Sunil
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
05/16/2014       Sunil            Created

**************************************************************************************/
public with sharing class ZTS_EU_checkZipSync {
    
    public static void newSync(List<ZTS_GL_ZipToBrick__c> zipNewList){
        for(ZTS_GL_ZipToBrick__c zip : zipNewList){
            if(zip.ZTS_EU_BrickCode__c != null){
                zip.ZTS_EU_To_Be_Synced__c = true;
                zip.ZTS_EU_Query_Ext_ID__c = zip.ZTS_EU_ZipPostalCode__c;
            }
            
        }
    
    }
    
    public static void updateSync(List<ZTS_GL_ZipToBrick__c> zipNewList , List<ZTS_GL_ZipToBrick__c> zipOldList,Map<Id,ZTS_GL_ZipToBrick__c> oldMap){
        Set<Id> newBrickSet = new Set<Id>();
        Set<Id> oldBrickSet = new Set<Id>();
        Set<Id> brickSet = new Set<Id>();
        Map<Id,String> allTerritoryMap = new Map<Id,String>();
        for(ZTS_GL_ZipToBrick__c zip : zipNewList){
            newBrickSet.add(zip.ZTS_EU_BrickCode__c);
            
        }
        for(ZTS_GL_ZipToBrick__c zip : zipOldList){
            oldBrickSet.add(zip.ZTS_EU_BrickCode__c);       
            
        }
        brickSet.addAll(newBrickSet);
        brickSet.addAll(oldBrickSet);
        
        List<ZTS_GL_BrickToTerr__c> allBrick = [select id,ZTS_EU_Territory__r.name from ZTS_GL_BrickToTerr__c where id in : brickSet];
        for(ZTS_GL_BrickToTerr__c brick : allBrick){
            allTerritoryMap.put(brick.id,brick.ZTS_EU_Territory__r.name);
        }
        
          for(ZTS_GL_ZipToBrick__c zip : zipNewList){
            if(zip.ZTS_EU_BrickCode__c != oldMap.get(zip.id).ZTS_EU_BrickCode__c  ){
                if(allTerritoryMap.get(zip.ZTS_EU_BrickCode__c) != allTerritoryMap.get(oldMap.get(zip.id).ZTS_EU_BrickCode__c)){
                    zip.ZTS_EU_To_Be_Synced__c = true;
                }
            }
            zip.ZTS_EU_Query_Ext_ID__c = zip.ZTS_EU_ZipPostalCode__c;
        }       
        
    }
}