/**
 * @description       : Controls precise sharing related actions with elevated privileges (ignores sharing)
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : 
 * @last modified on  : 01-22-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   12-17-2020   Morgan Marchese @ Zoetis Inc   Initial Version
**/
public without sharing class SharingUtil {
    
    /**
    * @description creates share records
    * @author Morgan Marchese @ Zoetis Inc | 12-17-2020 
    * @param List<SObject> records 
    **/
    public static List<Database.SaveResult> create(List<SObject> records){
        List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
        if(records.isEmpty()){
            return saveResults;
        }
        List<SObject> shareRecords = new List<SObject>();
        Schema.SObjectType objType;
        String objTypeStr;
        for(SObject record : records){
            objType = record.getSObjectType();
            objTypeStr = String.valueOf(objType);
            /* 
                Make sure nobody misuses this without sharing class
                to insert non-custom object share records by filtering 
                out any records in the list that aren't Share records
            */
            if(objTypeStr.endsWithIgnoreCase('Share')){
                shareRecords.add(record);
            }
        }
        if(!shareRecords.isEmpty()){
            saveResults = Database.insert(shareRecords);
        }
        return saveResults;
    }

    /**
    * @description
    * @author Morgan Marchese @ Zoetis Inc | 01-21-2021 
    * @param Set<Id> objectIds 
    * @param Set<Id> territoryIds 
    * @return List<ObjectTerritory2Association> 
    **/
    public static List<ObjectTerritory2Association> getObjTerritoryAssociations(Set<Id> objectIds, Set<Id> territoryIds){
        List<ObjectTerritory2Association> records = [SELECT Id 
                                                    FROM ObjectTerritory2Association 
                                                    WHERE ObjectId IN: objectIds 
                                                    AND Territory2Id = : territoryIds];
        return records;
    }

    /**
    * @description 
    * @author Morgan Marchese @ Zoetis Inc | 01-21-2021 
    * @param List<ObjectTerritory2Association> records 
    * @return List<Database.DeleteResult> 
    **/
    public static List<Database.DeleteResult> deleteObjTerritoryAssociations(List<ObjectTerritory2Association> records){
        List<Database.DeleteResult> results = Database.delete(records);
        return results;
    }
}