public with sharing class ZTS_GL_ZipToBrickService {
    
    public static void beforeInsert(List<ZTS_GL_ZipToBrick__c> triggerNew){
        for(ZTS_GL_ZipToBrick__c zip : triggerNew){
            if(zip.ZTS_EU_BrickCode__c != null){
                zip.ZTS_EU_To_Be_Synced__c = true;
                zip.ZTS_EU_Query_Ext_ID__c = zip.ZTS_EU_ZipPostalCode__c;
            }
            
        }
    
    }
    
    public static void beforeUpdate(List<ZTS_GL_ZipToBrick__c> triggerNew , List<ZTS_GL_ZipToBrick__c> triggerOld,Map<Id,ZTS_GL_ZipToBrick__c> triggerOldMap){
        Set<Id> newBrickSet = new Set<Id>();
        Set<Id> oldBrickSet = new Set<Id>();
        Set<Id> brickSet = new Set<Id>();
        Map<Id,String> allTerritoryMap = new Map<Id,String>();
        for(ZTS_GL_ZipToBrick__c zip : triggerNew){
            newBrickSet.add(zip.ZTS_EU_BrickCode__c);
            
        }
        for(ZTS_GL_ZipToBrick__c zip : triggerOld){
            oldBrickSet.add(zip.ZTS_EU_BrickCode__c);       
            
        }
        brickSet.addAll(newBrickSet);
        brickSet.addAll(oldBrickSet);
        
        List<ZTS_GL_BrickToTerr__c> allBrick = [select id,ZTS_EU_Territory__r.name from ZTS_GL_BrickToTerr__c where id in : brickSet];
        for(ZTS_GL_BrickToTerr__c brick : allBrick){
            allTerritoryMap.put(brick.id,brick.ZTS_EU_Territory__r.name);
        }
        
          for(ZTS_GL_ZipToBrick__c zip : triggerNew){
            if(zip.ZTS_EU_BrickCode__c != triggerOldMap.get(zip.id).ZTS_EU_BrickCode__c  ){
                if(allTerritoryMap.get(zip.ZTS_EU_BrickCode__c) != allTerritoryMap.get(triggerOldMap.get(zip.id).ZTS_EU_BrickCode__c)){
                    zip.ZTS_EU_To_Be_Synced__c = true;
                }
            }
            zip.ZTS_EU_Query_Ext_ID__c = zip.ZTS_EU_ZipPostalCode__c;
        }       
        
    }

}